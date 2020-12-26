//
//  HSMyAccountViewController.m
//  chaoyangdaojia
//
//  Created by hestyle on 2020/12/24.
//  Copyright © 2020 hestyle. All rights reserved.
//

#import "HSMyAccountViewController.h"
#import "HSLoginViewController.h"
#import <Masonry/Masonry.h>

@interface HSMyAccountViewController ()

@end

@implementation HSMyAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.navigationController setNavigationBarHidden:NO];
    UILabel *textLabel = [[UILabel alloc] init];
    [textLabel setText:@"我的"];
    
    [self.view addSubview:textLabel];
    [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(20);
        make.center.mas_equalTo(self.view);
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSDictionary *userInfoDict = [userDefault objectForKey:@"USER_INFO"];
    if (userInfoDict == nil) {
        // 跳转到登录
        HSLoginViewController *loginViewController = [HSLoginViewController new];
        [self.navigationController pushViewController:loginViewController animated:YES];
    } else {
        // 访问getinfo接口
        
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
