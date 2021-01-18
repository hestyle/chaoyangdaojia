//
//  HSExchangeBalanceViewController.m
//  chaoyangdaojia
//
//  Created by hestyle on 2021/1/12.
//  Copyright © 2021 hestyle. All rights reserved.
//

#import "HSExchangeBalanceViewController.h"
#import "HSNetwork.h"
#import <Masonry/Masonry.h>
#import <Toast/Toast.h>

@interface HSExchangeBalanceViewController ()

@property (nonatomic, strong) NSArray* exchangeBalanceArray;
@property (nonatomic, strong) NSArray* exchangeBalanceViewArray;
@property (nonatomic) NSInteger beforeSelectIndex;
@property (nonatomic, strong) UIButton *exchangeButton;

@end

static UIColor * noSelectTextColor;

@implementation HSExchangeBalanceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    self.beforeSelectIndex = -1;
    noSelectTextColor = [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1.0];
    [self getExchangeBalanceList];
    
    self.exchangeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.exchangeButton setTitle:@"立即兑换" forState:UIControlStateNormal];
    [self.exchangeButton setTitle:@"" forState:UIControlStateHighlighted];
    [self.exchangeButton setBackgroundColor:[UIColor redColor]];
    [self.exchangeButton.layer setCornerRadius:5.f];
    [self.exchangeButton addTarget:self action:@selector(exchangeAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.exchangeButton];
    [self.exchangeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(200, 40));
        make.centerX.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view).mas_offset(-50);
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setTitle:@"兑换余额"];
    [self.navigationController setNavigationBarHidden:NO];
}

#pragma mark - Event
- (void)selectExchangeBalanceView:(UITapGestureRecognizer *)sender {
    NSInteger selectIndex = sender.view.tag;
    if (self.beforeSelectIndex != -1) {
        NSDictionary *beforeSelectViewDict = self.exchangeBalanceViewArray[self.beforeSelectIndex];
        UIView *beforeSelectView = beforeSelectViewDict[@"exchangeBalanceView"];
        UILabel *moneyLabel = beforeSelectViewDict[@"moneyLabel"];
        UILabel *scoreLabel = beforeSelectViewDict[@"scoreLabel"];
        [beforeSelectView.layer setShadowOpacity:0.2];
        [beforeSelectView setBackgroundColor:[UIColor whiteColor]];
        [moneyLabel setTextColor:noSelectTextColor];
        [scoreLabel setTextColor:noSelectTextColor];
    }
    self.beforeSelectIndex = selectIndex;
    NSDictionary *selectViewDict = self.exchangeBalanceViewArray[selectIndex];
    UIView *selectView = selectViewDict[@"exchangeBalanceView"];
    UILabel *moneyLabel = selectViewDict[@"moneyLabel"];
    UILabel *scoreLabel = selectViewDict[@"scoreLabel"];
    [selectView.layer setShadowOpacity:0.6];
    [selectView setBackgroundColor:[UIColor colorWithRed:254/255.0 green:247/255.0 blue:245/255.0 alpha:1.0]];
    [moneyLabel setTextColor:[UIColor redColor]];
    [scoreLabel setTextColor:[UIColor redColor]];
}

- (void)exchangeAction {
    if (self.beforeSelectIndex == -1) {
        [self.view makeToast:@"请选择兑换的金额！" duration:3.f position:CSToastPositionCenter];
        return;
    }
    NSInteger exchangeMoney = [self.exchangeBalanceArray[self.beforeSelectIndex][@"money"] integerValue];
    NSDictionary *paramters = @{@"money":@(exchangeMoney)};
    HSNetworkManager *manager = [HSNetworkManager shareManager];
    __weak __typeof__(self) weakSelf = self;
    [manager postDataWithUrl:kExchangeMoneyUrl parameters:@{@"data":paramters} success:^(NSDictionary *responseDict) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // 提示验证码是否获取成功
            if ([[responseDict allKeys] containsObject:@"msg"]) {
                [weakSelf.view makeToast:responseDict[@"msg"] duration:3 position:CSToastPositionCenter];
            } else {
                [weakSelf.view makeToast:responseDict[@"接口返回数据格式错误！"] duration:3 position:CSToastPositionCenter];
            }
            NSLog(@"接口 %@ 返回数据responseDict = %@", kSetPayPassword, responseDict);
        });
        if ([responseDict[@"errcode"] isEqual:@(0)]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.8 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [weakSelf.navigationController popViewControllerAnimated:YES];
            });
        }
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.view makeToast:@"接口请求错误！"];
        });
        NSLog(@"%@", error);
    }];
}

