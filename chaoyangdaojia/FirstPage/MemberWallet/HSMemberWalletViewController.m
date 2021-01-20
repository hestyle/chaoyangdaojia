//
//  HSMemberWalletViewController.m
//  chaoyangdaojia
//
//  Created by hestyle on 2021/1/20.
//  Copyright © 2021 hestyle. All rights reserved.
//

#import "HSMemberWalletViewController.h"
#import "HSRechargeViewController.h"
#import "HSWithDrawalViewController.h"
#import "HSMemberWalletDetailTableViewController.h"
#import "HSAccount.h"
#import "HSNetwork.h"
#import <Masonry/Masonry.h>
#import <Toast/Toast.h>

@interface HSMemberWalletViewController ()

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIView *memberCardView;
@property (nonatomic, strong) UILabel *currentBalanceTitleLabel;
@property (nonatomic, strong) UILabel *currentBalanceLabel;
@property (nonatomic, strong) UILabel *rechargeLabel;
@property (nonatomic, strong) UILabel *withDrawalLabel;
@property (nonatomic, strong) UIView *memberWalletDetailView;
@property (nonatomic, strong) UILabel *memberWalletMoreLabel;
@property (nonatomic, strong) UIView *memberWalletListView;

@end

@implementation HSMemberWalletViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    [self.view setBackgroundColor:[UIColor colorWithRed:245.0/255 green:245.0/255 blue:245.0/255 alpha:1.0]];

    [self initView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setTitle:@"会员钱包"];
    [self.navigationController setNavigationBarHidden:NO];
}

