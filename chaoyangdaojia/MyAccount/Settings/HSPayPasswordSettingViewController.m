//
//  HSPayPasswordSettingViewController.m
//  chaoyangdaojia
//
//  Created by hestyle on 2021/1/2.
//  Copyright © 2021 hestyle. All rights reserved.
//

#import "HSPayPasswordSettingViewController.h"
#import "HSNetworkManager.h"
#import "HSNetworkUrl.h"
#import <Toast/Toast.h>
#import <Masonry/Masonry.h>

@interface HSPayPasswordSettingViewController ()

@property (nonatomic, strong) NSString *phoneNumberStr;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *verifyView;
@property (nonatomic, strong) UIView *setPayPasswordView;

@property (nonatomic, strong) UIView *phoneNumberView;
@property (nonatomic, strong) UILabel *phoneNumberLabel;
@property (nonatomic, strong) UIView *verifyCodeView;
@property (nonatomic, strong) UITextField *verifyCodeTextField;
@property (nonatomic, strong) UIButton *getVerifyCodeButton;
@property (nonatomic, strong) UIButton *nextStepButton;

@property (nonatomic, strong) UILabel *modifyPayPasswordLabel;
@property (nonatomic, strong) UIView *payPasswordView;
@property (nonatomic, strong) UILabel *payPasswordInputErrorLabel;
/* 记录下一个输入的数字 */
@property NSUInteger payPasswordLabelIndex;
@property (nonatomic, strong) NSArray<UILabel *> *payPasswordLabelArray;
@property (nonatomic, strong) UILabel *payPasswordInputTipLabel;
@property (nonatomic, strong) UITextField *payPasswordTextField;
@property (nonatomic, strong) NSString *firstPasswordString;

@end

@implementation HSPayPasswordSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self setTitle:@"支付密码设置"];
    [self.navigationController setNavigationBarHidden:NO];
    
    [self readPhoneNumberFromCashe];
    [self initView];
}

- (void)viewWillAppear:(BOOL)animated {
    // 注册键盘弹出通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == self.verifyCodeTextField) {
        if ([string length] > 6) {
            return NO;
        }
        if ([string length] > 0) {
            [self.nextStepButton setEnabled:YES];
            [self.nextStepButton setBackgroundColor:[UIColor orangeColor]];
        } else {
            [self.nextStepButton setEnabled:NO];
            [self.nextStepButton setBackgroundColor:[UIColor grayColor]];
        }
        return YES;
    } else if (textField == self.payPasswordTextField) {
        if ([string length] > 1) {
            // 防止粘贴
            return NO;
        } else if ([string length] == 1) {
            // 追加字符
            if (self.payPasswordLabelIndex < 6) {
                UILabel *currentLabel = self.payPasswordLabelArray[self.payPasswordLabelIndex];
                [currentLabel setText:@"●"];
                self.payPasswordLabelIndex += 1;
            } else {
                return NO;
            }
            if (self.payPasswordLabelIndex == 6) {
                // 6密码输入完成，下一次输入，或者两次密码输入完成
                self.payPasswordTextField.text = [self.payPasswordTextField.text stringByAppendingString:string];
                [self haveInputPassword];
                return NO;
            }
        } else if (self.payPasswordLabelIndex > 0){
            // 删减字符
            self.payPasswordLabelIndex -= 1;
            UILabel *currentLabel = self.payPasswordLabelArray[self.payPasswordLabelIndex];
            [currentLabel setText:@""];
        }
        return YES;
    } else {
        return YES;
    }
}

