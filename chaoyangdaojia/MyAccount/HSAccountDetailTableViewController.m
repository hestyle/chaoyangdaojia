//
//  HSAccountDetailTableViewController.m
//  chaoyangdaojia
//
//  Created by hestyle on 2020/12/27.
//  Copyright © 2020 hestyle. All rights reserved.
//

#import "HSAccountDetailTableViewController.h"
#import "HSNetworkManager.h"
#import "HSNetworkUrl.h"
#import <Masonry/Masonry.h>
#import <Toast/Toast.h>

@interface HSAccountDetailTableViewController ()

@property (nonatomic, strong) NSArray<UITableViewCell *> *tableCellArray;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *nickNameLabel;
@property (nonatomic, strong) UILabel *genderLabel;
@property (nonatomic, strong) UILabel *birthdayLabel;
@property (nonatomic, strong) UILabel *authenticationLabel;

@end

@implementation HSAccountDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self setTitle:@"个人信息"];
    [self.navigationController setNavigationBarHidden:NO];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self initTableCellArray];
}

#pragma mark tableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [self.tableCellArray count];
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return 70;
        } else {
            return 50;
        }
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return self.tableCellArray[indexPath.row];
    } else {
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            // 修改头像
            [self.tableView makeToast:@"点击了修改头像！" duration:3 position:CSToastPositionCenter];
        } else if (indexPath.row == 1) {
            // 修改用户名
            [self modifyNickName];
        } else if (indexPath.row == 2) {
            // 修改性别
            [self modifyGender];
        } else if (indexPath.row == 3) {
            // 修改出生日期
            [self modifyBirthday];
        } else if (indexPath.row == 4) {
            // 修改实名认证
            [self.tableView makeToast:@"点击了修改实名认证！" duration:3 position:CSToastPositionCenter];
        } else if (indexPath.row == 5) {
            // 修改亲友生日提醒
            [self.tableView makeToast:@"点击了修改亲友生日提醒！" duration:3 position:CSToastPositionCenter];
        }
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - event
- (void)modifyAvatar{
    
}

