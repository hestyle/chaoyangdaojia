//
//  HSRechargeViewController.m
//  chaoyangdaojia
//
//  Created by hestyle on 2021/1/20.
//  Copyright © 2021 hestyle. All rights reserved.
//

#import "HSRechargeViewController.h"
#import "HSAccount.h"
#import "HSNetwork.h"
#import <Masonry/Masonry.h>
#import <Toast/Toast.h>

@interface HSRechargeViewController ()

@property (nonatomic, strong) UIView *rechargeBalanceView;
@property (nonatomic, strong) UITextField *rechargeBalanceTextField;

@property (nonatomic, strong) UIView *paymentMethodView;
@property (nonatomic, strong) UILabel *paymentMethodLabel;

@property (nonatomic, strong) UILabel *paymentLabel;

@property (nonatomic) NSInteger paymentMethodType;

@end

@implementation HSRechargeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self initView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setTitle:@"充值"];
    [self.navigationController setNavigationBarHidden:NO];
}

#pragma mark - Event
- (void)gotoPaymentMethodSelectAction {
    [self.rechargeBalanceTextField endEditing:YES];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选择支付方式" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    __weak __typeof__(self) weakSelf = self;
    [alert addAction:[UIAlertAction actionWithTitle:@"支付宝" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.paymentMethodType = 1;
        [weakSelf.paymentMethodLabel setText:@"支付宝"];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"微信" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.paymentMethodType = 2;
        [weakSelf.paymentMethodLabel setText:@"微信"];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)gotoPaymentAction {
    [self.view makeToast:@"意思意思得了！"];
}

#pragma mark - Private
- (void)initView {
    self.rechargeBalanceView = [UIView new];
    [self.view addSubview:self.rechargeBalanceView];
    [self.rechargeBalanceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).mas_offset(20);
        make.right.mas_equalTo(self.view).mas_offset(-20);
        make.top.mas_equalTo(self.view).mas_offset(10);
        make.height.mas_equalTo(45);
    }];
    UILabel *rechargeBalanceTitleLabel = [UILabel new];
    [rechargeBalanceTitleLabel setText:@"充值金额"];
    [self.rechargeBalanceView addSubview:rechargeBalanceTitleLabel];
    [rechargeBalanceTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.rechargeBalanceView);
        make.centerY.mas_equalTo(self.rechargeBalanceView);
    }];
    self.rechargeBalanceTextField = [UITextField new];
    [self.rechargeBalanceTextField setKeyboardType:UIKeyboardTypeNumberPad];
    [self.rechargeBalanceTextField setPlaceholder:@"请输入充值金额(至少50元)"];
    [self.rechargeBalanceTextField setTextAlignment:NSTextAlignmentRight];
    [self.rechargeBalanceView addSubview:self.rechargeBalanceTextField];
    [self.rechargeBalanceTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.rechargeBalanceView);
        make.centerY.mas_equalTo(self.rechargeBalanceView);
    }];
    
    UIView *divisionLineView = [UIView new];
    [divisionLineView setBackgroundColor:[UIColor grayColor]];
    [self.view addSubview:divisionLineView];
    [divisionLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.rechargeBalanceView);
        make.right.mas_equalTo(self.rechargeBalanceView);
        make.top.mas_equalTo(self.rechargeBalanceView.mas_bottom).mas_offset(5);
        make.height.mas_equalTo(0.5);
    }];
    
    self.paymentMethodView = [UIView new];
    [self.view addSubview:self.paymentMethodView];
    [self.paymentMethodView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.rechargeBalanceView);
        make.right.mas_equalTo(self.rechargeBalanceView);
        make.top.mas_equalTo(divisionLineView.mas_bottom).mas_offset(5);
        make.height.mas_equalTo(self.rechargeBalanceView);
    }];
    UILabel *paymentMethodTitleLabel = [UILabel new];
    [paymentMethodTitleLabel setText:@"支付方式"];
    [self.paymentMethodView addSubview:paymentMethodTitleLabel];
    [paymentMethodTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.paymentMethodView);
        make.centerY.mas_equalTo(self.paymentMethodView);
    }];
    UIImageView *selectPaymentMethodImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"goto_detail"]];
    [self.paymentMethodView addSubview:selectPaymentMethodImageView];
    [selectPaymentMethodImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.paymentMethodView);
        make.right.mas_equalTo(self.paymentMethodView);
        make.size.mas_equalTo(CGSizeMake(15, 15));
    }];
    self.paymentMethodLabel = [UILabel new];
    self.paymentMethodType = 1;
    [self.paymentMethodLabel setText:@"支付宝"];
    [self.paymentMethodView addSubview:self.paymentMethodLabel];
    [self.paymentMethodLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.paymentMethodView);
        make.right.mas_equalTo(selectPaymentMethodImageView.mas_left).mas_offset(-10);
    }];
    // 添加点击事件
    UITapGestureRecognizer *paymentMethodSelectGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoPaymentMethodSelectAction)];
    [paymentMethodSelectGesture setNumberOfTapsRequired:1];
    [self.paymentMethodLabel setUserInteractionEnabled:YES];
    [self.paymentMethodLabel addGestureRecognizer:paymentMethodSelectGesture];
    
    UIView *divisionLineTwoView = [UIView new];
    [divisionLineTwoView setBackgroundColor:[UIColor grayColor]];
    [self.view addSubview:divisionLineTwoView];
    [divisionLineTwoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.paymentMethodView);
        make.right.mas_equalTo(self.paymentMethodView);
        make.top.mas_equalTo(self.paymentMethodView.mas_bottom).mas_offset(5);
        make.height.mas_equalTo(0.5);
    }];
    
    self.paymentLabel = [UILabel new];
    [self.paymentLabel setText:@"充值"];
    [self.paymentLabel setTextAlignment:NSTextAlignmentCenter];
    [self.paymentLabel setBackgroundColor:[UIColor orangeColor]];
    [self.paymentLabel setTextColor:[UIColor whiteColor]];
    [self.view addSubview:self.paymentLabel];
    [self.paymentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.rechargeBalanceView);
        make.right.mas_equalTo(self.rechargeBalanceView);
        make.bottom.mas_equalTo(self.view).mas_offset(-50);
        make.height.mas_equalTo(40);
    }];
    // 添加点击事件
    UITapGestureRecognizer *paymentGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoPaymentAction)];
    [paymentGesture setNumberOfTapsRequired:1];
    [self.paymentLabel setUserInteractionEnabled:YES];
    [self.paymentLabel addGestureRecognizer:paymentGesture];
}

@end
