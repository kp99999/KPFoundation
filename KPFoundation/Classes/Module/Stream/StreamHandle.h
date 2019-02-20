//
//  StreamHandle.h
//  zyy
//
//  Created by zyyuann on 16/3/31.
//  Copyright © 2016年 ZYY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StreamHandle : NSObject

+ (StreamHandle *)Share;

/**
 以流模式写文件

 @param folderName 文件夹
 @param fileName 文件名
 @return 生成的对象
 */
- (void)initOutStreamToFolderName:(NSString *)folderName FileName:(NSString *)fileName;


/**
 追加数据

 @param data 要追加数据
 @param fileName 文件名
 @return 返回是否写成功
 */
- (BOOL)writeToStream:(NSData *)data FileName:(NSString *)fileName;

/**
 写结束
 
 @param fileName 文件名
 */
- (void)writeToEndWithFileName:(NSString *)fileName;

@end
