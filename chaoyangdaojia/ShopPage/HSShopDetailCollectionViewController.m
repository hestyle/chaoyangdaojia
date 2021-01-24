//
//  HSShopDetailCollectionViewController.m
//  chaoyangdaojia
//
//  Created by hestyle on 2021/1/13.
//  Copyright © 2021 hestyle. All rights reserved.
//

#import "HSShopDetailCollectionViewController.h"
#import "HSProductDetailViewController.h"
#import "HSNetwork.h"
#import <Masonry/Masonry.h>
#import <Toast/Toast.h>

@interface HSShopDetailCollectionViewController ()

@property (nonatomic) NSInteger selectIndex;
@property (nonatomic) NSInteger nextShopProductPage;
@property (nonatomic) NSInteger nextShopCommentPage;
@property (nonatomic, strong) NSMutableDictionary *shopDataMutableDict;
@property (nonatomic, strong) NSMutableArray *shopProductArray;
@property (nonatomic, strong) NSMutableArray *shopCommentArray;

@property (nonatomic, strong) UIView *refreshView;
@property (nonatomic, strong) UIImageView *refreshImageView;
@property (nonatomic, strong) UILabel *refreshLabel;
@property (nonatomic, strong) UILabel *lastRefreshTimeLabel;

@property (nonatomic) CGFloat mloadMoreViewOffset;
@property (nonatomic, strong) UIView *loadMoreView;
@property (nonatomic, strong) UILabel *loadMoreLabel;

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIImageView *logoImageView;
@property (nonatomic, strong) UILabel *shopTitleLabel;
@property (nonatomic, strong) UILabel *shopDescriptionLabel;
@property (nonatomic, strong) UIView *shopTypeView;
@property (nonatomic, strong) UISegmentedControl *detailSegmentedControl;

@property (nonatomic, strong) UIView *emptyView;

@end

@implementation HSShopDetailCollectionViewController

static const NSInteger mShopProductPerPage = 10;
static const NSInteger mShopCommentPerPage = 10;
static const CGFloat mHeaderHeight = 280;
static const CGFloat mProductCellWidth = 170;
static const CGFloat mProductCellHeight = 260;
static const CGFloat mCommentCellHeight = 160;

static const NSInteger mRefreshViewHeight = 60;
static const NSInteger mLoadMoreViewHeight = 60;
/* navigationBar高度44、状态栏（狗啃屏）高度44，contentInsetAdjustmentBehavior */
static const NSInteger mTableViewBaseContentOffsetY = -88;

static NSString * const reuseCellIdentifier = @"reusableCell";
static NSString * const reuseHeaderIdentifier = @"reusableHeaderView";

