//
//  HSLoginViewController.m
//  chaoyangdaojia
//
//  Created by hestyle on 2020/12/25.
//  Copyright © 2020 hestyle. All rights reserved.
//

#import "HSLoginViewController.h"
#import "HSNetworkManager.h"
#import "HSNetworkUrl.h"
#import <Toast/Toast.h>
#import <Masonry/Masonry.h>

@interface HSLoginViewController ()

@property (nonatomic, strong) UIImageView *logoImageView;
@property (nonatomic, strong) UIView *phoneNumberView;
@property (nonatomic, strong) UILabel *phoneNumberLabel;
@property (nonatomic, strong) UITextField *phoneNumberTextField;
@property (nonatomic, strong) UIView *verifyCodeView;
@property (nonatomic, strong) UILabel *verifyCodeLabel;
@property (nonatomic, strong) UITextField *verifyCodeTextField;
@property (nonatomic, strong) UIButton *getVerifyCodeButton;
@property (nonatomic, strong) UIButton *loginButton;

@end

@implementation HSLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.navigationController setNavigationBarHidden:NO];
    [self setTitle:@"登录"];
    
    self.logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    [self.view addSubview:self.logoImageView];
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_offset(180);
        make.centerX.mas_equalTo(self.view);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(80);
    }];
    
    // 设置phoneNumber这一行
    self.phoneNumberView = [UIView new];
    [self.phoneNumberView.layer setBorderWidth:1];
    [self.phoneNumberView.layer setCornerRadius:5];
    [self.phoneNumberView.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [self.view addSubview:self.phoneNumberView];
    [self.phoneNumberView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.logoImageView.mas_bottom).with.offset(20);
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.left.mas_equalTo(self.view.mas_left).with.offset(40);
        make.right.mas_equalTo(self.view.mas_right).with.offset(-40);
        make.height.mas_equalTo(35);
    }];
    
    
    self.phoneNumberLabel = [[UILabel alloc] init];
    [self.phoneNumberLabel setText:@"手机号:"];
    [self.phoneNumberView addSubview:self.phoneNumberLabel];
    [self.phoneNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.phoneNumberView.mas_centerY);
        make.left.mas_equalTo(self.phoneNumberView.mas_left).with.offset(5);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(30);
    }];
    
    self.phoneNumberTextField = [[UITextField alloc] init];
    [self.phoneNumberTextField setDelegate:self];
    [self.phoneNumberTextField setPlaceholder:@"请输入手机号"];
    [self.phoneNumberView addSubview:self.phoneNumberTextField];
    [self.phoneNumberTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.phoneNumberView.mas_centerY);
        make.left.mas_equalTo(self.phoneNumberLabel.mas_right).with.offset(10);
        make.right.mas_equalTo(self.phoneNumberView.mas_right).with.offset(-2.5);
        make.height.mas_equalTo(self.phoneNumberLabel.mas_height);
    }];
    
    // 设置verifyCode这一行
    self.verifyCodeView = [UIView new];
    [self.verifyCodeView.layer setBorderWidth:1];
    [self.verifyCodeView.layer setCornerRadius:5];
    [self.verifyCodeView.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [self.view addSubview:self.verifyCodeView];
    [self.verifyCodeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.phoneNumberView.mas_bottom).with.offset(20);
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.left.mas_equalTo(self.view.mas_left).with.offset(40);
        make.right.mas_equalTo(self.view.mas_right).with.offset(-40);
        make.height.mas_equalTo(35);
    }];
    
    self.verifyCodeLabel = [[UILabel alloc] init];
    [self.verifyCodeLabel setText:@"验证码:"];
    [self.view addSubview:self.verifyCodeLabel];
    [self.verifyCodeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.verifyCodeView.mas_centerY);
        make.left.mas_equalTo(self.phoneNumberLabel.mas_left);
        make.width.mas_equalTo(self.phoneNumberLabel.mas_width);
        make.height.mas_equalTo(self.phoneNumberLabel.mas_height);
    }];
    
    self.verifyCodeTextField = [[UITextField alloc] init];
    [self.verifyCodeTextField setDelegate:self];
    [self.verifyCodeTextField setPlaceholder:@"请输入验证码"];
    [self.view addSubview:self.verifyCodeTextField];
    [self.verifyCodeTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.verifyCodeView.mas_centerY);
        make.left.mas_equalTo(self.verifyCodeLabel.mas_right).with.offset(10);
        make.right.mas_equalTo(self.verifyCodeView.mas_right).with.offset(-110);
        make.height.mas_equalTo(self.phoneNumberLabel.mas_height);
    }];
    
    self.getVerifyCodeButton = [UIButton new];
    [self.getVerifyCodeButton setBackgroundColor:[UIColor systemBlueColor]];
    [self.getVerifyCodeButton.layer setCornerRadius:5];
    [self.getVerifyCodeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
    [self.getVerifyCodeButton setTitle:@"" forState:UIControlStateHighlighted];
    [self.getVerifyCodeButton addTarget:self action:@selector(getVerifyCode) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.getVerifyCodeButton];
    [self.getVerifyCodeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.verifyCodeView.mas_centerY);
        make.left.mas_equalTo(self.verifyCodeTextField.mas_right).with.offset(5);
        make.right.mas_equalTo(self.verifyCodeView.mas_right).with.offset(-5);
        make.height.mas_equalTo(self.phoneNumberLabel.mas_height);
    }];
    
    self.loginButton = [UIButton new];
    [self.loginButton setBackgroundColor:[UIColor systemBlueColor]];
    [self.loginButton.layer setCornerRadius:5];
    [self.loginButton setTitle:@"登录" forState:UIControlStateNormal];
    [self.loginButton setTitle:@"" forState:UIControlStateHighlighted];
    [self.loginButton addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.loginButton];
    [self.loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.verifyCodeLabel.mas_bottom).with.offset(10);
        make.left.mas_equalTo(self.view.mas_left).with.offset(100);
        make.right.mas_equalTo(self.view.mas_right).with.offset(-100);
        make.height.mas_equalTo(self.phoneNumberLabel.mas_height);
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
/**
 *获取验证码
 */
