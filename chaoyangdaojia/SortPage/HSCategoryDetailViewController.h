//
//  HSCategoryDetailViewController.h
//  chaoyangdaojia
//
//  Created by hestyle on 2021/1/19.
//  Copyright © 2021 hestyle. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HSCategoryDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

- (HSCategoryDetailViewController *)initWithCategoryData:(NSDictionary *)categoryDataDict;

@end

NS_ASSUME_NONNULL_END
