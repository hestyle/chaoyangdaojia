//
//  HSFriendBirthdayEditViewController.m
//  chaoyangdaojia
//
//  Created by hestyle on 2020/12/28.
//  Copyright © 2020 hestyle. All rights reserved.
//

#import "HSFriendBirthdayEditViewController.h"
#import "HSNetwork.h"
#import <Masonry/Masonry.h>
#import <Toast/Toast.h>

@interface HSFriendBirthdayEditViewController ()

@property (nonatomic, strong) UIView *friendNameView;
@property (nonatomic, strong) UITextField *friendNameTextField;
@property (nonatomic, strong) UIView *friendCourtesyTitleView;
@property (nonatomic, strong) UITextField *friendCourtesyTitleTextField;
@property (nonatomic, strong) UIView *friendBirthdayView;
@property (nonatomic, strong) UITextField *friendBirthdayTextField;
/* 生日提醒类型     1、2、3 */
@property (nonatomic) NSInteger txtype;
@property (nonatomic, strong) UIView *remindTimeView;
@property (nonatomic, strong) UITextField *remindTimeTextField;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) NSDictionary *friendBirthdayDict;

@end

@implementation HSFriendBirthdayEditViewController

- (void)setFriendBirthday:(NSDictionary *)friendBirthday {
    self.friendBirthdayDict = friendBirthday;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self setTitle:@"新增亲友生日提醒"];
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    [self.navigationController setNavigationBarHidden:NO];
    
    // 绘制view
    [self initView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.friendBirthdayDict != nil) {
        // 初始化输入框
        if ([[self.friendBirthdayDict allKeys] containsObject:@"name"]) {
            [self.friendNameTextField setText:self.friendBirthdayDict[@"name"]];
        }
        if ([[self.friendBirthdayDict allKeys] containsObject:@"birthday"]) {
            [self.friendBirthdayTextField setText:self.friendBirthdayDict[@"birthday"]];
        }
        if ([[self.friendBirthdayDict allKeys] containsObject:@"zunchen"]) {
            [self.friendCourtesyTitleTextField setText:self.friendBirthdayDict[@"zunchen"]];
        }
        if ([[self.friendBirthdayDict allKeys] containsObject:@"txtype_str"]) {
            self.txtype = [self.friendBirthdayDict[@"txtype"] integerValue];
            [self.remindTimeTextField setText:self.friendBirthdayDict[@"txtype_str"]];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // 清空friendBirthdayDict
    self.friendBirthdayDict = nil;
}

#pragma mark - Event
- (void)selectFriendBirthday{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"设置出生" message:@"\n\n\n\n\n\n\n\n" preferredStyle:UIAlertControllerStyleAlert];
    
    UIDatePicker *datePicker = [UIDatePicker new];
    [datePicker setLocale:[NSLocale localeWithLocaleIdentifier:@"zh"]];
    [datePicker setDatePickerMode:UIDatePickerModeDate];
    // 生日最大值为当前日期
    [datePicker setMaximumDate:[NSDate new]];
    [alert.view addSubview:datePicker];
    [datePicker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(alert.view).mas_offset(30);
        make.right.mas_equalTo(alert.view).mas_offset(-30);
        make.height.mas_equalTo(180);
        make.centerY.mas_equalTo(alert.view);
    }];
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy.MM.dd"];
    if ([self.friendBirthdayTextField.text length] != 0) {
        NSDate *friendBirthday = [dateFormatter dateFromString:[self.friendBirthdayTextField text]];
        [datePicker setDate:friendBirthday];
    }
    __weak __typeof__(self) weakSelf = self;
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *dateString = [dateFormatter stringFromDate:[datePicker date]];
        [weakSelf.friendBirthdayTextField setText:dateString];
        
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)selectRemindTime{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"设置提醒时间" message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    __weak __typeof__(self) weakSelf = self;
    [alert addAction:[UIAlertAction actionWithTitle:@"生日当前提醒" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.txtype = 1;
        [weakSelf.remindTimeTextField setText:@"生日当前提醒"];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"生日前2天提醒" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.txtype = 2;
        [weakSelf.remindTimeTextField setText:@"生日前2天提醒"];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"生日前1周提醒" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.txtype = 3;
        [weakSelf.remindTimeTextField setText:@"生日前1周提醒"];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)saveAction{
    if ([[self.friendNameTextField text] length] == 0) {
        [self.view makeToast:@"请输入亲友姓名！"];
        return;
    }
    if ([[self.friendCourtesyTitleTextField text] length] == 0) {
        [self.view makeToast:@"请输入亲友尊称！"];
        return;
    }
    if ([[self.friendBirthdayTextField text] length] == 0) {
        [self.view makeToast:@"请设置亲友生日！"];
        return;
    }
    if ([[self.remindTimeTextField text] length] == 0) {
        [self.view makeToast:@"请设置提醒时间！"];
        return;
    }
    HSNetworkManager *manager = [HSNetworkManager shareManager];
    NSDictionary *data = @{@"birthday":self.friendBirthdayTextField.text, @"txtype":@(self.txtype), @"name":self.friendNameTextField.text, @"zunchen":self.friendCourtesyTitleTextField.text};
    if (self.friendBirthdayDict != nil && [[self.friendBirthdayDict allKeys] containsObject:@"id"]) {
        // 如果friendBirthdayDict包含id，说明是更新，带上id
        NSMutableDictionary *mutableData = data.mutableCopy;
        mutableData[@"id"] = self.friendBirthdayDict[@"id"];
        data = mutableData.copy;
    }
    __weak __typeof__(self) weakSelf = self;
    [manager postDataWithUrl:kAddFriendBirthdayRemind parameters:@{@"data":data} success:^(NSDictionary *responseDict) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.view makeToast:responseDict[@"msg"]];
        });
        // 获取成功
        if ([responseDict[@"errcode"] isEqual:@(0)]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [weakSelf.navigationController popViewControllerAnimated:YES];
            });
        } else {
            NSLog(@"接口 %@ 返回数据格式错误! responseDict = %@", kGetUserInfoUrl, responseDict);
        }
        
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.view makeToast:@"接口请求错误！"];
        });
        NSLog(@"%@", error);
    }];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == self.friendBirthdayTextField) {
        [self selectFriendBirthday];
    } else if (textField == self.remindTimeTextField) {
        [self selectRemindTime];
    }
    return NO;
}

