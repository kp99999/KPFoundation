//
//  TouchID.h
//  Pods
//
//  指纹锁
//
//

#import <Foundation/Foundation.h>
#import <LocalAuthentication/LocalAuthentication.h>

/**
 *  指纹验证结果枚举
 */
typedef NS_ENUM(NSInteger, TouchIDResult) {
    /**
     *  成功
     */
    TouchIDResultSuccess = 0,
    /**
     *  通用错误
     */
    TouchIDResultError,
    /**
     *  认证失败
     */
    TouchIDResultAuthenticationFailed,
    /**
     *  用户取消认证
     */
    TouchIDResultUserCancel,
    /**
     *  用户回退
     */
    TouchIDResultUserFallback,
    /**
     *  系统取消认证
     */
    TouchIDResultSystemCancel,
    /**
     *  密码没设置
     */
    TouchIDResultPasscodeNotSet,
    /**
     *  功能不可用
     */
    TouchIDResultNotAvailable,
    /**
     *  没设置指纹密码
     */
    TouchIDResultNotEnrolled
} NS_ENUM_AVAILABLE_IOS(8_0);

/**
 TouchID本地认证相关功能
 */
@interface TouchID : NSObject

/**
 显示指纹密码验证提醒窗体

 @param reason 显示在窗体上的提醒文本
 @param completion 结果回调Block
 */
+ (void)showTouchIDAuthenticationWithReason:(NSString * _Nonnull)reason
                                 completion:(void (^ _Nullable)(TouchIDResult result))completion;

/**
 显示指纹密码验证提醒窗体
 
 @param reason 显示在窗体上的提醒文本
 @param fallbackTitle 默认显示“Enter Password”按钮，如果传空字符串会隐藏按钮
 @param completion 结果回调Block
 */
+ (void)showTouchIDAuthenticationWithReason:(NSString * _Nonnull)reason
                              fallbackTitle:(NSString * _Nullable)fallbackTitle
                                 completion:(void (^ _Nullable)(TouchIDResult result))completion;
@end
