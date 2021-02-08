//
//  HSQiangGouTableViewController.m
//  chaoyangdaojia
//
//  Created by hestyle on 2021/1/18.
//  Copyright © 2021 hestyle. All rights reserved.
//

#import "HSQiangGouTableViewController.h"
#import "HSProductDetailViewController.h"
#import "HSNetwork.h"
#import "HSCommon.h"
#import <Masonry/Masonry.h>
#import <Toast/Toast.h>

@interface HSQiangGouTableViewController ()

@property (nonatomic, strong) NSMutableArray *productArray;

@property (nonatomic, strong) UIView *refreshView;
@property (nonatomic, strong) UIImageView *refreshImageView;
@property (nonatomic, strong) UILabel *refreshLabel;
@property (nonatomic, strong) UILabel *lastRefreshTimeLabel;

@property (nonatomic, strong) UIBarButtonItem *rightSearchButtonItem;
@property (nonatomic, strong) UIBarButtonItem *rightCartButtonItem;

@end

static const NSInteger mCellHeight = 100;
static const NSInteger mRefreshViewHeight = 60;

static NSString * const reuseCellIdentifier = @"reusableCell";

@implementation HSQiangGouTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:reuseCellIdentifier];
    
    self.productArray = [NSMutableArray new];
    
    [self initView];
    [self getQiangGouProductData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setTitle:@"限时抢购"];
    [self.navigationController setNavigationBarHidden:NO];

    [self.navigationItem setRightBarButtonItems:@[self.rightCartButtonItem, self.rightSearchButtonItem]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationItem setRightBarButtonItems:@[]];
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
    NSDictionary *productDataDict = self.productArray[indexPath.row];
    UIView *productView = [UIView new];
    [cell.contentView addSubview:productView];
    [productView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(cell.contentView).mas_offset(20);
        make.right.mas_equalTo(cell.contentView).mas_offset(-20);
        make.height.mas_equalTo(cell.contentView);
        make.centerY.mas_equalTo(cell.contentView);
    }];
    UIImageView *productImageView = [UIImageView new];
    [productImageView.layer setBorderWidth:0.5];
    [productImageView.layer setBorderColor:[[UIColor orangeColor] CGColor]];
    [productView addSubview:productImageView];
    [productImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(80, 80));
        make.left.mas_equalTo(productView);
        make.centerY.mas_equalTo(productView);
    }];
    UILabel *titleLabel = [UILabel new];
    [titleLabel setFont:[UIFont systemFontOfSize:[UIFont systemFontSize] - 2]];
    [titleLabel setText:[NSString stringWithFormat:@"%@", productDataDict[@"title"]]];
    [productView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(productImageView);
        make.left.mas_equalTo(productImageView.mas_right).mas_offset(10);
    }];
    UILabel *nowPriceLabel = [UILabel new];
    NSString *nowPriceString = [NSString stringWithFormat:@"￥%@", productDataDict[@"price"]];
    NSString *danweiString = [NSString stringWithFormat:@"/份"];
    NSMutableAttributedString *nowPriceAttributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", nowPriceString, danweiString]];
    [nowPriceAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, [nowPriceString length])];
    [nowPriceAttributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:[UIFont systemFontSize] + 2] range:NSMakeRange(0, [nowPriceString length])];
    [nowPriceAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange([nowPriceString length], [danweiString length])];
    [nowPriceAttributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:[UIFont systemFontSize] - 2] range:NSMakeRange([nowPriceString length], [danweiString length])];
    [nowPriceLabel setAttributedText:nowPriceAttributedString];
    [productView addSubview:nowPriceLabel];
    [nowPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleLabel.mas_bottom).mas_offset(5);
        make.left.mas_equalTo(titleLabel);
    }];
    
    UILabel *beforePriceLabel = [UILabel new];
    NSAttributedString *attributeString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"￥%@/份", productDataDict[@"scprice"]] attributes:@{NSForegroundColorAttributeName:[UIColor grayColor], NSStrikethroughStyleAttributeName:@(NSUnderlineStyleSingle | NSUnderlinePatternSolid), NSStrokeColorAttributeName:[UIColor grayColor], NSFontAttributeName:[UIFont systemFontOfSize:[UIFont systemFontSize] - 2]}];
    [beforePriceLabel setAttributedText:attributeString];
    [productView addSubview:beforePriceLabel];
    [beforePriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(nowPriceLabel.mas_bottom).mas_offset(5);
        make.left.mas_equalTo(nowPriceLabel);
    }];
    
    UIImageView *timeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"qianggou_time_orange_icon"]];
    [productView addSubview:timeImageView];
    [timeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(15, 18));
        make.top.mas_equalTo(beforePriceLabel.mas_bottom).mas_offset(5);
        make.left.mas_equalTo(beforePriceLabel);
    }];
    
    
    NSDate *nowDate = [NSDate new];
    NSInteger nowTimeStamp = (NSInteger)[nowDate timeIntervalSince1970];
    NSInteger startTimeStamp = [productDataDict[@"starttime"] integerValue];
    NSInteger endTimeStamp = [productDataDict[@"endtime"] integerValue];
    UILabel *tipLabel = [UILabel new];
    [tipLabel setTextColor:[UIColor redColor]];
    [tipLabel setFont:[UIFont systemFontOfSize:[UIFont systemFontSize] - 2]];
    [productView addSubview:tipLabel];
    [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(timeImageView.mas_right).mas_offset(3);
        make.top.mas_equalTo(beforePriceLabel.mas_bottom).mas_offset(5);
    }];
    
    if (nowTimeStamp < startTimeStamp) {
        [tipLabel setText:@"暂未开始"];
    } else if (nowTimeStamp > endTimeStamp) {
        [tipLabel setText:@"已结束"];
    } else {
        [tipLabel setText:@"距离结束"];
        
        NSInteger hourCount = (endTimeStamp - nowTimeStamp) / 3600;
        if (hourCount > 99) {
            hourCount = 99;
        }
        NSInteger minCount = (endTimeStamp - nowTimeStamp) % 3600 / 60;
        NSInteger secCount = (endTimeStamp - nowTimeStamp) % 60;
        UILabel *timeLabel = [UILabel new];
        [timeLabel setTextColor:[UIColor redColor]];
        [timeLabel setFont:[UIFont systemFontOfSize:[UIFont systemFontSize] - 2]];
        [timeLabel setText:[NSString stringWithFormat:@"%02ld:%02ld:%02ld", hourCount, minCount, secCount]];
        [productView addSubview:timeLabel];
        [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(tipLabel);
            make.left.mas_equalTo(tipLabel.mas_right).mas_offset(5);
        }];
    }
    
    UIImageView *qiangGouImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"qianggou_icon"]];
    [qiangGouImageView.layer setCornerRadius:10];
    [productView addSubview:qiangGouImageView];
    [qiangGouImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(20, 20));
        make.right.mas_equalTo(productView);
        make.centerY.mas_equalTo(tipLabel);
    }];
    
    UIView *qiangGouProgressView = [UIView new];
    [qiangGouProgressView.layer setCornerRadius:6];
    [qiangGouProgressView setBackgroundColor:[UIColor colorWithRed:233/255.0 green:233/255.0 blue:233/255.0 alpha:1.0]];
    [productView addSubview:qiangGouProgressView];
    [qiangGouProgressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(16);
        make.centerY.mas_equalTo(tipLabel);
        make.right.mas_equalTo(qiangGouImageView.mas_left).mas_offset(-10);
    }];
    NSInteger kuNum = [productDataDict[@"ku_num"] integerValue];
    NSInteger buyNum = [productDataDict[@"buy_num"] integerValue];
    UIView *qiangGouRemindProgressView = [UIView new];
    [qiangGouRemindProgressView.layer setCornerRadius:6];
    [qiangGouRemindProgressView setBackgroundColor:[UIColor orangeColor]];
    [qiangGouProgressView addSubview:qiangGouRemindProgressView];
    [qiangGouRemindProgressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(qiangGouProgressView);
        make.height.mas_equalTo(qiangGouProgressView);
        make.top.mas_equalTo(qiangGouProgressView);
        make.width.mas_equalTo(100.0 * kuNum / (kuNum + buyNum));
    }];
    UILabel *qiangGouRemindLabel = [UILabel new];
    [qiangGouRemindLabel setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];
    [qiangGouRemindLabel setText:[NSString stringWithFormat:@"剩余%ld份", kuNum]];
    [qiangGouProgressView addSubview:qiangGouRemindLabel];
    [qiangGouRemindLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(qiangGouProgressView);
    }];
    
    if ([[productDataDict allKeys] containsObject:@"productImage"]) {
        [productImageView setImage:productDataDict[@"productImage"]];
    } else {
        // 加载图片
        __weak __typeof__(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSURL *productImageUrl = [NSURL URLWithString:productDataDict[@"image"]];
            NSData *productImageData = [NSData dataWithContentsOfURL:productImageUrl];
            UIImage *productImage = [UIImage imageWithData:productImageData];
            // 缓存至shopCommentArray中
            NSMutableDictionary *productDataMutableDict = productDataDict.mutableCopy;
            productDataMutableDict[@"productImage"] = productImage;
            weakSelf.productArray[indexPath.row] = productDataMutableDict.copy;
            dispatch_async(dispatch_get_main_queue(), ^{
                [productImageView setImage:productImage];
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
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.y <= -mRefreshViewHeight) {
        if (self.refreshView.tag == 0) {
            self.refreshLabel.text = @"松开刷新";
        }
        self.refreshView.tag = -1;
    } else {
        // 上拉不足触发加载、下拉不足触发刷新
        self.refreshView.tag = 0;
        self.refreshLabel.text = @"下拉刷新";
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
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
        [self getQiangGouProductData];
    }
    NSLog(@"scrollView.contentOffset.y = %f", scrollView.contentOffset.y);
}

#pragma mark - Event
- (void)gotoSearchAction {
    [self.view makeToast:@"点击了搜索图标" duration:3.f position:CSToastPositionCenter];
}

- (void)gotoCartAction {
    [self.view makeToast:@"点击了购物车图标" duration:3.f position:CSToastPositionCenter];
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
    
    self.rightSearchButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search_white_iocn"] style:UIBarButtonItemStyleDone target:self action:@selector(gotoSearchAction)];
    
    self.rightCartButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cart_white_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(gotoCartAction)];
}

- (void)getQiangGouProductData {
    HSNetworkManager *manager = [HSNetworkManager shareManager];
    __weak __typeof__(self) weakSelf = self;
    [manager getDataWithUrl:kGetQiangGouProductDataUrl parameters:@{} success:^(NSDictionary *responseDict) {
        // 获取成功
        if ([responseDict[@"errcode"] isEqual:@(0)]) {
            NSArray *listData = responseDict[@"data"];
            [weakSelf.productArray removeAllObjects];
            if (![listData isEqual:[NSNull null]] && listData != nil) {
                [weakSelf.productArray addObjectsFromArray:listData];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                // 更新ui
                [weakSelf.tableView reloadData];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tableView makeToast:responseDict[@"msg"] duration:3 position:CSToastPositionCenter];
            });
            NSLog(@"接口 %@ 返回数据格式错误! responseDict = %@", kGetQiangGouProductDataUrl, responseDict);
        }
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.tableView makeToast:@"获取失败，接口请求错误！" duration:3 position:CSToastPositionCenter];
        });
        NSLog(@"%@", error);
    }];
}

@end
