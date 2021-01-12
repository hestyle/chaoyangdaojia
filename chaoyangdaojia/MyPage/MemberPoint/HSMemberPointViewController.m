//
//  HSMemberPointViewController.m
//  chaoyangdaojia
//
//  Created by hestyle on 2021/1/11.
//  Copyright © 2021 hestyle. All rights reserved.
//

#import "HSMemberPointViewController.h"
#import "HSMemberExplainViewController.h"
#import "HSExchangeBalanceViewController.h"
#import "HSMemberPointDetailTableViewController.h"
#import "HSAccount.h"
#import "HSNetwork.h"
#import <Masonry/Masonry.h>
#import <Toast/Toast.h>

@interface HSMemberPointViewController ()

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIView *memberCardView;
@property (nonatomic, strong) UILabel *memberTypeLabel;
@property (nonatomic, strong) UILabel *memberPointLabel;
@property (nonatomic, strong) UILabel *exchangeBalanceLabel;
@property (nonatomic, strong) UIView *memberPointDetailView;
@property (nonatomic, strong) UILabel *memberPointMoreLabel;
@property (nonatomic, strong) UIView *memberPointListView;


@property (nonatomic, strong) UIBarButtonItem *rightMemberExplainButtonItem;
@end

@implementation HSMemberPointViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self initView];
}

- (void)viewWillAppear:(BOOL)animated {
    [self setTitle:@"会员积分"];
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationItem setRightBarButtonItem:self.rightMemberExplainButtonItem];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationItem setRightBarButtonItem:nil];
}

