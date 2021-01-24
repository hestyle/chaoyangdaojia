//
//  HSCommentTableViewController.m
//  chaoyangdaojia
//
//  Created by hestyle on 2021/1/22.
//  Copyright © 2021 hestyle. All rights reserved.
//

#import "HSCommentTableViewController.h"
#import "HSNetwork.h"
#import <Masonry/Masonry.h>
#import <Toast/Toast.h>

@interface HSCommentTableViewController ()

@property (nonatomic) NSInteger productId;
@property (nonatomic, strong) NSMutableArray *commentArray;

@property (nonatomic, strong) UIView *refreshView;
@property (nonatomic, strong) UIImageView *refreshImageView;
@property (nonatomic, strong) UILabel *refreshLabel;
@property (nonatomic, strong) UILabel *lastRefreshTimeLabel;

@property (nonatomic) NSInteger nextCommentPage;
@property (nonatomic) CGFloat mloadMoreViewOffset;
@property (nonatomic, strong) UIView *loadMoreView;
@property (nonatomic, strong) UILabel *loadMoreLabel;

@end

/* API请求中1页包含的数量 */
static const NSInteger mPerPage = 10;
static NSString * const reuseCellIdentifier = @"reusableCell";

static const NSInteger mRefreshViewHeight = 60;
static const NSInteger mLoadMoreViewHeight = 60;
/* navigationBar高度44、状态栏（狗啃屏）高度44，contentInsetAdjustmentBehavior */
static const NSInteger mTableViewBaseContentOffsetY = -88;

@implementation HSCommentTableViewController

