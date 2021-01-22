//
//  HSCategoryDetailViewController.m
//  chaoyangdaojia
//
//  Created by hestyle on 2021/1/19.
//  Copyright © 2021 hestyle. All rights reserved.
//

#import "HSCategoryDetailViewController.h"
#import "HSProductDetailViewController.h"
#import "HSNetwork.h"
#import <Masonry/Masonry.h>
#import <Toast/Toast.h>

@interface HSCategoryDetailViewController ()

@property (nonatomic, strong) NSDictionary *categoryDataDict;
@property (nonatomic, strong) NSArray *categorySubArray;
@property (nonatomic) NSInteger nextProductPage;
@property (nonatomic, strong) NSMutableArray *categoryDetailArray;

@property (nonatomic, strong) UIView *refreshView;
@property (nonatomic, strong) UIImageView *refreshImageView;
@property (nonatomic, strong) UILabel *refreshLabel;
@property (nonatomic, strong) UILabel *lastRefreshTimeLabel;

@property (nonatomic) CGFloat mloadMoreViewOffset;
@property (nonatomic, strong) UIView *loadMoreView;
@property (nonatomic, strong) UILabel *loadMoreLabel;

@property (nonatomic, strong) UIView *noProductView;

@property (nonatomic, strong) NSIndexPath *leftListSelectIndexPath;
@property (nonatomic, strong) UITableView *leftListTableView;
@property (nonatomic, strong) UITableView *rightContentTableView;

@property (nonatomic, strong) UIBarButtonItem *rightSearchButtonItem;
@property (nonatomic, strong) UIBarButtonItem *rightCartButtonItem;

@end

static const NSInteger mProductPerPage = 10;
static const CGFloat mLeftListTableViewWidth = 120.f;
static const NSInteger mLeftListCellHeight = 40;
static const NSInteger mRightContentCellHeight = 90;
static const NSInteger mRefreshViewHeight = 60;
static const NSInteger mLoadMoreViewHeight = 60;
/* navigationBar高度44、状态栏（狗啃屏）高度44，contentInsetAdjustmentBehavior */
static const NSInteger mTableViewBaseContentOffsetY = -88;

static NSString * const reuseCellIdentifier = @"reusableCell";

@implementation HSCategoryDetailViewController