#pragma mark - Event
- (void)getVerifyCodeAction {
    NSDictionary *paramters = @{@"phone":self.phoneNumberStr, @"type":@"setpaypwd"};
    HSNetworkManager *manager = [HSNetworkManager manager];
    __weak __typeof__(self) weakSelf = self;
    [manager postDataWithUrl:kGetTelCodeUrl parameters:paramters success:^(NSDictionary *responseDict) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // 提示验证码是否获取成功
            if ([[responseDict allKeys] containsObject:@"msg"]) {
                [weakSelf.view makeToast:responseDict[@"msg"] duration:3 position:CSToastPositionCenter];
            } else {
                [weakSelf.view makeToast:responseDict[@"接口返回数据格式错误！"] duration:3 position:CSToastPositionCenter];
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

- (void)checkVerifyCodeAction {
    if ([self.verifyCodeTextField.text length] < 4) {
        [self.view makeToast:@"请输入验证码！" duration:3.0 position:CSToastPositionCenter];
        return;
    }
    NSDictionary *paramters = @{@"phone":self.phoneNumberStr, @"type":@"setpaypwd", @"code":self.verifyCodeTextField.text};
    HSNetworkManager *manager = [HSNetworkManager manager];
    __weak __typeof__(self) weakSelf = self;
    [manager postDataWithUrl:kCheckVerifyCode parameters:paramters success:^(NSDictionary *responseDict) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // 提示验证码是否获取成功
            if ([[responseDict allKeys] containsObject:@"msg"]) {
                [weakSelf.view makeToast:responseDict[@"msg"] duration:3 position:CSToastPositionCenter];
            } else {
                [weakSelf.view makeToast:responseDict[@"接口返回数据格式错误！"] duration:3 position:CSToastPositionCenter];
                NSLog(@"接口 %@ 返回数据格式错误! responseDict = %@", kCheckVerifyCode, responseDict);
            }
            if ([responseDict[@"errcode"] isEqual:@(0)]) {
                [weakSelf.verifyCodeTextField endEditing:YES];
                [weakSelf.scrollView setContentOffset:CGPointMake([UIScreen mainScreen].bounds.size.width, 0) animated:YES];
                [weakSelf upNumberKeyBoard];
            }
        });
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.view makeToast:@"接口请求错误！"];
        });
        NSLog(@"%@", error);
    }];
}

