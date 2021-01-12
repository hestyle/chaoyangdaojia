//
//  HSMemberExplainViewController.m
//  chaoyangdaojia
//
//  Created by hestyle on 2021/1/12.
//  Copyright © 2021 hestyle. All rights reserved.
//

#import "HSMemberExplainViewController.h"
#import "HSNetwork.h"
#import <Masonry/Masonry.h>
#import <Toast/Toast.h>

@interface HSMemberExplainViewController ()

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong) WKWebView *contentWebView;

@end

@implementation HSMemberExplainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self initView];
}

- (void)viewWillAppear:(BOOL)animated {
    [self setTitle:@"会员说明"];
    [self.navigationController setNavigationBarHidden:NO];
    
    [self.activityIndicatorView startAnimating];
    [self getMemberExplain];
}
#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self.activityIndicatorView stopAnimating];
}

#pragma mark - Private
- (void)initView {
    self.contentWebView = [WKWebView new];
    [self.contentWebView setNavigationDelegate:self];
    [self.view addSubview:self.contentWebView];
    [self.contentWebView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.view);
        make.size.mas_equalTo(self.view);
    }];
    
    self.activityIndicatorView = [UIActivityIndicatorView new];
    [self.activityIndicatorView setHidesWhenStopped:YES];
    [self.view addSubview:self.activityIndicatorView];
    [self.activityIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(60, 60));
    }];
}

- (void)getMemberExplain {
    HSNetworkManager *manager = [HSNetworkManager shareManager];
    __weak __typeof__(self) weakSelf = self;
    [manager getDataWithUrl:kGetMemberExplain parameters:@{} success:^(NSDictionary *responseDict) {
        if (![responseDict[@"errcode"] isEqual:@(0)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.activityIndicatorView stopAnimating];
                [weakSelf.view makeToast:responseDict[@"接口返回数据错误！"] duration:3.f position:CSToastPositionCenter];
                [weakSelf.activityIndicatorView stopAnimating];
            });
        }
        if ([[responseDict allKeys] containsObject:@"content"]) {
            NSString *contentString = [NSString stringWithFormat:@"<header><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'></header>%@", responseDict[@"content"]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.contentWebView loadHTMLString:contentString baseURL:nil];
            });
        }
        NSLog(@"接口 %@ 返回数据 responseDict = %@", kGetMemberExplain, responseDict);
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.view makeToast:@"接口请求错误！" duration:3.f position:CSToastPositionCenter];
        });
        NSLog(@"%@", error);
    }];
}
@end