- (HSCategoryDetailViewController *)initWithCategoryData:(NSDictionary *)categoryDataDict {
    self = [super init];
    [self setCategoryDataDict:categoryDataDict.copy];
    [self setCategorySubArray:((NSArray *)categoryDataDict[@"list"]).copy];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self initView];
    
    self.categoryDetailArray = [NSMutableArray new];
    
    self.leftListSelectIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.leftListTableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.leftListTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:reuseCellIdentifier];
    [self.rightContentTableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.rightContentTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:reuseCellIdentifier];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setTitle:[NSString stringWithFormat:@"%@", self.categoryDataDict[@"name"]]];
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationItem setRightBarButtonItems:@[self.rightCartButtonItem, self.rightSearchButtonItem]];
    if ([self.categorySubArray count] != 0) {
        [self.leftListTableView selectRowAtIndexPath:self.leftListSelectIndexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
        if ([self.categoryDetailArray count] == 0) {
            NSInteger categoryId = [((NSDictionary *)self.categorySubArray[self.leftListSelectIndexPath.row])[@"id"] integerValue];
            [self getCategoryDetailByCategoryId:categoryId page:1];
        }
    } else {
        [self.refreshView setHidden:YES];
        [self.loadMoreView setHidden:YES];
        [self.noProductView setHidden:NO];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationItem setRightBarButtonItems:@[]];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.leftListTableView) {
        return 1;
    } else if (tableView == self.rightContentTableView) {
        return 1;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.leftListTableView) {
        if (section == 0) {
            return [self.categorySubArray count];
        }
    } else if (tableView == self.rightContentTableView) {
        if (section == 0) {
            return [self.categoryDetailArray count];
        }
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.leftListTableView && indexPath.section == 0) {
        return mLeftListCellHeight;
    } else if (tableView == self.rightContentTableView && indexPath.section == 0) {
        return mRightContentCellHeight;
    }
    return 0.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.leftListTableView && indexPath.section == 0) {
        return mLeftListCellHeight;
    } else if (tableView == self.rightContentTableView && indexPath.section == 0) {
        return mRightContentCellHeight;
    }
    return 0.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseCellIdentifier forIndexPath:indexPath];
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    if (tableView == self.leftListTableView && indexPath.section == 0) {
        NSDictionary *leftListDataDict = self.categorySubArray[indexPath.row];
        UILabel *titleLabel = [UILabel new];
        [titleLabel setText:[NSString stringWithFormat:@"%@", leftListDataDict[@"name"]]];
        [cell.contentView addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(cell.contentView);
            make.width.mas_lessThanOrEqualTo(cell.contentView);
        }];
        cell.selectedBackgroundView = [UIView new];
        [cell.selectedBackgroundView setBackgroundColor:[UIColor orangeColor]];
    } else if (tableView == self.rightContentTableView && indexPath.section == 0) {
        NSDictionary *productDataDict = self.categoryDetailArray[indexPath.row];
        UIView *productView = [UIView new];
        [cell.contentView addSubview:productView];
        [productView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(cell.contentView).mas_offset(-20);
            make.height.mas_equalTo(cell.contentView).mas_offset(-10);
            make.center.mas_equalTo(cell.contentView);
        }];
        UIImageView *productImageView = [UIImageView new];
        [productView addSubview:productImageView];
        [productImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(80, 80));
            make.left.mas_equalTo(productView);
            make.centerY.mas_equalTo(productView);
        }];
        UILabel *titleLabel = [UILabel new];
        [titleLabel setText:[NSString stringWithFormat:@"%@", productDataDict[@"title"]]];
        [productView addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(productImageView.mas_right).mas_offset(5);
            make.top.mas_equalTo(productImageView);
            make.right.mas_lessThanOrEqualTo(productView);
        }];
        UILabel *weightPriceLabel = [UILabel new];
        [weightPriceLabel setTextColor:[UIColor grayColor]];
        [weightPriceLabel setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];
        [weightPriceLabel setText:[NSString stringWithFormat:@"￥%0.2f/%@g", [productDataDict[@"weight_price"] floatValue], productDataDict[@"weight"]]];
        [productView addSubview:weightPriceLabel];
        [weightPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(titleLabel);
            make.bottom.mas_equalTo(productImageView);
            make.right.mas_lessThanOrEqualTo(productView);
        }];
        
        UILabel *priceLabel = [UILabel new];
        NSString *priceString = [NSString stringWithFormat:@"￥%@", productDataDict[@"price"]];
        NSString *danweiString = [NSString stringWithFormat:@"/%@", productDataDict[@"danwei"]];
        NSMutableAttributedString *priceAttributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", priceString, danweiString]];
        [priceAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, [priceString length])];
        [priceAttributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:[UIFont systemFontSize] + 4] range:NSMakeRange(0, [priceString length])];
        [priceAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange([priceString length], [danweiString length])];
        [priceAttributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:[UIFont systemFontSize] - 2] range:NSMakeRange([priceString length], [danweiString length])];
        [priceLabel setAttributedText:priceAttributedString];
        [productView addSubview:priceLabel];
        [priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(titleLabel);
            make.bottom.mas_equalTo(weightPriceLabel.mas_top).mas_offset(-5);
            make.right.mas_lessThanOrEqualTo(productView);
        }];
        
        
        UIImageView *addToCartImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"add_to_cart_icon"]];
        [productView addSubview:addToCartImageView];
        [addToCartImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(25, 25));
            make.right.mas_equalTo(productView);
            make.centerY.mas_equalTo(priceLabel.mas_bottom);
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
                // 缓存至categoryDetailArray中
                NSMutableDictionary *productDataMutableDict = productDataDict.mutableCopy;
                productDataMutableDict[@"productImage"] = productImage;
                weakSelf.categoryDetailArray[indexPath.row] = productDataMutableDict.copy;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [productImageView setImage:productImage];
                });
            });
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.leftListTableView) {
        self.leftListSelectIndexPath = indexPath.copy;
        NSInteger categoryId = [((NSDictionary *)self.categorySubArray[self.leftListSelectIndexPath.row])[@"id"] integerValue];
        [self getCategoryDetailByCategoryId:categoryId page:1];
    } else if (tableView == self.rightContentTableView) {
        NSDictionary *productDataDict = self.categoryDetailArray[indexPath.row];
        HSProductDetailViewController *controller = [[HSProductDetailViewController alloc] initWithProductId:[productDataDict[@"id"] integerValue]];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y <= -mRefreshViewHeight + mTableViewBaseContentOffsetY) {
        if (self.loadMoreView.hidden) {
            return;
        }
        if (self.refreshView.tag == 0) {
            self.refreshLabel.text = @"松开刷新";
        }
        self.refreshView.tag = -1;
    } else if (scrollView.contentOffset.y >= self.mloadMoreViewOffset + mLoadMoreViewHeight - [UIScreen mainScreen].bounds.size.height) {
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
        // 上拉不足触发加载、下拉不足触发刷新
        self.refreshView.tag = 0;
        self.refreshLabel.text = @"下拉刷新";
        
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
        NSInteger categoryId = [((NSDictionary *)self.categorySubArray[self.leftListSelectIndexPath.row])[@"id"] integerValue];
        [self getCategoryDetailByCategoryId:categoryId page:1];
    } else if (self.loadMoreView.tag == 1) {
        self.loadMoreView.tag = 0;
        // 加载下一页
        if (self.nextProductPage != 0) {
            NSLog(@"已触发上拉加载更多！");
            [self.loadMoreView setHidden:YES];
            NSInteger categoryId = [((NSDictionary *)self.categorySubArray[self.leftListSelectIndexPath.row])[@"id"] integerValue];
            [self getCategoryDetailByCategoryId:categoryId page:self.nextProductPage];
        }
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
    self.leftListTableView = [UITableView new];
    [self.leftListTableView setBackgroundColor:[UIColor colorWithRed:245.0/255 green:245.0/255 blue:245.0/255 alpha:1.0]];
    [self.leftListTableView setDelegate:self];
    [self.leftListTableView setDataSource:self];
    [self.view addSubview:self.leftListTableView];
    [self.leftListTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view);
        make.height.mas_equalTo(self.view);
        make.width.mas_equalTo(mLeftListTableViewWidth);
    }];
    
    self.rightContentTableView = [UITableView new];
    [self.rightContentTableView setBackgroundColor:[UIColor whiteColor]];
    [self.rightContentTableView setDelegate:self];
    [self.rightContentTableView setDataSource:self];
    [self.view addSubview:self.rightContentTableView];
    [self.rightContentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.leftListTableView.mas_right);
        make.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view);
        make.height.mas_equalTo(self.view);
    }];
    
    self.refreshView = [UIView new];
    [self.refreshView setTag:0];
    [self.refreshView setBackgroundColor:[UIColor whiteColor]];
    [self.rightContentTableView addSubview:self.refreshView];
    [self.refreshView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.rightContentTableView.mas_top);
        make.centerX.mas_equalTo(self.rightContentTableView);
        make.width.mas_equalTo(self.rightContentTableView);
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
    [self.rightContentTableView addSubview:self.loadMoreView];
    self.mloadMoreViewOffset = [UIScreen mainScreen].bounds.size.height + mTableViewBaseContentOffsetY;
    [self.loadMoreView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.rightContentTableView);
        make.centerX.mas_equalTo(self.rightContentTableView);
        make.width.mas_equalTo(self.rightContentTableView);
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
    
    self.rightSearchButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search_white_iocn"] style:UIBarButtonItemStyleDone target:self action:@selector(gotoSearchAction)];
    
    self.rightCartButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cart_white_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(gotoCartAction)];
    
    [self initNoProductView];
}

