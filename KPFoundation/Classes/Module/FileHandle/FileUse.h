//
//  FileUse.h
//  ZYYObjcLib
//
//  Created by zyyuann on 2017/4/20.
//  Copyright © 2017年 ZYY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileUse : NSObject

+ (FileUse *)Share;

@end


#import "FileUse+Manager.h"
#import "FileUse+FMDB.h"
#import "FileUse+Other.h"
