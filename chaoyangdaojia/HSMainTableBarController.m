//
//  HSMainTableBarController.m
//  chaoyangdaojia
//
//  Created by hestyle on 2020/12/24.
//  Copyright © 2020 hestyle. All rights reserved.
//

#import "HSMainTableBarController.h"
#import "FirstPage/HSFirstPageViewController.h"
#import "Sort/HSSortViewController.h"
#import "Shop/HSShopViewController.h"
#import "Cart/HSCartViewController.h"
#import "MyAccount/HSMyAccountViewController.h"

@interface HSMainTableBarController ()

@end

@implementation HSMainTableBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // title选中时的颜色
    NSDictionary *dict = @{NSForegroundColorAttributeName:[UIColor blackColor]};
    // 设置5个tabBar
    HSFirstPageViewController *firstPageViewController = [HSFirstPageViewController new];
    [firstPageViewController.tabBarItem setTitle:@"首页"];
    [firstPageViewController.tabBarItem setTitleTextAttributes:dict forState:UIControlStateSelected];
    [firstPageViewController.tabBarItem setImage:[UIImage imageNamed:@"menu_firstpage"]];
    [firstPageViewController.tabBarItem setSelectedImage:[[UIImage imageNamed:@"menu_firstpage_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
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
    
    HSMyAccountViewController *myAccountViewController = [HSMyAccountViewController new];
    [myAccountViewController.tabBarItem setTitle:@"我的"];
    [myAccountViewController.tabBarItem setTitleTextAttributes:dict forState:UIControlStateSelected];
    [myAccountViewController.tabBarItem setImage:[UIImage imageNamed:@"menu_myaccount"]];
    [myAccountViewController.tabBarItem setSelectedImage:[[UIImage imageNamed:@"menu_myaccount_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    self.viewControllers = @[firstPageViewController, sortViewController, shopViewController, cartViewController, myAccountViewController];
}

@end