- (instancetype)init {
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    self = [super initWithCollectionViewLayout:flowLayout];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    
    self.selectIndex = 0;
    self.shopDataMutableDict = [NSMutableDictionary new];
    self.shopProductArray = [NSMutableArray new];
    self.shopCommentArray = [NSMutableArray new];
    
    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseCellIdentifier];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseHeaderIdentifier];
    
    [self initView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setTitle:@"店铺详情"];
    [self.navigationController setNavigationBarHidden:NO];
    // 获取shopData
    [self getShopDetail];
    // 获取shopProduct
    if ([self.shopProductArray count] == 0) {
        [self getShopProductByPage:1];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake([UIScreen mainScreen].bounds.size.width, mHeaderHeight);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && [kind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseHeaderIdentifier forIndexPath:indexPath];
        for (UIView *view in headerView.subviews) {
            [view removeFromSuperview];
        }
        self.backgroundView = [UIView new];
        [self.backgroundView setBackgroundColor:[UIColor whiteColor]];
        [headerView addSubview:self.backgroundView];
        [self.backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(headerView);
            make.top.mas_equalTo(headerView);
            make.height.mas_equalTo(220);
            make.centerX.mas_equalTo(headerView);
        }];
        self.backgroundImageView = [UIImageView new];
        [self.backgroundImageView setBackgroundColor:[UIColor grayColor]];
        [self.backgroundView addSubview:self.backgroundImageView];
        [self.backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(self.backgroundView);
            make.center.mas_equalTo(self.backgroundView);
        }];
        UIView *shadowView = [UIView new];
        [shadowView setBackgroundColor:[UIColor blackColor]];
        [shadowView setAlpha:0.5];
        [self.backgroundView addSubview:shadowView];
        [shadowView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(self.backgroundView);
            make.center.mas_equalTo(self.backgroundView);
        }];
        self.logoImageView = [UIImageView new];
        [self.logoImageView setBackgroundColor:[UIColor whiteColor]];
        [self.backgroundView addSubview:self.logoImageView];
        [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(80, 80));
            make.centerX.mas_equalTo(self.backgroundView);
            make.top.mas_equalTo(self.backgroundView).mas_offset(30);
        }];
        self.shopTitleLabel = [UILabel new];
        [self.shopTitleLabel setFont:[UIFont systemFontOfSize:[UIFont systemFontSize] + 4]];
        [self.shopTitleLabel setTextColor:[UIColor whiteColor]];
        [self.backgroundView addSubview:self.shopTitleLabel];
        [self.shopTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.backgroundView);
            make.top.mas_equalTo(self.logoImageView.mas_bottom).mas_offset(10);
        }];
        self.shopDescriptionLabel = [UILabel new];
        [self.shopDescriptionLabel setTextColor:[UIColor whiteColor]];
        [self.shopDescriptionLabel setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize] + 2]];
        [self.backgroundView addSubview:self.shopDescriptionLabel];
        [self.shopDescriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.backgroundView);
            make.width.mas_lessThanOrEqualTo(self.backgroundView);
            make.top.mas_equalTo(self.shopTitleLabel.mas_bottom).mas_offset(10);
        }];
        
        self.shopTypeView = [UIView new];
        [self.backgroundView addSubview:self.shopTypeView];
        [self.shopTypeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.backgroundView);
            make.top.mas_equalTo(self.shopTitleLabel.mas_bottom).mas_offset(10);
        }];
        self.detailSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"商品", @"评价", @"介绍"]];
        [self.detailSegmentedControl setTintColor:[UIColor clearColor]];
        [self.detailSegmentedControl setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor orangeColor]} forState:UIControlStateSelected];
        [self.detailSegmentedControl setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]} forState:UIControlStateNormal];
        [self.detailSegmentedControl setSelectedSegmentIndex:self.selectIndex];
        [self.detailSegmentedControl addTarget:self action:@selector(detailSegmentedControlChange:) forControlEvents:UIControlEventValueChanged];
        [headerView addSubview:self.detailSegmentedControl];
        [self.detailSegmentedControl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(headerView);
            make.top.mas_equalTo(self.backgroundView.mas_bottom).mas_offset(10);
            make.size.mas_equalTo(CGSizeMake(250, 40));
        }];
        [self initShopData];
        return headerView;
    } else {
        return nil;
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.selectIndex == 0) {
        return [self.shopProductArray count];
    } else if (self.selectIndex == 1) {
        return [self.shopCommentArray count];
    } else if (self.selectIndex == 2) {
        return 1;
    } else {
        return 0;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseCellIdentifier forIndexPath:indexPath];
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    if (self.selectIndex == 0) {
        NSDictionary *productDataDict = self.shopProductArray[indexPath.row];
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
            make.top.mas_equalTo(titleLabel.mas_bottom).mas_offset(20);
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
            make.size.mas_equalTo(CGSizeMake(20, 20));
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
                weakSelf.shopProductArray[indexPath.row] = shopProductDataMutableDict.copy;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [productImageView setImage:productImage];
                });
            });
        }
    } else if (self.selectIndex == 1) {
        NSDictionary *shopCommentDataDict = self.shopCommentArray[indexPath.row];
        UIView *userInfoView = [UIView new];
        [cell.contentView addSubview:userInfoView];
        [userInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(cell.contentView);
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
        [userNameLabel setText:[NSString stringWithFormat:@"%@", shopCommentDataDict[@"nickname"]]];
        [userInfoView addSubview:userNameLabel];
        [userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(imageView.mas_right).mas_offset(10);
            make.centerY.mas_equalTo(userInfoView);
        }];
        UIView *commentStarView = [UIView new];
        [userInfoView addSubview:commentStarView];
        NSInteger commentStarCount = [shopCommentDataDict[@"pintype"] integerValue];
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
        [commentStarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(userInfoView);
            make.centerY.mas_equalTo(userInfoView);
        }];
        
        UIView *dateInfoView = [UIView new];
        [cell.contentView addSubview:dateInfoView];
        [dateInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(cell.contentView);
            make.height.mas_equalTo(30);
            make.centerX.mas_equalTo(cell.contentView);
            make.top.mas_equalTo(userInfoView.mas_bottom);
        }];
        UILabel *commentDateLabel = [UILabel new];
        [commentDateLabel setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize] + 2]];
        [commentDateLabel setTextColor:[UIColor grayColor]];
        NSString *keyString = shopCommentDataDict[@"key"];
        if ([keyString isEqual:[NSNull null]] || [keyString isEqualToString:@"no"]) {
            keyString = @"默认规格";
        }
        [commentDateLabel setText:[NSString stringWithFormat:@"%@  %@", shopCommentDataDict[@"addtime"], keyString]];
        [dateInfoView addSubview:commentDateLabel];
        [commentDateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(dateInfoView);
            make.centerY.mas_equalTo(dateInfoView);
        }];
        UILabel *commentContentLabel = [UILabel new];
        [commentContentLabel setNumberOfLines:0];
        [commentContentLabel setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize] + 2]];
        [commentContentLabel setText:[NSString stringWithFormat:@"%@", shopCommentDataDict[@"content"]]];
        [cell.contentView addSubview:commentContentLabel];
        [commentContentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(dateInfoView.mas_bottom);
            if ([shopCommentDataDict[@"huifu"] isEqual:[NSNull null]]) {
                make.bottom.mas_equalTo(cell.contentView).mas_offset(-10);
            }
            make.width.mas_equalTo(cell.contentView);
            make.centerX.mas_equalTo(cell.contentView);
        }];
        if (![shopCommentDataDict[@"huifu"] isEqual:[NSNull null]]) {
            UIView *replyView = [UIView new];
            [replyView setBackgroundColor:[UIColor colorWithRed:245.0/255 green:245.0/255 blue:245.0/255 alpha:1.0]];
            [cell.contentView addSubview:replyView];
            
            UILabel *replyContentLabel = [UILabel new];
            [replyContentLabel setNumberOfLines:0];
            NSString *titleString = @"官方回复：";
            NSString *replyString = shopCommentDataDict[@"huifu"];
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
        if ([[shopCommentDataDict allKeys] containsObject:@"userAvatarImage"]) {
            [imageView setImage:shopCommentDataDict[@"userAvatarImage"]];
        } else {
            // 加载图片
            __weak __typeof__(self) weakSelf = self;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSURL *avatarUrl = [NSURL URLWithString:shopCommentDataDict[@"ulogo"]];
                NSData *avatarData = [NSData dataWithContentsOfURL:avatarUrl];
                UIImage *avatarImage = [UIImage imageWithData:avatarData];
                // 缓存至shopCommentArray中
                NSMutableDictionary *shopCommentDataMutableDict = shopCommentDataDict.mutableCopy;
                shopCommentDataMutableDict[@"userAvatarImage"] = avatarImage;
                weakSelf.shopCommentArray[indexPath.row] = shopCommentDataMutableDict.copy;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [imageView setImage:avatarImage];
                });
            });
        }
    } else if (self.selectIndex == 2) {
        if (![self.shopDataMutableDict[@"content"] isEqual:[NSNull null]] && [self.shopDataMutableDict[@"content"] length] != 0) {
            WKWebView *contentWebView = [WKWebView new];
            [cell.contentView addSubview:contentWebView];
            [contentWebView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.mas_equalTo(cell.contentView);
                make.size.mas_equalTo(cell.contentView);
            }];
            NSString *contentString = [NSString stringWithFormat:@"<header><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'><style>img{width:100%% !important;height:auto}</style></header>%@", self.shopDataMutableDict[@"content"]];
            [contentWebView loadHTMLString:contentString baseURL:nil];
            [self.emptyView setHidden:YES];
        } else {
            [self.emptyView setHidden:NO];
        }
    }
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat screenWith = [UIScreen mainScreen].bounds.size.width;
    if (self.selectIndex == 0) {
        return CGSizeMake(mProductCellWidth, mProductCellHeight);
    } else if (self.selectIndex == 1) {
        return CGSizeMake(screenWith - 40, mCommentCellHeight);
    } else if (self.selectIndex == 2) {
        return CGSizeMake(screenWith - 40, 400);
    } else {
        return CGSizeZero;
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 20, 10, 20);
};

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 20;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 20;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectIndex == 0) {
        NSDictionary *productDataDict = self.shopProductArray[indexPath.row];
        HSProductDetailViewController *controller = [[HSProductDetailViewController alloc] initWithProductId:[productDataDict[@"id"] integerValue]];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

#pragma mark - Event
- (void)detailSegmentedControlChange:(UISegmentedControl *)segmentedControl {
    if (segmentedControl.selectedSegmentIndex == 0) {
        self.selectIndex = 0;
        if ([self.shopProductArray count] == 0) {
            //shopProductArray为空，重新加载第1页
            [self getShopProductByPage:1];
            return;
        }
    } else if (segmentedControl.selectedSegmentIndex == 1) {
        self.selectIndex = 1;
        if ([self.shopCommentArray count] == 0) {
            //shopCommentArray为空，重新加载第1页
            [self getShopCommentByPage:1];
            return;
        }
    } else if (segmentedControl.selectedSegmentIndex == 2) {
         self.selectIndex = 2;
    } else {
        self.selectIndex = 0;
    }
    // 重新加载collect数据
    [self.emptyView setHidden:YES];
    [self.collectionView reloadData];
}

#pragma mark - UIScrollView Delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.y <= -mRefreshViewHeight) {
        if (self.refreshView.tag == 0) {
            self.refreshLabel.text = @"松开刷新";
        }
        self.refreshView.tag = -1;
    } else if (scrollView.contentOffset.y >= self.mloadMoreViewOffset + mLoadMoreViewHeight - self.view.bounds.size.height) {
        if (self.loadMoreView.tag == 0) {
            if (self.selectIndex == 0 && self.nextShopProductPage != 0) {
                [self.loadMoreLabel setText:@"松开加载"];
            } else if (self.selectIndex == 1 && self.nextShopCommentPage != 0) {
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
        if (self.selectIndex == 0 && self.nextShopProductPage != 0) {
            [self.loadMoreLabel setText:@"上拉加载更多"];
        } else if (self.selectIndex == 1 && self.nextShopCommentPage != 0) {
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
        if (self.selectIndex == 0) {
            [self getShopProductByPage:1];
        } else if (self.selectIndex == 1) {
            [self getShopCommentByPage:1];
        }
    } else if (self.loadMoreView.tag == 1) {
        self.loadMoreView.tag = 0;
        // 加载下一页
        if (self.selectIndex == 0 && self.nextShopProductPage != 0) {
            NSLog(@"已触发上拉加载更多！");
            [self getShopProductByPage:self.nextShopProductPage];
        } else if (self.selectIndex == 1 && self.nextShopCommentPage != 0) {
            NSLog(@"已触发上拉加载更多！");
            [self getShopCommentByPage:self.nextShopCommentPage];
        }
    }
    NSLog(@"scrollView.contentOffset.y = %f", scrollView.contentOffset.y);
}

#pragma mark - Private
- (void)initView {
    self.refreshView = [UIView new];
    [self.refreshView setTag:0];
    [self.collectionView addSubview:self.refreshView];
    [self.refreshView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.collectionView.mas_top).with.offset(-mRefreshViewHeight);
        make.centerX.mas_equalTo(self.collectionView.mas_centerX);
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
    [self.loadMoreView.layer setBorderWidth:0.5];
    [self.loadMoreView.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [self.collectionView addSubview:self.loadMoreView];
    self.mloadMoreViewOffset = [UIScreen mainScreen].bounds.size.height + mTableViewBaseContentOffsetY;
    [self.loadMoreView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.collectionView).mas_offset(self.mloadMoreViewOffset);
        make.centerX.mas_equalTo(self.collectionView.mas_centerX);
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
    
    self.emptyView = [UIView new];
    [self.emptyView setHidden:YES];
    [self.view addSubview:self.emptyView];
    [self.emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(160, 200));
        make.centerX.mas_equalTo(self.view);
        make.centerY.mas_equalTo(self.view).mas_offset(mHeaderHeight / 2);
    }];
    UIImageView *noMemberPointImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"no_xx"]];
    [self.emptyView addSubview:noMemberPointImageView];
    [noMemberPointImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.emptyView);
        make.size.mas_equalTo(CGSizeMake(160, 160));
        make.top.mas_equalTo(self.emptyView);
    }];
    UILabel *noMemberPointTitleLabel = [UILabel new];
    [noMemberPointTitleLabel setText:@"还没有内容~"];
    [noMemberPointTitleLabel setTextColor:[UIColor colorWithRed:160/255.0 green:160/255.0 blue:160/255.0 alpha:1.0]];
    [self.emptyView addSubview:noMemberPointTitleLabel];
    [noMemberPointTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.emptyView);
        make.top.mas_equalTo(noMemberPointImageView.mas_bottom).mas_offset(5);
    }];
}