- (instancetype)initWithProductId:(NSInteger)productId {
    self = [super init];
    
    self.productId = productId;
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.tableView setShowsVerticalScrollIndicator:NO];
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:reuseCellIdentifier];
    
    self.commentArray = [NSMutableArray new];
    
    [self initView];
    
    [self getCommentDataById:self.productId page:1];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setTitle:@"用户评价"];
    [self.navigationController setNavigationBarHidden:NO];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.commentArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseCellIdentifier forIndexPath:indexPath];
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    NSDictionary *commentDataDict = self.commentArray[indexPath.row];
    UIView *userInfoView = [UIView new];
    [cell.contentView addSubview:userInfoView];
    [userInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(cell.contentView).mas_offset(-40);
        make.height.mas_equalTo(35);
        make.centerX.mas_equalTo(cell.contentView);
        make.top.mas_equalTo(cell.contentView);
    }];
    UIImageView *imageView = [UIImageView new];
    [imageView.layer setCornerRadius:15];
    [userInfoView addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(30, 30));
        make.left.mas_equalTo(userInfoView);
        make.centerY.mas_equalTo(userInfoView);
    }];
    UILabel *userNameLabel = [UILabel new];
    [userNameLabel setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize] + 2]];
    [userNameLabel setText:[NSString stringWithFormat:@"%@", commentDataDict[@"nickname"]]];
    [userInfoView addSubview:userNameLabel];
    [userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(imageView.mas_right).mas_offset(10);
        make.centerY.mas_equalTo(userInfoView);
    }];
    UIView *commentStarView = [UIView new];
    [userInfoView addSubview:commentStarView];
    [commentStarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(userInfoView);
        make.centerY.mas_equalTo(userInfoView);
    }];
    NSInteger commentStarCount = [commentDataDict[@"pintype"] integerValue];
    UIImage *commentStarImage = [UIImage imageNamed:@"comment_star"];
    UIImage *commentNoStarImage = [UIImage imageNamed:@"comment_nostar"];
    for (int i = 0; i < 5; ++i) {
        UIImageView *commentStarImageView = [UIImageView new];
        [commentStarView addSubview:commentStarImageView];
        [commentStarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(15, 15));
            make.left.mas_equalTo(commentStarView).mas_equalTo(i * 20);
            make.centerY.mas_equalTo(commentStarView);
            if (i == 4) {
                make.height.mas_equalTo(commentStarView);
                make.right.mas_equalTo(commentStarView);
            };
        }];
        if (i < commentStarCount) {
            [commentStarImageView setImage:commentStarImage];
        } else {
            [commentStarImageView setImage:commentNoStarImage];
        }
    }
    
    UIView *dateInfoView = [UIView new];
    [cell.contentView addSubview:dateInfoView];
    [dateInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(userInfoView);
        make.height.mas_equalTo(30);
        make.centerX.mas_equalTo(userInfoView);
        make.top.mas_equalTo(userInfoView.mas_bottom);
    }];
    UILabel *commentDateLabel = [UILabel new];
    [commentDateLabel setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize] + 2]];
    [commentDateLabel setTextColor:[UIColor grayColor]];
    NSString *keyString = commentDataDict[@"key"];
    if ([keyString isEqual:[NSNull null]] || [keyString isEqualToString:@"no"]) {
        keyString = @"默认规格";
    }
    [commentDateLabel setText:[NSString stringWithFormat:@"%@  %@", commentDataDict[@"addtime"], keyString]];
    [dateInfoView addSubview:commentDateLabel];
    [commentDateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(dateInfoView);
        make.centerY.mas_equalTo(dateInfoView);
    }];
    UILabel *commentContentLabel = [UILabel new];
    [commentContentLabel setNumberOfLines:0];
    [commentContentLabel setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize] + 2]];
    [commentContentLabel setText:[NSString stringWithFormat:@"%@", commentDataDict[@"content"]]];
    [cell.contentView addSubview:commentContentLabel];
    [commentContentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(dateInfoView.mas_bottom);
        if ([commentDataDict[@"huifu"] isEqual:[NSNull null]]) {
            make.bottom.mas_equalTo(cell.contentView).mas_offset(-10);
        }
        make.width.mas_equalTo(userInfoView);
        make.centerX.mas_equalTo(userInfoView);
    }];
    if (![commentDataDict[@"huifu"] isEqual:[NSNull null]]) {
        UIView *replyView = [UIView new];
        [replyView setBackgroundColor:[UIColor colorWithRed:245.0/255 green:245.0/255 blue:245.0/255 alpha:1.0]];
        [cell.contentView addSubview:replyView];
        
        UILabel *replyContentLabel = [UILabel new];
        [replyContentLabel setNumberOfLines:0];
        NSString *titleString = @"官方回复：";
        NSString *replyString = commentDataDict[@"huifu"];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", titleString, replyString]];
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, [titleString length])];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:[UIFont smallSystemFontSize] + 2 weight:UIFontWeightSemibold] range:NSMakeRange(0, [titleString length])];
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange([titleString length], [replyString length])];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:[UIFont smallSystemFontSize] + 2] range:NSMakeRange([titleString length], [replyString length])];
        [replyContentLabel setAttributedText:attributedString];
        [replyView addSubview:replyContentLabel];
        [replyContentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(replyView).mas_offset(10);
            make.bottom.mas_equalTo(replyView).mas_offset(-10);
            make.width.mas_equalTo(replyView).mas_offset(-20);
            make.centerX.mas_equalTo(replyView);
        }];
        [cell.contentView addSubview:replyView];
        [replyView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(commentContentLabel.mas_bottom).mas_offset(10);
            make.width.mas_equalTo(userInfoView);
            make.centerX.mas_equalTo(userInfoView);
            make.bottom.mas_equalTo(cell.contentView).mas_offset(-10);
        }];
    }
    if ([[commentDataDict allKeys] containsObject:@"userAvatarImage"]) {
        [imageView setImage:commentDataDict[@"userAvatarImage"]];
    } else {
        // 加载图片
        __weak __typeof__(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSURL *avatarUrl = [NSURL URLWithString:commentDataDict[@"ulogo"]];
            NSData *avatarData = [NSData dataWithContentsOfURL:avatarUrl];
            UIImage *avatarImage = [UIImage imageWithData:avatarData];
            // 缓存至shopCommentArray中
            NSMutableDictionary *commentDataMutableDict = commentDataDict.mutableCopy;
            commentDataMutableDict[@"userAvatarImage"] = avatarImage;
            weakSelf.commentArray[indexPath.row] = commentDataMutableDict.copy;
            dispatch_async(dispatch_get_main_queue(), ^{
                [imageView setImage:avatarImage];
            });
        });
    }
    return cell;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.y <= -mRefreshViewHeight) {
        if (self.refreshView.tag == 0) {
            self.refreshLabel.text = @"松开刷新";
        }
        self.refreshView.tag = -1;
    } else if (scrollView.contentOffset.y >= self.mloadMoreViewOffset + mLoadMoreViewHeight - ([UIScreen mainScreen].bounds.size.height + mTableViewBaseContentOffsetY)) {
        if (self.loadMoreView.hidden) {
            return;
        }
        if (self.loadMoreView.tag == 0) {
            if (self.nextCommentPage != 0) {
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
        if (self.nextCommentPage != 0) {
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
        [self getCommentDataById:self.productId page:1];
    } else if (self.loadMoreView.tag == 1) {
        self.loadMoreView.tag = 0;
        // 加载下一页
        if (self.nextCommentPage != 0) {
            NSLog(@"已触发上拉加载更多！");
            [self.loadMoreView setHidden:YES];
            [self getCommentDataById:self.productId page:self.nextCommentPage];
        }
    }
    NSLog(@"scrollView.contentOffset.y = %f", scrollView.contentOffset.y);
}

#pragma mark - Private
- (void)initView {
    self.refreshView = [UIView new];
    [self.refreshView setTag:0];
    [self.refreshView setBackgroundColor:[UIColor whiteColor]];
    [self.tableView addSubview:self.refreshView];
    [self.refreshView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.tableView.mas_top);
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
        make.centerX.mas_equalTo(self.refreshView.mas_centerX).with.offset(10);
        make.size.mas_equalTo(CGSizeMake(180, 20));
    }];

    self.refreshImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"refresh_arrow"]];
    [self.refreshView addSubview:self.refreshImageView];
    [self.refreshImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.lastRefreshTimeLabel.mas_left).with.offset(-20);
        make.centerY.mas_equalTo(self.refreshView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(30, 50));
    }];
    
    self.loadMoreView = [UIView new];
    [self.loadMoreView setTag:0];
    [self.loadMoreView setBackgroundColor:[UIColor whiteColor]];
    [self.loadMoreView.layer setBorderWidth:0.5];
    [self.loadMoreView.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [self.tableView addSubview:self.loadMoreView];
    self.mloadMoreViewOffset = [UIScreen mainScreen].bounds.size.height + mTableViewBaseContentOffsetY;
    [self.loadMoreView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.tableView);
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
    [self.loadMoreView setHidden:YES];
}