- (void)modifyNickName{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"修改昵称" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UITextField *textField = [UITextField new];
    [textField setText:self.nickNameLabel.text];
    [textField.layer setBorderWidth:1];
    [textField.layer setCornerRadius:5];
    [textField.layer setBorderColor:[[UIColor systemBlueColor] CGColor]];
    [alert.view addSubview:textField];
    [textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(alert.view).with.offset(55);
        make.bottom.mas_equalTo(alert.view).with.offset(-60);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(200);
        make.centerX.mas_equalTo(alert.view.mas_centerX);
    }];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    __weak __typeof__(self) weakSelf = self;
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        HSNetworkManager *manager = [HSNetworkManager manager];
        NSDictionary *parameters = @{@"type":@"nickname",@"value":[textField text]};
        [manager postDataWithUrl:kModifyUserInfoUrl parameters:parameters success:^(NSDictionary *responseDict) {
            // 获取成功
            if ([responseDict[@"errcode"] isEqual:@(0)]) {
                NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
                NSMutableDictionary *userInfoDict = [[userDefault valueForKey:@"USER_INFO"] mutableCopy];
                userInfoDict[@"nickname"] = [weakSelf.nickNameLabel text];
                // 更新缓存
                [userDefault setObject:userInfoDict.copy forKey:@"USER_INFO"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    // 更新ui
                    [weakSelf.nickNameLabel setText:textField.text];
                    [weakSelf.tableView makeToast:@"修改成功！" duration:3 position:CSToastPositionCenter];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.tableView makeToast:responseDict[@"msg"] duration:3 position:CSToastPositionCenter];
                });
                NSLog(@"接口 %@ 返回数据格式错误! responseDict = %@", kModifyUserInfoUrl, responseDict);
            }
        } failure:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tableView makeToast:@"修改失败，接口请求错误！" duration:3 position:CSToastPositionCenter];
            });
            NSLog(@"%@", error);
        }];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)modifyGender{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"修改性别" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    __weak __typeof__(self) weakSelf = self;
    [alert addAction:[UIAlertAction actionWithTitle:@"男" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        HSNetworkManager *manager = [HSNetworkManager manager];
        NSDictionary *parameters = @{@"type":@"sex",@"value":@"1"};
        [manager postDataWithUrl:kModifyUserInfoUrl parameters:parameters success:^(NSDictionary *responseDict) {
            // 获取成功
            if ([responseDict[@"errcode"] isEqual:@(0)]) {
                NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
                NSMutableDictionary *userInfoDict = [[userDefault valueForKey:@"USER_INFO"] mutableCopy];
                userInfoDict[@"sex"] = @"1";
                // 更新缓存
                [userDefault setObject:userInfoDict.copy forKey:@"USER_INFO"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    // 更新ui
                    [weakSelf.genderLabel setText:@"男"];
                    [weakSelf.tableView makeToast:@"修改成功！" duration:3 position:CSToastPositionCenter];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.tableView makeToast:responseDict[@"msg"] duration:3 position:CSToastPositionCenter];
                });
                NSLog(@"接口 %@ 返回数据格式错误! responseDict = %@", kModifyUserInfoUrl, responseDict);
            }
        } failure:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tableView makeToast:@"修改失败，接口请求错误！" duration:3 position:CSToastPositionCenter];
            });
            NSLog(@"%@", error);
        }];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"女" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        HSNetworkManager *manager = [HSNetworkManager manager];
        NSDictionary *parameters = @{@"type":@"sex",@"value":@"2"};
        [manager postDataWithUrl:kModifyUserInfoUrl parameters:parameters success:^(NSDictionary *responseDict) {
            // 获取成功
            if ([responseDict[@"errcode"] isEqual:@(0)]) {
                NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
                NSMutableDictionary *userInfoDict = [[userDefault valueForKey:@"USER_INFO"] mutableCopy];
                userInfoDict[@"sex"] = @"2";
                // 更新缓存
                [userDefault setObject:userInfoDict.copy forKey:@"USER_INFO"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    // 更新ui
                    [weakSelf.genderLabel setText:@"女"];
                    [weakSelf.tableView makeToast:@"修改成功！" duration:3 position:CSToastPositionCenter];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.tableView makeToast:responseDict[@"msg"] duration:3 position:CSToastPositionCenter];
                });
                NSLog(@"接口 %@ 返回数据格式错误! responseDict = %@", kModifyUserInfoUrl, responseDict);
            }
        } failure:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tableView makeToast:@"修改失败，接口请求错误！" duration:3 position:CSToastPositionCenter];
            });
            NSLog(@"%@", error);
        }];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"保密" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        HSNetworkManager *manager = [HSNetworkManager manager];
        NSDictionary *parameters = @{@"type":@"sex",@"value":@"0"};
        [manager postDataWithUrl:kModifyUserInfoUrl parameters:parameters success:^(NSDictionary *responseDict) {
            // 获取成功
            if ([responseDict[@"errcode"] isEqual:@(0)]) {
                NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
                NSMutableDictionary *userInfoDict = [[userDefault valueForKey:@"USER_INFO"] mutableCopy];
                userInfoDict[@"sex"] = @"0";
                // 更新缓存
                [userDefault setObject:userInfoDict.copy forKey:@"USER_INFO"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    // 更新ui
                    [weakSelf.genderLabel setText:@"保密"];
                    [weakSelf.tableView makeToast:@"修改成功！" duration:3 position:CSToastPositionCenter];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.tableView makeToast:responseDict[@"msg"] duration:3 position:CSToastPositionCenter];
                });
                NSLog(@"接口 %@ 返回数据格式错误! responseDict = %@", kModifyUserInfoUrl, responseDict);
            }
        } failure:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tableView makeToast:@"修改失败，接口请求错误！" duration:3 position:CSToastPositionCenter];
            });
            NSLog(@"%@", error);
        }];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)modifyBirthday{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"修改出生日期" message:@"\n\n\n\n\n\n\n\n" preferredStyle:UIAlertControllerStyleAlert];
    
    UIDatePicker *datePicker = [UIDatePicker new];
    [datePicker setLocale:[NSLocale localeWithLocaleIdentifier:@"zh"]];
    [datePicker setDatePickerMode:UIDatePickerModeDate];
    [alert.view addSubview:datePicker];
    [datePicker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(alert.view).mas_offset(30);
        make.right.mas_equalTo(alert.view).mas_offset(-30);
        make.height.mas_equalTo(180);
        make.centerY.mas_equalTo(alert.view);
    }];
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy.MM.dd"];
    if (![[self.birthdayLabel text] isEqual:@"未设定"]) {
        NSDate *birthday = [dateFormatter dateFromString:[self.birthdayLabel text]];
        if (birthday != nil) {
            [datePicker setDate:birthday];
        }
    }
    __weak __typeof__(self) weakSelf = self;
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *dateString = [dateFormatter stringFromDate:[datePicker date]];
        HSNetworkManager *manager = [HSNetworkManager manager];
        NSDictionary *parameters = @{@"type":@"birthday",@"value":dateString};
        [manager postDataWithUrl:kModifyUserInfoUrl parameters:parameters success:^(NSDictionary *responseDict) {
            // 获取成功
            if ([responseDict[@"errcode"] isEqual:@(0)]) {
                NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
                NSMutableDictionary *userInfoDict = [[userDefault valueForKey:@"USER_INFO"] mutableCopy];
                userInfoDict[@"birthday"] = dateString;
                // 更新缓存
                [userDefault setObject:userInfoDict.copy forKey:@"USER_INFO"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    // 更新ui
                    [weakSelf.birthdayLabel setText:dateString];
                    [weakSelf.tableView makeToast:@"修改成功！" duration:3 position:CSToastPositionCenter];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.tableView makeToast:responseDict[@"msg"] duration:3 position:CSToastPositionCenter];
                });
                NSLog(@"接口 %@ 返回数据格式错误! responseDict = %@", kModifyUserInfoUrl, responseDict);
            }
        } failure:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tableView makeToast:@"修改失败，接口请求错误！" duration:3 position:CSToastPositionCenter];
            });
            NSLog(@"%@", error);
        }];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - private

