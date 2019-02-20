//
//  ZYPublicDefine.h
//  ZYYObjcLib
//
//  Created by zyyuann on 15/12/30.
//  Copyright © 2015年 ZYY. All rights reserved.
//

#ifndef PublicDefine_h
#define PublicDefine_h

// 外部可根据工程相应作修改

#define NetWorkBundleName      @""
#define NetWorkOpenLocal      0

#define DEBUG       1

#ifdef DEBUG
    #ifndef NSLog
        #define NSLog(fmt, ...) NSLog((@"%s [Line %d]\n" fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
    #endif

    #ifndef NSLogDetail
        #define NSLogDetail(FORMAT, ...) fprintf(__stderrp,"%s %s:%d\t%s\t%s\n",__TIME__,[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, __FUNCTION__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
    #endif
#else
    #ifndef NSLog
        #define NSLog(...)
    #endif

    #ifndef NSLogDetail
        #define NSLogDetail(...)
    #endif
#endif


#define WeakSelf __weak typeof(self) weakSelf = self;

#define OSWeak(o) autoreleasepool{} __weak typeof(o) o##Weak = o;
#define OSStrong(o) autoreleasepool{} __strong typeof(o) o = o##Weak;


/////////////////   UI

#define RGB(r,g,b) [UIColor colorWithRed:r/255. green:g/255. blue:b/255. alpha:1]
#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255. green:g/255. blue:b/255. alpha:a]

#define kUIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define kUIColorFromRGBAlpha(rgbValue,al) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:al]

#endif /* PublicDefine_h */
