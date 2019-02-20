//
//  CatchBugRecord.m
//  testCCBMonitor
//
//  Created by zyy_pro on 14-10-20.
//  Copyright (c) 2014年 zyy_pro. All rights reserved.
//

#import "CatchBugRecord.h"

#include <libkern/OSAtomic.h>
#include <execinfo.h>

#define SelfAuthority         @"CCBMonitor_bug_323dff"

NSString * const UncaughtExceptionHandlerSignalExceptionName = @"UncaughtExceptionHandlerSignalExceptionName";
NSString * const UncaughtExceptionHandlerSignalKey = @"BugSignalKey";
NSString * const UncaughtExceptionHandlerAddressesKey = @"BugStack";
//YDJR0003

volatile int32_t UncaughtExceptionCount = 0;
const int32_t UncaughtExceptionMaximum = 10;

const NSInteger UncaughtExceptionHandlerSkipAddressCount = 4;       // 去重复

BOOL HaveAuthority(id theAuth);
NSString* BackTrace(void);

void InstallCatchTypeExceptionHandler(void);
void CloseCatchTypeExceptionHandler(void);

@interface CatchBugRecord() {
    
    NSString *bugFile;          // bug文件路径
    
    __weak id<CatchBugRecordDelegate> bugDelegate;
}

@end

@implementation CatchBugRecord

+ (CatchBugRecord *)Bug{
    static dispatch_once_t once;
    static CatchBugRecord * singleton;
    dispatch_once(&once, ^{ singleton = [[CatchBugRecord alloc] init]; });
    return singleton;
}

- (id)init{
    self = [super init];
    if (self) {
        bugDelegate = nil;
    }
    return self;
}

#pragma mark - 外部调用

// 开启
- (void)openToBugDelegate:(id<CatchBugRecordDelegate>)delegate Authority:(NSString *)authStr{
    if (!HaveAuthority(authStr))
        return ;
    
    bugDelegate = delegate;
    
    InstallCatchTypeExceptionHandler();
}

#pragma mark -

//- (void)alertView:(UIAlertView *)anAlertView clickedButtonAtIndex:(NSInteger)anIndex
//{
//    if (anIndex == 0)
//    {
//        dismissed = YES;
//    }
//}
//[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"抱歉，程序出现了异常", nil)
//                            message:[NSString stringWithFormat:NSLocalizedString(@"如果点击继续，程序有可能会出现其他的问题，建议您还是点击退出按钮并重新打开\n\n"   @"异常原因如下:\n%@\n%@", nil),[exception reason],[[exception userInfo] objectForKey:UncaughtExceptionHandlerAddressesKey]]
//                           delegate:self
//                  cancelButtonTitle:NSLocalizedString(@"退出", nil)
//                  otherButtonTitles:NSLocalizedString(@"继续", nil), nil] show];


- (void)handleException:(NSException *)exception
{
    NSString *otherErr = nil;
    NSDictionary *errInfo = [exception userInfo];
    if (errInfo)
        otherErr = [errInfo objectForKey:UncaughtExceptionHandlerAddressesKey];
    if (bugDelegate && [bugDelegate respondsToSelector:@selector(backBugErrorNo:ErrorDesc:OtherError:)])
        [bugDelegate backBugErrorNo:[exception name] ErrorDesc:[exception reason] OtherError:otherErr];
        
    
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFArrayRef allModes = CFRunLoopCopyAllModes(runLoop);
    
    while (YES)// 出错，永远不退出
    {
        for (NSString *mode in (__bridge NSArray *)allModes)
        {
            CFRunLoopRunInMode((__bridge CFStringRef)mode, 0.001, false);
        }
    }
    
    CFRelease(allModes);
    
    CloseCatchTypeExceptionHandler();
    
    if ([[exception name] isEqual:UncaughtExceptionHandlerSignalExceptionName])
    {
        kill(getpid(), [[[exception userInfo] objectForKey:UncaughtExceptionHandlerSignalKey] intValue]);
    }
    else
    {
        [exception raise];
    }
}

@end

BOOL HaveAuthority(id theAuth){
    if ([theAuth isEqualToString:SelfAuthority])
        return YES;
    
    return NO;
}

NSString* BackTrace(void){
    void* callstack[128];
    int frames = backtrace(callstack, 128);
    char **strs = backtrace_symbols(callstack, frames);
    
    int i;
    NSString *backStr = @"";
    for (i = UncaughtExceptionHandlerSkipAddressCount; i < frames; i++)
        backStr = [backStr stringByAppendingFormat:@"%@  |#|  ",[NSString stringWithUTF8String:strs[i]]];
        
    free(strs);
    
    return backStr;
}



void HandleException(NSException *exception)
{
    int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
    if (exceptionCount > UncaughtExceptionMaximum)
    {
        return;
    }
    
    NSDictionary *userInfo = nil;
    NSString *callStack = BackTrace();
    if (callStack)
        userInfo = @{UncaughtExceptionHandlerAddressesKey:callStack};
    
    [[CatchBugRecord Bug] performSelectorOnMainThread:@selector(handleException:)
                                           withObject:[NSException exceptionWithName:[exception name]
                                                                              reason:[exception reason]
                                                                            userInfo:userInfo]
                                        waitUntilDone:YES];
}

void SignalHandler(int signal)
{
    int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
    if (exceptionCount > UncaughtExceptionMaximum)
        return;
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"%ld",(long)signal] forKey:UncaughtExceptionHandlerSignalKey];
    NSString *callStack = BackTrace();
    if (callStack)
        [userInfo setObject:callStack forKey:UncaughtExceptionHandlerAddressesKey];
    
    [[CatchBugRecord Bug] performSelectorOnMainThread:@selector(handleException:)
                                           withObject:[NSException exceptionWithName:UncaughtExceptionHandlerSignalExceptionName
                                                                              reason:[NSString stringWithFormat:NSLocalizedString(@"Signal %d was raised.", nil),signal]
                                                                            userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:signal]
                                                                                                                 forKey:UncaughtExceptionHandlerSignalKey]]
                                        waitUntilDone:YES];
    
    CloseCatchTypeExceptionHandler();
}

void CloseCatchTypeExceptionHandler(void){
    NSSetUncaughtExceptionHandler(NULL);
    signal(SIGABRT, SIG_DFL);
    signal(SIGILL, SIG_DFL);
    signal(SIGSEGV, SIG_DFL);
    signal(SIGFPE, SIG_DFL);
    signal(SIGBUS, SIG_DFL);
    signal(SIGPIPE, SIG_DFL);
}

void InstallCatchTypeExceptionHandler(void){

    NSSetUncaughtExceptionHandler(&HandleException);
    signal(SIGABRT, SignalHandler);
    signal(SIGILL, SignalHandler);
    signal(SIGSEGV, SignalHandler);
    signal(SIGFPE, SignalHandler);
    signal(SIGBUS, SignalHandler);
    signal(SIGPIPE, SignalHandler);
}