#pragma mark - Private
- (void)initView{
    self.friendNameView = [UIView new];
    [self.view addSubview:self.friendNameView];
    [self.friendNameView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view.mas_top).mas_offset(10);
        make.left.mas_equalTo(self.view.mas_left).mas_offset(20);
        make.right.mas_equalTo(self.view.mas_right).mas_offset(-20);
        make.height.mas_equalTo(40);
    }];
    [self.friendNameView.layer setBorderWidth:1];
    [self.friendNameView.layer setCornerRadius:5];
    [self.friendNameView.layer setBorderColor:[[UIColor blackColor] CGColor]];
    UILabel *friendNameTitleLabel = [UILabel new];
    [friendNameTitleLabel setText:@"亲友姓名:"];
    [self.friendNameView addSubview:friendNameTitleLabel];
    [friendNameTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.friendNameView);
        make.left.mas_equalTo(self.friendNameView).mas_offset(10);
        make.size.mas_equalTo(CGSizeMake(80, 30));
    }];
    self.friendNameTextField = [UITextField new];
    [self.friendNameTextField setPlaceholder:@"请输入姓名"];
    [self.friendNameView addSubview:self.friendNameTextField];
    [self.friendNameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.friendNameView);
        make.left.mas_equalTo(friendNameTitleLabel.mas_right).mas_offset(10);
        make.right.mas_equalTo(self.friendNameView.mas_right).mas_offset(-10);
        make.height.mas_equalTo(30);
    }];
    
    self.friendCourtesyTitleView = [UIView new];
    [self.view addSubview:self.friendCourtesyTitleView];
    [self.friendCourtesyTitleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.top.mas_equalTo(self.friendNameView.mas_bottom).mas_offset(10);
        make.left.mas_equalTo(self.view.mas_left).mas_offset(20);
        make.right.mas_equalTo(self.view.mas_right).mas_offset(-20);
        make.height.mas_equalTo(40);
    }];
    [self.friendCourtesyTitleView.layer setBorderWidth:1];
    [self.friendCourtesyTitleView.layer setCornerRadius:5];
    [self.friendCourtesyTitleView.layer setBorderColor:[[UIColor blackColor] CGColor]];
    UILabel *friendCourtesyTitleLabel = [UILabel new];
    [friendCourtesyTitleLabel setText:@"尊称:"];
    [self.friendCourtesyTitleView addSubview:friendCourtesyTitleLabel];
    [friendCourtesyTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.friendCourtesyTitleView);
        make.left.mas_equalTo(self.friendCourtesyTitleView).mas_offset(10);
        make.size.mas_equalTo(CGSizeMake(80, 30));
    }];
    self.friendCourtesyTitleTextField = [UITextField new];
    [self.friendCourtesyTitleTextField setPlaceholder:@"请输入尊称"];
    [self.friendCourtesyTitleView addSubview:self.friendCourtesyTitleTextField];
    [self.friendCourtesyTitleTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.friendCourtesyTitleView);
        make.left.mas_equalTo(friendCourtesyTitleLabel.mas_right).mas_offset(10);
        make.right.mas_equalTo(self.friendCourtesyTitleView.mas_right).mas_offset(-10);
        make.height.mas_equalTo(30);
    }];
    
    self.friendBirthdayView = [UIView new];
    [self.view addSubview:self.friendBirthdayView];
    [self.friendBirthdayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.top.mas_equalTo(self.friendCourtesyTitleView.mas_bottom).mas_offset(10);
        make.left.mas_equalTo(self.view.mas_left).mas_offset(20);
        make.right.mas_equalTo(self.view.mas_right).mas_offset(-20);
        make.height.mas_equalTo(40);
    }];
    [self.friendBirthdayView.layer setBorderWidth:1];
    [self.friendBirthdayView.layer setCornerRadius:5];
    [self.friendBirthdayView.layer setBorderColor:[[UIColor blackColor] CGColor]];
    UILabel *friendBirthdayTitleLabel = [UILabel new];
    [friendBirthdayTitleLabel setText:@"生日:"];
    [self.friendBirthdayView addSubview:friendBirthdayTitleLabel];
    [friendBirthdayTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.friendBirthdayView);
        make.left.mas_equalTo(self.friendBirthdayView).mas_offset(10);
        make.size.mas_equalTo(CGSizeMake(80, 30));
    }];
    self.friendBirthdayTextField = [UITextField new];
    [self.friendBirthdayTextField setDelegate:self];
    [self.friendBirthdayTextField setPlaceholder:@"请输入生日"];
    [self.friendBirthdayView addSubview:self.friendBirthdayTextField];
    [self.friendBirthdayTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.friendBirthdayView);
        make.left.mas_equalTo(friendBirthdayTitleLabel.mas_right).mas_offset(10);
        make.right.mas_equalTo(self.friendBirthdayView.mas_right).mas_offset(-10);
        make.height.mas_equalTo(30);
    }];
    
    self.remindTimeView = [UIView new];
    [self.view addSubview:self.remindTimeView];
    [self.remindTimeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.top.mas_equalTo(self.friendBirthdayView.mas_bottom).mas_offset(10);
        make.left.mas_equalTo(self.view.mas_left).mas_offset(20);
        make.right.mas_equalTo(self.view.mas_right).mas_offset(-20);
        make.height.mas_equalTo(40);
    }];
    [self.remindTimeView.layer setBorderWidth:1];
    [self.remindTimeView.layer setCornerRadius:5];
    [self.remindTimeView.layer setBorderColor:[[UIColor blackColor] CGColor]];
    UILabel *remindTimeTitleLabel = [UILabel new];
    [remindTimeTitleLabel setText:@"提醒时间:"];
    [self.remindTimeView addSubview:remindTimeTitleLabel];
    [remindTimeTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.remindTimeView);
        make.left.mas_equalTo(self.remindTimeView).mas_offset(10);
        make.size.mas_equalTo(CGSizeMake(80, 30));
    }];
    self.remindTimeTextField = [UITextField new];
    [self.remindTimeTextField setDelegate:self];
    [self.remindTimeTextField setPlaceholder:@"请输入提醒时间"];
    
    [self.remindTimeView addSubview:self.remindTimeTextField];
    [self.remindTimeTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.remindTimeView);
        make.left.mas_equalTo(remindTimeTitleLabel.mas_right).mas_offset(10);
        make.right.mas_equalTo(self.remindTimeView.mas_right).mas_offset(-10);
        make.height.mas_equalTo(30);
    }];
    
    self.saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.saveButton setBackgroundImage:[UIImage imageNamed:@"common_background"] forState:UIControlStateNormal];
    [self.saveButton setTitle:@"保存" forState:UIControlStateNormal];
    [self.saveButton setTitle:@"" forState:UIControlStateHighlighted];
    [self.saveButton.layer setCornerRadius:5];
    [self.saveButton addTarget:self action:@selector(saveAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.saveButton];
    [self.saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.remindTimeView.mas_bottom).mas_offset(10);
        make.centerX.mas_equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(100, 30));
    }];
    
}

@end
