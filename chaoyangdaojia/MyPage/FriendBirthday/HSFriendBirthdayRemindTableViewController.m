//
//  HSFriendBirthdayRemindTableViewController.m
//  chaoyangdaojia
//
//  Created by hestyle on 2020/12/28.
//  Copyright © 2020 hestyle. All rights reserved.
//

#import "HSFriendBirthdayRemindTableViewController.h"
#import "HSFriendBirthdayEditViewController.h"
#import "HSNetwork.h"
#import <Masonry/Masonry.h>
#import <Toast/Toast.h>

@interface HSFriendBirthdayRemindTableViewController ()

@property (nonatomic, strong) UIView *refreshView;
@property (nonatomic, strong) UIImageView *refreshImageView;
@property (nonatomic, strong) UILabel *refreshLabel;
@property (nonatomic, strong) UILabel *lastRefreshTimeLabel;

@property NSUInteger nextLoadPage;
@property (nonatomic, strong) UIView *loadMoreView;
@property (nonatomic, strong) UILabel *loadMoreLabel;

@property (nonatomic, strong) NSMutableArray *friendBirthdayArray;
@property (nonatomic, strong) UIBarButtonItem *rightAddFriendBirthdayBarButtonItem;

@end

/* API请求中1页包含的数量 */
static const NSInteger mPerPage = 10;
/* cell高度 */
static const NSInteger mHeightForRow = 50;
static const NSInteger mRefreshViewHeight = 60;
static const NSInteger mLoadMoreViewHeight = 60;
/* navigationBar高度44、状态栏（狗啃屏）高度44，contentInsetAdjustmentBehavior */
static const NSInteger mTableViewBaseContentOffsetY = -88;


@implementation HSFriendBirthdayRemindTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.rightAddFriendBirthdayBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"新增" style:UIBarButtonItemStylePlain target:self action:@selector(gotoFriendBirthdayAddViewController)];
    
    self.friendBirthdayArray = [NSMutableArray new];
    
    [self initView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 显示“新增”按钮
    [self setTitle:@"亲友生日提醒"];
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationItem setRightBarButtonItem:self.rightAddFriendBirthdayBarButtonItem];
    
    // vc出现时，获取第一页
    [self getFriendBirthdaysByPage:1];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
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
        make.height.mas_equalTo(20);
    }];
    // 宽度足够时，压缩
    [nameLabel setPreferredMaxLayoutWidth:100];
    [nameLabel setContentHuggingPriority:UILayoutPriorityRequired
                                 forAxis:UILayoutConstraintAxisHorizontal];
    
    UILabel *zunchenLabel = [UILabel new];
    [zunchenLabel setText:[NSString stringWithFormat:@" %@ ", friendBirthday[@"zunchen"]]];
    [zunchenLabel setTextColor:[UIColor redColor]];
    [zunchenLabel.layer setBorderWidth:0.5];
    [zunchenLabel.layer setBorderColor:[[UIColor redColor] CGColor]];
    [zunchenLabel setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];
    [cell.contentView addSubview:zunchenLabel];
    [zunchenLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(nameLabel.mas_right).mas_offset(5);
        make.bottom.mas_equalTo(nameLabel);
        make.height.mas_equalTo(16);
    }];
    
    UILabel *birthdayLabel = [UILabel new];
    [birthdayLabel setText:friendBirthday[@"birthday"]];
    [birthdayLabel setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];
    [cell.contentView addSubview:birthdayLabel];
    [birthdayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(nameLabel);
        make.top.mas_equalTo(nameLabel.mas_bottom).mas_offset(5);
        make.height.mas_equalTo(15);
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
        make.height.mas_equalTo(15);
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

#pragma mark - UIScrollView Delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat loadMoreOffset = mTableViewBaseContentOffsetY + mLoadMoreViewHeight;
    if ([self.friendBirthdayArray count] * mHeightForRow > self.view.bounds.size.height + mTableViewBaseContentOffsetY) {
        // tableView的contentheight超过了navigationBar下方到屏幕底部的高度
        loadMoreOffset += [self.friendBirthdayArray count] * mHeightForRow - (self.view.bounds.size.height + mTableViewBaseContentOffsetY);
    }
    if (scrollView.contentOffset.y <= (mTableViewBaseContentOffsetY - mRefreshViewHeight)) {
        if (self.refreshView.tag == 0) {
            self.refreshLabel.text = @"松开刷新";
        }
        self.refreshView.tag = -1;
    } else if (scrollView.contentOffset.y >= loadMoreOffset) {
        if (self.loadMoreView.tag == 0) {
            if (self.nextLoadPage != 0) {
                [self.loadMoreLabel setText:@"松开加载"];
            } else {
                [self.loadMoreLabel setText:@"我是有底线的！"];
            }
        }
        self.loadMoreView.tag = 1;
    } else {
        // 上拉不足触发加载、下拉不足触发刷新
        self.refreshView.tag = 0;
        self.refreshLabel.text = @"下拉刷新";
        
        self.loadMoreView.tag = 0;
        if (self.nextLoadPage != 0) {
            [self.loadMoreLabel setText:@"上拉加载更多"];
        } else {
            [self.loadMoreLabel setText:@"我是有底线的！"];
        }
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    if (self.refreshView.tag == -1) {
        [UIView animateWithDuration:.3 animations:^{
            self.refreshLabel.text = @"加载中";
            scrollView.contentInset = UIEdgeInsetsMake(mRefreshViewHeight, 0.0f, 0.0f, 0.0f);
        }];
        //数据加载成功后执行；这里为了模拟加载效果，一秒后执行恢复原状代码
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:.3 animations:^{
                self.refreshView.tag = 0;
                self.refreshLabel.text = @"下拉刷新";
                scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
                NSLog(@"已触发下拉刷新！");
            }];
        });
        // 重新第1页
        [self getFriendBirthdaysByPage:1];
    } else if (self.loadMoreView.tag == 1) {
        self.loadMoreView.tag = 0;
        // 加载下一页
        if (self.nextLoadPage != 0) {
            NSLog(@"已触发上拉加载更多！");
            [self getFriendBirthdaysByPage:self.nextLoadPage];
        }
    }
    NSLog(@"scrollView.contentOffset.y = %f", scrollView.contentOffset.y);
}

