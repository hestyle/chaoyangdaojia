//
//  HSProductCollectionViewController.m
//  chaoyangdaojia
//
//  Created by hestyle on 2021/1/24.
//  Copyright © 2021 hestyle. All rights reserved.
//

#import "HSProductCollectionViewController.h"
#import "HSProductDetailViewController.h"
#import "HSNetwork.h"
#import "HSAccount.h"
#import "HSCommon.h"
#import <Masonry/Masonry.h>
#import <Toast/Toast.h>

@interface HSProductCollectionViewController ()

@property (nonatomic, strong) UIView *refreshView;
@property (nonatomic, strong) UIImageView *refreshImageView;
@property (nonatomic, strong) UILabel *refreshLabel;
@property (nonatomic, strong) UILabel *lastRefreshTimeLabel;

@property (nonatomic) NSInteger nextProductPage;
@property (nonatomic) CGFloat mloadMoreViewOffset;
@property (nonatomic, strong) UIView *loadMoreView;
@property (nonatomic, strong) UILabel *loadMoreLabel;



@property (nonatomic, strong) NSMutableArray *productArray;

@end

@implementation HSProductCollectionViewController

static const NSInteger mProductPerPage = 10;
static const NSInteger mRefreshViewHeight = 60;
static const NSInteger mLoadMoreViewHeight = 60;

static NSString * const reuseCellIdentifier = @"reusableCell";

static const CGFloat mProductCellWidth = 175.f;
static const CGFloat mProductCellHeight = 280.f;

- (instancetype)init {
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    self = [super initWithCollectionViewLayout:flowLayout];
    
    self.productArray = [NSMutableArray new];

    [self initView];
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    
    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseCellIdentifier];
    
    [self getProductCollectionByPage:1];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setTitle:@"我的收藏"];
    [self.navigationController setNavigationBarHidden:NO];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.productArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseCellIdentifier forIndexPath:indexPath];
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    NSDictionary *productDataDict = self.productArray[indexPath.row];
    UIView *productView = [UIView new];
    [cell.contentView addSubview:productView];
    [productView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(cell.contentView);
        make.center.mas_equalTo(cell.contentView);
    }];
    UIImageView *productImageView = [UIImageView new];
    [productView addSubview:productImageView];
    [productImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(mProductCellWidth - 10, mProductCellWidth - 10));
        make.top.mas_equalTo(productView).mas_offset(5);
        make.centerX.mas_equalTo(productView);
    }];
    UILabel *titleLabel = [UILabel new];
    [titleLabel setText:[NSString stringWithFormat:@"%@", productDataDict[@"title"]]];
    [productView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(productImageView);
        make.top.mas_equalTo(productImageView.mas_bottom).mas_offset(10);
        make.right.mas_lessThanOrEqualTo(productImageView);
    }];
    UILabel *supplierLabel = [UILabel new];
    [supplierLabel setTextColor:[UIColor grayColor]];
    [supplierLabel setFont:[UIFont systemFontOfSize:[UIFont systemFontSize] - 1]];
    [supplierLabel setText:[NSString stringWithFormat:@"%@", productDataDict[@"supplier_name"]]];
    [productView addSubview:supplierLabel];
    [supplierLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(productImageView);
        make.top.mas_equalTo(titleLabel.mas_bottom).mas_offset(5);
        make.right.mas_lessThanOrEqualTo(productImageView);
    }];
    UILabel *priceLabel = [UILabel new];
    NSString *priceString = [NSString stringWithFormat:@"￥%@", productDataDict[@"price"]];
    NSString *danweiString = [NSString stringWithFormat:@"/%@", productDataDict[@"danwei"]];
    NSMutableAttributedString *priceAttributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", priceString, danweiString]];
    [priceAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, [priceString length])];
    [priceAttributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:[UIFont systemFontSize] + 2] range:NSMakeRange(0, [priceString length])];
    [priceAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange([priceString length], [danweiString length])];
    [priceAttributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:[UIFont systemFontSize] - 2] range:NSMakeRange([priceString length], [danweiString length])];
    [priceLabel setAttributedText:priceAttributedString];
    [productView addSubview:priceLabel];
    [priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(productImageView);
        make.top.mas_equalTo(supplierLabel.mas_bottom).mas_offset(10);
        make.right.mas_lessThanOrEqualTo((productImageView));
    }];
    
    UILabel *weightPriceLabel = [UILabel new];
    [weightPriceLabel setTextColor:[UIColor grayColor]];
    [weightPriceLabel setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];
    [weightPriceLabel setText:[NSString stringWithFormat:@"￥%0.2f/%@g", [productDataDict[@"weight_price"] floatValue], productDataDict[@"weight"]]];
    [productView addSubview:weightPriceLabel];
    [weightPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(productImageView);
        make.top.mas_equalTo(priceLabel.mas_bottom).mas_offset(5);
        make.right.mas_lessThanOrEqualTo((productImageView));
    }];
    
    UIImageView *addToCartImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"add_to_cart_icon"]];
    [productView addSubview:addToCartImageView];
    [addToCartImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(23, 23));
        make.right.mas_equalTo(productImageView);
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
            // 缓存至shopCommentArray中
            NSMutableDictionary *shopProductDataMutableDict = productDataDict.mutableCopy;
            shopProductDataMutableDict[@"productImage"] = productImage;
            weakSelf.productArray[indexPath.row] = shopProductDataMutableDict.copy;
            dispatch_async(dispatch_get_main_queue(), ^{
                [productImageView setImage:productImage];
            });
        });
    }
    [cell.contentView.layer setBorderColor:[[UIColor colorWithRed:244.0/255 green:244.0/255 blue:244.0/255 alpha:1.0] CGColor]];
    [cell.contentView.layer setBorderWidth:2.0f];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return CGSizeMake(mProductCellWidth, mProductCellHeight);
    }
    return CGSizeZero;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 20, 10, 20);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 15;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 20;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        NSDictionary *productDataDict = self.productArray[indexPath.row];
        HSProductDetailViewController *controller = [[HSProductDetailViewController alloc] initWithProductId:[productDataDict[@"id"] integerValue]];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
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
    if (scrollView.contentOffset.y >= self.mloadMoreViewOffset + mLoadMoreViewHeight - (SCREEN_HEIGHT - STATUS_BAR_AND_NAVIGATION_BAR_HEIGHT)) {
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
        [self getProductCollectionByPage:1];
    } else if (self.loadMoreView.tag == 1) {
        self.loadMoreView.tag = 0;
        // 加载下一页
        if (self.nextProductPage != 0) {
            NSLog(@"已触发上拉加载更多！");
            [self.loadMoreView setHidden:YES];
            [self getProductCollectionByPage:self.nextProductPage];
        }
    }
    NSLog(@"scrollView.contentOffset.y = %f", scrollView.contentOffset.y);
}

