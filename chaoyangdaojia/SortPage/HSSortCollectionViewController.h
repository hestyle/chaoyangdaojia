//
//  HSSortCollectionViewController.h
//  chaoyangdaojia
//
//  Created by hestyle on 2021/1/17.
//  Copyright © 2021 hestyle. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HSSortCollectionViewController : UICollectionViewController <UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSMutableArray *categoryArray;

@end

NS_ASSUME_NONNULL_END
