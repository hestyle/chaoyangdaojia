//
//  HSAddToCartAnimation.m
//  chaoyangdaojia
//
//  Created by hestyle on 2021/1/26.
//  Copyright © 2021 hestyle. All rights reserved.
//

#import "HSAddToCartAnimation.h"
#import "HSCommon.h"

@interface HSAddToCartAnimation ()

@property (nonatomic, strong) CALayer *layer;
@property (nonatomic, copy) AnimationFinishBlock animationFinishBlock;

@end

@implementation HSAddToCartAnimation

+ (instancetype)shareInstance {
    static HSAddToCartAnimation *addToCartAnimation;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        addToCartAnimation = [HSAddToCartAnimation new];
    });
    return addToCartAnimation;
}

+ (void)shakeAnimation:(UIView *)shakeView {
    CABasicAnimation *shakeAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    shakeAnimation.duration = 0.25f;
    shakeAnimation.fromValue = @(-5.f);
    shakeAnimation.toValue = @(5.f);
    shakeAnimation.autoreverses = YES;
    [shakeView.layer addAnimation:shakeAnimation forKey:nil];
}

- (void)startAnimationWithView:(UIView *)view rect:(CGRect)rect finishPoint:(CGPoint)finishPoint finishBlock:(AnimationFinishBlock)completion {
    self.layer = [CALayer layer];
    [self.layer setContents:view.layer.contents];
    [self.layer setContentsGravity:kCAGravityResizeAspectFill];
    rect.size.width = 60;
    rect.size.height = 60;
    
    [self.layer setBounds:rect];
    [self.layer setCornerRadius:rect.size.width/2];
    [self.layer setMasksToBounds:YES];
    
    UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    [window.layer addSublayer:self.layer];
    [self.layer setPosition:CGPointMake(rect.origin.x + view.frame.size.height/2, CGRectGetMaxY(rect))];
    [self createAnimationWithRect:rect finishPoint:finishPoint];
    // 回调
    if (completion) {
        self.animationFinishBlock = completion;
    }
}

#pragma mark - Private
- (void)createAnimationWithRect:(CGRect)rect finishPoint:(CGPoint)finishPoint {
    // 路径动画
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:self.layer.position];
    [bezierPath addQuadCurveToPoint:finishPoint controlPoint:CGPointMake(SCREEN_WIDTH/2, rect.origin.y - 80)];
    CAKeyframeAnimation *pathFrameAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    [pathFrameAnimation setPath:bezierPath.CGPath];
    // 旋转动画
    CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    [rotateAnimation setRemovedOnCompletion:YES];
    [rotateAnimation setFromValue:@(0.f)];
    [rotateAnimation setToValue:@(12.f)];
    [rotateAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    // 添加动画组合
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    [animationGroup setAnimations:@[pathFrameAnimation, rotateAnimation]];
    [animationGroup setDuration:1.2f];
    [animationGroup setRemovedOnCompletion:NO];
    [animationGroup setFillMode:kCAFillModeForwards];
    [animationGroup setDelegate:self];
    [self.layer addAnimation:animationGroup forKey:@"group"];
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (anim == [self.layer animationForKey:@"group"]) {
        [self.layer removeFromSuperlayer];
        self.layer = nil;
        if (self.animationFinishBlock) {
            self.animationFinishBlock(YES);
        }
    }
}

@end
