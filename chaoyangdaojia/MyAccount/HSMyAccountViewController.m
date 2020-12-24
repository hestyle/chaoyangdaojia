//
//  HSMyAccountViewController.m
//  chaoyangdaojia
//
//  Created by hestyle on 2020/12/24.
//  Copyright © 2020 hestyle. All rights reserved.
//

#import "HSMyAccountViewController.h"
#import <Masonry/Masonry.h>

@interface HSMyAccountViewController ()

@end

@implementation HSMyAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    UILabel *textLabel = [[UILabel alloc] init];
    [textLabel setText:@"我的"];
    
    [self.view addSubview:textLabel];
    [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(20);
        make.center.mas_equalTo(self.view);
    }];
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
