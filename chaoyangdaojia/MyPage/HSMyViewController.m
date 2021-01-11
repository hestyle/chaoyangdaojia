//
//  HSMyViewController.m
//  chaoyangdaojia
//
//  Created by hestyle on 2020/12/24.
//  Copyright © 2020 hestyle. All rights reserved.
//

#import "HSMyViewController.h"
#import "HSLoginViewController.h"
#import "HSMyDetailTableViewController.h"
#import "HSSettingsTableViewController.h"
#import "HSNetwork.h"
#import "HSAccount.h"
#import <Toast/Toast.h>
#import <Masonry/Masonry.h>

@interface HSMyViewController ()

@property (nonatomic, strong) UIScrollView *contentScrollView;
@property (nonatomic, strong) UIView *refreshView;
@property (nonatomic, strong) UIImageView *refreshImageView;
@property (nonatomic, strong) UILabel *refreshLabel;
@property (nonatomic, strong) UILabel *lastRefreshTimeLabel;

@property (nonatomic, strong) UIView *accountInfoView;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *usernameLabel;
@property (nonatomic, strong) UILabel *scoreTitleLabel;
@property (nonatomic, strong) UILabel *scoreLabel;
@property (nonatomic, strong) UILabel *authenticationLabel;

@property (nonatomic, strong) UIView *orderInfoView;
@property (nonatomic, strong) UILabel *myOrderTitleLabel;
@property (nonatomic, strong) UILabel *myAllOrderLabel;
@property (nonatomic, strong) UIImageView *orderTobePaidImageView;
@property (nonatomic, strong) UIImageView *orderTobeReceivedImageView;
@property (nonatomic, strong) UIImageView *orderTobeEvaluatedImageView;
@property (nonatomic, strong) UIImageView *orderHadCancelledImageView;
@property (nonatomic, strong) UIImageView *orderAfterSaleImageView;

@property (nonatomic, strong) UIView *myCollectionView;
@property (nonatomic, strong) UILabel *myCollectionTitleLabel;
@property (nonatomic, strong) UIView *myEvaluationView;
@property (nonatomic, strong) UILabel *myEvaluationTitleLabel;
@property (nonatomic, strong) UIView *myCroupWorkView;
@property (nonatomic, strong) UILabel *myCroupWorkTitleLabel;
@property (nonatomic, strong) UIView *myWalletView;
@property (nonatomic, strong) UILabel *myWalletTitleLabel;
@property (nonatomic, strong) UIView *myCouponView;
@property (nonatomic, strong) UILabel *myCouponTitleLabel;
@property (nonatomic, strong) UIView *myDeliveryAddressView;
@property (nonatomic, strong) UILabel *myDeliveryAddressTitleLabel;


@property (nonatomic, strong) UIView *businessEntryView;
@property (nonatomic, strong) UILabel *businessEntryTitleLabel;
@property (nonatomic, strong) UIView *electronicInvoiceView;
@property (nonatomic, strong) UILabel *electronicInvoiceTitleLabel;
@property (nonatomic, strong) UIView *merchantPaymentView;
@property (nonatomic, strong) UILabel *merchantPaymentTitleLabel;
@property (nonatomic, strong) UIView *onlineServiceView;
@property (nonatomic, strong) UILabel *onlineServiceTitleLabel;

@property (nonatomic, strong) UIBarButtonItem *leftSettingButtonItem;
@property (nonatomic, strong) UIBarButtonItem *rightMessageButtonItem;

@end

static const NSInteger mRefreshViewHeight = 60;
/* navigationBar高度44、状态栏（狗啃屏）高度44，contentInsetAdjustmentBehavior */
static const NSInteger mTableViewBaseContentOffsetY = -88;
/* 当前页面只有登录了才能显示，没登录就跳转到登录，需要防止从登录页面（未登录）状态下返回此页面 */
static BOOL isHadGotoLoginViewController = NO;

@implementation HSMyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    // 绘制view
    [self initView];
}

