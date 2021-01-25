//
//  HSProductSpecificationViewController.h
//  chaoyangdaojia
//
//  Created by hestyle on 2021/1/24.
//  Copyright © 2021 hestyle. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HSProductSpecificationViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

- (instancetype)init;

- (void)getProductSpecificationWithId:(NSInteger)productId hid:(NSInteger)hid;

@end

NS_ASSUME_NONNULL_END