#pragma mark - Private
- (void)initView {
    self.refreshView = [UIView new];
    [self.refreshView setTag:0];
    [self.refreshView setBackgroundColor:[UIColor whiteColor]];
    [self.collectionView addSubview:self.refreshView];
    [self.refreshView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.collectionView.mas_top);
        make.centerX.mas_equalTo(self.collectionView.mas_centerX);
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
        make.centerX.mas_equalTo(self.collectionView.mas_centerX).with.offset(10);
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
    [self.collectionView addSubview:self.loadMoreView];
    self.mloadMoreViewOffset = SCREEN_HEIGHT - STATUS_BAR_AND_NAVIGATION_BAR_HEIGHT;
    [self.loadMoreView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.collectionView).mas_offset(self.mloadMoreViewOffset);
        make.centerX.mas_equalTo(self.collectionView.mas_centerX);
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

- (void)getProductCollectionByPage:(NSInteger)page {
    HSNetworkManager *manager = [HSNetworkManager shareManager];
    NSString *url = [kGetProductCollectionListUrl stringByAppendingFormat:@"?page=%ld", page];
    __weak __typeof__(self) weakSelf = self;
    [manager getDataWithUrl:url parameters:@{} success:^(NSDictionary *responseDict) {
        // 获取成功
        if ([responseDict[@"errcode"] isEqual:@(0)]) {
            if (page == 1) {
                // 获取首页，则清空所有
                [weakSelf.productArray removeAllObjects];
            }
            NSArray *listData = responseDict[@"list"];
            // 判断是否有下一页
            if ([listData isEqual:[NSNull null]] || [listData count] < mProductPerPage) {
                weakSelf.nextProductPage = 0;
            } else {
                weakSelf.nextProductPage = page + 1;
            }
            if (![listData isEqual:[NSNull null]] && listData != nil) {
                [weakSelf.productArray addObjectsFromArray:listData];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                // 更新ui
                [weakSelf.collectionView performBatchUpdates:^{
                    [weakSelf.loadMoreView setHidden:YES];
                    [weakSelf.collectionView reloadSections:[[NSIndexSet alloc] initWithIndex:0]];
                } completion:^(BOOL finished) {
                    [weakSelf updateLoadMoreView];
                }];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.view makeToast:responseDict[@"msg"] duration:3 position:CSToastPositionCenter];
            });
            NSLog(@"接口 %@ 返回数据格式错误! responseDict = %@", kModifyUserInfoUrl, responseDict);
        }
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.view makeToast:@"获取失败，接口请求错误！" duration:3 position:CSToastPositionCenter];
        });
        NSLog(@"%@", error);
    }];
}

- (void)updateLoadMoreView {
    self.mloadMoreViewOffset = self.collectionView.contentSize.height;
    [self.loadMoreView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.collectionView).mas_offset(self.mloadMoreViewOffset);
    }];
    [self.loadMoreView setHidden:NO];
}

@end