#pragma mark - Private
- (void)getExchangeBalanceList {
    HSNetworkManager *manager = [HSNetworkManager shareManager];
    __weak __typeof__(self) weakSelf = self;
    [manager getDataWithUrl:kGetExchangeBalanceList parameters:@{} success:^(NSDictionary *responseDict) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (![responseDict[@"errcode"] isEqual:@(0)]) {
                [weakSelf.view makeToast:@"接口请求错误！" duration:3.f position:CSToastPositionCenter];
            } else {
                weakSelf.exchangeBalanceArray = responseDict[@"listData"];
                [weakSelf initExchangeBalanceView];
            }
        });
        NSLog(@"接口 %@ 返回数据 responseDict = %@", kGetExchangeBalanceList, responseDict);
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.view makeToast:@"接口请求错误！" duration:3.f position:CSToastPositionCenter];
        });
        NSLog(@"%@", error);
    }];
}

- (void)initExchangeBalanceView {
    if (self.exchangeBalanceArray == nil) {
        return;
    }
    NSMutableArray *viewArray = [NSMutableArray new];
    CGFloat viewWidth = (self.view.bounds.size.width - 20 * 4) / 3.0;
    for (int i = 0; i < [self.exchangeBalanceArray count]; ++i) {
        NSDictionary *exchangeBalanceDataDict = self.exchangeBalanceArray[i];
        UIView *exchangeBalanceView = [UIView new];
        [self.view addSubview:exchangeBalanceView];
        CGFloat exchangeBalanceViewLeft = 20.0 + (i % 3) * (viewWidth + 20.0);
        CGFloat exchangeBalanceViewTop = 20.0 + (i / 3) * (60.0 + 20);
        [exchangeBalanceView setBackgroundColor:[UIColor whiteColor]];
        [exchangeBalanceView.layer setCornerRadius:5];
        [exchangeBalanceView.layer setShadowRadius:5];
        [exchangeBalanceView.layer setShadowOpacity:0.2];
        [exchangeBalanceView.layer setShadowOffset:CGSizeMake(3, 6)];
        [exchangeBalanceView.layer setShadowColor:[[UIColor blackColor] CGColor]];
        [exchangeBalanceView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.view).mas_offset(exchangeBalanceViewLeft);
            make.top.mas_equalTo(self.view).mas_offset(exchangeBalanceViewTop);
            make.size.mas_equalTo(CGSizeMake(viewWidth, 60));
        }];
        [exchangeBalanceView setTag:i];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectExchangeBalanceView:)];
        [tapGesture setNumberOfTapsRequired:1];
        [exchangeBalanceView setUserInteractionEnabled:YES];
        [exchangeBalanceView addGestureRecognizer:tapGesture];
        
        UILabel *moneyLabel = [UILabel new];
        [moneyLabel setTextColor:noSelectTextColor];
        [moneyLabel setText:[NSString stringWithFormat:@"%@元", exchangeBalanceDataDict[@"money"]]];
        [exchangeBalanceView addSubview:moneyLabel];
        [moneyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(exchangeBalanceView);
            make.top.mas_equalTo(exchangeBalanceView).mas_offset(10);
        }];
        UILabel *scoreLabel = [UILabel new];
        [scoreLabel setTextColor:noSelectTextColor];
        [scoreLabel setText:[NSString stringWithFormat:@"%@积分可兑换", exchangeBalanceDataDict[@"score"]]];
        [scoreLabel setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];
        [exchangeBalanceView addSubview:scoreLabel];
        [scoreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(exchangeBalanceView);
            make.bottom.mas_equalTo(exchangeBalanceView).mas_offset(-10);
        }];
        
        [viewArray addObject:@{@"exchangeBalanceView":exchangeBalanceView, @"moneyLabel":moneyLabel, @"scoreLabel":scoreLabel}];
    }
    self.exchangeBalanceViewArray = [viewArray copy];
}
@end