- (void)initTableCellArray{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSDictionary *userInfoDict = [userDefault objectForKey:@"USER_INFO"];
    UIImage *detailImage = [UIImage imageNamed:@"goto_detail"];
    // 头像
    UITableViewCell *avatarCell = [[UITableViewCell alloc] init];
    UILabel *avatarTitleLabel = [UILabel new];
    [avatarTitleLabel setText:@"头像"];
    [avatarCell.contentView addSubview:avatarTitleLabel];
    [avatarTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(avatarCell.contentView);
        make.left.mas_equalTo(avatarCell.contentView).with.offset(20);
        make.size.mas_equalTo(CGSizeMake(100, 20));
    }];
    UIImageView *avatarDetailImageView = [[UIImageView alloc] initWithImage:detailImage];
    [avatarCell.contentView addSubview:avatarDetailImageView];
    [avatarDetailImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(avatarCell.contentView);
        make.right.mas_equalTo(avatarCell.contentView.mas_right).offset(-20);
        make.size.mas_equalTo(CGSizeMake(15, 15));
    }];
    self.avatarImageView = [[UIImageView alloc] init];
    // 读取缓存中的图片
    NSString *path_sandox = NSHomeDirectory();
    NSString *avatarPathSuffix = [userDefault objectForKey:@"AVATAR_PATH"];
    NSString *avatarPath = [path_sandox stringByAppendingPathComponent:avatarPathSuffix];
    UIImage *image = [UIImage imageWithContentsOfFile:avatarPath];
    if (image != nil) {
        [self.avatarImageView setImage:image];
    }
    [avatarCell.contentView addSubview:self.avatarImageView];
    [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(avatarCell.contentView);
        make.right.mas_equalTo(avatarDetailImageView.mas_left);
        make.size.mas_equalTo(CGSizeMake(55, 55));
    }];
    
    // 昵称
    UITableViewCell *nickNameCell = [[UITableViewCell alloc] init];
    UILabel *nickNameTitleLabel = [UILabel new];
    [nickNameTitleLabel setText:@"昵称"];
    [nickNameCell.contentView addSubview:nickNameTitleLabel];
    [nickNameTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(nickNameCell.contentView);
        make.left.mas_equalTo(nickNameCell.contentView).with.offset(20);
        make.size.mas_equalTo(CGSizeMake(100, 20));
    }];
    UIImageView *nickNameDetailImageView = [[UIImageView alloc] initWithImage:detailImage];
    [nickNameCell.contentView addSubview:nickNameDetailImageView];
    [nickNameDetailImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(nickNameCell.contentView);
        make.right.mas_equalTo(nickNameCell.contentView.mas_right).offset(-20);
        make.size.mas_equalTo(CGSizeMake(15, 15));
    }];
    self.nickNameLabel = [UILabel new];
    [self.nickNameLabel setText:userInfoDict[@"nickname"]];
    [self.nickNameLabel setTextAlignment:NSTextAlignmentRight];
    [nickNameCell.contentView addSubview:self.nickNameLabel];
    [self.nickNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(nickNameCell.contentView);
        make.right.mas_equalTo(nickNameDetailImageView.mas_left);
        make.size.mas_equalTo(CGSizeMake(100, 20));
    }];
    
    // 性别
    UITableViewCell *genderCell = [[UITableViewCell alloc] init];
    UILabel *genderTitleLabel = [UILabel new];
    [genderTitleLabel setText:@"性别"];
    [genderCell.contentView addSubview:genderTitleLabel];
    [genderTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(genderCell.contentView);
        make.left.mas_equalTo(genderCell.contentView).with.offset(20);
        make.size.mas_equalTo(CGSizeMake(100, 20));
    }];
    UIImageView *genderDetailImageView = [[UIImageView alloc] initWithImage:detailImage];
    [genderCell.contentView addSubview:genderDetailImageView];
    [genderDetailImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(genderCell.contentView);
        make.right.mas_equalTo(genderCell.contentView.mas_right).offset(-20);
        make.size.mas_equalTo(CGSizeMake(15, 15));
    }];
    self.genderLabel = [UILabel new];
    if ([userInfoDict[@"sex"] isEqual:@"1"]) {
        [self.genderLabel setText:@"男"];
    } else if ([userInfoDict[@"sex"] isEqual:@"2"]) {
        [self.genderLabel setText:@"女"];
    } else {
        [self.genderLabel setText:@"保密"];
    }
    [self.genderLabel setTextAlignment:NSTextAlignmentRight];
    [genderCell.contentView addSubview:self.genderLabel];
    [self.genderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(genderCell.contentView);
        make.right.mas_equalTo(genderDetailImageView.mas_left);
        make.size.mas_equalTo(CGSizeMake(50, 20));
    }];
    
    // 出生日期
    UITableViewCell *birthdayCell = [[UITableViewCell alloc] init];
    UILabel *birthdayTitleLabel = [UILabel new];
    [birthdayTitleLabel setText:@"出生日期"];
    [birthdayCell.contentView addSubview:birthdayTitleLabel];
    [birthdayTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(birthdayCell.contentView);
        make.left.mas_equalTo(birthdayCell.contentView).with.offset(20);
        make.size.mas_equalTo(CGSizeMake(100, 20));
    }];
    UIImageView *birthdayDetailImageView = [[UIImageView alloc] initWithImage:detailImage];
    [birthdayCell.contentView addSubview:birthdayDetailImageView];
    [birthdayDetailImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(birthdayCell.contentView);
        make.right.mas_equalTo(birthdayCell.contentView.mas_right).offset(-20);
        make.size.mas_equalTo(CGSizeMake(15, 15));
    }];
    self.birthdayLabel = [UILabel new];
    if (userInfoDict[@"birthday"] != nil) {
        [self.birthdayLabel setText:userInfoDict[@"birthday"]];
    } else {
        [self.birthdayLabel setText:@"未设定"];
    }
    [self.birthdayLabel setTextAlignment:NSTextAlignmentRight];
    [birthdayCell.contentView addSubview:self.birthdayLabel];
    [self.birthdayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(birthdayCell.contentView);
        make.right.mas_equalTo(birthdayDetailImageView.mas_left);
        make.size.mas_equalTo(CGSizeMake(110, 20));
    }];
    
    // 实名认证
    UITableViewCell *authenticationCell = [[UITableViewCell alloc] init];
    UILabel *authenticationTitleLabel = [UILabel new];
    [authenticationTitleLabel setText:@"实名认证"];
    [authenticationCell.contentView addSubview:authenticationTitleLabel];
    [authenticationTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(authenticationCell.contentView);
        make.left.mas_equalTo(authenticationCell.contentView).with.offset(20);
        make.size.mas_equalTo(CGSizeMake(100, 20));
    }];
    UIImageView *authenticationDetailImageView = [[UIImageView alloc] initWithImage:detailImage];
    [authenticationCell.contentView addSubview:authenticationDetailImageView];
    [authenticationDetailImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(authenticationCell.contentView);
        make.right.mas_equalTo(authenticationCell.contentView.mas_right).offset(-20);
        make.size.mas_equalTo(CGSizeMake(15, 15));
    }];
    self.authenticationLabel = [UILabel new];
    if ([userInfoDict[@"isrenzheng"] isEqual:@(0)]) {
        [self.authenticationLabel setText:@"未认证"];
    } else {
        [self.authenticationLabel setText:@"已设定"];
    }
    [self.authenticationLabel setTextAlignment:NSTextAlignmentRight];
    [authenticationCell.contentView addSubview:self.authenticationLabel];
    [self.authenticationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(authenticationCell.contentView);
        make.right.mas_equalTo(authenticationDetailImageView.mas_left);
        make.size.mas_equalTo(CGSizeMake(100, 20));
    }];
    
    // 亲友生日提醒
    UITableViewCell *friendBirthdayRemindCell = [[UITableViewCell alloc] init];
    UILabel *friendBirthdayRemindTitleLabel = [UILabel new];
    [friendBirthdayRemindTitleLabel setText:@"亲友生日提醒"];
    [friendBirthdayRemindCell.contentView addSubview:friendBirthdayRemindTitleLabel];
    [friendBirthdayRemindTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(friendBirthdayRemindCell.contentView);
        make.left.mas_equalTo(friendBirthdayRemindCell.contentView).with.offset(20);
        make.size.mas_equalTo(CGSizeMake(120, 20));
    }];
    UIImageView *friendBirthdayRemindDetailImageView = [[UIImageView alloc] initWithImage:detailImage];
    [friendBirthdayRemindCell.contentView addSubview:friendBirthdayRemindDetailImageView];
    [friendBirthdayRemindDetailImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(friendBirthdayRemindCell.contentView);
        make.right.mas_equalTo(friendBirthdayRemindCell.contentView.mas_right).offset(-20);
        make.size.mas_equalTo(CGSizeMake(15, 15));
    }];
    
    self.tableCellArray = @[avatarCell, nickNameCell, genderCell, birthdayCell, authenticationCell, friendBirthdayRemindCell];
}


@end
