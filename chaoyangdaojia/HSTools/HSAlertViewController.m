//
//  HSAlertViewController.m
//  chaoyangdaojia
//
//  Created by hestyle on 2021/1/24.
//  Copyright © 2021 hestyle. All rights reserved.
//

#import "HSAlertViewController.h"
#import <Masonry/Masonry.h>

@interface HSAlertViewController ()

@property (nonatomic, strong) UIView *contentView;

@end

@implementation HSAlertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [UIView animateWithDuration:0.1 animations:^{
        [self.view setBackgroundColor:[UIColor colorWithWhite:0.3 alpha:0.5f]];
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIView animateWithDuration:0.05 animations:^{
        [self.view setBackgroundColor:[UIColor clearColor]];
    }];
}

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message {
    self = [super init];
    [self initView];
    
    UILabel *titleLabel = [UILabel new];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setFont:[UIFont systemFontOfSize:[UIFont systemFontSize] + 2 weight:UIFontWeightSemibold]];
    [titleLabel setText:title];
    [self.contentView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.contentView);
        make.top.mas_equalTo(self.contentView).mas_offset(10);
        make.centerX.mas_equalTo(self.contentView);
    }];
    
    UILabel *messageLabel = [UILabel new];
    [messageLabel setTextAlignment:NSTextAlignmentCenter];
    [messageLabel setFont:[UIFont systemFontOfSize:[UIFont systemFontSize]]];
    [messageLabel setText:message];
    [self.contentView addSubview:messageLabel];
    [messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.contentView);
        make.top.mas_equalTo(titleLabel.mas_bottom).mas_offset(10);
        make.centerX.mas_equalTo(self.contentView);
    }];
    
    UIButton *sureButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [sureButton setTitle:@"确认" forState:UIControlStateNormal];
    [sureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sureButton setBackgroundColor:[UIColor orangeColor]];
    [sureButton addTarget:self action:@selector(processSure:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:sureButton];
    [sureButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(70, 35));
        make.centerX.mas_equalTo(self.contentView);
        make.top.mas_equalTo(messageLabel.mas_bottom).mas_offset(10);
        make.bottom.mas_equalTo(self.contentView).mas_offset(-10);
    }];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view.mas_bottom);
        make.centerX.mas_equalTo(self.view);
        make.width.mas_equalTo(self.view);
    }];
    
    [self addCloseIcon];
    
    return self;
}

- (instancetype)initWithCommonView:(UIView *)commonView {
    self = [super init];
    [self initView];
    
    [self.contentView addSubview:commonView];
    [commonView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).mas_offset(10);
        make.bottom.mas_equalTo(self.contentView).mas_offset(-10);
        make.centerX.mas_equalTo(self.contentView);
    }];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view.mas_bottom);
        make.centerX.mas_equalTo(self.view);
        make.width.mas_equalTo(self.view);
    }];
    
    [self addCloseIcon];
    return self;
}

- (void)initView {
    [self.view setFrame:[UIScreen mainScreen].bounds];
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    self.contentView = [UIView new];
    [self.contentView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.contentView];
}

- (void)addCloseIcon {
    UIImageView *closeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"close_icon"]];
    [self.contentView addSubview:closeImageView];
    [closeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(20, 20));
        make.top.mas_equalTo(self.contentView).mas_offset(10);
        make.right.mas_equalTo(self.contentView).mas_offset(-10);
    }];
    // 添加点击事件
    UITapGestureRecognizer *closeTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    [closeTapGesture setNumberOfTapsRequired:1];
    [closeImageView setUserInteractionEnabled:YES];
    [closeImageView addGestureRecognizer:closeTapGesture];
}

- (void)processSure:(UIButton *)sender {
    [self dismiss];
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