#pragma mark - Event
- (void)gotoRechargeAction {
    HSRechargeViewController *controller = [HSRechargeViewController new];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)gotoWithDrawalAction {
    HSWithDrawalViewController *controller = [HSWithDrawalViewController new];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)gotoMemberWalletDetailAction {
    HSMemberWalletDetailTableViewController *controller = [HSMemberWalletDetailTableViewController new];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Private
- (void)initView {
    HSUserAccountManger *userAccountManger = [HSUserAccountManger shareManager];
    NSDictionary *userInfoDict = [userAccountManger userInfoDict];
    
    self.backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"jifen_background_1"]];
    [self.view addSubview:self.backgroundImageView];
    [self.backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view);
        make.left.mas_equalTo(self.view);
        make.right.mas_equalTo(self.view);
        make.height.mas_equalTo(180);
    }];
    
    self.memberCardView = [UIView new];
    [self.view addSubview:self.memberCardView];
    [self.memberCardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).mas_offset(20);
        make.right.mas_equalTo(self.view).mas_offset(-20);
        make.top.mas_equalTo(self.view).mas_offset(20);
        make.height.mas_equalTo(180);
    }];
    
    UIImageView *memberCardImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"jifen_background_2"]];
    [self.memberCardView addSubview:memberCardImageView];
    [memberCardImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(self.memberCardView);
    }];

    
    UIColor *textColor = [UIColor colorWithRed:250.0/255 green:209.0/255 blue:138.0/255 alpha:1.0];
    
    self.currentBalanceTitleLabel = [UILabel new];
    [self.currentBalanceTitleLabel setTextColor:textColor];
    [self.currentBalanceTitleLabel setFont:[UIFont systemFontOfSize:[UIFont systemFontSize] + 18]];
    [self.currentBalanceTitleLabel setText:@"当前余额(元)"];
    [self.memberCardView addSubview:self.currentBalanceTitleLabel];
    [self.currentBalanceTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.memberCardView).mas_offset(20);
        make.left.mas_equalTo(self.memberCardView).mas_offset(10);
    }];
    
    self.currentBalanceLabel = [UILabel new];
    [self.currentBalanceLabel setText:[NSString stringWithFormat:@"￥%@", userInfoDict[@"lmoney"]]];
    [self.currentBalanceLabel setFont:[UIFont systemFontOfSize:[UIFont systemFontSize] + 25]];
    [self.currentBalanceLabel setTextColor:textColor];
    [self.memberCardView addSubview:self.currentBalanceLabel];
    [self.currentBalanceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.memberCardView).mas_offset(-20);
        make.left.mas_equalTo(self.currentBalanceTitleLabel);
    }];
    
    self.rechargeLabel = [UILabel new];
    [self.rechargeLabel setText:@"充值"];
    [self.rechargeLabel setTextColor:textColor];
    [self.rechargeLabel setTextAlignment:NSTextAlignmentCenter];
    [self.rechargeLabel setBackgroundColor:[UIColor colorWithRed:55.0/255 green:48.0/255 blue:41.0/255 alpha:1.0]];
    [self.rechargeLabel.layer setBorderWidth:0.5];
    [self.rechargeLabel.layer setBorderColor:[textColor CGColor]];
    [self.view addSubview:self.rechargeLabel];
    [self.rechargeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.memberCardView);
        make.right.mas_equalTo(self.memberCardView.mas_centerX).mas_offset(-20);
        make.top.mas_equalTo(self.memberCardView.mas_bottom).mas_offset(20);
        make.height.mas_equalTo(40);
    }];
    // 添加点击事件
    UITapGestureRecognizer *rechargeGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoRechargeAction)];
    [rechargeGesture setNumberOfTapsRequired:1];
    [self.rechargeLabel setUserInteractionEnabled:YES];
    [self.rechargeLabel addGestureRecognizer:rechargeGesture];
    
    self.withDrawalLabel = [UILabel new];
    [self.withDrawalLabel setText:@"提现"];
    [self.withDrawalLabel setBackgroundColor:[UIColor whiteColor]];
    [self.withDrawalLabel setTextAlignment:NSTextAlignmentCenter];
    [self.withDrawalLabel setTextColor:[UIColor redColor]];
    [self.withDrawalLabel.layer setBorderWidth:0.5];
    [self.withDrawalLabel.layer setBorderColor:[[UIColor redColor] CGColor]];
    [self.view addSubview:self.withDrawalLabel];
    [self.withDrawalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.memberCardView.mas_centerX).mas_offset(20);
        make.right.mas_equalTo(self.memberCardView);
        make.top.mas_equalTo(self.rechargeLabel);
        make.height.mas_equalTo(self.rechargeLabel);
    }];
    // 添加点击事件
    UITapGestureRecognizer *withDrawalGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoWithDrawalAction)];
    [withDrawalGesture setNumberOfTapsRequired:1];
    [self.withDrawalLabel setUserInteractionEnabled:YES];
    [self.withDrawalLabel addGestureRecognizer:withDrawalGesture];
    
    self.memberWalletDetailView = [UIView new];
    [self.memberWalletDetailView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.memberWalletDetailView];
    [self.memberWalletDetailView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view);
        make.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.rechargeLabel.mas_bottom).mas_offset(20);
        make.height.mas_equalTo(60);
    }];
    
    UILabel *memberWalletDetailTitleLabel = [UILabel new];
    [memberWalletDetailTitleLabel setText:@"钱包明细"];
    [memberWalletDetailTitleLabel setFont:[UIFont systemFontOfSize:[UIFont systemFontSize] + 4]];
    [self.memberWalletDetailView addSubview:memberWalletDetailTitleLabel];
    [memberWalletDetailTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.memberWalletDetailView);
        make.left.mas_equalTo(self.memberWalletDetailView).mas_offset(20);
    }];
    
    self.memberWalletMoreLabel = [UILabel new];
    [self.memberWalletMoreLabel setText:@"查看更多 >"];
    [self.memberWalletMoreLabel setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];
    [self.memberWalletDetailView addSubview:self.memberWalletMoreLabel];
    [self.memberWalletMoreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.memberWalletDetailView);
        make.right.mas_equalTo(self.memberWalletDetailView).mas_offset(-20);
    }];
    // 添加点击事件
    UITapGestureRecognizer *gotoMemberWalletDetailTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoMemberWalletDetailAction)];
    [gotoMemberWalletDetailTapGesture setNumberOfTapsRequired:1];
    [self.memberWalletMoreLabel setUserInteractionEnabled:YES];
    [self.memberWalletMoreLabel addGestureRecognizer:gotoMemberWalletDetailTapGesture];
    
    self.memberWalletListView = [UIView new];
    [self.view addSubview:self.memberWalletListView];
    [self.memberWalletListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).mas_offset(20);
        make.right.mas_equalTo(self.view).mas_offset(-20);
        make.top.mas_equalTo(self.memberWalletDetailView.mas_bottom).mas_offset(10);
        make.bottom.mas_equalTo(self.view).mas_offset(-20);
    }];
    
    UIImageView *noMemberPointImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"no_xx"]];
    [self.memberWalletListView addSubview:noMemberPointImageView];
    [noMemberPointImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.memberWalletListView);
        make.size.mas_equalTo(CGSizeMake(160, 160));
        make.centerY.mas_equalTo(self.memberWalletListView).mas_offset(-60);
    }];
    UILabel *noMemberPointTitleLabel = [UILabel new];
    [noMemberPointTitleLabel setText:@"还没有内容~"];
    [noMemberPointTitleLabel setTextColor:[UIColor colorWithRed:160/255.0 green:160/255.0 blue:160/255.0 alpha:1.0]];
    [self.memberWalletListView addSubview:noMemberPointTitleLabel];
    [noMemberPointTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.memberWalletListView);
        make.top.mas_equalTo(noMemberPointImageView.mas_bottom).mas_offset(10);
    }];
}

@end
