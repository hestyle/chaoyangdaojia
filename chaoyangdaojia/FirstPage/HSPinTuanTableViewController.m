//
//  HSPinTuanTableViewController.m
//  chaoyangdaojia
//
//  Created by hestyle on 2021/1/18.
//  Copyright © 2021 hestyle. All rights reserved.
//

#import "HSPinTuanTableViewController.h"
#import "HSProductDetailViewController.h"
#import "HSNetwork.h"
#import "HSCommon.h"
#import <Masonry/Masonry.h>
#import <Toast/Toast.h>

@interface HSPinTuanTableViewController ()

@property (nonatomic, strong) NSMutableArray *productArray;

@property (nonatomic, strong) UIView *refreshView;
@property (nonatomic, strong) UIImageView *refreshImageView;
@property (nonatomic, strong) UILabel *refreshLabel;
@property (nonatomic, strong) UILabel *lastRefreshTimeLabel;

@property (nonatomic) NSInteger nextProductPage;
@property (nonatomic) CGFloat mloadMoreViewOffset;
@property (nonatomic, strong) UIView *loadMoreView;
@property (nonatomic, strong) UILabel *loadMoreLabel;

@end

static const NSInteger mProductPerPage = 10;
static const CGFloat mCellHeight = 370.f;
static const NSInteger mRefreshViewHeight = 60;
static const NSInteger mLoadMoreViewHeight = 60;

static NSString * const reuseCellIdentifier = @"reusableCell";

