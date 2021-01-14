//
//  HSShopTableViewController.m
//  chaoyangdaojia
//
//  Created by hestyle on 2021/1/13.
//  Copyright © 2021 hestyle. All rights reserved.
//

#import "HSShopTableViewController.h"
#import "HSShopDetailCollectionViewController.h"
#import "HSNetwork.h"
#import <Masonry/Masonry.h>
#import <Toast/Toast.h>

@interface HSShopTableViewController ()

@property (nonatomic, strong) UIView *refreshView;
@property (nonatomic, strong) UIImageView *refreshImageView;
@property (nonatomic, strong) UILabel *refreshLabel;
@property (nonatomic, strong) UILabel *lastRefreshTimeLabel;

@property NSUInteger nextLoadPage;
@property (nonatomic, strong) UIView *loadMoreView;
@property (nonatomic, strong) UILabel *loadMoreLabel;

@property (nonatomic, strong) NSMutableArray *shopArray;

@end

/* API请求中1页包含的数量 */
static const NSInteger mPerPage = 20;
/* cell高度 */
static const NSInteger mHeightForRow = 100;
static const NSInteger mRefreshViewHeight = 60;
static const NSInteger mLoadMoreViewHeight = 60;
/* navigationBar高度44、状态栏（狗啃屏）高度44，contentInsetAdjustmentBehavior */
static const NSInteger mTableViewBaseContentOffsetY = -88;
static const NSInteger mTabBarHeight = 64;

@implementation HSShopTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    //[self.tableView setContentInset:UIEdgeInsetsMake(0, 0, 64, 0)];
    self.shopArray = [NSMutableArray new];
    [self initView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tabBarController setTitle:@"商家店铺"];
    [self.navigationController setNavigationBarHidden:NO];
    
    [self.tableView setFrame:self.view.frame];
    // vc出现时，获取第一页
    if ([self.shopArray count] == 0) {
        [self getShopsByPage:1];
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.shopArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return mHeightForRow;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != 0 || indexPath.row >= [self.shopArray count]) {
        return nil;
    }
    UITableViewCell *cell = [UITableViewCell new];
    NSDictionary *shopDict = self.shopArray[indexPath.row];
    UIImageView *logoImageView = [UIImageView new];
    [cell.contentView addSubview:logoImageView];
    [logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(70, 70));
        make.left.mas_equalTo(cell.contentView).mas_offset(20);
        make.centerY.mas_equalTo(cell.contentView);
    }];
    if ([[shopDict allKeys] containsObject:@"logoImage"]) {
        [logoImageView setImage:shopDict[@"logoImage"]];
    } else {
        // 加载图片
        __weak __typeof__(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSURL *logoUrl = [NSURL URLWithString:shopDict[@"logo"]];
            NSData *logoData = [NSData dataWithContentsOfURL:logoUrl];
            UIImage *logoImage = [UIImage imageWithData:logoData];
            // 缓存至shopCommentArray中
            NSMutableDictionary *shopMutableDict = shopDict.mutableCopy;
            shopMutableDict[@"logoImage"] = logoImage;
            weakSelf.shopArray[indexPath.row] = shopMutableDict.copy;
            dispatch_async(dispatch_get_main_queue(), ^{
                [logoImageView setImage:logoImage];
            });
        });
    }
    UILabel *shopTitleLabel = [UILabel new];
    [shopTitleLabel setText:[NSString stringWithFormat:@"%@", shopDict[@"title"]]];
    [shopTitleLabel setFont:[UIFont systemFontOfSize:[UIFont systemFontSize] + 2]];
    [cell.contentView addSubview:shopTitleLabel];
    [shopTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(logoImageView.mas_right).mas_offset(10);
        make.top.mas_equalTo(logoImageView);
        make.width.mas_lessThanOrEqualTo(200);
    }];
    if (![shopDict[@"catids_str"] isEqual:[NSNull null]]) {
        NSArray *shopTypeArray = shopDict[@"catids_str"];
        NSMutableArray<UILabel *> *shopTypeLabelArray = [NSMutableArray new];
        for (int i = 0; i < [shopTypeArray count]; ++i) {
            UILabel *shopTypeLabel = [UILabel new];
            [shopTypeLabel setText:[NSString stringWithFormat:@"%@", shopTypeArray[i]]];
            [shopTypeLabel setTextColor:[UIColor redColor]];
            [shopTypeLabel setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];
            [shopTypeLabel.layer setBorderColor:[[UIColor redColor] CGColor]];
            [shopTypeLabel.layer setBorderWidth:0.5f];
            [shopTypeLabelArray addObject:shopTypeLabel];
            [cell.contentView addSubview:shopTypeLabel];
            [shopTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(logoImageView);
                if (i > 0) {
                    make.left.mas_equalTo(shopTypeLabelArray[i - 1].mas_right).mas_offset(10);
                } else {
                    make.left.mas_equalTo(logoImageView.mas_right).mas_offset(10);
                }
            }];
        }
    }
    UILabel *gotoShopLabel = [UILabel new];
    [gotoShopLabel setText:@" 进店 "];
    [gotoShopLabel setTextColor:[UIColor whiteColor]];
    [gotoShopLabel setBackgroundColor:[UIColor redColor]];
    [cell.contentView addSubview:gotoShopLabel];
    [gotoShopLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(cell.contentView).mas_offset(-20);
        make.top.mas_equalTo(logoImageView);
    }];
    if (![shopDict[@"message"] isEqual:[NSNull null]]) {
        UILabel *shopDescriptionLabel = [UILabel new];
        [shopDescriptionLabel setTextColor:[UIColor grayColor]];
        [shopDescriptionLabel setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize] + 2]];
        [shopDescriptionLabel setText:[NSString stringWithFormat:@"%@", shopDict[@"message"]]];
        [cell.contentView addSubview:shopDescriptionLabel];
        [shopDescriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(logoImageView);
            make.left.mas_equalTo(shopTitleLabel);
            make.right.mas_lessThanOrEqualTo(gotoShopLabel);
        }];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *shopDict = self.shopArray[indexPath.row];
    NSInteger shopId = [shopDict[@"id"] integerValue];
    HSShopDetailCollectionViewController *controller = [HSShopDetailCollectionViewController new];
    [controller setShopId:shopId];
    [self.navigationController pushViewController:controller animated:YES];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return mHeightForRow;
}

