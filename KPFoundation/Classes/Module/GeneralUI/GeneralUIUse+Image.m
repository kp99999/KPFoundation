//
//  GeneralUIUse+Image.m
//  ZYYObjcLib
//
//  Created by zyyuann on 2017/4/19.
//  Copyright © 2017年 ZYY. All rights reserved.
//

#import <KPFoundation/GeneralUIUse+Image.h>

#import <KPFoundation/KPPublicDefine.h>

@implementation GeneralUIUse (Image)

#pragma mark - 获取本地 图片
+ (UIImage *)GetImageLocal:(NSString *)imageName BundleResource:(NSString *)bunleName{
    if (!(imageName && [imageName length])) {
        return nil;
    }
    NSBundle *bkBundle = [NSBundle mainBundle];
    if (bunleName) {
        bkBundle = [NSBundle bundleWithPath:[bkBundle pathForResource:bunleName ofType:@"bundle"]];
    }
    
    return [UIImage imageNamed:imageName inBundle:bkBundle compatibleWithTraitCollection:nil];
}

// UIView 转化image
+ (UIImage *)GetImageFromView:(UIView *)view{
    if (!view) {
        return nil;
    }
    //创建一个画布
    //UIGraphicsBeginImageContext(view.frame.size);
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, [UIScreen mainScreen].scale);
    //把view中的内容渲染到画布中
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    //把画布中的图片取出来
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    //结束渲染
    UIGraphicsEndImageContext();
    return image;
}


// 合并图片数组
+ (UIImage *)MergeImageArray:(NSArray *)imgArr ImageSize:(CGSize)size{
    if (!imgArr) {
        return nil;
    }
    
    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    [bgView setBackgroundColor:[UIColor clearColor]];
    switch ([imgArr count]) {
        case 1:
            return imgArr[0];
            
        case 2:
        {
            for (NSInteger i = 0; i < [imgArr count]; i++) {
                UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(i * (size.width/2 - 4), i * (size.height/2 - 4), size.width/2 + 4, size.height/2 + 4)];
                [imgView setImage:imgArr[i]];
                [imgView setClipsToBounds:YES];
                [imgView.layer setCornerRadius:imgView.frame.size.width/2];
                [bgView addSubview:imgView];
            }
        }
            return [self GetImageFromView:bgView];
            
        case 3:
        {
            CGRect frame = CGRectMake(0, 0, size.width/2, size.height/2);
            for (NSInteger i = 0; i < [imgArr count]; i++) {
                UIImageView *imgView = [[UIImageView alloc]init];
                if (i == 0) {
                    frame.origin.x = (size.width - frame.size.width) / 2;
                    frame.origin.y = 2;
                }else if (i == 1){
                    frame.origin.x = 0;
                    frame.origin.y = frame.size.height - 2;
                }else if (i == 2){
                    frame.origin.x = frame.size.width;
                    frame.origin.y = frame.size.height - 2;
                }
                [imgView setFrame:frame];
                [imgView setImage:imgArr[i]];
                [imgView setClipsToBounds:YES];
                [imgView.layer setCornerRadius:imgView.frame.size.width/2];
                [bgView addSubview:imgView];
            }
        }
            return [self GetImageFromView:bgView];
            
        case 4:
        {
            for (NSInteger i = 0; i < [imgArr count]; i++) {
                UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake((i%2) * size.width/2, (i/2) * size.height/2, size.width/2, size.height/2)];
                [imgView setImage:imgArr[i]];
                [imgView setClipsToBounds:YES];
                [imgView.layer setCornerRadius:imgView.frame.size.width/2];
                [bgView addSubview:imgView];
            }
        }
            return [self GetImageFromView:bgView];
            
        default:
            return nil;
    }
}

+ (UIImage *)CreateRoundedRectImage:(UIImage *)image size:(CGSize)size
{
    // 防止圆角半径小于0，或者大于宽/高中较小值的一半。
    if (!(image && size.width == size.height && size.width > 0)) {
        return nil;
    }
    
    CGFloat minImageR = (image.size.width > image.size.height) ? image.size.height : image.size.width;
    minImageR = (minImageR > size.width) ? size.width : minImageR;
    
    CGFloat scale = 1.0;
    CGFloat cornerRadius = minImageR / 2;
    
    CGRect imageFrame = CGRectMake(0., 0., minImageR, minImageR);
    UIGraphicsBeginImageContextWithOptions(imageFrame.size, NO, scale);
    [[UIBezierPath bezierPathWithRoundedRect:imageFrame cornerRadius:cornerRadius] addClip];
    [image drawInRect:imageFrame];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)ScaleToSize:(UIImage *)img Size:(CGSize)size{
    
    if (!img) {
        return nil;
    }
    if (!(size.width > 1 && size.height > 1)) {
        return nil;
    }
    
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return scaledImage;
}

+ (UIImage*)ChangeUIColorToUIImage:(UIColor*)color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

