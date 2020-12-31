//
//  HSFriendBirthdayRemindTableViewController.m
//  chaoyangdaojia
//
//  Created by hestyle on 2020/12/28.
//  Copyright © 2020 hestyle. All rights reserved.
//

#import "HSFriendBirthdayRemindTableViewController.h"
#import "HSFriendBirthdayEditViewController.h"
#import "HSNetworkManager.h"
#import "HSNetworkUrl.h"
#import <Masonry/Masonry.h>
#import <Toast/Toast.h>

@interface HSFriendBirthdayRemindTableViewController ()

@property (nonatomic, strong) NSMutableArray *friendBirthdayArray;
@property (nonatomic, strong) UIBarButtonItem *rightAddFriendBirthdayBarButtonItem;

@end

@implementation HSFriendBirthdayRemindTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.rightAddFriendBirthdayBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"新增" style:UIBarButtonItemStylePlain target:self action:@selector(gotoFriendBirthdayAddViewController)];
    
    self.friendBirthdayArray = [NSMutableArray new];
}

- (void)viewWillAppear:(BOOL)animated {
    // 显示“新增”按钮
    [self setTitle:@"亲友生日提醒"];
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationItem setRightBarButtonItem:self.rightAddFriendBirthdayBarButtonItem];
    
    // vc出现时，获取第一页
    [self getFriendBirthdaysByPage:1];
}

- (void)viewWillDisappear:(BOOL)animated {
    // 隐藏“新增”按钮
    [self.tabBarController.navigationItem setRightBarButtonItem:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.friendBirthdayArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != 0 || indexPath.row >= [self.friendBirthdayArray count]) {
        return;
    }
    NSDictionary *friendBirthday = self.friendBirthdayArray[indexPath.row];
    HSFriendBirthdayEditViewController *controller = [HSFriendBirthdayEditViewController new];
    [controller setFriendBirthday:friendBirthday];
    [self.navigationController pushViewController:controller animated:YES];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != 0 || indexPath.row >= [self.friendBirthdayArray count]) {
        return nil;
    }
    UITableViewCell *cell = [UITableViewCell new];
    NSDictionary *friendBirthday = self.friendBirthdayArray[indexPath.row];
    UILabel *nameLabel = [UILabel new];
    [nameLabel setText:friendBirthday[@"name"]];
    [cell.contentView addSubview:nameLabel];
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(cell.contentView).mas_offset(20);
        make.top.mas_equalTo(cell.contentView).mas_offset(5);
        make.size.mas_equalTo(CGSizeMake(100, 20));
    }];
    // 宽度足够时，压缩
    [nameLabel setPreferredMaxLayoutWidth:100];
    [nameLabel setContentHuggingPriority:UILayoutPriorityRequired
                                 forAxis:UILayoutConstraintAxisHorizontal];
    
    UILabel *zunchenLabel = [UILabel new];
    [zunchenLabel setText:friendBirthday[@"zunchen"]];
    [zunchenLabel setTextColor:[UIColor redColor]];
    [zunchenLabel.layer setBorderWidth:0.5];
    [zunchenLabel.layer setBorderColor:[[UIColor redColor] CGColor]];
    [zunchenLabel setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];
    [cell.contentView addSubview:zunchenLabel];
    [zunchenLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(nameLabel.mas_right).mas_offset(5);
        make.bottom.mas_equalTo(nameLabel);
        make.size.mas_equalTo(CGSizeMake(100, 20));
    }];
    [zunchenLabel setPreferredMaxLayoutWidth:100];
    [zunchenLabel setContentHuggingPriority:UILayoutPriorityRequired
                                 forAxis:UILayoutConstraintAxisHorizontal];
    
    UILabel *birthdayLabel = [UILabel new];
    [birthdayLabel setText:friendBirthday[@"birthday"]];
    [birthdayLabel setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];
    [cell.contentView addSubview:birthdayLabel];
    [birthdayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(nameLabel);
        make.top.mas_equalTo(nameLabel.mas_bottom).mas_offset(5);
        make.size.mas_equalTo(CGSizeMake(100, 15));
    }];
    [birthdayLabel sizeToFit];
    
    UILabel *remindTimeLabel = [UILabel new];
    [remindTimeLabel setText:friendBirthday[@"txtype_str"]];
    [remindTimeLabel setTextAlignment:NSTextAlignmentRight];
    [remindTimeLabel setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];
    [cell.contentView addSubview:remindTimeLabel];
    [remindTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(cell.contentView);
        make.right.mas_equalTo(cell.contentView).mas_offset(-20);
        make.size.mas_equalTo(CGSizeMake(120, 15));
    }];
    [remindTimeLabel sizeToFit];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    UIContextualAction *editRowAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"编辑" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
            if (indexPath.section != 0 || indexPath.row >= [self.friendBirthdayArray count]) {
                return;
            }
            NSDictionary *friendBirthday = self.friendBirthdayArray[indexPath.row];
            HSFriendBirthdayEditViewController *controller = [HSFriendBirthdayEditViewController new];
            [controller setFriendBirthday:friendBirthday];
            [self.navigationController pushViewController:controller animated:YES];
    }];
    [editRowAction setBackgroundColor:[UIColor systemBlueColor]];
    UIContextualAction *deleteRowAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"删除" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"删除生日提醒" message:@"是否需要删除该提醒？" preferredStyle:UIAlertControllerStyleAlert];
        [controller addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [controller addAction:[UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            NSDictionary *friendBirthday = self.friendBirthdayArray[indexPath.row];
            [self deleteFriendBirthdayRemind:[friendBirthday[@"id"] integerValue] indexPath:indexPath];
        }]];
        [self presentViewController:controller animated:YES completion:nil];
    }];
    [deleteRowAction setBackgroundColor:[UIColor redColor]];
    return [UISwipeActionsConfiguration configurationWithActions:@[deleteRowAction, editRowAction]];
}

