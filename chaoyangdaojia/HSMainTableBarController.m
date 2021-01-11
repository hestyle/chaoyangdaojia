//
//  HSMainTableBarController.m
//  chaoyangdaojia
//
//  Created by hestyle on 2020/12/24.
//  Copyright © 2020 hestyle. All rights reserved.
//

#import "HSMainTableBarController.h"
#import "FirstPage/HSFirstViewController.h"
#import "SortPage/HSSortViewController.h"
#import "ShopPage/HSShopViewController.h"
#import "CartPage/HSCartViewController.h"
#import "MyPage/HSMyViewController.h"

@interface HSMainTableBarController ()

@end

@implementation HSMainTableBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // title选中时的颜色
    NSDictionary *dict = @{NSForegroundColorAttributeName:[UIColor blackColor]};
    // 设置5个tabBar
    HSFirstViewController *firstViewController = [HSFirstViewController new];
    [firstViewController.tabBarItem setTitle:@"首页"];
    [firstViewController.tabBarItem setTitleTextAttributes:dict forState:UIControlStateSelected];
    [firstViewController.tabBarItem setImage:[UIImage imageNamed:@"menu_firstpage"]];
    [firstViewController.tabBarItem setSelectedImage:[[UIImage imageNamed:@"menu_firstpage_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    HSSortViewController *sortViewController = [HSSortViewController new];
    [sortViewController.tabBarItem setTitle:@"分类"];
    [sortViewController.tabBarItem setTitleTextAttributes:dict forState:UIControlStateSelected];
    [sortViewController.tabBarItem setImage:[UIImage imageNamed:@"menu_sort"]];
    [sortViewController.tabBarItem setSelectedImage:[[UIImage imageNamed:@"menu_sort_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    HSShopViewController *shopViewController = [HSShopViewController new];
    [shopViewController.tabBarItem setTitle:@"店铺"];
    [shopViewController.tabBarItem setTitleTextAttributes:dict forState:UIControlStateSelected];
    [shopViewController.tabBarItem setImage:[UIImage imageNamed:@"menu_shop"]];
    [shopViewController.tabBarItem setSelectedImage:[[UIImage imageNamed:@"menu_shop_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    HSCartViewController *cartViewController = [HSCartViewController new];
    [cartViewController.tabBarItem setTitle:@"购物车"];
    [cartViewController.tabBarItem setTitleTextAttributes:dict forState:UIControlStateSelected];
    [cartViewController.tabBarItem setImage:[UIImage imageNamed:@"menu_cart"]];
    [cartViewController.tabBarItem setSelectedImage:[[UIImage imageNamed:@"menu_cart_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    HSMyViewController *myViewController = [HSMyViewController new];
    [myViewController.tabBarItem setTitle:@"我的"];
    [myViewController.tabBarItem setTitleTextAttributes:dict forState:UIControlStateSelected];
    [myViewController.tabBarItem setImage:[UIImage imageNamed:@"menu_myaccount"]];
    [myViewController.tabBarItem setSelectedImage:[[UIImage imageNamed:@"menu_myaccount_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    self.viewControllers = @[firstViewController, sortViewController, shopViewController, cartViewController, myViewController];
}

@end
