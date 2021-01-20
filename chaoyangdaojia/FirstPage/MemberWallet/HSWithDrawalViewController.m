//
//  HSWithDrawalViewController.m
//  chaoyangdaojia
//
//  Created by hestyle on 2021/1/20.
//  Copyright © 2021 hestyle. All rights reserved.
//

#import "HSWithDrawalViewController.h"
#import "HSAccount.h"
#import "HSNetwork.h"
#import <Masonry/Masonry.h>
#import <Toast/Toast.h>


@interface HSWithDrawalViewController ()

@property (nonatomic) float leftMoney;
@property (nonatomic) float exchangeMoney;

@property (nonatomic, strong) UIView *withDrawalAccountView;
@property (nonatomic, strong) UILabel *withDrawalAccountTypeLabel;

@property (nonatomic, strong) UIView *withDrawalBalanceView;
@property (nonatomic, strong) UITextField *withDrawalBalanceTextField;
@property (nonatomic, strong) UILabel *withDrawalAllLabel;

@property (nonatomic, strong) UILabel *withDrawalTipLabel;
@property (nonatomic, strong) UILabel *withDrawalLabel;

@end

@implementation HSWithDrawalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self initView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setTitle:@"提现"];
    [self.navigationController setNavigationBarHidden:NO];
}

#pragma mark - Event
- (void)selectWithDrawalAccountTypeAction {
    [self.withDrawalBalanceTextField endEditing:YES];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选择提现账号类型" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    __weak __typeof__(self) weakSelf = self;
    [alert addAction:[UIAlertAction actionWithTitle:@"支付宝" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf.withDrawalAccountTypeLabel setText:@"支付宝"];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"微信" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf.withDrawalAccountTypeLabel setText:@"微信"];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)withDrawalAllBalanceAction {
    [self.withDrawalBalanceTextField setText:[NSString stringWithFormat:@"%.2f", self.leftMoney - self.exchangeMoney]];
}

- (void)withDrawalAction {
    [self.view makeToast:@"意思意思得了！"];
}

