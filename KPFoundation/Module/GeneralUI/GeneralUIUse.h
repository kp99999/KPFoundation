//
//  GeneralUIUse.h
//  ZYYObjcLib
//
//  Created by zyyuann on 2017/4/19.
//  Copyright © 2017年 ZYY. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GeneralUIUse : NSObject

/**
 自适应控件高、宽度

 @param c_view 要调节的控件
 @param maxFrame 要调节的最大范围
 @param minSize 要调节的最小长宽
 */
+ (void)AutoCalculationView:(id)c_view MaxFrame:(CGRect)maxFrame;
+ (void)AutoCalculationView:(id)c_view MaxFrame:(CGRect)maxFrame MinSize:(CGSize)minSize;

/**
 创建一个UINavigationController
 
 @param vc GeneralViewController 对象
 @return 返回 UINavigationController 对象
 */
+ (id)buildNavWithViewController:(UIViewController *)vc;

/**
 获取 UIView 所在的 UIViewController

 @param view 要处理的UIView
 @return 所在的UIViewController
 */
+ (UIViewController *)SuperViewController:(UIView *)view;

/**
 获取当前窗口 UIViewController

 @return 返回 UIViewController
 */
+ (UIViewController *)GetWindowViewController;

/**
 为UIView添加 上、下两条线段

 @param l_view 控件
 @param l_color 线段颜色
 */
+ (void)AddLineUpDown:(UIView *)l_view Color:(UIColor *)l_color;

/**
 部署上线段

 @param l_view 控件
 @param l_color 线段颜色
 @param ori_l 左偏移
 @param oti_r 右偏移
 */
+ (void)AddLineUp:(UIView *)l_view Color:(UIColor *)l_color LeftOri:(CGFloat)ori_l RightOri:(CGFloat)oti_r;

/**
 部署下线段

 @param l_view 控件
 @param l_color 线段颜色
 @param ori_l 左偏移
 @param oti_r 右偏移
 */
+ (void)AddLineDown:(UIView *)l_view Color:(UIColor *)l_color LeftOri:(CGFloat)ori_l RightOri:(CGFloat)oti_r;

/**
 部署左线段
 
 @param l_view 控件
 @param l_color 线段颜色
 @param ori_up 左偏移
 @param ori_down 右偏移
 */
+ (void)AddLineLeft:(UIView *)l_view Color:(UIColor *)l_color UpOri:(CGFloat)ori_up DownOri:(CGFloat)ori_down;

/**
 部署右线段
 
 @param l_view 控件
 @param l_color 线段颜色
 @param ori_up 左偏移
 @param ori_down 右偏移
 */
+ (void)AddLineRight:(UIView *)l_view Color:(UIColor *)l_color UpOri:(CGFloat)ori_up DownOri:(CGFloat)ori_down;

+ (void)CleanAllLine:(UIView *)l_view;

@end

#import "GeneralUIUse+Image.h"
