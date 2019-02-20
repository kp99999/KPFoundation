//
//  GeneralUIUse.m
//  ZYYObjcLib
//
//  Created by zyyuann on 2017/4/19.
//  Copyright © 2017年 ZYY. All rights reserved.
//

#import <KPFoundation/GeneralUIUse.h>

#define UpLineTag           78763
#define DownLineTag           78762

#define LeftLineTag           78764
#define RightLineTag           78765

@implementation GeneralUIUse

#pragma mark - 自适应控件高、宽度

+ (void)AutoCalculationView:(id)c_view MaxFrame:(CGRect)maxFrame {
    [GeneralUIUse AutoCalculationView:c_view MaxFrame:maxFrame MinSize:CGSizeMake(0, 0)];
}

+ (void)AutoCalculationView:(id)c_view MaxFrame:(CGRect)maxFrame MinSize:(CGSize)minSize{
    CGRect now_frame;
    if ([c_view isKindOfClass:[UILabel class]]) {
        UILabel *c_lab = c_view;
        now_frame = [c_lab.text boundingRectWithSize:CGSizeMake(maxFrame.size.width, maxFrame.size.height)//限制最大的宽度和高度
                                             options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading//采用换行模式
                                          attributes:@{NSFontAttributeName:c_lab.font}//传人的字体字典
                                             context:nil];
        
        now_frame.origin.x = maxFrame.origin.x;
        now_frame.origin.y = maxFrame.origin.y;
        
        if (minSize.height > 0 && minSize.height > now_frame.size.height) {
            now_frame.size.height = minSize.height;
        }
        if (minSize.width > 0 && minSize.width > now_frame.size.width) {
            now_frame.size.width = minSize.width;
        }
        
        [(UIView *)c_view setFrame:now_frame];
    }else if ([c_view isKindOfClass:[UIButton class]]){
        UIButton *c_btn = c_view;
        now_frame = [c_btn.titleLabel.text boundingRectWithSize:CGSizeMake(maxFrame.size.width, maxFrame.size.height)//限制最大的宽度和高度
                                                        options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading//采用换行模式
                                                     attributes:@{NSFontAttributeName:c_btn.titleLabel.font}//传人的字体字典
                                                        context:nil];
        
        now_frame.origin.x = maxFrame.origin.x;
        now_frame.origin.y = maxFrame.origin.y;
        
        if (minSize.height > 0 && minSize.height > now_frame.size.height) {
            now_frame.size.height = minSize.height;
        }
        if (minSize.width > 0 && minSize.width > now_frame.size.width) {
            now_frame.size.width = minSize.width;
        }
        
        [(UIView *)c_view setFrame:now_frame];
    }
}

#pragma mark - 创建、获取一个Controller
+ (id)buildNavWithViewController:(UIViewController *)vc{
    if (vc) {
        UINavigationController *navigate = [[UINavigationController alloc] initWithRootViewController:vc];
        navigate.navigationBar.translucent = NO;
        
        if([[[UIDevice currentDevice] systemVersion] doubleValue] >= 7.0) {
            vc.automaticallyAdjustsScrollViewInsets = YES;
            vc.edgesForExtendedLayout = UIRectEdgeNone;
            vc.extendedLayoutIncludesOpaqueBars = NO;
            vc.modalPresentationCapturesStatusBarAppearance = NO;
        }
        
        return navigate;
    }
    
    return nil;
}

+ (UIViewController *)SuperViewController:(UIView *)view {
    
    if (!view) {
        return nil;
    }
    //获取下个响应者
    UIResponder *next = [view nextResponder];
    do {
        //如果响应者为视图控制器，将视图控制器返回
        if ([next isKindOfClass:[UIViewController class]]) {
            return (UIViewController *) next;
        }
        
        next = [next nextResponder];
        
    } while (next != nil);
    
    return nil;
}

+ (UIViewController *)GetWindowViewController{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    id nextResponder = nil;
    NSArray *frontArr = [window subviews];
    for (NSInteger i = 0; frontArr && i < [frontArr count]; i++) {
        UIView *frontView = frontArr[[frontArr count] - i - 1];
        nextResponder = [frontView nextResponder];
        
        while(nextResponder && ![nextResponder isKindOfClass:[UIViewController class]])//这里跳不出来。。。有人说这里跳不出来，其实是因为它没有当前这个view放入ViewController中，自然也就跳不出来了，会死循环，使用时需要注意。
        {
            nextResponder = [nextResponder nextResponder];
        }
        
        if ([nextResponder isKindOfClass:[UIViewController class]]){
            result = nextResponder;
            break;
        }
    }
    
    if (!result)
        result = window.rootViewController;
    
    return result;
}

#pragma mark - 控件布线
+ (void)AddLineUpDown:(UIView *)l_view Color:(UIColor *)l_color{
    if (!l_view || !l_color)
        return;
    
    id up_line = nil;
    for (UIView *view_ in [l_view subviews]) {
        if (view_.tag == UpLineTag) {
            up_line = view_;
            break;
        }
    }
    if (up_line && [up_line isKindOfClass:[UIView class]]) {
        [up_line setBackgroundColor:l_color];
    } else {
        up_line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, l_view.frame.size.width, 1.0 / [UIScreen mainScreen].scale)];
        [up_line setTag:UpLineTag];
        [up_line setBackgroundColor:l_color];
        [l_view addSubview:up_line];
    }
    
    id down_line = nil;
    for (UIView *view_ in [down_line subviews]) {
        if (view_.tag == DownLineTag) {
            down_line = view_;
            break;
        }
    }
    if (down_line && [down_line isKindOfClass:[UIView class]]) {
        [down_line setBackgroundColor:l_color];
    } else {
        down_line = [[UIView alloc]initWithFrame:CGRectMake(0, l_view.frame.size.height - 1.0 / [UIScreen mainScreen].scale, l_view.frame.size.width, 1.0 / [UIScreen mainScreen].scale)];
        [down_line setTag:DownLineTag];
        [down_line setBackgroundColor:l_color];
        [l_view addSubview:down_line];
    }
}