- (void)initView{
    self.contentScrollView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.contentScrollView setDelegate:self];
    [self.contentScrollView setBackgroundColor:[UIColor grayColor]];
    [self.contentScrollView setContentSize:CGSizeMake(0, [UIScreen mainScreen].bounds.size.height)];
    [self.view addSubview:self.contentScrollView];
    
    self.refreshView = [UIView new];
    [self.refreshView setTag:0];
    [self.contentScrollView addSubview:self.refreshView];
    [self.refreshView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentScrollView.mas_top).with.offset(-mRefreshViewHeight);
        make.centerX.mas_equalTo(self.contentScrollView.mas_centerX);
        make.width.mas_equalTo([UIScreen mainScreen].bounds.size.width);
        make.height.mas_equalTo(mRefreshViewHeight);
    }];
    
    self.refreshLabel = [UILabel new];
    [self.refreshLabel setTextAlignment:NSTextAlignmentCenter];
    [self.refreshLabel setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];
    [self.refreshView addSubview:self.refreshLabel];
    [self.refreshLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.refreshView.mas_top).with.offset(7.5);
        make.centerX.mas_equalTo(self.refreshView.mas_centerX).with.offset(10);
        make.size.mas_equalTo(CGSizeMake(100, 20));
    }];
    
    self.lastRefreshTimeLabel = [UILabel new];
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    // 获取当前时间日期展示字符串 如：2019-05-23-13:58:59
    [self.lastRefreshTimeLabel setText:[NSString stringWithFormat:@"最后更新: %@", [formatter stringFromDate:date]]];
    [self.lastRefreshTimeLabel setTextAlignment:NSTextAlignmentCenter];
    [self.lastRefreshTimeLabel setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];
    [self.refreshView addSubview:self.lastRefreshTimeLabel];
    [self.lastRefreshTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.refreshLabel.mas_bottom).with.offset(2.5);
        make.centerX.mas_equalTo(self.contentScrollView.mas_centerX).with.offset(10);
        make.size.mas_equalTo(CGSizeMake(180, 20));
    }];

    self.refreshImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"refresh_arrow"]];
    [self.refreshView addSubview:self.refreshImageView];
    [self.refreshImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.lastRefreshTimeLabel.mas_left).with.offset(-20);
        make.centerY.mas_equalTo(self.refreshView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(30, 50));
    }];
    
    // 初始化navigationBar
    [self initNavigationBar];
    // 初始化accountView
    [self initAccountView];
    // 初始化orderView
    [self initOrderView];
    // 初始化myFunctionView
    [self initMyFunctionView];
}

- (void)viewWillAppear:(BOOL)animated {
    // 显示两侧的tabBar按钮
    [self.navigationController setNavigationBarHidden:NO];
    [self.tabBarController setTitle:@"我的"];
    [self.tabBarController.navigationItem setLeftBarButtonItem:self.leftSettingButtonItem];
    [self.tabBarController.navigationItem setRightBarButtonItem:self.rightMessageButtonItem];
    
    [self getUserInfo];
}

- (void)viewWillDisappear:(BOOL)animated {
    // 移除tabBarController两侧的按钮
    [self.tabBarController.navigationItem setLeftBarButtonItem:nil];
    [self.tabBarController.navigationItem setRightBarButtonItem:nil];
}

#pragma mark - UIScrollView Delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.y <= (mTableViewBaseContentOffsetY - mRefreshViewHeight)) {
        if (self.refreshView.tag == 0) {
            self.refreshLabel.text = @"松开刷新";
        }
        self.refreshView.tag = 1;
    } else {
        //防止用户在下拉到contentOffset.y <= -50后不松手，然后又往回滑动，需要将值设为默认状态
        self.refreshView.tag = 0;
        self.refreshLabel.text = @"下拉刷新";
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    if (self.refreshView.tag == 1) {
        [UIView animateWithDuration:.3 animations:^{
            self.refreshLabel.text = @"加载中";
            scrollView.contentInset = UIEdgeInsetsMake(mRefreshViewHeight, 0.0f, 0.0f, 0.0f);
        }];
        // 重新访问账号信息
        [self refreshUserInfo];
        //数据加载成功后执行；这里为了模拟加载效果，一秒后执行恢复原状代码
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:.3 animations:^{
                self.refreshView.tag = 0;
                self.refreshLabel.text = @"下拉刷新";
                scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
            }];
        });
    }
}