- (void)getShopDetail {
    HSNetworkManager *manager = [HSNetworkManager shareManager];
    NSString *url = [kGetShopDetailByIdUrl stringByAppendingFormat:@"?id=%ld", self.shopId];
    __weak __typeof__(self) weakSelf = self;
    [manager getDataWithUrl:url parameters:@{} success:^(NSDictionary *responseDict) {
        // 获取成功
        if ([responseDict[@"errcode"] isEqual:@(0)]) {
            NSDictionary *shopDict = responseDict[@"data"];
            [weakSelf.shopDataMutableDict removeAllObjects];
            [weakSelf.shopDataMutableDict addEntriesFromDictionary:shopDict];
            NSString *logoUrlString = shopDict[@"logo"];
            if ([logoUrlString length] != 0) {
                NSURL *logoUrl = [NSURL URLWithString:logoUrlString];
                NSData *logoData = [NSData dataWithContentsOfURL:logoUrl];
                UIImage *logoImage = [UIImage imageWithData:logoData];
                weakSelf.shopDataMutableDict[@"logoImage"] = logoImage;
            }
            NSString *backgroundImageUrlString = shopDict[@"bgimage"];
            if ([backgroundImageUrlString length] != 0) {
                NSURL *backgroundImageUrl = [NSURL URLWithString:backgroundImageUrlString];
                NSData *backgroundImageData = [NSData dataWithContentsOfURL:backgroundImageUrl];
                UIImage *backgroundImage = [UIImage imageWithData:backgroundImageData];
                weakSelf.shopDataMutableDict[@"backgroundImage"] = backgroundImage;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf initShopData];
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

- (void)getShopProductByPage:(NSInteger)page {
    HSNetworkManager *manager = [HSNetworkManager shareManager];
    NSString *url = [kGetShopProductListUrl stringByAppendingFormat:@"?isdian=1&dian_id=%ld&page=%ld", self.shopId, page];
    __weak __typeof__(self) weakSelf = self;
    [manager getDataWithUrl:url parameters:@{} success:^(NSDictionary *responseDict) {
        // 获取成功
        if ([responseDict[@"errcode"] isEqual:@(0)]) {
            if (page == 1) {
                // 获取首页，则清空所有
                [weakSelf.shopProductArray removeAllObjects];
            }
            NSArray *listData = responseDict[@"list"];
            // 判断是否有下一页
            if ([listData count] < mShopProductPerPage) {
                weakSelf.nextShopProductPage = 0;
            } else {
                weakSelf.nextShopProductPage = page + 1;
            }
            if (![listData isEqual:[NSNull null]] && listData != nil) {
                [weakSelf.shopProductArray addObjectsFromArray:listData];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([weakSelf.shopProductArray count] == 0) {
                    [weakSelf.emptyView setHidden:NO];
                } else {
                    [weakSelf.emptyView setHidden:YES];
                }
                // 更新ui
                [weakSelf.collectionView reloadSections:[[NSIndexSet alloc] initWithIndex:0]];
                NSLog(@"[UIScreen mainScreen].bounds.size.height = %f", [UIScreen mainScreen].bounds.size.height);
                NSLog(@"view.bounds.size.height = %f", weakSelf.view.bounds.size.height);
                NSInteger perRowCellCount = ([UIScreen mainScreen].bounds.size.width - 20) / (mProductCellWidth + 20);
                NSInteger cellRow = ([weakSelf.shopProductArray count] + perRowCellCount - 1) / perRowCellCount;
                CGFloat collectionViewHeight = 20.f;
                if ([weakSelf.shopProductArray count] == 0) {
                    cellRow = 0;
                } else {
                    collectionViewHeight += cellRow * mProductCellHeight + (cellRow - 1) * 20.f;
                }
                if (cellRow != 0 && collectionViewHeight >= weakSelf.view.bounds.size.height + mTableViewBaseContentOffsetY - mHeaderHeight) {
                    // collectionView的contentSize.height > 屏幕高度
                    weakSelf.mloadMoreViewOffset = collectionViewHeight + mHeaderHeight;
                    [weakSelf.loadMoreView mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.top.mas_equalTo(weakSelf.collectionView).mas_offset(weakSelf.mloadMoreViewOffset);
                        make.centerX.mas_equalTo(weakSelf.collectionView.mas_centerX);
                        make.width.mas_equalTo([UIScreen mainScreen].bounds.size.width);
                        make.height.mas_equalTo(mLoadMoreViewHeight);
                    }];
                } else {
                    // collectionView内容过少
                    weakSelf.mloadMoreViewOffset = [UIScreen mainScreen].bounds.size.height + mTableViewBaseContentOffsetY;
                    [weakSelf.loadMoreView mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.top.mas_equalTo(weakSelf.collectionView).mas_offset(weakSelf.mloadMoreViewOffset);
                        make.centerX.mas_equalTo(weakSelf.collectionView.mas_centerX);
                        make.width.mas_equalTo([UIScreen mainScreen].bounds.size.width);
                        make.height.mas_equalTo(mLoadMoreViewHeight);
                    }];
                }
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

- (void)getShopCommentByPage:(NSInteger)page {
    HSNetworkManager *manager = [HSNetworkManager shareManager];
    NSString *url = [kGetShopCommentUrl stringByAppendingFormat:@"?dian_id=%ld&page=%ld", self.shopId, page];
    __weak __typeof__(self) weakSelf = self;
    [manager getDataWithUrl:url parameters:@{} success:^(NSDictionary *responseDict) {
        // 获取成功
        if ([responseDict[@"errcode"] isEqual:@(0)]) {
            if (page == 1) {
                // 获取首页，则清空所有
                [weakSelf.shopCommentArray removeAllObjects];
            }
            NSArray *listData = responseDict[@"list"];
            // 判断是否有下一页
            if ([listData count] < mShopCommentPerPage) {
                weakSelf.nextShopCommentPage = 0;
            } else {
                weakSelf.nextShopCommentPage = page + 1;
            }
            if (![listData isEqual:[NSNull null]] && listData != nil) {
                [weakSelf.shopCommentArray addObjectsFromArray:listData];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([weakSelf.shopCommentArray count] == 0) {
                    [weakSelf.emptyView setHidden:NO];
                } else {
                    [weakSelf.emptyView setHidden:YES];
                }
                // 更新ui
                [weakSelf.collectionView reloadSections:[[NSIndexSet alloc] initWithIndex:0]];
                NSLog(@"[UIScreen mainScreen].bounds.size.height = %f", [UIScreen mainScreen].bounds.size.height);
                NSLog(@"view.bounds.size.height = %f", weakSelf.view.bounds.size.height);
                CGFloat collectionViewHeight = 20.f;
                if ([weakSelf.shopCommentArray count] == 0) {
                    collectionViewHeight = 0.f;
                } else {
                    collectionViewHeight += [weakSelf.shopCommentArray count] * mCommentCellHeight + ([weakSelf.shopCommentArray count] - 1) * 20.f;
                }
                if (collectionViewHeight >= weakSelf.view.bounds.size.height + mTableViewBaseContentOffsetY - mHeaderHeight) {
                    // collectionView的contentSize.height > 屏幕高度
                    weakSelf.mloadMoreViewOffset = collectionViewHeight + mHeaderHeight;
                    [weakSelf.loadMoreView mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.top.mas_equalTo(weakSelf.collectionView).mas_offset(weakSelf.mloadMoreViewOffset);
                        make.centerX.mas_equalTo(weakSelf.collectionView.mas_centerX);
                        make.width.mas_equalTo([UIScreen mainScreen].bounds.size.width);
                        make.height.mas_equalTo(mLoadMoreViewHeight);
                    }];
                } else {
                    // collectionView内容过少
                    weakSelf.mloadMoreViewOffset = [UIScreen mainScreen].bounds.size.height + mTableViewBaseContentOffsetY;
                    [weakSelf.loadMoreView mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.top.mas_equalTo(weakSelf.collectionView).mas_offset(weakSelf.mloadMoreViewOffset);
                        make.centerX.mas_equalTo(weakSelf.collectionView.mas_centerX);
                        make.width.mas_equalTo([UIScreen mainScreen].bounds.size.width);
                        make.height.mas_equalTo(mLoadMoreViewHeight);
                    }];
                }
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

- (void)initShopData {
    if ([[self.shopDataMutableDict allKeys] containsObject:@"backgroundImage"]) {
        [self.backgroundImageView setImage:self.shopDataMutableDict[@"backgroundImage"]];
    }
    if ([[self.shopDataMutableDict allKeys] containsObject:@"logoImage"]) {
        [self.logoImageView setImage:self.shopDataMutableDict[@"logoImage"]];
    }
    if ([[self.shopDataMutableDict allKeys] containsObject:@"title"]) {
        [self.shopTitleLabel setText:[NSString stringWithFormat:@"%@", self.shopDataMutableDict[@"title"]]];
    }
    NSString *shopDescriptionString = nil;
    if (![self.shopDataMutableDict[@"message"] isEqual:[NSNull null]]) {
        shopDescriptionString = [NSString stringWithFormat:@"%@", self.shopDataMutableDict[@"message"]];
    }
    if (shopDescriptionString != nil) {
        [self.shopDescriptionLabel setText:shopDescriptionString];
    }
    if ([[self.shopDataMutableDict allKeys] containsObject:@"catids_str"]) {
        NSArray *shopTypeArray = self.shopDataMutableDict[@"catids_str"];
        NSMutableArray<UILabel *> *shopTypeLabelArray = [NSMutableArray new];
        for (int i = 0; i < [shopTypeArray count]; ++i) {
            UILabel *shopTypeLabel = [UILabel new];
            [shopTypeLabel setText:[NSString stringWithFormat:@"%@", shopTypeArray[i]]];
            [shopTypeLabel setTextColor:[UIColor whiteColor]];
            [shopTypeLabel setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];
            [shopTypeLabel.layer setBorderColor:[[UIColor whiteColor] CGColor]];
            [shopTypeLabel.layer setBorderWidth:0.5f];
            [shopTypeLabelArray addObject:shopTypeLabel];
            [self.shopTypeView addSubview:shopTypeLabel];
            [shopTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(self.shopTypeView);
                if (i > 0) {
                    make.left.mas_equalTo(shopTypeLabelArray[i - 1].mas_right).mas_offset(10);
                } else {
                    make.left.mas_equalTo(self.shopTypeView);
                }
                make.height.mas_equalTo(self.shopTypeView);
                if (i + 1 == [shopTypeArray count]) {
                    make.right.mas_equalTo(self.shopTypeView);
                }
            }];
        }
        [self.shopTypeView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.backgroundView);
            if (shopDescriptionString != nil) {
                make.top.mas_equalTo(self.shopDescriptionLabel.mas_bottom).mas_offset(10);
            } else {
                make.top.mas_equalTo(self.shopTitleLabel.mas_bottom).mas_offset(10);
            }
        }];
    }
}

@end