+ (void)AddLineUp:(UIView *)l_view Color:(UIColor *)l_color LeftOri:(CGFloat)ori_l RightOri:(CGFloat)oti_r{
    if (!l_view || !l_color)
        return;
    
    id down_line = nil;
    for (UIView *view_ in [l_view subviews]) {
        if (view_.tag == DownLineTag) {
            down_line = view_;
            break;
        }
    }
    if (down_line) {
        [down_line removeFromSuperview];
        down_line = nil;
    }
    
    id up_line = nil;
    for (UIView *view_ in [l_view subviews]) {
        if (view_.tag == UpLineTag) {
            up_line = view_;
            break;
        }
    }
    if (up_line && [up_line isKindOfClass:[UIView class]]) {
        [up_line setBackgroundColor:l_color];
        return;
    }
    
    up_line = [[UIView alloc]initWithFrame:CGRectMake(ori_l, 0, l_view.frame.size.width - ori_l - oti_r, 1.0 / [UIScreen mainScreen].scale)];
    [up_line setTag:UpLineTag];
    [up_line setBackgroundColor:l_color];
    [l_view addSubview:up_line];
}

+ (void)AddLineDown:(UIView *)l_view Color:(UIColor *)l_color LeftOri:(CGFloat)ori_l RightOri:(CGFloat)oti_r{
    if (!l_view || !l_color)
        return;
    
    id up_line = nil;
    for (UIView *view_ in [l_view subviews]) {
        if (view_.tag == UpLineTag) {
            up_line = view_;
            break;
        }
    }
    if (up_line) {
        [up_line removeFromSuperview];
        up_line = nil;
    }
    
    id down_line = nil;
    for (UIView *view_ in [l_view subviews]) {
        if (view_.tag == DownLineTag) {
            down_line = view_;
            break;
        }
    }
    if (down_line && [down_line isKindOfClass:[UIView class]]) {
        [down_line setBackgroundColor:l_color];
        return;
    }
    
    down_line = [[UIView alloc]initWithFrame:CGRectMake(ori_l, l_view.frame.size.height - 1.0 / [UIScreen mainScreen].scale, l_view.frame.size.width - ori_l - oti_r, 1.0 / [UIScreen mainScreen].scale)];
    [down_line setTag:DownLineTag];
    [down_line setBackgroundColor:l_color];
    
    [l_view addSubview:down_line];
}

+ (void)AddLineLeft:(UIView *)l_view Color:(UIColor *)l_color UpOri:(CGFloat)ori_up DownOri:(CGFloat)ori_down{
    if (!l_view || !l_color)
        return;
    
    id left_line = [l_view viewWithTag:LeftLineTag];
    if (left_line && [left_line isKindOfClass:[UIView class]]) {
        [left_line setBackgroundColor:l_color];
        return;
    }
    
    left_line = [[UIView alloc]initWithFrame:CGRectMake(0, ori_up, 1.0 / [UIScreen mainScreen].scale, l_view.frame.size.height - ori_up - ori_down)];
    [left_line setBackgroundColor:l_color];
    [left_line setTag:LeftLineTag];
    [l_view addSubview:left_line];
}

+ (void)AddLineRight:(UIView *)l_view Color:(UIColor *)l_color UpOri:(CGFloat)ori_up DownOri:(CGFloat)ori_down{
    if (!l_view || !l_color)
        return;
    
    id left_line = [l_view viewWithTag:RightLineTag];
    if (left_line && [left_line isKindOfClass:[UIView class]]) {
        [left_line setBackgroundColor:l_color];
        return;
    }
    
    left_line = [[UIView alloc]initWithFrame:CGRectMake(l_view.frame.size.width - 1.0 / [UIScreen mainScreen].scale, ori_up, 1.0 / [UIScreen mainScreen].scale, l_view.frame.size.height - ori_up - ori_down)];
    [left_line setTag:RightLineTag];
    [left_line setBackgroundColor:l_color];
    
    [l_view addSubview:left_line];
}

+ (void)CleanAllLine:(UIView *)l_view{
    if (!l_view)
        return;
    
    id left_line = [l_view viewWithTag:LeftLineTag];
    if (left_line && [left_line isKindOfClass:[UIView class]]) {
        [left_line removeFromSuperview];
    }
    
    id right_line = [l_view viewWithTag:RightLineTag];
    if (right_line && [right_line isKindOfClass:[UIView class]]) {
        [right_line removeFromSuperview];
    }
    
    id up_line = [l_view viewWithTag:UpLineTag];
    if (up_line && [up_line isKindOfClass:[UIView class]]) {
        [up_line removeFromSuperview];
    }
    
    id down_line = [l_view viewWithTag:DownLineTag];
    if (down_line && [down_line isKindOfClass:[UIView class]]) {
        [down_line removeFromSuperview];
    }
}

@end