#pragma mark - Event
- (void)gotoMyDetail {
    HSMyDetailTableViewController *controller = [[HSMyDetailTableViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Private
- (void)refreshUserInfo {
    HSUserAccountManger *userAccoutManager = [HSUserAccountManger shareManager];
    [userAccoutManager refreshUserInfoFromNetWork];
    __weak __typeof__(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [weakSelf getUserInfo];
    });
}

- (void)getUserInfo {
    // 访问getinfo接口
    HSUserAccountManger *userAccoutManager = [HSUserAccountManger shareManager];
    if (!userAccoutManager.isLogin) {
        // 未登录
        if (!isHadGotoLoginViewController) {
            // 之前未到登录页面，则直接跳转到登录页面
            HSLoginViewController *loginViewController = [HSLoginViewController new];
            [self.navigationController pushViewController:loginViewController animated:YES];
            isHadGotoLoginViewController = YES;
        } else {
            // 之前已到登录页面，跳转到首页
            isHadGotoLoginViewController = NO;
            [self.tabBarController setSelectedIndex:0];
        }
        return;
    }
    // 设置用户名、积分
    NSDictionary *userInfoDict = userAccoutManager.userInfoDict;
    if (userInfoDict != nil) {
        [self.usernameLabel setText:userInfoDict[@"nickname"]];
        [self.scoreLabel setText:[NSString stringWithFormat:@"%@", userInfoDict[@"lscore"]]];
        // 是否实名认证
        if ([userInfoDict[@"isrenzheng"] isEqual:@(0)]) {
            [self.authenticationLabel setText:@"未实名认证 >"];
        } else {
            [self.authenticationLabel setText:@"已实名认证 >"];
        }
    }
    // 设置用户头像
    if (userAccoutManager.avatarPath != nil) {
        NSString *path_sandox = NSHomeDirectory();
        NSString *avatarPath = [path_sandox stringByAppendingPathComponent:userAccoutManager.avatarPath];
        UIImage *avatarImage = [UIImage imageWithContentsOfFile:avatarPath];
        [self.avatarImageView setImage:avatarImage];
    } else {
        // 设置默认头像
        [self.avatarImageView setImage:[UIImage imageNamed:@"noavatar"]];
    }
}

- (void)initNavigationBar{
    self.leftSettingButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"app_setting"] style:UIBarButtonItemStyleDone target:self action:@selector(gotoSettingsViewController)];
    [self.tabBarController.navigationItem setLeftBarButtonItem:self.leftSettingButtonItem];
    
    UIImageView *rightMessageImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [rightMessageImageView setImage:[UIImage imageNamed:@"app_message"]];
    self.rightMessageButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightMessageImageView];
    [self.tabBarController.navigationItem setRightBarButtonItem:self.rightMessageButtonItem];
}

- (void)initAccountView {
    // 账号信息
    self.accountInfoView = [UIView new];
    [self.accountInfoView setBackgroundColor:[UIColor whiteColor]];
    [self.contentScrollView addSubview:self.accountInfoView];
    [self.accountInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.refreshView.mas_bottom);
        make.centerX.mas_equalTo(self.contentScrollView.mas_centerX);
        make.width.mas_equalTo([UIScreen mainScreen].bounds.size.width);
        make.height.mas_equalTo(80);
    }];
    // 添加点击事件
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoMyDetail)];
    [tapGesture setNumberOfTapsRequired:1];
    [self.accountInfoView setUserInteractionEnabled:YES];
    [self.accountInfoView addGestureRecognizer:tapGesture];
    
    self.avatarImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noavatar"]];
    [self.accountInfoView addSubview:self.avatarImageView];
    [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.accountInfoView.mas_centerY);
        make.left.mas_equalTo(self.accountInfoView.mas_left).with.offset(20);
        make.size.mas_equalTo(CGSizeMake(55, 55));
    }];
    
    self.usernameLabel = [UILabel new];
    [self.usernameLabel setText:@""];
    [self.usernameLabel setFont:[UIFont systemFontOfSize:[UIFont systemFontSize] + 6]];
    [self.accountInfoView addSubview:self.usernameLabel];
    [self.usernameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.avatarImageView);
        make.left.mas_equalTo(self.avatarImageView.mas_right).with.offset(10);
        make.size.mas_equalTo(CGSizeMake(200, 25));
    }];
    
    self.scoreTitleLabel = [UILabel new];
    [self.scoreTitleLabel setText:@"积分："];
    [self.accountInfoView addSubview:self.scoreTitleLabel];
    [self.scoreTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.avatarImageView.mas_bottom);
        make.left.mas_equalTo(self.usernameLabel);
        make.size.mas_equalTo(CGSizeMake(50, 20));
    }];
    
    self.scoreLabel = [UILabel new];
    [self.scoreLabel setText:@"0"];
    [self.accountInfoView addSubview:self.scoreLabel];
    [self.scoreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.scoreTitleLabel);
        make.left.mas_equalTo(self.scoreTitleLabel.mas_right);
        make.size.mas_equalTo(CGSizeMake(100, 20));
    }];
    
    self.authenticationLabel = [UILabel new];
    [self.authenticationLabel setText:@"未实名认证 >"];
    [self.authenticationLabel setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];
    [self.authenticationLabel setTextAlignment:NSTextAlignmentRight];
    [self.accountInfoView addSubview:self.authenticationLabel];
    [self.authenticationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.accountInfoView.mas_centerY);
        make.right.mas_equalTo(self.accountInfoView.mas_right).with.offset(-20);
        make.size.mas_equalTo(CGSizeMake(110, 20));
    }];
}