#pragma mark - private
- (void)getFriendBirthdaysByPage:(NSUInteger)page {
    HSNetworkManager *manager = [HSNetworkManager manager];
    NSString *url = [kGetFriendBirthdaysByPageUrl stringByAppendingFormat:@"?page=%ld", page];
    __weak __typeof__(self) weakSelf = self;
    [manager getDataWithUrl:url parameters:[NSDictionary new] success:^(NSDictionary *responseDict) {
        // 获取成功
        if ([responseDict[@"errcode"] isEqual:@(0)]) {
            if (page == 1) {
                // 获取首页，则清空所有
                [weakSelf.friendBirthdayArray removeAllObjects];
            }
            NSArray *listData = responseDict[@"list"];
            if (![listData isEqual:[NSNull null]] && listData != nil) {
                [weakSelf.friendBirthdayArray addObjectsFromArray:listData];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                // 更新ui
                [weakSelf.tableView reloadData];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tableView makeToast:responseDict[@"msg"] duration:3 position:CSToastPositionCenter];
            });
            NSLog(@"接口 %@ 返回数据格式错误! responseDict = %@", kModifyUserInfoUrl, responseDict);
        }
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.tableView makeToast:@"获取失败，接口请求错误！" duration:3 position:CSToastPositionCenter];
        });
        NSLog(@"%@", error);
    }];
}

- (void)deleteFriendBirthdayRemind:(NSUInteger)id indexPath:(NSIndexPath *)indexPath {
    HSNetworkManager *manager = [HSNetworkManager manager];
    NSString *url = [kDeleteFriendBirthdayRemind stringByAppendingFormat:@"?id=%ld", id];
    __weak __typeof__(self) weakSelf = self;
    [manager getDataWithUrl:url parameters:[NSDictionary new] success:^(NSDictionary *responseDict) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.tableView makeToast:responseDict[@"msg"] duration:3 position:CSToastPositionCenter];
        });
        // 获取成功
        if ([responseDict[@"errcode"] isEqual:@(0)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // 更新ui
                [weakSelf.friendBirthdayArray removeObjectAtIndex:indexPath.row];
                [weakSelf.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            });
        } else {
            NSLog(@"接口 %@ 返回数据格式错误! responseDict = %@", url, responseDict);
        }
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.tableView makeToast:@"删除失败，接口请求错误！" duration:3 position:CSToastPositionCenter];
        });
        NSLog(@"%@", error);
    }];
}

- (void)gotoFriendBirthdayAddViewController {
    HSFriendBirthdayEditViewController *controller = [HSFriendBirthdayEditViewController new];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
