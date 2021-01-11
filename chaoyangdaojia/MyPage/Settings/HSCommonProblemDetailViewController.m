//
//  HSCommonProblemDetailViewController.m
//  chaoyangdaojia
//
//  Created by hestyle on 2021/1/3.
//  Copyright © 2021 hestyle. All rights reserved.
//

#import "HSCommonProblemDetailViewController.h"
#import <WebKit/WebKit.h>
#import <Masonry/Masonry.h>

@interface HSCommonProblemDetailViewController ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) WKWebView *contentWebView;

@end

@implementation HSCommonProblemDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self setTitle:@"问题详情"];
    [self.navigationController setNavigationBarHidden:NO];
}

- (HSCommonProblemDetailViewController *)initWithCommonProblem:(NSDictionary *)commonProblemDict {
    self.titleLabel = [UILabel new];
    if ([[commonProblemDict allKeys] containsObject:@"title"]) {
        [self.titleLabel setText:[NSString stringWithFormat:@"%@", commonProblemDict[@"title"]]];
    }
    [self.titleLabel setFont:[UIFont systemFontOfSize:[UIFont systemFontSize] + 3]];
    [self.view addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view).mas_offset(20);
        make.left.mas_equalTo(self.view).mas_offset(20);
    }];
    
    self.timeLabel = [UILabel new];
    if ([[commonProblemDict allKeys] containsObject:@"addtime"]) {
        // 时间字符串
        NSString *timeStr = [NSString stringWithFormat:@"%@", commonProblemDict[@"addtime"]];
        // 时间字符串转换时段
        NSTimeInterval time = [timeStr doubleValue];
        // 时段转换时间
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
        // 时间格式
        NSDateFormatter *dataformatter = [[NSDateFormatter alloc] init];
        dataformatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        // 时间转换字符串
        [self.timeLabel setText:[dataformatter stringFromDate:date]];
    }
    [self.timeLabel setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];
    [self.view addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).mas_offset(10);
        make.right.mas_equalTo(self.view).mas_offset(-20);
    }];
    
    self.contentWebView = [WKWebView new];
    if ([[commonProblemDict allKeys] containsObject:@"content"]) {
        [self.contentWebView loadHTMLString:[NSString stringWithFormat:@"<header><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'></header>%@", commonProblemDict[@"content"]] baseURL:nil];
    }
    [self.view addSubview:self.contentWebView];
    [self.contentWebView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel);
        make.right.mas_equalTo(self.timeLabel);
        make.top.mas_equalTo(self.timeLabel.mas_bottom).mas_offset(10);
        make.bottom.mas_equalTo(self.view).mas_offset(-20);
    }];
    return self;
}

@end
