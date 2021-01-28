//
//  HSMainTableBarController.m
//  chaoyangdaojia
//
//  Created by hestyle on 2020/12/24.
//  Copyright © 2020 hestyle. All rights reserved.
//

#import "HSMainTableBarController.h"
#import "FirstPage/HSFirstCollectionViewController.h"
#import "SortPage/HSSortCollectionViewController.h"
#import "ShopPage/HSShopTableViewController.h"
#import "CartPage/HSCartViewController.h"
#import "MyPage/HSMyViewController.h"
#import "HSAccount.h"
#import "HSNetwork.h"
#import "HSCommon.h"

@interface HSMainTableBarController ()

@end

@implementation HSMainTableBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // viewcontroller title颜色
    NSDictionary *dict = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    // 设置5个tabBar
    HSFirstCollectionViewController *firstViewController = [HSFirstCollectionViewController new];
    [firstViewController.tabBarItem setTitle:@"首页"];
    [firstViewController.tabBarItem setImage:[UIImage imageNamed:@"menu_firstpage"]];
    [firstViewController.tabBarItem setSelectedImage:[[UIImage imageNamed:@"menu_firstpage_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    UINavigationController *firstNavigationController = [[UINavigationController alloc] initWithRootViewController:firstViewController];
    [firstNavigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [firstNavigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    [firstNavigationController.navigationBar setTitleTextAttributes:dict];
    
    HSSortCollectionViewController *sortViewController = [HSSortCollectionViewController new];
    [sortViewController.tabBarItem setTitle:@"分类"];
    [sortViewController.tabBarItem setImage:[UIImage imageNamed:@"menu_sort"]];
    [sortViewController.tabBarItem setSelectedImage:[[UIImage imageNamed:@"menu_sort_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    UINavigationController *sortNavigationController = [[UINavigationController alloc] initWithRootViewController:sortViewController];
    [sortNavigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [sortNavigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    [sortNavigationController.navigationBar setTitleTextAttributes:dict];
    
    HSShopTableViewController *shopTableViewController = [HSShopTableViewController new];
    [shopTableViewController.tabBarItem setTitle:@"店铺"];
    [shopTableViewController.tabBarItem setImage:[UIImage imageNamed:@"menu_shop"]];
    [shopTableViewController.tabBarItem setSelectedImage:[[UIImage imageNamed:@"menu_shop_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    UINavigationController *shopNavigationController = [[UINavigationController alloc] initWithRootViewController:shopTableViewController];
    [shopNavigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [shopNavigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    [shopNavigationController.navigationBar setTitleTextAttributes:dict];
    
    HSCartViewController *cartViewController = [HSCartViewController new];
    [cartViewController.tabBarItem setTitle:@"购物车"];
    [cartViewController.tabBarItem setImage:[UIImage imageNamed:@"menu_cart"]];
    [cartViewController.tabBarItem setSelectedImage:[[UIImage imageNamed:@"menu_cart_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    UINavigationController *cartNavigationController = [[UINavigationController alloc] initWithRootViewController:cartViewController];
    [cartNavigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [cartNavigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    [cartNavigationController.navigationBar setTitleTextAttributes:dict];
    
    HSMyViewController *myViewController = [HSMyViewController new];
    [myViewController.tabBarItem setTitle:@"我的"];
    [myViewController.tabBarItem setImage:[UIImage imageNamed:@"menu_myaccount"]];
    [myViewController.tabBarItem setSelectedImage:[[UIImage imageNamed:@"menu_myaccount_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    UINavigationController *myNavigationController = [[UINavigationController alloc] initWithRootViewController:myViewController];
    [myNavigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [myNavigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    [myNavigationController.navigationBar setTitleTextAttributes:dict];
    
    [self.tabBar setTintColor:[UIColor blackColor]];
    
    self.viewControllers = @[firstNavigationController, sortNavigationController, shopNavigationController, cartNavigationController, myNavigationController];
    
    [self getCartProductCount];
}

- (void)getCartProductCount {
    HSNetworkManager *manager = [HSNetworkManager shareManager];
    __weak __typeof__(self) weakSelf = self;
    [manager getDataWithUrl:kGetCartProductCountUrl parameters:@{} success:^(NSDictionary *responseDict) {
        if ([responseDict[@"errcode"] isEqual:@(0)]) {
            HSUserAccountManger *userAccountManger = [HSUserAccountManger shareManager];
            [userAccountManger setCartCount:[responseDict[@"cartnum"] integerValue]];
            // 发送通知
            [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCartCountNotificationKey object:weakSelf userInfo:@{@"cartCount":responseDict[@"cartnum"]}];
        }
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

@end