#pragma mark - Event
- (void)gotoMemberExplain {
    HSMemberExplainViewController *controller = [HSMemberExplainViewController new];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)gotoExchangeBalance {
    HSExchangeBalanceViewController *controller = [HSExchangeBalanceViewController new];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)gotoMemberPointDetail {
    HSMemberPointDetailTableViewController *controller = [HSMemberPointDetailTableViewController new];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Private
- (void)initView {
    [self initNavigationBar];
    
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
    
    UIImageView *memberTypeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"jifen_icon"]];
    [self.memberCardView addSubview:memberTypeImageView];
    [memberTypeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(30, 30));
        make.left.mas_equalTo(self.memberCardView).mas_offset(30);
        make.top.mas_equalTo(self.memberCardView).mas_offset(25);
    }];
    
    UIColor *textColor = [UIColor colorWithRed:250.0/255 green:209.0/255 blue:138.0/255 alpha:1.0];
    
    self.memberTypeLabel = [UILabel new];
    [self.memberTypeLabel setText:userInfoDict[@"levelid_str"]];
    [self.memberTypeLabel setTextColor:textColor];
    [self.memberTypeLabel setFont:[UIFont systemFontOfSize:[UIFont systemFontSize] + 12]];
    [self.memberCardView addSubview:self.memberTypeLabel];
    [self.memberTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(memberTypeImageView);
        make.left.mas_equalTo(memberTypeImageView.mas_right).mas_offset(10);
    }];
    
    UILabel *memberPointTitle = [UILabel new];
    [memberPointTitle setText:@"当前积分："];
    [memberPointTitle setTextColor:textColor];
    [self.memberCardView addSubview:memberPointTitle];
    [memberPointTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.memberCardView).mas_offset(30);
        make.bottom.mas_equalTo(self.memberCardView).mas_offset(-25);
    }];
    
    self.memberPointLabel = [UILabel new];
    [self.memberPointLabel setText:[NSString stringWithFormat:@"%@", userInfoDict[@"score"]]];
    [self.memberPointLabel setTextColor:textColor];
    [self.memberCardView addSubview:self.memberPointLabel];
    [self.memberPointLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(memberPointTitle);
        make.left.mas_equalTo(memberPointTitle.mas_right);
    }];
    
    self.exchangeBalanceLabel = [UILabel new];
    [self.exchangeBalanceLabel setText:@"兑换余额"];
    [self.exchangeBalanceLabel setTextColor:textColor];
    [self.exchangeBalanceLabel.layer setBorderWidth:0.5];
    [self.exchangeBalanceLabel.layer setBorderColor:[textColor CGColor]];
    [self.memberCardView addSubview:self.exchangeBalanceLabel];
    [self.exchangeBalanceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.memberCardView).mas_offset(-30);
        make.bottom.mas_equalTo(self.memberCardView).mas_offset(-25);
    }];
    // 添加点击事件
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoExchangeBalance)];
    [tapGesture setNumberOfTapsRequired:1];
    [self.exchangeBalanceLabel setUserInteractionEnabled:YES];
    [self.exchangeBalanceLabel addGestureRecognizer:tapGesture];
    
    
    self.memberPointDetailView = [UIView new];
    [self.view addSubview:self.memberPointDetailView];
    [self.memberPointDetailView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).mas_offset(20);
        make.right.mas_equalTo(self.view).mas_offset(-20);
        make.top.mas_equalTo(self.memberCardView.mas_bottom).mas_offset(10);
        make.height.mas_equalTo(40);
    }];
    
    UILabel *memberPointDetailTitleLabel = [UILabel new];
    [memberPointDetailTitleLabel setText:@"积分明细"];
    [memberPointDetailTitleLabel setFont:[UIFont systemFontOfSize:[UIFont systemFontSize] + 4]];
    [self.memberPointDetailView addSubview:memberPointDetailTitleLabel];
    [memberPointDetailTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.memberPointDetailView);
        make.left.mas_equalTo(self.memberPointDetailView);
    }];
    
    self.memberPointMoreLabel = [UILabel new];
    [self.memberPointMoreLabel setText:@"查看更多 >"];
    [self.memberPointMoreLabel setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];
    [self.memberPointDetailView addSubview:self.memberPointMoreLabel];
    [self.memberPointMoreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.memberPointDetailView);
        make.right.mas_equalTo(self.memberPointDetailView);
    }];
    // 添加点击事件
    UITapGestureRecognizer *gotoMemberPointDetailTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoMemberPointDetail)];
    [gotoMemberPointDetailTapGesture setNumberOfTapsRequired:1];
    [self.memberPointMoreLabel setUserInteractionEnabled:YES];
    [self.memberPointMoreLabel addGestureRecognizer:gotoMemberPointDetailTapGesture];
    
    self.memberPointListView = [UIView new];
    [self.view addSubview:self.memberPointListView];
    [self.memberPointListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).mas_offset(20);
        make.right.mas_equalTo(self.view).mas_offset(-20);
        make.top.mas_equalTo(self.memberPointDetailView.mas_bottom).mas_offset(10);
        make.bottom.mas_equalTo(self.view).mas_offset(-20);
    }];
    
    UIImageView *noMemberPointImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"no_xx"]];
    [self.memberPointListView addSubview:noMemberPointImageView];
    [noMemberPointImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.memberPointListView);
        make.size.mas_equalTo(CGSizeMake(160, 160));
        make.centerY.mas_equalTo(self.memberPointListView).mas_offset(-60);
    }];
    UILabel *noMemberPointTitleLabel = [UILabel new];
    [noMemberPointTitleLabel setText:@"还没有内容~"];
    [noMemberPointTitleLabel setTextColor:[UIColor colorWithRed:160/255.0 green:160/255.0 blue:160/255.0 alpha:1.0]];
    [self.memberPointListView addSubview:noMemberPointTitleLabel];
    [noMemberPointTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.memberPointListView);
        make.top.mas_equalTo(noMemberPointImageView.mas_bottom).mas_offset(10);
    }];
}

- (void)initNavigationBar {
    self.rightMemberExplainButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"会员说明" style:UIBarButtonItemStylePlain target:self action:@selector(gotoMemberExplain)];
}

@end
