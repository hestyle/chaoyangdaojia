//
//  HSNotification.h
//  chaoyangdaojia
//
//  Created by hestyle on 2021/1/26.
//  Copyright © 2021 hestyle. All rights reserved.
//

#import <Foundation/Foundation.h>

// 选择商品规格后的通知(传递商品规格信息)
extern NSString * const kChooseProductSpecificationNotificationKey;
// 成功添加商品到购物车的通知(传递商品规格信息:productId、specificationKey、buyCount、cartCount)
extern NSString * const kAddProductToCartNotificationKey;
// 购物车中的商品数量变更的通知(传递当前购物车中商品数量信息:cartCount)
extern NSString * const kUpdateCartCountNotificationKey;

NS_ASSUME_NONNULL_BEGIN

@interface HSNotification : NSObject

@end

NS_ASSUME_NONNULL_END
