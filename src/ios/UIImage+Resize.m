//
//  UIImage+Resize.m
//  ImageResize
//
//  Created by Linhaibo on 2022/7/5.
//
// 根据最大值resize image

#import "UIImage+Resize.h"

@implementation UIImage (Resize)


- (UIImage *)resize:(int)maxsize {

    CGSize imageSize = self.size;
    CGFloat ratio;
    if(imageSize.width > imageSize.height && imageSize.width > maxsize){
        ratio = maxsize/imageSize.width;
    }else if(imageSize.width < imageSize.height && imageSize.height > maxsize){
        ratio = maxsize/imageSize.height;
    }else if(imageSize.width == imageSize.height && imageSize.width > maxsize){
        ratio = maxsize/imageSize.width;
    }else{
        return self; //高和宽都小于 maxsize
    }
    CGFloat newWidth = imageSize.width * ratio;
    CGFloat newHeight = imageSize.height * ratio;
    CGRect targetImageDrawRect = CGRectMake(0,0,newWidth,newHeight);

    UIGraphicsBeginImageContextWithOptions(CGSizeMake(newWidth,newHeight), false, 1.0);
    [self drawInRect:targetImageDrawRect blendMode:kCGBlendModeCopy alpha:1.0];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
