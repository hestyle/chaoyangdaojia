//
//  HSAddToCartAnimation.h
//  chaoyangdaojia
//
//  Created by hestyle on 2021/1/26.
//  Copyright © 2021 hestyle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^AnimationFinishBlock)(BOOL finish);

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

NS_ASSUME_NONNULL_BEGIN

@interface HSAddToCartAnimation : NSObject <CAAnimationDelegate>

/**
 * 单例
 */
+ (instancetype)shareInstance;

/**
 * 开始动画
 */
- (void)startAnimationWithView:(UIView *)view rect:(CGRect)rect finishPoint:(CGPoint)finishPoint finishBlock:(AnimationFinishBlock)completion;

/**
 * 摇晃动画
 */
+ (void)shakeAnimation:(UIView *)shakeView;

@end

NS_ASSUME_NONNULL_END
