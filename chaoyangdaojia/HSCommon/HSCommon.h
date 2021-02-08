//
//  HSCommon.h
//  chaoyangdaojia
//
//  Created by hestyle on 2021/1/26.
//  Copyright © 2021 hestyle. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HSNotification.h"


/* 屏幕宽度、高度 */
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

// 判断是否是刘海屏
#define IPHONE_X \
({BOOL isPhoneX = NO;\
if (@available(iOS 11.0, *)) {\
isPhoneX = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.0;\
}\
(isPhoneX);})

/* 状态栏高度 */
#define STATUS_BAR_HEIGHT (IPHONE_X ? 44.f : 24.f)
/* 导航栏高度 */
#define NAVIGATION_BAR_HEIGHT (44.f)
/* 状态栏 + 导航栏高度 */
#define STATUS_BAR_AND_NAVIGATION_BAR_HEIGHT (STATUS_BAR_HEIGHT + NAVIGATION_BAR_HEIGHT)
/* TabBar高度 */
#define TAB_BAR_HEIGHT (49.f)
/* TabBar底部与屏幕底部之间的Margin */
#define TAB_BAR_SAFE_BOTTOM_MARGIN (IPHONE_X ? 34.f : 0.f)
/* TabBar + SafeBottomMargin */
#define TAB_BAR_HEIGHT_AND_SAFE_BOTTOM_MARGIN (TAB_BAR_HEIGHT + TAB_BAR_SAFE_BOTTOM_MARGIN)
