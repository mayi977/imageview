//
//  ImageInWindow.m
//  AnimationDemo
//
//  Created by Zilu.Ma on 2017/3/20.
//  Copyright © 2017年 VSI. All rights reserved.
//

#import "ImageInWindow.h"

@implementation ImageInWindow

static CGRect oldFrame;
static CGFloat lastScale;
static CGFloat lastRotation;


+ (void)showImage:(UIImageView *)avatarImageView{
    UIImage *image = avatarImageView.image;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    CGRect rect = [UIScreen mainScreen].bounds;
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
    bgView.backgroundColor = [UIColor blackColor];
    bgView.alpha = 1.0;
    [window addSubview:bgView];

    oldFrame = [avatarImageView convertRect:avatarImageView.bounds toView:window];

    UIImageView *imageView = [[UIImageView alloc] initWithFrame:oldFrame];
    imageView.tag = 100;
    imageView.image = image;
    imageView.userInteractionEnabled = YES;
    [bgView addSubview:imageView];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [bgView addGestureRecognizer:tap];

    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGesture:)];
    [imageView addGestureRecognizer:pinch];

    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    [imageView addGestureRecognizer:pan];

    UIRotationGestureRecognizer *rotation = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotationGesture:)];
    [imageView addGestureRecognizer:rotation];

    [UIView animateWithDuration:1.0 animations:^{
        imageView.frame=CGRectMake(0,(rect.size.height-image.size.height*rect.size.width/image.size.width)/2,
                                   rect.size.width, image.size.height*rect.size.width/image.size.width);


        //旋转后的状态怎样回到初始状态？？？？
//        CGAffineTransform currentTransform = imageView.transform;
//        CGAffineTransform newTransform = CGAffineTransformRotate(currentTransform, rotation.rotation - lastRotation);
//        [imageView setTransform:newTransform];
//        bgView.alpha = 1.0;
    } completion:nil];
}

+ (void)tapGesture:(UITapGestureRecognizer *)tap{
    UIView *bgView = tap.view;
    UIImageView *imageView = (UIImageView *)[bgView viewWithTag:100];
    [UIView animateWithDuration:1.0 animations:^{
        imageView.frame = oldFrame;
    } completion:^(BOOL finished) {
        bgView.alpha = 0.0;
        [bgView removeFromSuperview];
    }];
}

+ (void)pinchGesture:(UIPinchGestureRecognizer *)pinch{
    UIImageView *imageView = (UIImageView *)pinch.view;
    if (pinch.state == UIGestureRecognizerStateBegan) {
        lastScale = 1.0;
        return ;
    }

    CGFloat scale = 1.0 - (lastScale - pinch.scale);
    CGAffineTransform currentTransform = imageView.transform;
    CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, scale, scale);
    [imageView setTransform:newTransform];

    lastScale = pinch.scale;
}

+ (void)panGesture:(UIPanGestureRecognizer *)pan{
    UIImageView *imageView = (UIImageView *)pan.view;

    CGPoint point = [pan translationInView:imageView];
    static CGFloat firstX;
    static CGFloat firstY;
    if (pan.state == UIGestureRecognizerStateBegan) {
        firstX = [imageView center].x;
        firstY = [imageView center].y;
    }

    point = CGPointMake(firstX + point.x, firstY + point.y);
    NSLog(@"firstX=%f  firstY=%f  pointX=%f  pointY=%f",firstX,firstY,point.x,point.y);
    if (point.x < 0 || point.y < 0 || point.x > [UIScreen mainScreen].bounds.size.width || point.y > [UIScreen mainScreen].bounds.size.height) {
        return;
    }
    [imageView setCenter:point];

}

+ (void)rotationGesture:(UIRotationGestureRecognizer *)rotation{
    UIImageView *imageView = (UIImageView *)rotation.view;

    if (rotation.state == UIGestureRecognizerStateBegan) {
        lastRotation = 0.0;
        return;
    }

    CGFloat rotate = 0.0 - (lastRotation - rotation.rotation);
    CGAffineTransform currentTransform = imageView.transform;
    CGAffineTransform newTransform = CGAffineTransformRotate(currentTransform, rotate);
    [imageView setTransform:newTransform];

    lastRotation = rotation.rotation;
}

@end