/** 返回一个黑色三角形图片 */
+ (UIImage *)getSanJiaoImage{
    
    CGFloat W = 500.0;
    CGFloat H = 500.0;
    CGFloat headH = 50.0;
    CGFloat raidiu = 40.0;
    CGRect r = CGRectMake(0.0, 0.0, W, H);
    UIGraphicsBeginImageContext(r.size);
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, headH + raidiu)];
    [path addQuadCurveToPoint:CGPointMake(raidiu, headH) controlPoint:CGPointMake(0, headH)];
    [path addLineToPoint:CGPointMake((W - headH) * 0.5, headH)];
    [path addLineToPoint:CGPointMake(W * 0.5, 0)];
    [path addLineToPoint:CGPointMake((W + headH) * 0.5, headH)];
    [path addLineToPoint:CGPointMake(W - raidiu, headH)];
    [path addQuadCurveToPoint:CGPointMake(W, headH + raidiu) controlPoint:CGPointMake(W, headH)];
    [path addLineToPoint:CGPointMake(W, H - raidiu)];
    [path addQuadCurveToPoint:CGPointMake(W - raidiu, H) controlPoint:CGPointMake(W, H)];
    [path addLineToPoint:CGPointMake(raidiu, H)];
    [path addQuadCurveToPoint:CGPointMake(0, H - raidiu) controlPoint:CGPointMake(0, H)];
    [path addLineToPoint:CGPointMake(0, headH)];
    
    [path addClip];
    [[UIColor colorWithHue:10.0 / 255.0 saturation:10.0 / 255.0 brightness:10.0 / 255.0 alpha:0.82] set];
    [path fill];
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

/** 返回一个黑色三角形图片
    corner 尖角在视图上的位置
 */
+ (UIImage *)getSanJiaoImageWithCorner:(CGFloat)corner{
    
    CGFloat W = 500.0;
    CGFloat H = 500.0;
    CGFloat headH = 30.0;
    CGFloat raidiu = 40.0;
    CGRect r = CGRectMake(0.0, 0.0, W, H);
    UIGraphicsBeginImageContext(r.size);
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, headH + raidiu)];
    [path addQuadCurveToPoint:CGPointMake(raidiu, headH) controlPoint:CGPointMake(0, headH)];
    [path addLineToPoint:CGPointMake((W - headH) * corner, headH)];
    [path addLineToPoint:CGPointMake(W * corner, 0)];
    [path addLineToPoint:CGPointMake((W + headH) * corner, headH)];
    [path addLineToPoint:CGPointMake(W - raidiu, headH)];
    [path addQuadCurveToPoint:CGPointMake(W, headH + raidiu) controlPoint:CGPointMake(W, headH)];
    [path addLineToPoint:CGPointMake(W, H - raidiu)];
    [path addQuadCurveToPoint:CGPointMake(W - raidiu, H) controlPoint:CGPointMake(W, H)];
    [path addLineToPoint:CGPointMake(raidiu, H)];
    [path addQuadCurveToPoint:CGPointMake(0, H - raidiu) controlPoint:CGPointMake(0, H)];
    [path addLineToPoint:CGPointMake(0, headH)];
    
    [path addClip];
    //    [[UIColor colorWithHue:10.0 / 255.0 saturation:10.0 / 255.0 brightness:10.0 / 255.0 alpha:0.82] set];
    [[UIColor blackColor] set];
    [path fill];
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

+ (CGContextRef)BitmapRGBA8ContextFromImage:(CGImageRef) image {
    CGContextRef context = NULL;
    CGColorSpaceRef colorSpace;
    uint32_t *bitmapData;
    
    size_t bitsPerPixel = 32;
    size_t bitsPerComponent = 8;
    size_t bytesPerPixel = bitsPerPixel / bitsPerComponent;
    
    size_t width = CGImageGetWidth(image);
    size_t height = CGImageGetHeight(image);
    
    size_t bytesPerRow = width * bytesPerPixel;
    size_t bufferLength = bytesPerRow * height;
    
    colorSpace = CGColorSpaceCreateDeviceRGB();
    
    if(!colorSpace) {
        NSLog(@"Error allocating color space RGB\n");
        return NULL;
    }
    
    // Allocate memory for image data
    bitmapData = (uint32_t *)malloc(bufferLength);
    
    if(!bitmapData) {
        NSLog(@"Error allocating memory for bitmap\n");
        CGColorSpaceRelease(colorSpace);
        return NULL;
    }
    
    //Create bitmap context
    
    context = CGBitmapContextCreate(bitmapData,
                                    width,
                                    height,
                                    bitsPerComponent,
                                    bytesPerRow,
                                    colorSpace,
                                    kCGImageAlphaPremultipliedFirst);    // RGBA
    if(!context) {
        free(bitmapData);
        NSLog(@"Bitmap context not created");
    }
    
    CGColorSpaceRelease(colorSpace);
    
    return context;
}

