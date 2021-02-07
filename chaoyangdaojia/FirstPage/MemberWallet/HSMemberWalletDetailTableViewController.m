//
//  HSMemberWalletDetailTableViewController.m
//  chaoyangdaojia
//
//  Created by hestyle on 2021/1/20.
//  Copyright © 2021 hestyle. All rights reserved.
//

#import "HSMemberWalletDetailTableViewController.h"
#import "HSNetwork.h"
#import <Masonry/Masonry.h>
#import <Toast/Toast.h>

@interface HSMemberWalletDetailTableViewController ()

@end

@implementation HSMemberWalletDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self setTitle:@"钱包明细"];
    [self.navigationController setNavigationBarHidden:NO];
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    UIImageView *noMemberPointImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"no_xx"]];
    [self.tableView addSubview:noMemberPointImageView];
    [noMemberPointImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.tableView);
        make.size.mas_equalTo(CGSizeMake(240, 240));
        make.centerY.mas_equalTo(self.tableView).mas_offset(-100);
    }];
    UILabel *noMemberPointTitleLabel = [UILabel new];
    [noMemberPointTitleLabel setText:@"暂无记录"];
    [noMemberPointTitleLabel setTextColor:[UIColor colorWithRed:160/255.0 green:160/255.0 blue:160/255.0 alpha:1.0]];
    [self.tableView addSubview:noMemberPointTitleLabel];
    [noMemberPointTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.tableView);
        make.top.mas_equalTo(noMemberPointImageView.mas_bottom).mas_offset(10);
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

@end