#pragma mark - Private
- (void)initView {
    self.withDrawalAccountView = [UIView new];
    [self.view addSubview:self.withDrawalAccountView];
    [self.withDrawalAccountView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).mas_offset(20);
        make.right.mas_equalTo(self.view).mas_offset(-20);
        make.top.mas_equalTo(self.view).mas_offset(10);
        make.height.mas_equalTo(45);
    }];
    UILabel *withDrawalAccountTitleLabel = [UILabel new];
    [withDrawalAccountTitleLabel setText:@"提现账号"];
    [self.withDrawalAccountView addSubview:withDrawalAccountTitleLabel];
    [withDrawalAccountTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.withDrawalAccountView);
        make.centerY.mas_equalTo(self.withDrawalAccountView);
    }];
    UIImageView *selectWithDrawalAccountImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"goto_detail"]];
    [self.withDrawalAccountView addSubview:selectWithDrawalAccountImageView];
    [selectWithDrawalAccountImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.withDrawalAccountView);
        make.right.mas_equalTo(self.withDrawalAccountView);
        make.size.mas_equalTo(CGSizeMake(15, 15));
    }];
    self.withDrawalAccountTypeLabel = [UILabel new];
    [self.withDrawalAccountTypeLabel setText:@"微信"];
    [self.withDrawalAccountView addSubview:self.withDrawalAccountTypeLabel];
    [self.withDrawalAccountTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(selectWithDrawalAccountImageView.mas_left).mas_equalTo(-5);
        make.centerY.mas_equalTo(self.withDrawalAccountView);
    }];
    // 添加点击事件
    UITapGestureRecognizer *withDrawalAccountTypeGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectWithDrawalAccountTypeAction)];
    [withDrawalAccountTypeGesture setNumberOfTapsRequired:1];
    [self.withDrawalAccountTypeLabel setUserInteractionEnabled:YES];
    [self.withDrawalAccountTypeLabel addGestureRecognizer:withDrawalAccountTypeGesture];
    
    UIView *divisionLineView = [UIView new];
    [divisionLineView setBackgroundColor:[UIColor grayColor]];
    [self.view addSubview:divisionLineView];
    [divisionLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.withDrawalAccountView);
        make.right.mas_equalTo(self.withDrawalAccountView);
        make.top.mas_equalTo(self.withDrawalAccountView.mas_bottom).mas_offset(5);
        make.height.mas_equalTo(0.5);
    }];
    
    self.withDrawalBalanceView = [UIView new];
    [self.view addSubview:self.withDrawalBalanceView];
    [self.withDrawalBalanceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.withDrawalAccountView);
        make.right.mas_equalTo(self.withDrawalAccountView);
        make.top.mas_equalTo(divisionLineView.mas_bottom).mas_offset(5);
        make.height.mas_equalTo(80);
    }];
    UILabel *withDrawalBalanceTitleLabel = [UILabel new];
    [withDrawalBalanceTitleLabel setText:@"提现金额"];
    [self.withDrawalBalanceView addSubview:withDrawalBalanceTitleLabel];
    [withDrawalBalanceTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.withDrawalBalanceView);
        make.top.mas_equalTo(self.withDrawalBalanceView).mas_offset(10);
    }];
    UILabel *balanceTitleLabel = [UILabel new];
    [balanceTitleLabel setText:@"￥"];
    [balanceTitleLabel setFont:[UIFont systemFontOfSize:[UIFont systemFontSize] + 10]];
    [self.withDrawalBalanceView addSubview:balanceTitleLabel];
    [balanceTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.withDrawalBalanceView);
        make.width.mas_equalTo(20);
        make.top.mas_equalTo(withDrawalBalanceTitleLabel.mas_bottom).mas_offset(10);
    }];
    self.withDrawalAllLabel = [UILabel new];
    [self.withDrawalAllLabel setText:@"全部提现"];
    [self.withDrawalAllLabel setTextColor:[UIColor redColor]];
    [self.withDrawalAllLabel setTextAlignment:NSTextAlignmentCenter];
    [self.withDrawalBalanceView addSubview:self.withDrawalAllLabel];
    [self.withDrawalAllLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.withDrawalBalanceView);
        make.width.mas_equalTo(80);
        make.centerY.mas_equalTo(balanceTitleLabel);
    }];
    // 添加点击事件
    UITapGestureRecognizer *withDrawalAllBalanceGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(withDrawalAllBalanceAction)];
    [withDrawalAllBalanceGesture setNumberOfTapsRequired:1];
    [self.withDrawalAllLabel setUserInteractionEnabled:YES];
    [self.withDrawalAllLabel addGestureRecognizer:withDrawalAllBalanceGesture];
    
    self.withDrawalBalanceTextField = [UITextField new];
    [self.withDrawalBalanceTextField setKeyboardType:UIKeyboardTypeNumberPad];
    [self.withDrawalBalanceTextField setFont:[UIFont systemFontOfSize:[UIFont systemFontSize] + 10]];
    [self.withDrawalBalanceView addSubview:self.withDrawalBalanceTextField];
    [self.withDrawalBalanceTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(balanceTitleLabel);
        make.left.mas_equalTo(balanceTitleLabel.mas_right).mas_offset(5);
        make.right.mas_equalTo(self.withDrawalAllLabel.mas_left).mas_offset(-5);
    }];
    
    UIView *divisionLineTwoView = [UIView new];
    [divisionLineTwoView setBackgroundColor:[UIColor grayColor]];
    [self.view addSubview:divisionLineTwoView];
    [divisionLineTwoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.withDrawalBalanceView);
        make.right.mas_equalTo(self.withDrawalBalanceView);
        make.top.mas_equalTo(self.withDrawalBalanceView.mas_bottom).mas_offset(5);
        make.height.mas_equalTo(0.5);
    }];
    
    HSUserAccountManger *userAccountManger = [HSUserAccountManger shareManager];
    NSDictionary *userInfoDict = [userAccountManger userInfoDict];
    self.leftMoney = [((NSString *)userInfoDict[@"lmoney"]) floatValue];
    self.exchangeMoney = [((NSString *)userInfoDict[@"moneydh"]) floatValue];
    
    self.withDrawalTipLabel = [UILabel new];
    [self.withDrawalTipLabel setNumberOfLines:0];
    [self.withDrawalTipLabel setTextColor:[UIColor grayColor]];
    [self.withDrawalTipLabel setFont:[UIFont systemFontOfSize:[UIFont systemFontSize] - 2]];
    [self.withDrawalTipLabel setText:[NSString stringWithFormat:@"当前余额：%.2f\n注：有%.2f元不可提现，因积分兑换的余额不支持提现", self.leftMoney, self.exchangeMoney]];
    [self.view addSubview:self.withDrawalTipLabel];
    [self.withDrawalTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.withDrawalBalanceView);
        make.right.mas_equalTo(self.withDrawalBalanceView);
        make.top.mas_equalTo(divisionLineTwoView.mas_bottom).mas_offset(5);
    }];
    
    self.withDrawalLabel = [UILabel new];
    [self.withDrawalLabel setText:@"确认提现"];
    [self.withDrawalLabel setTextAlignment:NSTextAlignmentCenter];
    [self.withDrawalLabel setBackgroundColor:[UIColor orangeColor]];
    [self.withDrawalLabel setTextColor:[UIColor whiteColor]];
    [self.view addSubview:self.withDrawalLabel];
    [self.withDrawalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.withDrawalAccountView);
        make.right.mas_equalTo(self.withDrawalAccountView);
        make.bottom.mas_equalTo(self.view).mas_offset(-50);
        make.height.mas_equalTo(40);
    }];
    // 添加点击事件
    UITapGestureRecognizer *withDrawalGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(withDrawalAction)];
    [withDrawalGesture setNumberOfTapsRequired:1];
    [self.withDrawalLabel setUserInteractionEnabled:YES];
    [self.withDrawalLabel addGestureRecognizer:withDrawalGesture];
}

@end
