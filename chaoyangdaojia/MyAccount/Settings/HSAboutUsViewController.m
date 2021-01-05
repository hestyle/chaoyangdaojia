//
//  HSAboutUsViewController.m
//  chaoyangdaojia
//
//  Created by hestyle on 2021/1/4.
//  Copyright © 2021 hestyle. All rights reserved.
//

#import "HSAboutUsViewController.h"
#import "HSNetworkManager.h"
#import "HSNetworkUrl.h"
#import <Toast/Toast.h>
#import <Masonry/Masonry.h>

@interface HSAboutUsViewController ()

@property (nonatomic, strong) UIView *callView;
@property (nonatomic, strong) UILabel *phoneNumberLabel;
@property (nonatomic, strong) UITextView *contentTextView;

@end

@implementation HSAboutUsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self setTitle:@"关于我们"];
    [self.navigationController setNavigationBarHidden:NO];
    
    [self initView];
}

- (void)viewWillAppear:(BOOL)animated {
    [self getAboutUsInfo];
}

#pragma mark - Event
- (void)callAction {
    NSString *telephoneNumber = [self.phoneNumberLabel text];
    NSMutableString * str = [[NSMutableString alloc] initWithFormat:@"tel:%@", telephoneNumber];
    UIApplication *application = [UIApplication sharedApplication];
    NSURL *URL = [NSURL URLWithString:str];
    [application openURL:URL options:@{} completionHandler:^(BOOL success) {
        //OpenSuccess=选择 呼叫 为 1  选择 取消 为0
        if (!success) {
            NSLog(@"电话拨打失败 tel = %@", telephoneNumber);
            [self.view makeToast:@"设备不支持，电话拨打失败！"];
        } else {
            NSLog(@"成功拨打电话 tel = %@", telephoneNumber);
        }
    }];
}

#pragma mark - Private
- (void)initView {
    self.callView = [UIView new];
    [self.callView setBackgroundColor:[UIColor colorWithWhite:0.85 alpha:1.0]];
    [self.view addSubview:self.callView];
    [self.callView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).mas_offset(20);
        make.right.mas_equalTo(self.view).mas_offset(-20);
        make.top.mas_equalTo(self.view).mas_offset(20);
        make.height.mas_equalTo(50);
    }];
    // 添加点击事件
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(callAction)];
    [tapGesture setNumberOfTapsRequired:1];
    [self.callView addGestureRecognizer:tapGesture];
    
    UIImageView *callImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"call_icon"]];
    [self.callView addSubview:callImageView];
    [callImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(30, 30));
        make.centerY.mas_equalTo(self.callView);
        make.left.mas_equalTo(self.callView).mas_offset(5);
    }];
    
    UILabel *callTitleLabel = [UILabel new];
    [callTitleLabel setText:@"点击拨打"];
    [self.callView addSubview:callTitleLabel];
    [callTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(callImageView.mas_right).mas_offset(5);
        make.centerY.mas_equalTo(self.callView);
    }];
    
    self.phoneNumberLabel = [UILabel new];
    [self.phoneNumberLabel setText:@"xxxxxxx"];
    [self.callView addSubview:self.phoneNumberLabel];
    [self.phoneNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.callView).mas_offset(-5);
        make.centerY.mas_equalTo(self.callView);
    }];
    
    self.contentTextView = [UITextView new];
    [self.contentTextView setEditable:NO];
    [self.contentTextView setFont:[UIFont systemFontOfSize:17.f]];
    [self.contentTextView setBackgroundColor:[UIColor colorWithWhite:0.85 alpha:1.0]];
    [self.contentTextView setText:@"朝阳到家，您的掌上朝阳农贸市场!"];
    [self.view addSubview:self.contentTextView];
    [self.contentTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.callView);
        make.right.mas_equalTo(self.callView);
        make.top.mas_equalTo(self.callView.mas_bottom).mas_offset(20);
        make.height.mas_equalTo(200);
    }];
}

- (void)getAboutUsInfo {
    HSNetworkManager *manager = [HSNetworkManager manager];
    __weak __typeof__(self) weakSelf = self;
    [manager getDataWithUrl:kGetAboutUsInfo parameters:@{} success:^(NSDictionary *responseDict) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // 提示验证码是否获取成功
            if ([responseDict[@"errcode"] isEqual:@(0)]) {
                [weakSelf.phoneNumberLabel setText:[NSString stringWithFormat:@"%@", responseDict[@"lxtel"]]];
                NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData: [responseDict[@"content"] dataUsingEncoding:NSUnicodeStringEncoding] options: @{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes: nil error: nil];
                [weakSelf.contentTextView setAttributedText:attributedString];
            } else {
                [weakSelf.view makeToast:responseDict[@"接口返回数据错误！"] duration:3.f position:CSToastPositionCenter];
            }
        });
        NSLog(@"接口 %@ 返回数据 responseDict = %@", kGetAboutUsInfo, responseDict);
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.view makeToast:@"接口请求错误！" duration:3.f position:CSToastPositionCenter];
        });
        NSLog(@"%@", error);
    }];
}
@end