#pragma mark - Private
- (void)initView{
    self.refreshView = [UIView new];
    [self.refreshView setTag:0];
    [self.tableView addSubview:self.refreshView];
    [self.refreshView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.tableView.mas_top).with.offset(-mRefreshViewHeight);
        make.centerX.mas_equalTo(self.tableView.mas_centerX);
        make.width.mas_equalTo([UIScreen mainScreen].bounds.size.width);
        make.height.mas_equalTo(mRefreshViewHeight);
    }];
    
    self.refreshLabel = [UILabel new];
    [self.refreshLabel setTextAlignment:NSTextAlignmentCenter];
    [self.refreshLabel setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];
    [self.refreshView addSubview:self.refreshLabel];
    [self.refreshLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.refreshView.mas_top).with.offset(7.5);
        make.centerX.mas_equalTo(self.refreshView.mas_centerX).with.offset(10);
        make.size.mas_equalTo(CGSizeMake(100, 20));
    }];
    
    self.lastRefreshTimeLabel = [UILabel new];
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    // 获取当前时间日期展示字符串 如：2019-05-23-13:58:59
    [self.lastRefreshTimeLabel setText:[NSString stringWithFormat:@"最后更新: %@", [formatter stringFromDate:date]]];
    [self.lastRefreshTimeLabel setTextAlignment:NSTextAlignmentCenter];
    [self.lastRefreshTimeLabel setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];
    [self.refreshView addSubview:self.lastRefreshTimeLabel];
    [self.lastRefreshTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.refreshLabel.mas_bottom).with.offset(2.5);
        make.centerX.mas_equalTo(self.tableView.mas_centerX).with.offset(10);
        make.size.mas_equalTo(CGSizeMake(180, 20));
    }];

    self.refreshImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"refresh_arrow"]];
    [self.refreshView addSubview:self.refreshImageView];
    [self.refreshImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.lastRefreshTimeLabel.mas_left).with.offset(-20);
        make.centerY.mas_equalTo(self.refreshView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(30, 50));
    }];
    
    self.nextLoadPage = 0;
    self.loadMoreView = [UIView new];
    [self.loadMoreView setTag:0];
    [self.loadMoreView.layer setBorderWidth:0.5];
    [self.loadMoreView.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [self.tableView addSubview:self.loadMoreView];
    [self.loadMoreView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.tableView).mas_offset([UIScreen mainScreen].bounds.size.height + mTableViewBaseContentOffsetY);
        make.centerX.mas_equalTo(self.tableView.mas_centerX);
        make.width.mas_equalTo([UIScreen mainScreen].bounds.size.width);
        make.height.mas_equalTo(mLoadMoreViewHeight);
    }];
    self.loadMoreLabel = [UILabel new];
    [self.loadMoreLabel setText:@"上拉加载更多"];
    [self.loadMoreLabel setTextAlignment:NSTextAlignmentCenter];
    [self.loadMoreLabel setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];
    [self.loadMoreView addSubview:self.loadMoreLabel];
    [self.loadMoreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.loadMoreView);
        make.height.mas_equalTo(20);
    }];
}

- (void)getFriendBirthdaysByPage:(NSUInteger)page {
    HSNetworkManager *manager = [HSNetworkManager shareManager];
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
            // 判断是否有下一页
            if ([listData count] < mPerPage) {
                weakSelf.nextLoadPage = 0;
            } else {
                weakSelf.nextLoadPage = page + 1;
            }
            if (![listData isEqual:[NSNull null]] && listData != nil) {
                [weakSelf.friendBirthdayArray addObjectsFromArray:listData];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                // 更新ui
                [weakSelf.tableView reloadData];
                NSLog(@"[UIScreen mainScreen].bounds.size.height = %f", [UIScreen mainScreen].bounds.size.height);
                NSLog(@"view.bounds.size.height = %f", weakSelf.view.bounds.size.height);
                if ([weakSelf.friendBirthdayArray count] * mHeightForRow >= weakSelf.view.bounds.size.height + mTableViewBaseContentOffsetY) {
                    // tableView的contentSize.height > 屏幕高度
                    [weakSelf.loadMoreView mas_updateConstraints:^(MASConstraintMaker *make) {
                        make.top.mas_equalTo([weakSelf.friendBirthdayArray count] * mHeightForRow);
                        make.centerX.mas_equalTo(weakSelf.tableView.mas_centerX);
                        make.width.mas_equalTo([UIScreen mainScreen].bounds.size.width);
                        make.height.mas_equalTo(mLoadMoreViewHeight);
                    }];
                } else {
                    // tableView内容过少
                    [weakSelf.loadMoreView mas_updateConstraints:^(MASConstraintMaker *make) {
                        make.top.mas_equalTo(weakSelf.tableView).mas_offset([UIScreen mainScreen].bounds.size.height + mTableViewBaseContentOffsetY);
                        make.centerX.mas_equalTo(weakSelf.tableView.mas_centerX);
                        make.width.mas_equalTo([UIScreen mainScreen].bounds.size.width);
                        make.height.mas_equalTo(mLoadMoreViewHeight);
                    }];
                }
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
    HSNetworkManager *manager = [HSNetworkManager shareManager];
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
