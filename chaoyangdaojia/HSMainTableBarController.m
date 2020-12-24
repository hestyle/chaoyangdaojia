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
    // 设置5个tabBar
    HSFirstPageViewController *firstPageViewController = [HSFirstPageViewController new];
    [firstPageViewController.tabBarItem setTitle:@"首页"];
    [firstPageViewController.tabBarItem setImage:[UIImage imageNamed:@"menu_firstpage"]];
    [firstPageViewController.tabBarItem setSelectedImage:[UIImage imageNamed:@"menu_firstpage_selected"]];
    
    HSSortViewController *sortViewController = [HSSortViewController new];
    [sortViewController.tabBarItem setTitle:@"分类"];
    [sortViewController.tabBarItem setImage:[UIImage imageNamed:@"menu_sort"]];
    [sortViewController.tabBarItem setSelectedImage:[UIImage imageNamed:@"menu_sort_selected"]];
    
    HSShopViewController *shopViewController = [HSShopViewController new];
    [shopViewController.tabBarItem setTitle:@"店铺"];
    [shopViewController.tabBarItem setImage:[UIImage imageNamed:@"menu_shop"]];
    [shopViewController.tabBarItem setSelectedImage:[UIImage imageNamed:@"menu_shop_selected"]];
    
    HSCartViewController *cartViewController = [HSCartViewController new];
    [cartViewController.tabBarItem setTitle:@"购物车"];
    [cartViewController.tabBarItem setImage:[UIImage imageNamed:@"menu_cart"]];
    [cartViewController.tabBarItem setSelectedImage:[UIImage imageNamed:@"menu_cart_selected"]];
    
    HSMyAccountViewController *myAccountViewController = [HSMyAccountViewController new];
    [myAccountViewController.tabBarItem setTitle:@"我的"];
    [myAccountViewController.tabBarItem setImage:[UIImage imageNamed:@"menu_myaccount"]];
    [myAccountViewController.tabBarItem setSelectedImage:[UIImage imageNamed:@"menu_myaccount_selected"]];
    
    self.viewControllers = @[firstPageViewController, sortViewController, shopViewController, cartViewController, myAccountViewController];
}

@end