#pragma mark - UIScrollView Delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat loadMoreOffset = mTableViewBaseContentOffsetY + mLoadMoreViewHeight;
    if ([self.shopArray count] * mHeightForRow > self.view.bounds.size.height + mTableViewBaseContentOffsetY) {
        // tableView的contentheight超过了navigationBar下方到屏幕底部的高度
        loadMoreOffset += [self.shopArray count] * mHeightForRow - (self.view.bounds.size.height + mTableViewBaseContentOffsetY);
    }
    if (scrollView.contentOffset.y <= (mTableViewBaseContentOffsetY - mRefreshViewHeight)) {
        if (self.refreshView.tag == 0) {
            self.refreshLabel.text = @"松开刷新";
        }
        self.refreshView.tag = -1;
    } else if (scrollView.contentOffset.y >= loadMoreOffset + mTabBarHeight) {
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
        [self getShopsByPage:1];
    } else if (self.loadMoreView.tag == 1) {
        self.loadMoreView.tag = 0;
        // 加载下一页
        if (self.nextLoadPage != 0) {
            NSLog(@"已触发上拉加载更多！");
            [self getShopsByPage:self.nextLoadPage];
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


- (void)getShopsByPage:(NSUInteger)page {
    HSNetworkManager *manager = [HSNetworkManager shareManager];
    NSString *url = [kGetShopsByPageUrl stringByAppendingFormat:@"?page=%ld", page];
    __weak __typeof__(self) weakSelf = self;
    [manager getDataWithUrl:url parameters:@{} success:^(NSDictionary *responseDict) {
        // 获取成功
        if ([responseDict[@"errcode"] isEqual:@(0)]) {
            if (page == 1) {
                // 获取首页，则清空所有
                [weakSelf.shopArray removeAllObjects];
            }
            NSArray *listData = responseDict[@"storelist"];
            // 判断是否有下一页
            if ([listData count] < mPerPage) {
                weakSelf.nextLoadPage = 0;
            } else {
                weakSelf.nextLoadPage = page + 1;
            }
            if (![listData isEqual:[NSNull null]] && listData != nil) {
                [weakSelf.shopArray addObjectsFromArray:listData];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                // 更新ui
                [weakSelf.tableView reloadData];
                NSLog(@"[UIScreen mainScreen].bounds.size.height = %f", [UIScreen mainScreen].bounds.size.height);
                NSLog(@"view.bounds.size.height = %f", weakSelf.view.bounds.size.height);
                if ([weakSelf.shopArray count] * mHeightForRow >= weakSelf.view.bounds.size.height + mTableViewBaseContentOffsetY) {
                    // tableView的contentSize.height > 屏幕高度
                    [weakSelf.loadMoreView mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.top.mas_equalTo([weakSelf.shopArray count] * mHeightForRow);
                        make.centerX.mas_equalTo(weakSelf.tableView.mas_centerX);
                        make.width.mas_equalTo([UIScreen mainScreen].bounds.size.width);
                        make.height.mas_equalTo(mLoadMoreViewHeight);
                    }];
                } else {
                    // tableView内容过少
                    [weakSelf.loadMoreView mas_remakeConstraints:^(MASConstraintMaker *make) {
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
