//
//  HSBannerDetailViewController.m
//  chaoyangdaojia
//
//  Created by hestyle on 2021/1/18.
//  Copyright © 2021 hestyle. All rights reserved.
//

#import "HSBannerDetailViewController.h"
#import <WebKit/WebKit.h>
#import "HSNetwork.h"
#import <Masonry/Masonry.h>
#import <Toast/Toast.h>

@interface HSBannerDetailViewController ()

@property (nonatomic, strong) WKWebView *contentWebView;

@end

@implementation HSBannerDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
    [self initView];
    [self getBannerDataById:self.bannerId];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

#pragma mark - Private
- (void)initView {
    self.contentWebView = [WKWebView new];
    [self.view addSubview:self.contentWebView];
    [self.contentWebView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(self.view);
        make.center.mas_equalTo(self.view);
    }];
}

- (void)getBannerDataById:(NSInteger)bannerId {
    HSNetworkManager *manager = [HSNetworkManager shareManager];
    __weak __typeof__(self) weakSelf = self;
    NSString *url = [kGetBannerDetailDataUrl stringByAppendingFormat:@"?id=%ld", bannerId];
    [manager getDataWithUrl:url parameters:@{} success:^(NSDictionary *responseDict) {
        // 获取成功
        if ([responseDict[@"errcode"] isEqual:@(0)]) {
            NSDictionary *bannerData = responseDict[@"data"];
            NSString *contentString = [NSString stringWithFormat:@"<header><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'><style>img{width:100%% !important;height:auto}</style></header>%@", bannerData[@"content"]];
            dispatch_async(dispatch_get_main_queue(), ^{
                // 更新ui
                [weakSelf.contentWebView loadHTMLString:contentString baseURL:nil];
                [weakSelf setTitle:[NSString stringWithFormat:@"%@", bannerData[@"title"]]];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.view makeToast:responseDict[@"msg"] duration:3 position:CSToastPositionCenter];
            });
            NSLog(@"接口 %@ 返回数据格式错误! responseDict = %@", url, responseDict);
        }
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.view makeToast:@"获取失败，接口请求错误！" duration:3 position:CSToastPositionCenter];
        });
        NSLog(@"%@", error);
    }];
}

@end
