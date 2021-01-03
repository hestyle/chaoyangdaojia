//
//  HSCommonProblemTableViewController.m
//  chaoyangdaojia
//
//  Created by hestyle on 2021/1/3.
//  Copyright © 2021 hestyle. All rights reserved.
//

#import "HSCommonProblemTableViewController.h"
#import "HSCommonProblemDetailViewController.h"
#import "HSNetworkManager.h"
#import "HSNetworkUrl.h"
#import <Toast/Toast.h>
#import <Masonry/Masonry.h>

@interface HSCommonProblemTableViewController ()

@property (nonatomic, strong) UIView *refreshView;
@property (nonatomic, strong) UIImageView *refreshImageView;
@property (nonatomic, strong) UILabel *refreshLabel;
@property (nonatomic, strong) UILabel *lastRefreshTimeLabel;

@property NSUInteger nextLoadPage;
@property (nonatomic, strong) UIView *loadMoreView;
@property (nonatomic, strong) UILabel *loadMoreLabel;

@property (nonatomic, strong) NSMutableArray *commonProblemArray;

@end

/* API请求中1页包含的数量 */
/* API请求中1页包含的数量 */
static const NSInteger mPerPage = 10;
/* cell高度 */
static const NSInteger mheightForCell = 50;
static const NSInteger mRefreshViewHeight = 60;
static const NSInteger mLoadMoreViewHeight = 60;
/* navigationBar高度44、状态栏（狗啃屏）高度44，contentInsetAdjustmentBehavior */
static const NSInteger mTableViewBaseContentOffsetY = -88;

@implementation HSCommonProblemTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self setTitle:@"常见问题"];
    [self.navigationController setNavigationBarHidden:NO];
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    self.commonProblemArray = [NSMutableArray new];
    
    [self initView];
}

- (void)viewWillAppear:(BOOL)animated {
    self.nextLoadPage = 1;
    [self getCommonProblemByPage:1];
}

#pragma mark - UIScrollView Delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat loadMoreOffset = mTableViewBaseContentOffsetY + mLoadMoreViewHeight;
    if ([self.commonProblemArray count] * mheightForCell > self.view.bounds.size.height + mTableViewBaseContentOffsetY) {
        // tableView的contentheight超过了navigationBar下方到屏幕底部的高度
        loadMoreOffset += [self.commonProblemArray count] * mheightForCell - (self.view.bounds.size.height + mTableViewBaseContentOffsetY);
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

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
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
        [self getCommonProblemByPage:1];
    } else if (self.loadMoreView.tag == 1) {
        self.loadMoreView.tag = 0;
        // 加载下一页
        if (self.nextLoadPage != 0) {
            NSLog(@"已触发上拉加载更多！");
            [self getCommonProblemByPage:self.nextLoadPage];
        }
    }
    NSLog(@"scrollView.contentOffset.y = %f", scrollView.contentOffset.y);
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [self.commonProblemArray count];
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return mheightForCell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    NSDictionary *commonProblem = self.commonProblemArray[indexPath.row];
    UILabel *titleLabel = [UILabel new];
    [titleLabel setText:commonProblem[@"title"]];
    [cell.contentView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(cell.contentView).mas_offset(20);
        make.centerY.mas_equalTo(cell.contentView);
    }];
    UIImageView *detailImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"goto_detail"]];
    [cell.contentView addSubview:detailImageView];
    [detailImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(cell.contentView);
        make.right.mas_equalTo(cell.contentView.mas_right).offset(-20);
        make.size.mas_equalTo(CGSizeMake(15, 15));
    }];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    HSCommonProblemDetailViewController *controller = [[HSCommonProblemDetailViewController alloc] initWithCommonProblem:self.commonProblemArray[indexPath.row]];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Private
- (void)initView {
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

- (void)getCommonProblemByPage:(NSUInteger)page {
    HSNetworkManager *manager = [HSNetworkManager manager];
    NSString *url = [kGetCommonProblemByPage stringByAppendingFormat:@"?page=%ld", page];
    __weak __typeof__(self) weakSelf = self;
    [manager getDataWithUrl:url parameters:[NSDictionary new] success:^(NSDictionary *responseDict) {
        // 获取成功
        if ([responseDict[@"errcode"] isEqual:@(0)]) {
            if (page == 1) {
                // 获取首页，则清空所有
                [weakSelf.commonProblemArray removeAllObjects];
            }
            NSArray *listData = responseDict[@"list"];
            // 判断是否有下一页
            if ([listData count] < mPerPage) {
                weakSelf.nextLoadPage = 0;
            } else {
                weakSelf.nextLoadPage = page + 1;
            }
            if (![listData isEqual:[NSNull null]] && listData != nil) {
                [weakSelf.commonProblemArray addObjectsFromArray:listData];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                // 更新ui
                [weakSelf.tableView reloadData];
                NSLog(@"[UIScreen mainScreen].bounds.size.height = %f", [UIScreen mainScreen].bounds.size.height);
                NSLog(@"view.bounds.size.height = %f", weakSelf.view.bounds.size.height);
                if ([weakSelf.commonProblemArray count] * mheightForCell >= weakSelf.view.bounds.size.height + mTableViewBaseContentOffsetY) {
                    // tableView的contentSize.height > 屏幕高度
                    [weakSelf.loadMoreView mas_updateConstraints:^(MASConstraintMaker *make) {
                        make.top.mas_equalTo([weakSelf.commonProblemArray count] * mheightForCell);
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
@end