- (void)getCommentDataById:(NSInteger)productId page:(NSInteger)page {
    HSNetworkManager *manager = [HSNetworkManager shareManager];
    NSString *url = [kGetProductCommentDataUrl stringByAppendingFormat:@"?id=%ld&page=%ld", productId, page];
    __weak __typeof__(self) weakSelf = self;
    [manager getDataWithUrl:url parameters:@{} success:^(NSDictionary *responseDict) {
        // 获取成功
        if ([responseDict[@"errcode"] isEqual:@(0)]) {
            if (page == 1) {
                [weakSelf.commentArray removeAllObjects];
            }
            NSArray *list = responseDict[@"list"];
            if (![list isEqual:[NSNull null]]) {
                if ([list count] < mPerPage) {
                    weakSelf.nextCommentPage = 0;
                } else {
                    weakSelf.nextCommentPage = page + 1;
                }
                [weakSelf.commentArray addObjectsFromArray:list];
            } else {
                weakSelf.nextCommentPage = 0;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tableView performBatchUpdates:^{
                    [weakSelf.loadMoreView setHidden:YES];
                    [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
                } completion:^(BOOL finished) {
                    [weakSelf updateLoadMoreView];
                }];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.view makeToast:responseDict[@"msg"] duration:3 position:CSToastPositionCenter];
            });
            NSLog(@"接口 %@ 返回数据格式错误! responseDict = %@", url, responseDict);
        }
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.view makeToast:@"获取失败，接口请求错误！" duration:3 position:CSToastPositionCenter];
        });
        NSLog(@"%@", error);
    }];
}

- (void)updateLoadMoreView {
    self.mloadMoreViewOffset = self.tableView.contentSize.height;
    [self.loadMoreView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.tableView).mas_offset(self.mloadMoreViewOffset);
    }];
    [self.loadMoreView setHidden:NO];
}

@end