- (void)getVerifyCode{
    // 检查电话号码是否输入
    NSString *phoneNumberStr = [self.phoneNumberTextField text];
    if (phoneNumberStr == nil || phoneNumberStr.length == 0) {
        [self.view makeToast:@"请输入电话号码！"];
        return;
    }
    NSDictionary *paramters = @{@"phone":phoneNumberStr, @"type":@"login"};
    HSNetworkManager *manager = [HSNetworkManager manager];
    __weak __typeof__(self) weakSelf = self;
    [manager postDataWithUrl:kGetTelCodeUrl parameters:paramters success:^(NSDictionary *responseDict) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // 提示验证码是否获取成功
            if ([[responseDict allKeys] containsObject:@"msg"]) {
                [weakSelf.view makeToast:responseDict[@"msg"]];
            } else {
                [weakSelf.view makeToast:responseDict[@"接口返回数据格式错误！"]];
                NSLog(@"接口 %@ 返回数据格式错误! responseDict = %@", kGetTelCodeUrl, responseDict);
            }
        });
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.view makeToast:@"接口请求错误！"];
        });
        NSLog(@"%@", error);
    }];
}

/**
 *登录
 */
- (void)login{
    // 检查电话号码是否输入
    NSString *phoneNumberStr = [self.phoneNumberTextField text];
    if (phoneNumberStr == nil || phoneNumberStr.length == 0) {
        [self.view makeToast:@"请输入电话号码！"];
        return;
    }
    // 检查验证码是否输入
    NSString *verifyCodeStr = [self.verifyCodeTextField text];
    if (verifyCodeStr == nil || verifyCodeStr.length == 0) {
        [self.view makeToast:@"请输入验证码！"];
        return;
    }
    NSDictionary *data = @{@"phone":phoneNumberStr, @"type":@"login", @"username": phoneNumberStr, @"code": verifyCodeStr};
    NSDictionary *paramters = @{@"data":data};
    HSNetworkManager *manager = [HSNetworkManager manager];
    __weak __typeof__(self) weakSelf = self;
    [manager postDataWithUrl:kLoginUrl parameters:paramters success:^(NSDictionary *responseDict) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // 提示是否登录成功
            if ([[responseDict allKeys] containsObject:@"msg"]) {
                [weakSelf.view makeToast:responseDict[@"msg"]];
            } else {
                [weakSelf.view makeToast:responseDict[@"接口返回数据格式错误！"]];
                NSLog(@"接口 %@ 返回数据格式错误! responseDict = %@", kGetTelCodeUrl, responseDict);
            }
            // 登录成功
            if ([responseDict[@"errcode"] isEqual:@(0)]) {
                NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
                NSDictionary *userInfoDict = responseDict[@"uinfo"];
                NSMutableDictionary *realUserInfoDict = [NSMutableDictionary new];
                // 挑选value ！= nil的key/value
                for (NSString *keyString in [userInfoDict allKeys]) {
                    if (![userInfoDict[keyString] isEqual:[NSNull null]]) {
                        realUserInfoDict[keyString] = userInfoDict[keyString];
                    }
                }
                [userDefault setObject:realUserInfoDict forKey:@"USER_INFO"];
                NSLog(@"%@", responseDict[@"uinfo"]);
                // 登录成功，返回前一个页面
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
        });
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.view makeToast:@"接口请求错误！"];
        });
        NSLog(@"%@", error);
    }];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == self.phoneNumberTextField) {
        // 电话号码：检查字符是否是数字
        for (int i = 0; i < string.length; ++i) {
            unichar ch = [string characterAtIndex:i];
            if (ch < '0' || ch > '9') {
                return NO;
            }
        }
        // 长度不能超过11
        if (string.length > 11) {
            return NO;
        } else {
            return YES;
        }
    } else if (textField == self.verifyCodeTextField) {
        // 验证码：检查字符是否是数字
        for (int i = 0; i < string.length; ++i) {
            unichar ch = [string characterAtIndex:i];
            if (ch < '0' || ch > '9') {
                return NO;
            }
        }
        return YES;
    } else {
        return YES;
    }
}

@end
