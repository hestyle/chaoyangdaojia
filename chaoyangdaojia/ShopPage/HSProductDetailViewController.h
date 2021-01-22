//
//  HSProductDetailViewController.h
//  chaoyangdaojia
//
//  Created by hestyle on 2021/1/20.
//  Copyright © 2021 hestyle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HSProductDetailViewController : UITableViewController <WKNavigationDelegate>

- (instancetype)initWithProductId:(NSInteger)productId;

@end

NS_ASSUME_NONNULL_END