- (void)initNoProductView {
    self.noProductView = [UIView new];
    [self.view addSubview:self.noProductView];
    [self.noProductView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(200, 240));
        make.centerX.mas_equalTo(self.view).mas_offset(mLeftListTableViewWidth / 2);
        make.centerY.mas_equalTo(self.view);
    }];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"no_product"]];
    [self.noProductView addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(200, 210));
        make.top.mas_equalTo(self.noProductView);
        make.centerX.mas_equalTo(self.noProductView);
    }];
    UILabel *infoLabel = [UILabel new];
    [infoLabel setTextColor:[UIColor colorWithRed:102.0/255 green:102.0/255 blue:102.0/255 alpha:1.0]];
    [infoLabel setText:@"暂未商品"];
    [self.noProductView addSubview:infoLabel];
    [infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(imageView.mas_bottom).mas_offset(5);
        make.centerX.mas_equalTo(self.noProductView);
    }];
    [self.noProductView setHidden:YES];
}

- (void)getCategoryDetailByCategoryId:(NSInteger)categoryId page:(NSInteger)page {
    HSNetworkManager *manager = [HSNetworkManager shareManager];
    __weak __typeof__(self) weakSelf = self;
    NSString *url = [kGetCategoryDetailDataUrl stringByAppendingFormat:@"?catid=%ld&page=%ld", categoryId, page];
    [manager getDataWithUrl:url parameters:@{} success:^(NSDictionary *responseDict) {
        // 获取成功
        if ([responseDict[@"errcode"] isEqual:@(0)]) {
            NSArray *listData = responseDict[@"list"];
            if (page == 1) {
                [weakSelf.categoryDetailArray removeAllObjects];
            }
            if (![listData isEqual:[NSNull null]] && listData != nil) {
                [weakSelf.categoryDetailArray addObjectsFromArray:listData];
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
                [weakSelf.rightContentTableView performBatchUpdates:^{
                    [weakSelf.loadMoreView setHidden:YES];
                    [weakSelf.rightContentTableView reloadSections:[[NSIndexSet alloc] initWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
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
    if ([self.categoryDetailArray count] == 0) {
        [self.loadMoreView setHidden:YES];
        [self.noProductView setHidden:NO];
    } else {
        [self.noProductView setHidden:YES];
        self.mloadMoreViewOffset = self.rightContentTableView.contentSize.height;
        [self.loadMoreView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.rightContentTableView).mas_offset(self.mloadMoreViewOffset);
        }];
        [self.loadMoreView setHidden:NO];
    }
}

@end