+ (UIImage*)Grayscale:(UIImage*)source type:(int)type {
    
    CGSize size = [source size];
    int width = size.width;
    int height = size.height;
    // the pixels will be painted to this array
    uint32_t*pixels = (uint32_t*)malloc(width * height *sizeof(uint32_t));
    // clear the pixels so any transparency is preserved
    memset(pixels,0, width * height *sizeof(uint32_t));
    //颜色空间DeviceRGB
    CGColorSpaceRef colorSpace =CGColorSpaceCreateDeviceRGB();
    // create a context with RGBA pixels
    CGContextRef context = CGBitmapContextCreate(pixels, width, height,8, width *sizeof(uint32_t), colorSpace,kCGBitmapByteOrder32Little|kCGImageAlphaPremultipliedLast);
    // paint the bitmap to our context which will fill in the pixels array
    CGContextDrawImage(context,CGRectMake(0,0, width, height), source.CGImage);
    for(int y =0; y < height; y++) {
        for(int x =0; x < width; x++) {
            uint8_t*rgbaPixel = (uint8_t*) &pixels[y * width + x];
            
            uint32_t gray = MIN(rgbaPixel[1], MIN(rgbaPixel[3], rgbaPixel[2])) ;
            // set the pixels to gray
            rgbaPixel[1] = gray;
            rgbaPixel[2] = gray;
            rgbaPixel[3] = gray;
        }
    }
    // create a new CGImageRef from our context with the modified pixels
    CGImageRef image = CGBitmapContextCreateImage(context);
    // we're done with the context, color space, and pixels
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(pixels);
    // make a new UIImage to return
    UIImage *resultUIImage = [UIImage imageWithCGImage:image];
    // we're done with image now too
    CGImageRelease(image);
    
    return resultUIImage;
    
}

// 字符图片背景
+ (UIColor*)GetColorWithFirstChar:(NSString *)firstChar {
    
    int asciiCode = [firstChar.uppercaseString characterAtIndex:0];
    
    UIColor *charColor = nil;
    switch (asciiCode) {
        case 65:
            charColor = RGBA(0xee, 0xb7, 0x1f, 1);
            break;
        case 66:
            charColor = RGBA(0x6e, 0xb0, 0xfd, 1);
            break;
        case 67:
            charColor = RGBA(0x6d, 0xcc, 0x60, 1);
            break;
        case 68:
            charColor = RGBA(0xc5, 0x7f, 0xd0, 1);
            break;
        case 69:
            charColor = RGBA(0xfa, 0x7f, 0x7f, 1);
            break;
        case 70:
            charColor = RGBA(0xab, 0x8a, 0xe8, 1);
            break;
        case 71:
            charColor = RGBA(0xdc, 0x94, 0x7b, 1);
            break;
        case 72:
            charColor = RGBA(0x9a, 0x97, 0x97, 1);
            break;
        case 73:
            charColor = RGBA(0xc7, 0xce, 0x59, 1);
            break;
        case 74:
            charColor = RGBA(0xfa, 0x9a, 0x4c, 1);
            break;
        case 75:
            charColor = RGBA(0x79, 0x89, 0xe4, 1);
            break;
        case 76:
            charColor = RGBA(0x1d, 0xb4, 0xfc, 1);
            break;
        case 77:
            charColor = RGBA(0xf4, 0x76, 0x9d, 1);
            break;
        case 78:
            charColor = RGBA(0x26, 0xd9, 0xc8, 1);
            break;
        case 79:
            charColor = RGBA(0xee, 0xb7, 0x1f, 1);
            break;
        case 80:
            charColor = RGBA(0x6e, 0xb0, 0xfd, 1);
            break;
        case 81:
            charColor = RGBA(0x6d, 0xcc, 0x60, 1);
            break;
        case 82:
            charColor = RGBA(0xc5, 0x7f, 0xd0, 1);
            break;
        case 83:
            charColor = RGBA(0xfa, 0x7f, 0x7f, 1);
            break;
        case 84:
            charColor = RGBA(0xab, 0x8a, 0xe8, 1);
            break;
        case 85:
            charColor = RGBA(0xdc, 0x94, 0x7b, 1);
            break;
        case 86:
            charColor = RGBA(0x9a, 0x97, 0x97, 1);
            break;
        case 87:
            charColor = RGBA(0xc7, 0xce, 0x59, 1);
            break;
        case 88:
            charColor = RGBA(0xfa, 0x9a, 0x4c, 1);
            break;
        case 89:
            charColor = RGBA(0x79, 0x89, 0xe4, 1);
            break;
        case 90:
            charColor = RGBA(0x1d, 0xb4, 0xfc, 1);
            break;
        default:
            charColor = RGBA(0xf4, 0x76, 0x9d, 1);
            break;
    }
    
    return charColor;
}

@end