- (void)setPayPasswordAction {
    NSDictionary *paramters = @{@"pwd":self.firstPasswordString};
    HSNetworkManager *manager = [HSNetworkManager manager];
    __weak __typeof__(self) weakSelf = self;
    [manager postDataWithUrl:kSetPayPassword parameters:paramters success:^(NSDictionary *responseDict) {
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
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.8 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [weakSelf.navigationController popViewControllerAnimated:YES];
            });
        } else if ([responseDict[@"errcode"] isEqual:@(1)]) {
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

- (void)upNumberKeyBoard {
    [self.payPasswordTextField becomeFirstResponder];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    // 键盘大小
    CGSize keyboardSize = [info[UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    // 动画时间
    NSTimeInterval animationDuration = [info[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:animationDuration animations:^{
        [self.modifyPayPasswordLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(-(keyboardSize.height / 2));
        }];
        [self.payPasswordView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(-keyboardSize.height);
        }];
    }];
}

#pragma mark - Private
- (void)initView {
    self.scrollView = [UIScrollView new];
    [self.scrollView setScrollEnabled:NO];
    [self.scrollView setShowsVerticalScrollIndicator:NO];
    [self.scrollView setShowsHorizontalScrollIndicator:NO];
    [self.scrollView setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width * 2, 0)];
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(self.view);
        make.center.mas_equalTo(self.view);
    }];
    
    self.verifyView = [UIView new];
    [self.scrollView addSubview:self.verifyView];
    [self.verifyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.scrollView);
        make.top.mas_equalTo(self.scrollView);
        make.size.mas_equalTo(self.scrollView);
    }];
    
    self.phoneNumberView = [UIView new];
    [self.phoneNumberView.layer setBorderWidth:1];
    [self.phoneNumberView.layer setCornerRadius:5];
    [self.phoneNumberView.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [self.verifyView addSubview:self.phoneNumberView];
    [self.phoneNumberView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.verifyView).with.offset(20);
        make.centerX.mas_equalTo(self.verifyView.mas_centerX);
        make.left.mas_equalTo(self.verifyView.mas_left).with.offset(20);
        make.right.mas_equalTo(self.verifyView.mas_right).with.offset(-20);
        make.height.mas_equalTo(50);
    }];
    
    UIImageView *phoneImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"phone_icon"]];
    [self.phoneNumberView addSubview:phoneImageView];
    [phoneImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.phoneNumberView).mas_offset(12.5);
        make.centerY.mas_equalTo(self.phoneNumberView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(25, 35));
    }];
    
    self.phoneNumberLabel = [UILabel new];
    NSString *phoneNumberSecrecyStr = [NSString stringWithFormat:@"%@****%@", [self.phoneNumberStr substringWithRange:NSMakeRange(0, 3)], [self.phoneNumberStr substringFromIndex:7]];
    [self.phoneNumberLabel setText:phoneNumberSecrecyStr];
    [self.phoneNumberView addSubview:self.phoneNumberLabel];
    [self.phoneNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.phoneNumberView).mas_offset(50);
        make.right.mas_equalTo(self.phoneNumberView.mas_right).mas_offset(-5);
        make.centerY.mas_equalTo(self.phoneNumberView.mas_centerY);
    }];
    
    self.verifyCodeView = [UIView new];
    [self.verifyCodeView.layer setBorderWidth:1];
    [self.verifyCodeView.layer setCornerRadius:5];
    [self.verifyCodeView.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [self.verifyView addSubview:self.verifyCodeView];
    [self.verifyCodeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.phoneNumberView.mas_bottom).with.offset(10);
        make.centerX.mas_equalTo(self.verifyView.mas_centerX);
        make.left.mas_equalTo(self.verifyView.mas_left).with.offset(20);
        make.right.mas_equalTo(self.verifyView.mas_right).with.offset(-20);
        make.height.mas_equalTo(50);
    }];
    
    UIImageView *messageImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"message_icon"]];
    [self.verifyCodeView addSubview:messageImageView];
    [messageImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.verifyCodeView).mas_offset(7.5);
        make.centerY.mas_equalTo(self.verifyCodeView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(35, 25));
    }];
    
    self.verifyCodeTextField = [UITextField new];
    [self.verifyCodeTextField setDelegate:self];
    [self.verifyCodeTextField setPlaceholder:@"请输入验证码"];
    [self.verifyCodeView addSubview:self.verifyCodeTextField];
    [self.verifyCodeTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.verifyCodeView).mas_offset(50);
        make.height.mas_equalTo(40);
        make.right.mas_equalTo(self.verifyCodeView.mas_right).mas_offset(-130);
        make.centerY.mas_equalTo(self.verifyCodeView);
    }];
    
    self.getVerifyCodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.getVerifyCodeButton setBackgroundColor:[UIColor orangeColor]];
    [self.getVerifyCodeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
    [self.getVerifyCodeButton setTitle:@"" forState:UIControlStateHighlighted];
    [self.getVerifyCodeButton addTarget:self action:@selector(getVerifyCodeAction) forControlEvents:UIControlEventTouchUpInside];
    [self.verifyCodeView addSubview:self.getVerifyCodeButton];
    [self.getVerifyCodeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.verifyCodeTextField.mas_right).mas_offset(5);
        make.right.mas_equalTo(self.verifyCodeView).mas_offset(-10);
        make.height.mas_equalTo(40);
        make.centerY.mas_equalTo(self.verifyCodeView);
    }];
    
    self.nextStepButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.nextStepButton setBackgroundColor:[UIColor grayColor]];
    [self.nextStepButton setTitle:@"下一步" forState:UIControlStateNormal];
    [self.nextStepButton setTitle:@"" forState:UIControlStateHighlighted];
    [self.nextStepButton addTarget:self action:@selector(checkVerifyCodeAction) forControlEvents:UIControlEventTouchUpInside];
    [self.nextStepButton setEnabled:NO];
    [self.verifyView addSubview:self.nextStepButton];
    [self.nextStepButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.verifyCodeView.mas_bottom).mas_equalTo(50);
        make.size.mas_equalTo(CGSizeMake(200, 40));
        make.centerX.mas_equalTo(self.verifyView);
    }];
    
    self.setPayPasswordView = [UIView new];
    [self.scrollView addSubview:self.setPayPasswordView];
    [self.setPayPasswordView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.scrollView).mas_offset([UIScreen mainScreen].bounds.size.width);
        make.top.mas_equalTo(self.scrollView);
        make.size.mas_equalTo(self.scrollView);
    }];
    self.modifyPayPasswordLabel = [UILabel new];
    [self.modifyPayPasswordLabel setText:@"初始设置支付密码"];
    [self.setPayPasswordView addSubview:self.modifyPayPasswordLabel];
    [self.modifyPayPasswordLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.setPayPasswordView);
    }];
    
    self.payPasswordView = [UIView new];
    [self.payPasswordView setBackgroundColor:[UIColor colorWithWhite:0.85 alpha:1.0]];
    [self.setPayPasswordView addSubview:self.payPasswordView];
    [self.payPasswordView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.setPayPasswordView).mas_offset(10);
        make.right.mas_equalTo(self.setPayPasswordView.mas_right).mas_offset(-10);
        make.height.mas_equalTo(100);
        make.bottom.mas_equalTo(self.setPayPasswordView);
    }];
    UITapGestureRecognizer *tapGesturRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(upNumberKeyBoard)];
    [self.payPasswordView addGestureRecognizer:tapGesturRecognizer];
    
    NSMutableArray<UILabel *> *labelArray = [NSMutableArray new];
    // password的每个数字label为正方形，边长最大值为50
    CGFloat passwordLabelWidth = ([UIScreen mainScreen].bounds.size.width - 40 - 20) / 6;
    CGFloat firstPasswordLabelLeft = 20.f;
    CGFloat passwordLabelRealWidth = passwordLabelWidth;
    if (passwordLabelWidth > 50.f) {
        passwordLabelRealWidth = 50.f;
        firstPasswordLabelLeft = ([UIScreen mainScreen].bounds.size.width - 20 - passwordLabelRealWidth * 6) / 2;
    }
    self.payPasswordTextField = [UITextField new];
    [self.payPasswordTextField setDelegate:self];
    [self.payPasswordTextField setKeyboardType:UIKeyboardTypeNumberPad];
    [self.payPasswordView addSubview:self.payPasswordTextField];
    [self.payPasswordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.payPasswordView).mas_offset(firstPasswordLabelLeft);
        make.centerY.mas_equalTo(self.payPasswordView);
        make.size.mas_equalTo(CGSizeMake(passwordLabelRealWidth * 6, passwordLabelRealWidth));
    }];
    for (int i = 0; i < 6; ++i) {
        UILabel *passwordLabel = [UILabel new];
        [labelArray addObject:passwordLabel];
        [passwordLabel setBackgroundColor:[UIColor whiteColor]];
        [passwordLabel setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize] - 4]];
        [passwordLabel setTextAlignment:NSTextAlignmentCenter];
        [passwordLabel.layer setBorderColor:[[UIColor blackColor] CGColor]];
        [passwordLabel.layer setBorderWidth:0.5];
        [self.payPasswordView addSubview:passwordLabel];
        [passwordLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(passwordLabelRealWidth, passwordLabelRealWidth));
            make.centerY.mas_equalTo(self.payPasswordView);
            make.left.mas_equalTo(self.payPasswordView).mas_offset(firstPasswordLabelLeft + passwordLabelRealWidth * i);
        }];
    }
    self.payPasswordLabelIndex = 0;
    self.payPasswordLabelArray = labelArray.copy;
    self.firstPasswordString = @"";
    
    self.payPasswordInputErrorLabel = [UILabel new];
    [self.payPasswordInputErrorLabel setTextColor:[UIColor redColor]];
    [self.payPasswordView addSubview:self.payPasswordInputErrorLabel];
    [self.payPasswordInputErrorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.payPasswordView).mas_offset(firstPasswordLabelLeft);
        make.bottom.mas_equalTo(self.payPasswordView.mas_centerY).mas_offset(-(passwordLabelRealWidth / 2));
    }];
    self.payPasswordInputTipLabel = [UILabel new];
    [self.payPasswordInputTipLabel setText:@"请输入支付密码"];
    [self.payPasswordInputTipLabel setTextColor:[UIColor orangeColor]];
    [self.payPasswordView addSubview:self.payPasswordInputTipLabel];
    [self.payPasswordInputTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.payPasswordView);
        make.top.mas_equalTo(self.payPasswordView.mas_centerY).mas_offset(passwordLabelRealWidth / 2);
    }];
}

- (void)readPhoneNumberFromCashe {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSDictionary *userInfoDict = [userDefault objectForKey:@"USER_INFO"];
    self.phoneNumberStr = userInfoDict[@"phone"];
}

- (void)haveInputPassword {
    if ([self.firstPasswordString length] == 0) {
        // 成功输入密码（第一次）
        self.firstPasswordString = self.payPasswordTextField.text;
        [self.payPasswordTextField setText:@""];
        while (self.payPasswordLabelIndex > 0) {
            self.payPasswordLabelIndex -= 1;
            UILabel *currentLabel = self.payPasswordLabelArray[self.payPasswordLabelIndex];
            [currentLabel setText:@""];
        }
        [self.payPasswordInputTipLabel setText:@"请重复输入支付密码"];
    } else {
        // 第二次完成密码输入
        if (![self.payPasswordTextField.text isEqual:self.firstPasswordString]) {
            [self.payPasswordInputErrorLabel setText:@"两次密码输入不一致！"];
            return;
        }
        [self.payPasswordInputErrorLabel setText:@""];
        // 提交支付密码重置请求
        [self setPayPasswordAction];
    }
}

@end
