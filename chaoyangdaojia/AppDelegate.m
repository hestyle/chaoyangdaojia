//
//  AppDelegate.m
//  chaoyangdaojia
//
//  Created by hestyle on 2020/12/23.
//  Copyright © 2020 hestyle. All rights reserved.
//

#import "AppDelegate.h"
#import "HSMainTableBarController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 修改程序入口
    HSMainTableBarController *controller = [[HSMainTableBarController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    NSDictionary *attributes=@{NSForegroundColorAttributeName:[UIColor whiteColor]};
    [navigationController.navigationBar setTitleTextAttributes:attributes];
    [navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"main_navigationbar_background"] forBarMetrics:UIBarMetricsDefault];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
