//
//  HSAlertView.h
//  chaoyangdaojia
//
//  Created by hestyle on 2021/1/23.
//  Copyright © 2021 hestyle. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HSAlertView : UIView

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message;

- (instancetype)initWithCommonView:(UIView *)commonView;

- (void)show;
@end

NS_ASSUME_NONNULL_END
