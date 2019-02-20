//
//  GeneralUIUse+Image.h
//  ZYYObjcLib
//
//  Created by zyyuann on 2017/4/19.
//  Copyright © 2017年 ZYY. All rights reserved.
//

#import <KPFoundation/GeneralUIUse.h>

#define GUUImageLocal(key) \
[GeneralUIUse GetImageLocal:key BundleResource:@"KPPLibBundle"]

@interface GeneralUIUse (Image)

/**
 获取本地资源 图片
 
 @param imageName 图片名
 @param bunleName 从属Bundle
 @return 返回UIImage
 */
+ (UIImage *)GetImageLocal:(NSString *)imageName BundleResource:(NSString *)bunleName;

/**
 UIView 转化image

 @param view 要转换UIView
 @return 返回 UIImage
 */
+ (UIImage *)GetImageFromView:(UIView *)view;

/**
 合并图片

 @param imgArr 非空UIImage数组（最多4个图片，其他不处理，类似QQ讨论组头像）
 @param size 排版大小
 @return 返回UIImage
 */
+ (UIImage *)MergeImageArray:(NSArray *)imgArr ImageSize:(CGSize)size;

/**
 图片圆角化

 @param image 图片源
 @param size 大小
 @return 返回 UIImage
 */
+ (UIImage *)CreateRoundedRectImage:(UIImage *)image size:(CGSize)size;

/**
 *  图片缩放到指定大小尺寸
 *
 *  @param img  要压缩图片
 *  @param size 指定长宽
 *
 *  @return 压缩后图片
 */
+ (UIImage *)ScaleToSize:(UIImage *)img Size:(CGSize)size;

/**
 用颜色生成一个图片

 @param color 颜色
 @return 返回 UIImage
 */
+ (UIImage*)ChangeUIColorToUIImage:(UIColor*)color;

+ (CGContextRef)BitmapRGBA8ContextFromImage:(CGImageRef) image;


/** 返回一张三角形图片 */
+ (UIImage *)getSanJiaoImage;

+ (UIImage *)getSanJiaoImageWithCorner:(CGFloat)corner;

// 图片灰度化，type 1、2 区分不同阀值，type 3取反
+ (UIImage*)Grayscale:(UIImage*)anImage type:(int)type;

@end