- (void)initOrderView {
    CGFloat mainWidth = [UIScreen mainScreen].bounds.size.width;
    // 订单信息
    self.orderInfoView = [UIView new];
    [self.orderInfoView setBackgroundColor:[UIColor whiteColor]];
    [self.contentScrollView addSubview:self.orderInfoView];
    [self.orderInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.accountInfoView.mas_bottom).with.offset(10);
        make.centerX.mas_equalTo(self.contentScrollView.mas_centerX);
        make.width.mas_equalTo(mainWidth);
        make.height.mas_equalTo(122.5);
    }];
    
    self.myOrderTitleLabel = [UILabel new];
    [self.myOrderTitleLabel setText:@"我的订单"];
    [self.orderInfoView addSubview:self.myOrderTitleLabel];
    [self.myOrderTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.orderInfoView.mas_top).with.offset(12.5);
        make.left.mas_equalTo(self.orderInfoView.mas_left).with.offset(20);
        make.size.mas_equalTo(CGSizeMake(100, 20));
    }];
    self.myAllOrderLabel = [UILabel new];
    [self.myAllOrderLabel setText:@"全部订单 >"];
    [self.myAllOrderLabel setTextAlignment:NSTextAlignmentRight];
    [self.myAllOrderLabel setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];
    [self.orderInfoView addSubview:self.myAllOrderLabel];
    [self.myAllOrderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.orderInfoView.mas_top).with.offset(15);
        make.right.mas_equalTo(self.orderInfoView.mas_right).with.offset(-20);
        make.size.mas_equalTo(CGSizeMake(100, 20));
    }];
    
    self.orderTobePaidImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"order_tobe_paid"]];
    [self.orderInfoView addSubview:self.orderTobePaidImageView];
    [self.orderTobePaidImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.myOrderTitleLabel.mas_bottom).with.offset(7.5);
        make.left.mas_equalTo(self.orderInfoView.mas_left).with.offset(30);
        make.size.mas_equalTo(CGSizeMake(45, 45));
    }];
    UILabel *tobePaidOrderTitle = [UILabel new];
    [tobePaidOrderTitle setText:@"待付款"];
    [tobePaidOrderTitle setTextAlignment:NSTextAlignmentCenter];
    [tobePaidOrderTitle setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];
    [self.orderInfoView addSubview:tobePaidOrderTitle];
    [tobePaidOrderTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.orderTobePaidImageView);
        make.top.mas_equalTo(self.orderTobePaidImageView.mas_bottom).with.offset(5);
        make.size.mas_equalTo(CGSizeMake(50, 18));
    }];
    
    // 五个order图标间距 屏幕宽度 - (最左、最右屏幕间距) - (5张图片宽度)
    CGFloat imageDistance = (mainWidth - 60 - 45 * 5) / 4;
    
    self.orderTobeReceivedImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"order_tobe_received"]];
    [self.orderInfoView addSubview:self.orderTobeReceivedImageView];
    [self.orderTobeReceivedImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.orderTobePaidImageView);
        make.left.mas_equalTo(self.orderTobePaidImageView.mas_right).with.offset(imageDistance);
        make.size.mas_equalTo(CGSizeMake(45, 45));
    }];
    UILabel *tobeReceivedOrderTitle = [UILabel new];
    [tobeReceivedOrderTitle setText:@"待收货"];
    [tobeReceivedOrderTitle setTextAlignment:NSTextAlignmentCenter];
    [tobeReceivedOrderTitle setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];
    [self.orderInfoView addSubview:tobeReceivedOrderTitle];
    [tobeReceivedOrderTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.orderTobeReceivedImageView);
        make.top.mas_equalTo(self.orderTobeReceivedImageView.mas_bottom).with.offset(5);
        make.size.mas_equalTo(CGSizeMake(50, 18));
    }];
    
    self.orderTobeEvaluatedImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"order_tobe_evaluated"]];
    [self.orderInfoView addSubview:self.orderTobeEvaluatedImageView];
    [self.orderTobeEvaluatedImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.orderTobeReceivedImageView);
        make.left.mas_equalTo(self.orderTobeReceivedImageView.mas_right).with.offset(imageDistance);
        make.size.mas_equalTo(CGSizeMake(45, 45));
    }];
    UILabel *tobeEvaluatedOrderTitle = [UILabel new];
    [tobeEvaluatedOrderTitle setText:@"待评价"];
    [tobeEvaluatedOrderTitle setTextAlignment:NSTextAlignmentCenter];
    [tobeEvaluatedOrderTitle setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];
    [self.orderInfoView addSubview:tobeEvaluatedOrderTitle];
    [tobeEvaluatedOrderTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.orderTobeEvaluatedImageView);
        make.top.mas_equalTo(self.orderTobeEvaluatedImageView.mas_bottom).with.offset(5);
        make.size.mas_equalTo(CGSizeMake(50, 18));
    }];
    
    self.orderHadCancelledImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"order_had_cancelled"]];
    [self.orderInfoView addSubview:self.orderHadCancelledImageView];
    [self.orderHadCancelledImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.orderTobeEvaluatedImageView);
        make.left.mas_equalTo(self.orderTobeEvaluatedImageView.mas_right).with.offset(imageDistance);
        make.size.mas_equalTo(CGSizeMake(45, 45));
    }];
    UILabel *hadCancelledOrderTitle = [UILabel new];
    [hadCancelledOrderTitle setText:@"已取消"];
    [hadCancelledOrderTitle setTextAlignment:NSTextAlignmentCenter];
    [hadCancelledOrderTitle setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];
    [self.orderInfoView addSubview:hadCancelledOrderTitle];
    [hadCancelledOrderTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.orderHadCancelledImageView);
        make.top.mas_equalTo(self.orderHadCancelledImageView.mas_bottom).with.offset(5);
        make.size.mas_equalTo(CGSizeMake(50, 18));
    }];
    
    self.orderAfterSaleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"order_after_sale"]];
    [self.orderInfoView addSubview:self.orderAfterSaleImageView];
    [self.orderAfterSaleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.orderHadCancelledImageView);
        make.left.mas_equalTo(self.orderHadCancelledImageView.mas_right).with.offset(imageDistance);
        make.size.mas_equalTo(CGSizeMake(45, 45));
    }];
    UILabel *afterSaleOrderTitle = [UILabel new];
    [afterSaleOrderTitle setText:@"售后/退款"];
    [afterSaleOrderTitle setTextAlignment:NSTextAlignmentCenter];
    [afterSaleOrderTitle setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];
    [self.orderInfoView addSubview:afterSaleOrderTitle];
    [afterSaleOrderTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.orderAfterSaleImageView);
        make.top.mas_equalTo(self.orderAfterSaleImageView.mas_bottom).with.offset(5);
        make.size.mas_equalTo(CGSizeMake(70, 18));
    }];
}

