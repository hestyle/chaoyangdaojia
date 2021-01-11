//
//  HSFeedbackViewController.m
//  chaoyangdaojia
//
//  Created by hestyle on 2021/1/4.
//  Copyright © 2021 hestyle. All rights reserved.
//

#import "HSFeedbackViewController.h"
#import "HSNetwork.h"
#import <Toast/Toast.h>
#import <Masonry/Masonry.h>

@interface HSFeedbackViewController ()

@property (nonatomic, strong) UITextView *proposalTextView;
@property (nonatomic, strong) UILabel *contentLengthTipLabel;
@property (nonatomic, strong) UITextField *contactPhoneNumberTextField;
@property (nonatomic, strong) UIButton *submitButton;

@end

/* 建议最长200个字符 */
static const NSUInteger maxContentLength = 200;

@implementation HSFeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self setTitle:@"意见反馈"];
    [self.navigationController setNavigationBarHidden:NO];
    
    [self initView];
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (range.length != 0) {
        // 删字符
        [self.contentLengthTipLabel setText:[NSString stringWithFormat:@"%ld/%ld", [textView.text length] - range.length, maxContentLength]];
        return YES;
    }
    if ([text length] + [textView.text length] > maxContentLength) {
        // 增字符，防止粘贴
        [self.view makeToast:@"不能超过200个字符！" duration:3.f position:CSToastPositionCenter];
        return NO;
    } else {
        [self.contentLengthTipLabel setText:[NSString stringWithFormat:@"%ld/%ld", [textView.text length] + [text length], maxContentLength]];
    }
    return YES;
}

#pragma mark - Event
- (void)submitAction {
    // 检查反馈内容是否填写
    NSString *proposalStr = [self.proposalTextView text];
    if (proposalStr == nil || proposalStr.length == 0) {
        [self.view makeToast:@"请输入反馈描述！" duration:3.f position:CSToastPositionCenter];
        return;
    }
    // 检查电话号码是否输入
    NSString *phoneNumberStr = [self.contactPhoneNumberTextField text];
    if (phoneNumberStr == nil || phoneNumberStr.length == 0) {
        [self.view makeToast:@"请输入联系电话！" duration:3.f position:CSToastPositionCenter];
        return;
    }
    [self.proposalTextView endEditing:YES];
    [self.contactPhoneNumberTextField endEditing:YES];
    NSDictionary *data = @{@"content":proposalStr, @"phone":phoneNumberStr};
    HSNetworkManager *manager = [HSNetworkManager shareManager];
    __weak __typeof__(self) weakSelf = self;
    [manager postDataWithUrl:kFeedbackProblem parameters:@{@"data":data} success:^(NSDictionary *responseDict) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // 提示验证码是否获取成功
            if ([[responseDict allKeys] containsObject:@"msg"]) {
                [weakSelf.view makeToast:responseDict[@"msg"] duration:3.f position:CSToastPositionCenter];
            } else {
                [weakSelf.view makeToast:responseDict[@"接口返回数据格式错误！"] duration:3.f position:CSToastPositionCenter];
            }
        });
        NSLog(@"接口 %@ 返回数据 responseDict = %@", kFeedbackProblem, responseDict);
        if ([responseDict[@"errcode"] isEqual:@(0)]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.8 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [weakSelf.navigationController popViewControllerAnimated:YES];
            });
        }
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.view makeToast:@"接口请求错误！" duration:3.f position:CSToastPositionCenter];
        });
        NSLog(@"%@", error);
    }];
}

#pragma mark - Private
- (void)initView {
    self.proposalTextView = [UITextView new];
    [self.proposalTextView setDelegate:self];
    [self.proposalTextView setFont:[UIFont systemFontOfSize:17.f]];
    [self.proposalTextView setBackgroundColor:[UIColor colorWithWhite:0.85 alpha:1.0]];
    [self.view addSubview:self.proposalTextView];
    [self.proposalTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view).mas_offset(20);
        make.left.mas_equalTo(self.view).mas_offset(20);
        make.right.mas_equalTo(self.view).mas_offset(-20);
        make.height.mas_equalTo(300);
    }];
    // proposalTextView添加placeHolder
    UILabel *placeHolderLabel = [[UILabel alloc] init];
    placeHolderLabel.text = @"请描述您的建议";
    placeHolderLabel.numberOfLines = 0;
    placeHolderLabel.textColor = [UIColor lightGrayColor];
    [placeHolderLabel sizeToFit];
    [self.proposalTextView addSubview:placeHolderLabel];
    placeHolderLabel.font = [UIFont systemFontOfSize:17.f];
    [self.proposalTextView setValue:placeHolderLabel forKey:@"_placeholderLabel"];
    
    self.contentLengthTipLabel = [UILabel new];
    [self.contentLengthTipLabel setText:@"0/200"];
    [self.contentLengthTipLabel setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];
    [self.view addSubview:self.contentLengthTipLabel];
    [self.contentLengthTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.proposalTextView).mas_offset(-8);
        make.bottom.mas_equalTo(self.proposalTextView).mas_offset(-8);
    }];
    
    UIView *contactPhoneNumberView = [UIView new];
    [contactPhoneNumberView setBackgroundColor:[UIColor colorWithWhite:0.85 alpha:1.0]];
    [self.view addSubview:contactPhoneNumberView];
    [contactPhoneNumberView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.proposalTextView.mas_bottom).mas_offset(10);
        make.left.mas_equalTo(self.proposalTextView);
        make.right.mas_equalTo(self.proposalTextView);
        make.height.mas_equalTo(50);
    }];
    
    UILabel *contactPhoneNumberTitleLabel = [UILabel new];
    [contactPhoneNumberTitleLabel setText:@"联系方式"];
    [contactPhoneNumberView addSubview:contactPhoneNumberTitleLabel];
    [contactPhoneNumberTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(contactPhoneNumberView).mas_offset(5);
        make.centerY.mas_equalTo(contactPhoneNumberView);
    }];
    // 宽度足够时，压缩
    [contactPhoneNumberTitleLabel setPreferredMaxLayoutWidth:100];
    [contactPhoneNumberTitleLabel setContentHuggingPriority:UILayoutPriorityRequired
                                 forAxis:UILayoutConstraintAxisHorizontal];

    
    self.contactPhoneNumberTextField = [UITextField new];
    [self.contactPhoneNumberTextField setPlaceholder:@"请填写联系方式"];
    [contactPhoneNumberView addSubview:self.contactPhoneNumberTextField];
    [self.contactPhoneNumberTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(contactPhoneNumberTitleLabel.mas_right).mas_offset(5);
        make.right.mas_equalTo(contactPhoneNumberView).mas_offset(-5);
        make.centerY.mas_equalTo(contactPhoneNumberView);
    }];
    
    self.submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.submitButton setTitle:@"提交" forState:UIControlStateNormal];
    [self.submitButton setTitle:@"" forState:UIControlStateHighlighted];
    [self.submitButton setBackgroundColor:[UIColor orangeColor]];
    [self.view addSubview:self.submitButton];
    [self.submitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(contactPhoneNumberView.mas_bottom).mas_equalTo(10);
        make.left.mas_equalTo(self.view).mas_offset(50);
        make.right.mas_equalTo(self.view).mas_offset(-50);
        make.height.mas_equalTo(40);
    }];
    [self.submitButton addTarget:self action:@selector(submitAction) forControlEvents:UIControlEventTouchUpInside];
}

@end