@implementation HSPinTuanTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:reuseCellIdentifier];
    
    self.productArray = [NSMutableArray new];
    
    [self initView];
    [self getPinTuanProductDataByPage:1];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setTitle:@"全部拼团"];
    [self.navigationController setNavigationBarHidden:NO];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [self.productArray count];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return mCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return mCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseCellIdentifier forIndexPath:indexPath];
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    [cell.contentView setBackgroundColor:[UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0]];
    NSDictionary *pinTuanDataDict = self.productArray[indexPath.row];
    UIView *pinTuanView = [UIView new];
    [pinTuanView.layer setCornerRadius:5.f];
    [pinTuanView setBackgroundColor:[UIColor whiteColor]];
    [cell.contentView addSubview:pinTuanView];
    [pinTuanView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(cell.contentView).mas_offset(10);
        make.right.mas_equalTo(cell.contentView).mas_offset(-10);
        make.height.mas_equalTo(cell.contentView).mas_offset(-20);
        make.centerY.mas_equalTo(cell.contentView);
    }];
    UIView *imageHeaderView = [UIView new];
    [pinTuanView addSubview:imageHeaderView];
    [imageHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(pinTuanView).mas_offset(5);
        make.right.mas_equalTo(pinTuanView).mas_offset(-5);
        make.top.mas_equalTo(pinTuanView).mas_offset(5);
        make.height.mas_equalTo(300);
    }];
    UIImageView *pinTuanImageView = [UIImageView new];
    [imageHeaderView addSubview:pinTuanImageView];
    [pinTuanImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(imageHeaderView);
        make.center.mas_equalTo(imageHeaderView);
    }];
    UIView *pinTuanNumView = [UIView new];
    [imageHeaderView addSubview:pinTuanNumView];
    [pinTuanNumView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(60, 25));
        make.left.mas_equalTo(imageHeaderView);
        make.top.mas_equalTo(imageHeaderView).mas_offset(100);
    }];
    UIImageView *pinTuanNumImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pintuan_num"]];;
    [pinTuanNumView addSubview:pinTuanNumImageView];
    [pinTuanNumImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(pinTuanNumView);
        make.center.mas_equalTo(pinTuanNumView);
    }];
    UILabel *pinTuanNumLabel = [UILabel new];
    [pinTuanNumLabel setFont:[UIFont systemFontOfSize:[UIFont systemFontSize]]];
    [pinTuanNumLabel setText:[NSString stringWithFormat:@"%@人团", pinTuanDataDict[@"tuan_cnum"]]];
    [pinTuanNumView addSubview:pinTuanNumLabel];
    [pinTuanNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(pinTuanNumView);
    }];
    
    UIView *pinTuanInfoView = [UIView new];
    [pinTuanView addSubview:pinTuanInfoView];
    [pinTuanInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(pinTuanView).mas_offset(10);
        make.right.mas_equalTo(pinTuanView).mas_offset(-10);
        make.height.mas_equalTo(80);
        make.bottom.mas_equalTo(pinTuanView).mas_offset(-10);
    }];
    UIImageView *pinTuanBackgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pingtuan_background"]];
    [pinTuanInfoView addSubview:pinTuanBackgroundImageView];
    [pinTuanBackgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(pinTuanInfoView);
        make.center.mas_equalTo(pinTuanInfoView);
    }];
    UILabel *priceLabel = [UILabel new];
    NSString *nowPriceString = [NSString stringWithFormat:@"￥%@", pinTuanDataDict[@"price"]];
    NSString *beforePriceString = [NSString stringWithFormat:@"￥%@", pinTuanDataDict[@"scprice"]];
    NSMutableAttributedString *priceAttributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", nowPriceString, beforePriceString]];
    [priceAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, [nowPriceString length] + [beforePriceString length] + 1)];
    [priceAttributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:[UIFont systemFontSize] + 10] range:NSMakeRange(1, [nowPriceString length])];
    [priceAttributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:[UIFont systemFontSize] - 2] range:NSMakeRange([nowPriceString length] + 1, [beforePriceString length])];
    [priceAttributedString addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlineStyleSingle | NSUnderlinePatternSolid) range:NSMakeRange([nowPriceString length] + 1, [beforePriceString length])];
    [priceAttributedString addAttribute:NSStrokeColorAttributeName value:[UIColor whiteColor] range:NSMakeRange([nowPriceString length] + 1, [beforePriceString length])];
    [priceLabel setAttributedText:priceAttributedString];
    [pinTuanInfoView addSubview:priceLabel];
    [priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(pinTuanInfoView).mas_offset(10);
        make.top.mas_equalTo(pinTuanInfoView).mas_offset(10);
    }];
    UILabel *pinTuanTitleLabel = [UILabel new];
    [pinTuanTitleLabel setTextColor:[UIColor whiteColor]];
    [pinTuanTitleLabel setFont:[UIFont systemFontOfSize:[UIFont systemFontSize] - 1]];
    [pinTuanTitleLabel setText:[NSString stringWithFormat:@"%@", pinTuanDataDict[@"title"]]];
    [pinTuanInfoView addSubview:pinTuanTitleLabel];
    [pinTuanTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(pinTuanInfoView).mas_offset(10);
        make.bottom.mas_equalTo(pinTuanInfoView).mas_offset(-10);
    }];
    
    NSDate *nowDate = [NSDate new];
    NSInteger nowTimeStamp = (NSInteger)[nowDate timeIntervalSince1970];
    NSInteger startTimeStamp = [pinTuanDataDict[@"starttime"] integerValue];
    NSInteger endTimeStamp = [pinTuanDataDict[@"endtime"] integerValue];
    if (nowTimeStamp < startTimeStamp) {
        UILabel *tipLabel = [UILabel new];
        [tipLabel setText:@"暂未开始"];
        [pinTuanInfoView addSubview:tipLabel];
        [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(pinTuanInfoView).mas_offset(-10);
            make.centerY.mas_equalTo(pinTuanInfoView);
        }];
    } else if (nowTimeStamp > endTimeStamp) {
        UILabel *tipLabel = [UILabel new];
        [tipLabel setText:@"已结束"];
        [pinTuanInfoView addSubview:tipLabel];
        [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(pinTuanInfoView).mas_offset(-20);
            make.centerY.mas_equalTo(pinTuanInfoView);
        }];
    } else {
        UILabel *tipLabel = [UILabel new];
        [tipLabel setText:@"距离结束"];
        [pinTuanInfoView addSubview:tipLabel];
        [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(pinTuanInfoView).mas_offset(-5);
            make.top.mas_equalTo(pinTuanInfoView).mas_equalTo(15);
        }];
        UIImageView *nzImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pintuan_nz"]];
        [pinTuanInfoView addSubview:nzImageView];
        [nzImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(20, 20));
            make.right.mas_equalTo(tipLabel.mas_left);
            make.centerY.mas_equalTo(tipLabel);
        }];
        NSInteger hourCount = (endTimeStamp - nowTimeStamp) / 3600;
        if (hourCount > 99) {
            hourCount = 99;
        }
        NSInteger minCount = (endTimeStamp - nowTimeStamp) % 3600 / 60;
        NSInteger secCount = (endTimeStamp - nowTimeStamp) % 60;
        UILabel *timeLabel = [UILabel new];
        [timeLabel setText:[NSString stringWithFormat:@"%02ld:%02ld:%02ld", hourCount, minCount, secCount]];
        [pinTuanInfoView addSubview:timeLabel];
        [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(pinTuanInfoView).mas_offset(-10);
            make.right.mas_equalTo(pinTuanInfoView).mas_offset(-10);
        }];
    }
    if ([[pinTuanDataDict allKeys] containsObject:@"pinTuanImage"]) {
        [pinTuanImageView setImage:pinTuanDataDict[@"pinTuanImage"]];
    } else {
        // 加载图片
        __weak __typeof__(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSURL *pinTuanImageUrl = [NSURL URLWithString:pinTuanDataDict[@"image"]];
            NSData *pinTuanImageData = [NSData dataWithContentsOfURL:pinTuanImageUrl];
            UIImage *pinTuanImage = [UIImage imageWithData:pinTuanImageData];
            // 缓存至pinTuanArray中
            NSMutableDictionary *pinTuanDataMutableDict = pinTuanDataDict.mutableCopy;
            pinTuanDataMutableDict[@"pinTuanImage"] = pinTuanImage;
            weakSelf.productArray[indexPath.row] = pinTuanDataMutableDict.copy;
            dispatch_async(dispatch_get_main_queue(), ^{
                [pinTuanImageView setImage:pinTuanImage];
            });
        });
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *productDataDict = self.productArray[indexPath.row];
    HSProductDetailViewController *controller = [[HSProductDetailViewController alloc] initWithProductId:[productDataDict[@"sid"] integerValue]];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y <= -mRefreshViewHeight) {
        if (self.refreshView.tag == 0) {
            self.refreshLabel.text = @"松开刷新";
        }
        self.refreshView.tag = -1;
    } else {
        // 下拉不足触发刷新
        self.refreshView.tag = 0;
        self.refreshLabel.text = @"下拉刷新";
    }
    if (scrollView.contentOffset.y >= self.mloadMoreViewOffset + mLoadMoreViewHeight - SCREEN_HEIGHT) {
        if (self.loadMoreView.hidden) {
            return;
        }
        if (self.loadMoreView.tag == 0) {
            if (self.nextProductPage != 0) {
                [self.loadMoreLabel setText:@"松开加载"];
            } else {
                [self.loadMoreLabel setText:@"我是有底线的！"];
            }
        }
        self.loadMoreView.tag = 1;
    } else {
        // 上拉不足触发加载
        self.loadMoreView.tag = 0;
        if (self.nextProductPage != 0) {
            [self.loadMoreLabel setText:@"上拉加载更多"];
        } else {
            [self.loadMoreLabel setText:@"我是有底线的！"];
        }
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (self.refreshView.tag == -1) {
        __weak __typeof__(self) weakSelf = self;
        [UIView animateWithDuration:.3 animations:^{
            weakSelf.refreshLabel.text = @"加载中";
            scrollView.contentInset = UIEdgeInsetsMake(mRefreshViewHeight, 0.0f, 0.0f, 0.0f);
        }];
        //数据加载成功后执行；这里为了模拟加载效果，一秒后执行恢复原状代码
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:.3 animations:^{
                weakSelf.refreshView.tag = 0;
                weakSelf.refreshLabel.text = @"下拉刷新";
                scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
                NSLog(@"已触发下拉刷新！");
            }];
        });
        // 重新第1页
        [self getPinTuanProductDataByPage:1];
    } else if (self.loadMoreView.tag == 1) {
        self.loadMoreView.tag = 0;
        // 加载下一页
        if (self.nextProductPage != 0) {
            NSLog(@"已触发上拉加载更多！");
            [self.loadMoreView setHidden:YES];
            [self getPinTuanProductDataByPage:self.nextProductPage];
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
        make.width.mas_equalTo(SCREEN_WIDTH);
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
        make.centerX.mas_equalTo(self.refreshView).with.offset(10);
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
    self.mloadMoreViewOffset = SCREEN_HEIGHT;
    [self.loadMoreView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.tableView);
        make.centerX.mas_equalTo(self.tableView.mas_centerX);
        make.width.mas_equalTo(SCREEN_WIDTH);
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

- (void)getPinTuanProductDataByPage:(NSInteger)page {
    HSNetworkManager *manager = [HSNetworkManager shareManager];
    __weak __typeof__(self) weakSelf = self;
    NSString *url = [kGetPinTuanProductDataUrl stringByAppendingFormat:@"?page=%ld", page];
    [manager getDataWithUrl:url parameters:@{} success:^(NSDictionary *responseDict) {
        // 获取成功
        if ([responseDict[@"errcode"] isEqual:@(0)]) {
            NSArray *listData = responseDict[@"data"];
            if (page == 1) {
                [weakSelf.productArray removeAllObjects];
            }
            if (![listData isEqual:[NSNull null]] && listData != nil) {
                [weakSelf.productArray addObjectsFromArray:listData];
                if ([listData count] < mProductPerPage) {
                    weakSelf.nextProductPage = 0;
                } else {
                    weakSelf.nextProductPage = page + 1;
                }
            } else {
                weakSelf.nextProductPage = 0;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                // 更新ui
                [weakSelf.tableView performBatchUpdates:^{
                    [weakSelf.loadMoreView setHidden:YES];
                    [weakSelf.tableView reloadSections:[[NSIndexSet alloc] initWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
                } completion:^(BOOL finished) {
                    [weakSelf updateLoadMoreView];
                }];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tableView makeToast:responseDict[@"msg"] duration:3 position:CSToastPositionCenter];
            });
            NSLog(@"接口 %@ 返回数据格式错误! responseDict = %@", url, responseDict);
        }
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.tableView makeToast:@"获取失败，接口请求错误！" duration:3 position:CSToastPositionCenter];
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
