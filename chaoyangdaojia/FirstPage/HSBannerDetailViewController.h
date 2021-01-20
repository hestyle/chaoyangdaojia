//
//  HSBannerDetailViewController.h
//  chaoyangdaojia
//
//  Created by hestyle on 2021/1/18.
//  Copyright © 2021 hestyle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HSBannerDetailViewController : UIViewController <WKNavigationDelegate>

@property (nonatomic) NSInteger bannerId;

@end

NS_ASSUME_NONNULL_END