- (void)initMyFunctionView {
    CGFloat mainWidth = [UIScreen mainScreen].bounds.size.width;
    UIImage *gotoDetailImage = [UIImage imageNamed:@"goto_detail"];
    
    // 我的收藏
    self.myCollectionView = [UIView new];
    [self.myCollectionView setBackgroundColor:[UIColor whiteColor]];
    [self.contentScrollView addSubview:self.myCollectionView];
    [self.myCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.orderInfoView.mas_bottom).with.offset(10);
        make.centerX.mas_equalTo(self.contentScrollView.mas_centerX);
        make.width.mas_equalTo(mainWidth);
        make.height.mas_equalTo(50);
    }];
    self.myCollectionTitleLabel = [UILabel new];
    [self.myCollectionTitleLabel setText:@"我的收藏"];
    [self.myCollectionView addSubview:self.myCollectionTitleLabel];
    [self.myCollectionTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.myCollectionView);
        make.left.mas_equalTo(self.myCollectionView.mas_left).offset(20);
        make.size.mas_equalTo(CGSizeMake(80, 25));
    }];
    UIImageView *gotoMyCollectionImageView = [[UIImageView alloc] initWithImage:gotoDetailImage];
    [self.myCollectionView addSubview:gotoMyCollectionImageView];
    [gotoMyCollectionImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.myCollectionView);
        make.right.mas_equalTo(self.myCollectionView.mas_right).offset(-20);
        make.size.mas_equalTo(CGSizeMake(15, 15));
    }];
    
    // 我的评价
    self.myEvaluationView = [UIView new];
    [self.myEvaluationView setBackgroundColor:[UIColor whiteColor]];
    [self.contentScrollView addSubview:self.myEvaluationView];
    [self.myEvaluationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.myCollectionView.mas_bottom).with.offset(1);
        make.centerX.mas_equalTo(self.contentScrollView.mas_centerX);
        make.width.mas_equalTo(mainWidth);
        make.height.mas_equalTo(50);
    }];
    self.myEvaluationTitleLabel = [UILabel new];
    [self.myEvaluationTitleLabel setText:@"我的评价"];
    [self.myEvaluationView addSubview:self.myEvaluationTitleLabel];
    [self.myEvaluationTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.myEvaluationView);
        make.left.mas_equalTo(self.myEvaluationView.mas_left).offset(20);
        make.size.mas_equalTo(CGSizeMake(80, 25));
    }];
    UIImageView *gotoMyEvaluationImageView = [[UIImageView alloc] initWithImage:gotoDetailImage];
    [self.myEvaluationView addSubview:gotoMyEvaluationImageView];
    [gotoMyEvaluationImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.myEvaluationView);
        make.right.mas_equalTo(self.myEvaluationView.mas_right).offset(-20);
        make.size.mas_equalTo(CGSizeMake(15, 15));
    }];
    
    // 我的拼团
    self.myCroupWorkView = [UIView new];
    [self.myCroupWorkView setBackgroundColor:[UIColor whiteColor]];
    [self.contentScrollView addSubview:self.myCroupWorkView];
    [self.myCroupWorkView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.myEvaluationView.mas_bottom).with.offset(1);
        make.centerX.mas_equalTo(self.contentScrollView.mas_centerX);
        make.width.mas_equalTo(mainWidth);
        make.height.mas_equalTo(50);
    }];
    self.myEvaluationTitleLabel = [UILabel new];
    [self.myEvaluationTitleLabel setText:@"我的拼团"];
    [self.myCroupWorkView addSubview:self.myEvaluationTitleLabel];
    [self.myEvaluationTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.myCroupWorkView);
        make.left.mas_equalTo(self.myCroupWorkView.mas_left).offset(20);
        make.size.mas_equalTo(CGSizeMake(80, 25));
    }];
    UIImageView *gotoMyCroupWorkImageView = [[UIImageView alloc] initWithImage:gotoDetailImage];
    [self.myCroupWorkView addSubview:gotoMyCroupWorkImageView];
    [gotoMyCroupWorkImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.myCroupWorkView);
        make.right.mas_equalTo(self.myCroupWorkView.mas_right).offset(-20);
        make.size.mas_equalTo(CGSizeMake(15, 15));
    }];
    
    // 我的钱包
    self.myWalletView = [UIView new];
    [self.myWalletView setBackgroundColor:[UIColor whiteColor]];
    [self.contentScrollView addSubview:self.myWalletView];
    [self.myWalletView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.myCroupWorkView.mas_bottom).with.offset(1);
        make.centerX.mas_equalTo(self.contentScrollView.mas_centerX);
        make.width.mas_equalTo(mainWidth);
        make.height.mas_equalTo(50);
    }];
    self.myWalletTitleLabel = [UILabel new];
    [self.myWalletTitleLabel setText:@"我的钱包"];
    [self.myWalletView addSubview:self.myWalletTitleLabel];
    [self.myWalletTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.myWalletView);
        make.left.mas_equalTo(self.myWalletView.mas_left).offset(20);
        make.size.mas_equalTo(CGSizeMake(80, 25));
    }];
    UIImageView *gotoMyWalletImageView = [[UIImageView alloc] initWithImage:gotoDetailImage];
    [self.myWalletView addSubview:gotoMyWalletImageView];
    [gotoMyWalletImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.myWalletView);
        make.right.mas_equalTo(self.myWalletView.mas_right).offset(-20);
        make.size.mas_equalTo(CGSizeMake(15, 15));
    }];
    
    // 我的优惠券
    self.myCouponView = [UIView new];
    [self.myCouponView setBackgroundColor:[UIColor whiteColor]];
    [self.contentScrollView addSubview:self.myCouponView];
    [self.myCouponView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.myWalletView.mas_bottom).with.offset(1);
        make.centerX.mas_equalTo(self.contentScrollView.mas_centerX);
        make.width.mas_equalTo(mainWidth);
        make.height.mas_equalTo(50);
    }];
    self.myCouponTitleLabel = [UILabel new];
    [self.myCouponTitleLabel setText:@"我的优惠券"];
    [self.myCouponView addSubview:self.myCouponTitleLabel];
    [self.myCouponTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.myCouponView);
        make.left.mas_equalTo(self.myCouponView.mas_left).offset(20);
        make.size.mas_equalTo(CGSizeMake(100, 25));
    }];
    UIImageView *gotoMyCouponImageView = [[UIImageView alloc] initWithImage:gotoDetailImage];
    [self.myCouponView addSubview:gotoMyCouponImageView];
    [gotoMyCouponImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.myCouponView);
        make.right.mas_equalTo(self.myCouponView.mas_right).offset(-20);
        make.size.mas_equalTo(CGSizeMake(15, 15));
    }];
    
    // 我的收货地址
    self.myDeliveryAddressView = [UIView new];
    [self.myDeliveryAddressView setBackgroundColor:[UIColor whiteColor]];
    [self.contentScrollView addSubview:self.myDeliveryAddressView];
    [self.myDeliveryAddressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.myCouponView.mas_bottom).with.offset(1);
        make.centerX.mas_equalTo(self.contentScrollView.mas_centerX);
        make.width.mas_equalTo(mainWidth);
        make.height.mas_equalTo(50);
    }];
    self.myDeliveryAddressTitleLabel = [UILabel new];
    [self.myDeliveryAddressTitleLabel setText:@"我的收货地址"];
    [self.myDeliveryAddressView addSubview:self.myDeliveryAddressTitleLabel];
    [self.myDeliveryAddressTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.myDeliveryAddressView);
        make.left.mas_equalTo(self.myDeliveryAddressView.mas_left).offset(20);
        make.size.mas_equalTo(CGSizeMake(110, 25));
    }];
    UIImageView *gotoMyDeliveryAddressImageView = [[UIImageView alloc] initWithImage:gotoDetailImage];
    [self.myDeliveryAddressView addSubview:gotoMyDeliveryAddressImageView];
    [gotoMyDeliveryAddressImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.myDeliveryAddressView);
        make.right.mas_equalTo(self.myDeliveryAddressView.mas_right).offset(-20);
        make.size.mas_equalTo(CGSizeMake(15, 15));
    }];
    
    // 电子发票
    self.electronicInvoiceView = [UIView new];
    [self.electronicInvoiceView setBackgroundColor:[UIColor whiteColor]];
    [self.contentScrollView addSubview:self.electronicInvoiceView];
    [self.electronicInvoiceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.myDeliveryAddressView.mas_bottom).with.offset(10);
        make.centerX.mas_equalTo(self.contentScrollView.mas_centerX);
        make.width.mas_equalTo(mainWidth);
        make.height.mas_equalTo(50);
    }];
    self.electronicInvoiceTitleLabel = [UILabel new];
    [self.electronicInvoiceTitleLabel setText:@"电子发票"];
    [self.electronicInvoiceView addSubview:self.electronicInvoiceTitleLabel];
    [self.electronicInvoiceTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.electronicInvoiceView);
        make.left.mas_equalTo(self.electronicInvoiceView.mas_left).offset(20);
        make.size.mas_equalTo(CGSizeMake(80, 25));
    }];
    UIImageView *gotoElectronicInvoiceImageView = [[UIImageView alloc] initWithImage:gotoDetailImage];
    [self.electronicInvoiceView addSubview:gotoElectronicInvoiceImageView];
    [gotoElectronicInvoiceImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.electronicInvoiceView);
        make.right.mas_equalTo(self.electronicInvoiceView.mas_right).offset(-20);
        make.size.mas_equalTo(CGSizeMake(15, 15));
    }];
    
    // 商家入驻
    self.businessEntryView = [UIView new];
    [self.businessEntryView setBackgroundColor:[UIColor whiteColor]];
    [self.contentScrollView addSubview:self.businessEntryView];
    [self.businessEntryView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.electronicInvoiceView.mas_bottom).with.offset(1);
        make.centerX.mas_equalTo(self.contentScrollView.mas_centerX);
        make.width.mas_equalTo(mainWidth);
        make.height.mas_equalTo(50);
    }];
    self.businessEntryTitleLabel = [UILabel new];
    [self.businessEntryTitleLabel setText:@"商家入驻"];
    [self.businessEntryView addSubview:self.businessEntryTitleLabel];
    [self.businessEntryTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.businessEntryView);
        make.left.mas_equalTo(self.businessEntryView.mas_left).offset(20);
        make.size.mas_equalTo(CGSizeMake(80, 25));
    }];
    UIImageView *gotoBusinessEntryImageView = [[UIImageView alloc] initWithImage:gotoDetailImage];
    [self.businessEntryView addSubview:gotoBusinessEntryImageView];
    [gotoBusinessEntryImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.businessEntryView);
        make.right.mas_equalTo(self.businessEntryView.mas_right).offset(-20);
        make.size.mas_equalTo(CGSizeMake(15, 15));
    }];
    
    // 商户缴费
    self.merchantPaymentView = [UIView new];
    [self.merchantPaymentView setBackgroundColor:[UIColor whiteColor]];
    [self.contentScrollView addSubview:self.merchantPaymentView];
    [self.merchantPaymentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.businessEntryView.mas_bottom).with.offset(1);
        make.centerX.mas_equalTo(self.contentScrollView.mas_centerX);
        make.width.mas_equalTo(mainWidth);
        make.height.mas_equalTo(50);
    }];
    self.merchantPaymentTitleLabel = [UILabel new];
    [self.merchantPaymentTitleLabel setText:@"商户缴费"];
    [self.merchantPaymentView addSubview:self.merchantPaymentTitleLabel];
    [self.merchantPaymentTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.merchantPaymentView);
        make.left.mas_equalTo(self.merchantPaymentView.mas_left).offset(20);
        make.size.mas_equalTo(CGSizeMake(80, 25));
    }];
    UIImageView *gotoMerchantPaymentImageView = [[UIImageView alloc] initWithImage:gotoDetailImage];
    [self.merchantPaymentView addSubview:gotoMerchantPaymentImageView];
    [gotoMerchantPaymentImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.merchantPaymentView);
        make.right.mas_equalTo(self.merchantPaymentView.mas_right).offset(-20);
        make.size.mas_equalTo(CGSizeMake(15, 15));
    }];
    
    // 在线客服
    self.onlineServiceView = [UIView new];
    [self.onlineServiceView setBackgroundColor:[UIColor whiteColor]];
    [self.contentScrollView addSubview:self.onlineServiceView];
    [self.onlineServiceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.merchantPaymentView.mas_bottom).with.offset(1);
        make.centerX.mas_equalTo(self.contentScrollView.mas_centerX);
        make.width.mas_equalTo(mainWidth);
        make.height.mas_equalTo(50);
    }];
    self.onlineServiceTitleLabel = [UILabel new];
    [self.onlineServiceTitleLabel setText:@"在线客服"];
    [self.onlineServiceView addSubview:self.onlineServiceTitleLabel];
    [self.onlineServiceTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.onlineServiceView);
        make.left.mas_equalTo(self.onlineServiceView.mas_left).offset(20);
        make.size.mas_equalTo(CGSizeMake(80, 25));
    }];
    UIImageView *gotoOnlineServiceImageView = [[UIImageView alloc] initWithImage:gotoDetailImage];
    [self.onlineServiceView addSubview:gotoOnlineServiceImageView];
    [gotoOnlineServiceImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.onlineServiceView);
        make.right.mas_equalTo(self.onlineServiceView.mas_right).offset(-20);
        make.size.mas_equalTo(CGSizeMake(15, 15));
    }];
}

- (void)gotoSettingsViewController{
    HSSettingsTableViewController *controller = [HSSettingsTableViewController new];
    [self.navigationController pushViewController:controller animated:YES];
}
@end
