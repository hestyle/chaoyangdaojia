//
//  HSFirstCollectionViewController.m
//  chaoyangdaojia
//
//  Created by hestyle on 2021/1/15.
//  Copyright © 2021 hestyle. All rights reserved.
//

#import "HSFirstCollectionViewController.h"
#import "HSSortCollectionViewController.h"
#import "HSQiangGouTableViewController.h"
#import "HSPinTuanTableViewController.h"
#import "HSBannerDetailViewController.h"
#import "HSCategoryDetailViewController.h"
#import "HSMemberWalletViewController.h"
#import "HSProductDetailViewController.h"
#import "HSTools.h"
#import "HSAccount.h"
#import "HSNetwork.h"
#import <Masonry/Masonry.h>
#import <Toast/Toast.h>

@interface HSFirstCollectionViewController ()

@property (nonatomic, strong) UIView *refreshView;
@property (nonatomic, strong) UIImageView *refreshImageView;
@property (nonatomic, strong) UILabel *refreshLabel;
@property (nonatomic, strong) UILabel *lastRefreshTimeLabel;

@property (nonatomic) NSInteger nextProductPage;
@property (nonatomic) CGFloat mloadMoreViewOffset;
@property (nonatomic, strong) UIView *loadMoreView;
@property (nonatomic, strong) UILabel *loadMoreLabel;

@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) UIImageView *gotoTopImageView;

@property (nonatomic, strong) UIView *categorySectionHeaderView;
@property (nonatomic, strong) UIView *carouselView;
@property (nonatomic, strong) UIScrollView *carouselScrollView;
@property (nonatomic, strong) UIImageView *carouselLeftImageView;
@property (nonatomic, strong) UIImageView *carouselCurrentImageView;
@property (nonatomic, strong) UIImageView *carouselRightImageView;
@property (nonatomic, strong) UIPageControl *carouselPageControl;
@property (nonatomic, strong) UIView *memberInfoView;
@property (nonatomic, strong) UIImageView *memberImageView;
@property (nonatomic, strong) UILabel *memberNameLabel;
@property (nonatomic, strong) UILabel *memberTypeLabel;
@property (nonatomic, strong) UILabel *memberRechargeLabel;

@property (nonatomic, strong) UIView *qiangGouSectionHeaderView;
@property (nonatomic, strong) UIView *pinTuanSectionHeaderView;
@property (nonatomic, strong) UIView *productSectionHeaderView;

@property (nonatomic, strong) NSMutableArray *bannerArray;
@property (nonatomic, strong) NSMutableArray *categoryArray;
@property (nonatomic, strong) NSMutableArray *productArray;
@property (nonatomic, strong) NSMutableArray *qiangGouArray;
@property (nonatomic, strong) NSMutableArray *pinTuanArray;
@property (nonatomic, strong) NSArray *recipeArray;

@end

@implementation HSFirstCollectionViewController

/* 轮播转动间隔 */
static BOOL mCarouselChangeContinue = NO;
static CGFloat mCarouselChangeInterval = 3.0;

static NSString * const reuseCellIdentifier = @"reusableCell";
static NSString * const reuseHeaderIdentifier = @"reusableHeaderView";

static const NSInteger mProductPerPage = 10;
static const NSInteger mRefreshViewHeight = 60;
static const NSInteger mLoadMoreViewHeight = 60;
/* navigationBar高度44、状态栏（狗啃屏）高度44，contentInsetAdjustmentBehavior */
static const NSInteger mTableViewBaseContentOffsetY = -88;

static const CGFloat mCategorySectionHeaderHeight = 160.f;
static const CGFloat mQiangGouSectionHeaderHeight = 60.f;
static const CGFloat mPinTuanSectionHeaderHeight = 60.f;
static const CGFloat mProductSectionHeaderHeight = 60.f;

static const CGFloat mMemberInfoViewHeight = 70.f;

static const CGFloat mCategoryCellWidth = 60.f;
static const CGFloat mCategoryCellHeight = 90.f;

static NSInteger mQiangGouCellCount = 1;
static const CGFloat mQiangGouCellWidth = 100.f;
static const CGFloat mQiangGouCellHeight = 180.f;

static const CGFloat mPinTuanCellHeight = 340.f;

static const CGFloat mProductCellWidth = 170.f;
static const CGFloat mProductCellHeight = 260.f;

- (instancetype)init {
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    self = [super initWithCollectionViewLayout:flowLayout];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setEdgesForExtendedLayout:UIRectEdgeBottom];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    
    // Register cell classes
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseHeaderIdentifier];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseCellIdentifier];
    
    self.nextProductPage = 0;
    self.bannerArray = [NSMutableArray new];
    self.categoryArray = [NSMutableArray new];
    self.qiangGouArray = [NSMutableArray new];
    self.pinTuanArray = [NSMutableArray new];
    self.productArray = [NSMutableArray new];
    
    [self initView];
    [self getIndexData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tabBarController setTitle:@"首页"];
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.view addSubview:self.titleView];

    // 开始轮转
    [self startCarouselAutoChange];
    // 刷新第一个section(防止未登录出现memberInfoView)
    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.titleView removeFromSuperview];
    // 停止轮转
    [self stopCarouselAutoChange];
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        HSUserAccountManger *manager = [HSUserAccountManger shareManager];
        if (manager.isLogin) {
            CGSize headerSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, mCategorySectionHeaderHeight + mMemberInfoViewHeight + 10);
            [self.categorySectionHeaderView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(headerSize);
            }];
            [self.memberInfoView setHidden:NO];
            [self memberInfoViewSetData];
            return headerSize;
        } else {
            [self.memberInfoView setHidden:YES];
            return CGSizeMake([UIScreen mainScreen].bounds.size.width, mCategorySectionHeaderHeight);
        }
    } else if (section == 1) {
        return CGSizeMake([UIScreen mainScreen].bounds.size.width, mQiangGouSectionHeaderHeight);
    } else if (section == 2) {
        return CGSizeMake([UIScreen mainScreen].bounds.size.width, mPinTuanSectionHeaderHeight);
    } else if (section == 3) {
        return CGSizeMake([UIScreen mainScreen].bounds.size.width, mProductSectionHeaderHeight);
    }
    return CGSizeZero;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseHeaderIdentifier forIndexPath:indexPath];
        for (UIView *view in headerView.subviews) {
            [view removeFromSuperview];
        }
        if (indexPath.section == 0) {
            [headerView addSubview:self.categorySectionHeaderView];
        } else if (indexPath.section == 1) {
            [headerView addSubview:self.qiangGouSectionHeaderView];
        } else if (indexPath.section == 2) {
            [headerView addSubview:self.pinTuanSectionHeaderView];
        } else if (indexPath.section == 3) {
            [headerView addSubview:self.productSectionHeaderView];
        }
        return headerView;
    } else {
        return nil;
    }
}

#pragma mark <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 4;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return [self.categoryArray count];
    } else if (section == 1) {
        if (mQiangGouCellCount > [self.qiangGouArray count]) {
            return [self.qiangGouArray count];
        } else {
            return mQiangGouCellCount;
        }
    } else if (section == 2) {
        return [self.pinTuanArray count];
    } else if (section == 3) {
        return [self.productArray count];
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseCellIdentifier forIndexPath:indexPath];
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    if (indexPath.section == 0) {
        NSDictionary *categoryDataDict = self.categoryArray[indexPath.row];
        UIView *categoryView = [UIView new];
        [cell.contentView addSubview:categoryView];
        [categoryView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(cell.contentView);
            make.center.mas_equalTo(cell.contentView);
        }];
        UIImageView *categoryImageView = [UIImageView new];
        [categoryImageView.layer setCornerRadius:25.f];
        [categoryImageView setBackgroundColor:[UIColor colorWithRed:233/255.0 green:233/255.0 blue:233/255.0 alpha:1.0]];
        [categoryView addSubview:categoryImageView];
        [categoryImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(50, 50));
            make.centerX.mas_equalTo(categoryView);
            make.top.mas_equalTo(categoryView).mas_equalTo(5);
        }];
        UILabel *categoryNameLabel = [UILabel new];
        [categoryNameLabel setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize] + 2]];
        [categoryNameLabel setText:categoryDataDict[@"name"]];
        [categoryView addSubview:categoryNameLabel];
        [categoryNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_lessThanOrEqualTo(categoryView);
            make.centerX.mas_equalTo(categoryView);
            make.top.mas_equalTo(categoryImageView.mas_bottom).mas_offset(10);
        }];
        if ([[categoryDataDict allKeys] containsObject:@"categoryImage"]) {
            [categoryImageView setImage:categoryDataDict[@"categoryImage"]];
        } else {
            // 加载图片
            __weak __typeof__(self) weakSelf = self;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSURL *categoryImageUrl = [NSURL URLWithString:categoryDataDict[@"image"]];
                NSData *categoryImageData = [NSData dataWithContentsOfURL:categoryImageUrl];
                UIImage *categoryImage = [UIImage imageWithData:categoryImageData];
                // 缓存至categoryArray中
                NSMutableDictionary *categoryDataMutableDict = categoryDataDict.mutableCopy;
                categoryDataMutableDict[@"categoryImage"] = categoryImage;
                weakSelf.categoryArray[indexPath.row] = categoryDataMutableDict.copy;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [categoryImageView setImage:categoryImage];
                });
            });
        }
    } else if (indexPath.section == 1) {
        NSDictionary *qiangGouDataDict = self.qiangGouArray[indexPath.row];
        UIView *qiangGouView = [UIView new];
        [cell.contentView addSubview:qiangGouView];
        [qiangGouView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(cell.contentView);
            make.center.mas_equalTo(cell.contentView);
        }];
        UIView *imageHeaderView = [UIView new];
        [imageHeaderView.layer setBorderColor:[[UIColor orangeColor] CGColor]];
        [imageHeaderView.layer setBorderWidth:0.5];
        [qiangGouView addSubview:imageHeaderView];
        [imageHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(qiangGouView);
            make.height.mas_equalTo(90);
            make.top.mas_equalTo(qiangGouView);
            make.centerX.mas_equalTo(qiangGouView);
        }];
        UIImageView *qiangGouImageView = [UIImageView new];
        [imageHeaderView addSubview:qiangGouImageView];
        [qiangGouImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(imageHeaderView);
            make.height.mas_equalTo(70);
            make.top.mas_equalTo(imageHeaderView);
            make.centerX.mas_equalTo(imageHeaderView);
        }];
        UIView *qiangGouTimeView = [UIView new];
        [qiangGouTimeView setBackgroundColor:[UIColor orangeColor]];
        [imageHeaderView addSubview:qiangGouTimeView];
        [qiangGouTimeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(qiangGouImageView.mas_bottom);
            make.bottom.mas_equalTo(imageHeaderView);
            make.width.mas_equalTo(imageHeaderView);
            make.centerX.mas_equalTo(imageHeaderView);
        }];
        UIImageView *qiangGouTimeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"qianggou_time_white_icon"]];
        [qiangGouTimeView addSubview:qiangGouTimeImageView];
        [qiangGouTimeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(12, 12));
            make.left.mas_equalTo(qiangGouTimeView).mas_offset(1);
            make.centerY.mas_equalTo(qiangGouTimeView).mas_offset(2);
        }];
        UILabel *qiangGouTimeLabel = [UILabel new];
        [qiangGouTimeLabel setTextColor:[UIColor whiteColor]];
        [qiangGouTimeLabel setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize] - 3]];
        [qiangGouTimeLabel setText:@"距离结束 99:99:00"];
        [qiangGouTimeView addSubview:qiangGouTimeLabel];
        [qiangGouTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(qiangGouTimeImageView.mas_right).mas_offset(1);
            make.right.mas_lessThanOrEqualTo(qiangGouTimeView);
            make.centerY.mas_equalTo(qiangGouTimeView);
        }];
        
        UIView *qiangGouProgressView = [UIView new];
        [qiangGouProgressView.layer setCornerRadius:6];
        [qiangGouProgressView setBackgroundColor:[UIColor colorWithRed:233/255.0 green:233/255.0 blue:233/255.0 alpha:1.0]];
        [qiangGouView addSubview:qiangGouProgressView];
        [qiangGouProgressView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(qiangGouView);
            make.height.mas_equalTo(16);
            make.top.mas_equalTo(imageHeaderView.mas_bottom).mas_offset(5);
            make.centerX.mas_equalTo(qiangGouView);
        }];
        NSInteger kuNum = [qiangGouDataDict[@"ku_num"] integerValue];
        NSInteger buyNum = [qiangGouDataDict[@"buy_num"] integerValue];
        UIView *qiangGouRemindProgressView = [UIView new];
        [qiangGouRemindProgressView.layer setCornerRadius:6];
        [qiangGouRemindProgressView setBackgroundColor:[UIColor orangeColor]];
        [qiangGouProgressView addSubview:qiangGouRemindProgressView];
        [qiangGouRemindProgressView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(qiangGouProgressView);
            make.height.mas_equalTo(qiangGouProgressView);
            make.top.mas_equalTo(qiangGouProgressView);
            make.width.mas_equalTo(mQiangGouCellWidth * 1.0 * kuNum / (kuNum + buyNum));
        }];
        UILabel *qiangGouRemindLabel = [UILabel new];
        [qiangGouRemindLabel setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];
        [qiangGouRemindLabel setText:[NSString stringWithFormat:@"剩余%ld份", kuNum]];
        [qiangGouProgressView addSubview:qiangGouRemindLabel];
        [qiangGouRemindLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(qiangGouProgressView);
        }];
        UILabel *titleLabel = [UILabel new];
        [titleLabel setFont:[UIFont systemFontOfSize:[UIFont systemFontSize] - 1]];
        [titleLabel setText:qiangGouDataDict[@"title"]];
        [qiangGouView addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(qiangGouView);
            make.width.mas_lessThanOrEqualTo(qiangGouView);
            make.top.mas_equalTo(qiangGouProgressView.mas_bottom).mas_offset(5);
        }];
        UILabel *nowPriceLabel = [UILabel new];
        [nowPriceLabel setTextColor:[UIColor redColor]];
        [nowPriceLabel setFont:[UIFont systemFontOfSize:[UIFont systemFontSize] - 2]];
        [nowPriceLabel setText:[NSString stringWithFormat:@"￥%@", qiangGouDataDict[@"price"]]];
        [qiangGouView addSubview:nowPriceLabel];
        [nowPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(qiangGouView);
            make.width.mas_lessThanOrEqualTo(qiangGouView);
            make.top.mas_equalTo(titleLabel.mas_bottom).mas_offset(5);
        }];
        UILabel *beforePriceLabel = [UILabel new];
        NSAttributedString *attributeString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"￥%@", qiangGouDataDict[@"scprice"]] attributes:@{NSForegroundColorAttributeName:[UIColor grayColor], NSStrikethroughStyleAttributeName:@(NSUnderlineStyleSingle | NSUnderlinePatternSolid), NSStrokeColorAttributeName:[UIColor grayColor], NSFontAttributeName:[UIFont systemFontOfSize:[UIFont smallSystemFontSize] - 1]}];
        [beforePriceLabel setAttributedText:attributeString];
        [qiangGouView addSubview:beforePriceLabel];
        [beforePriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(qiangGouView);
            make.width.mas_lessThanOrEqualTo(qiangGouView);
            make.top.mas_equalTo(nowPriceLabel.mas_bottom).mas_offset(1);
        }];
        if ([[qiangGouDataDict allKeys] containsObject:@"qiangGouImage"]) {
            [qiangGouImageView setImage:qiangGouDataDict[@"qiangGouImage"]];
        } else {
            // 加载图片
            __weak __typeof__(self) weakSelf = self;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSURL *qiangGouImageUrl = [NSURL URLWithString:qiangGouDataDict[@"image"]];
                NSData *qiangGouImageData = [NSData dataWithContentsOfURL:qiangGouImageUrl];
                UIImage *qiangGouImage = [UIImage imageWithData:qiangGouImageData];
                // 缓存至qiangGouArray中
                NSMutableDictionary *qiangGouDataMutableDict = qiangGouDataDict.mutableCopy;
                qiangGouDataMutableDict[@"qiangGouImage"] = qiangGouImage;
                weakSelf.qiangGouArray[indexPath.row] = qiangGouDataMutableDict.copy;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [qiangGouImageView setImage:qiangGouImage];
                });
            });
        }
    } else if (indexPath.section == 2) {
        NSDictionary *pinTuanDataDict = self.pinTuanArray[indexPath.row];
        UIView *pinTuanView = [UIView new];
        [cell.contentView addSubview:pinTuanView];
        [pinTuanView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(cell.contentView);
            make.center.mas_equalTo(cell.contentView);
        }];
        UIView *imageHeaderView = [UIView new];
        [pinTuanView addSubview:imageHeaderView];
        [imageHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(pinTuanView);
            make.right.mas_equalTo(pinTuanView);
            make.top.mas_equalTo(pinTuanView);
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
            make.left.mas_equalTo(pinTuanView);
            make.right.mas_equalTo(pinTuanView);
            make.height.mas_equalTo(80);
            make.bottom.mas_equalTo(pinTuanView);
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
            NSInteger minCount = (endTimeStamp - nowTimeStamp) % 3600 / 60;
            NSInteger secCount = (endTimeStamp - nowTimeStamp) % 60;
            UILabel *timeLabel = [UILabel new];
            [timeLabel setText:[NSString stringWithFormat:@"%2ld:%2ld:%2ld", hourCount, minCount, secCount]];
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
                weakSelf.pinTuanArray[indexPath.row] = pinTuanDataMutableDict.copy;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [pinTuanImageView setImage:pinTuanImage];
                });
            });
        }
    } else if (indexPath.section == 3) {
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
        [addToCartImageView setTag:indexPath.row];
        [productView addSubview:addToCartImageView];
        [addToCartImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(23, 23));
            make.right.mas_equalTo(productImageView);
            make.centerY.mas_equalTo(priceLabel.mas_bottom);
        }];
        // 添加点击事件
        UITapGestureRecognizer *addToCartTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addToCartAction:)];
        [addToCartTapGesture setNumberOfTapsRequired:1];
        [addToCartImageView setUserInteractionEnabled:YES];
        [addToCartImageView addGestureRecognizer:addToCartTapGesture];
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
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return CGSizeMake(mCategoryCellWidth, mCategoryCellHeight);
    } else if (indexPath.section == 1) {
        return CGSizeMake(mQiangGouCellWidth, mQiangGouCellHeight);
    } else if (indexPath.section == 2) {
        return CGSizeMake([UIScreen mainScreen].bounds.size.width - 40, mPinTuanCellHeight);
    } else if (indexPath.section == 3) {
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
        NSDictionary *categoryDataDict = self.categoryArray[indexPath.row];
        HSCategoryDetailViewController *controller = [[HSCategoryDetailViewController alloc] initWithCategoryData:categoryDataDict];
        [self.navigationController pushViewController:controller animated:YES];
    } else if (indexPath.section == 1) {
        NSDictionary *productDataDict = self.qiangGouArray[indexPath.row];
        HSProductDetailViewController *controller = [[HSProductDetailViewController alloc] initWithProductId:[productDataDict[@"sid"] integerValue]];
        [self.navigationController pushViewController:controller animated:YES];
    } else if (indexPath.section == 2) {
        NSDictionary *productDataDict = self.pinTuanArray[indexPath.row];
        HSProductDetailViewController *controller = [[HSProductDetailViewController alloc] initWithProductId:[productDataDict[@"sid"] integerValue]];
        [self.navigationController pushViewController:controller animated:YES];
    } else if (indexPath.section == 3) {
        NSDictionary *productDataDict = self.productArray[indexPath.row];
        HSProductDetailViewController *controller = [[HSProductDetailViewController alloc] initWithProductId:[productDataDict[@"id"] integerValue]];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.carouselScrollView) {
        NSInteger currentPage = self.carouselPageControl.currentPage;
        if (scrollView.contentOffset.x > scrollView.frame.size.width) {
            // 向右滑
            currentPage = (currentPage + 1);
            if ([self.bannerArray count] != 0) {
                currentPage %= [self.bannerArray count];
            } else {
                currentPage %= 3;
            }
        } else if (scrollView.contentOffset.x == 0){
            // 向左滑
            currentPage = currentPage - 1;
            if ([self.bannerArray count] != 0) {
                currentPage = (currentPage + [self.bannerArray count]) % [self.bannerArray count];
            } else {
                currentPage = (currentPage + 3) % [self.bannerArray count];
            }
        } else {
            // 未滑动
            return;
        }
        [self.carouselPageControl setCurrentPage:currentPage];
        [self updateCarouselUi];
        scrollView.contentOffset = CGPointMake(scrollView.bounds.size.width, 0);
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView != self.collectionView) {
        return;
    }
    if (self.gotoTopImageView.hidden && scrollView.contentOffset.y >= [UIScreen mainScreen].bounds.size.height + mTableViewBaseContentOffsetY) {
        // 滚动超过一屏，则显示gotoTopImageView
        [self.gotoTopImageView setHidden:NO];
    } else if (!self.gotoTopImageView.hidden && scrollView.contentOffset.y < [UIScreen mainScreen].bounds.size.height + mTableViewBaseContentOffsetY) {
        // 否则隐藏
        [self.gotoTopImageView setHidden:YES];
    }
    if (scrollView.contentOffset.y <= -mRefreshViewHeight + mTableViewBaseContentOffsetY) {
        if (self.refreshView.tag == 0) {
            self.refreshLabel.text = @"松开刷新";
        }
        self.refreshView.tag = -1;
    } else if (scrollView.contentOffset.y >= self.mloadMoreViewOffset + mLoadMoreViewHeight - ([UIScreen mainScreen].bounds.size.height + mTableViewBaseContentOffsetY)) {
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

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    if (scrollView != self.collectionView) {
        return;
    }
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
        [self getIndexData];
    } else if (self.loadMoreView.tag == 1) {
        self.loadMoreView.tag = 0;
        // 加载下一页
        if (self.nextProductPage != 0) {
            NSLog(@"已触发上拉加载更多！");
            [self.loadMoreView setHidden:YES];
            [self getShopProductByPage:self.nextProductPage];
        }
    }
    NSLog(@"scrollView.contentOffset.y = %f", scrollView.contentOffset.y);
}

#pragma mark - Event
- (void)gotoSearchAction {
    [self.view makeToast:@"点击了搜索栏！"];
}

- (void)gotoTopAction {
    [self.gotoTopImageView setHidden:YES];
    [self.collectionView setContentOffset:CGPointMake(0, mTableViewBaseContentOffsetY) animated:YES];
}

- (void)gotoCarouselImageDetailAction {
    NSInteger currentPage = self.carouselPageControl.currentPage;
    NSInteger bannerId = [((NSDictionary *)self.bannerArray[currentPage])[@"id"] integerValue];
    HSBannerDetailViewController *controller = [HSBannerDetailViewController new];
    [controller setBannerId:bannerId];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)pageControlChangeAction {
    [self updateCarouselUi];
}

- (void)gotoQiangGouDetailAction {
    HSQiangGouTableViewController *controller = [HSQiangGouTableViewController new];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)gotoPinTuanDetailAction {
    HSPinTuanTableViewController *controller = [HSPinTuanTableViewController new];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)gotoMemberWalletAction {
    HSMemberWalletViewController *controller = [HSMemberWalletViewController new];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)addToCartAction:(UITapGestureRecognizer *)sender {
    NSInteger index = sender.view.tag;
    NSDictionary *productDataDict = self.productArray[index];
    
    NSDictionary *parameters = @{@"buynum":[NSString stringWithFormat:@"%d", 1], @"gkey":productDataDict[@"defkey"], @"sid":[NSString stringWithFormat:@"%@", productDataDict[@"id"]]};
    
    HSNetworkManager *manager = [HSNetworkManager shareManager];
    __weak __typeof__(self) weakSelf = self;
    [manager postDataWithUrl:kAddProductToCartUrl parameters:parameters success:^(NSDictionary *responseDict) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.view makeToast:responseDict[@"msg"] duration:2.f position:CSToastPositionCenter];
        });
        // 添加成功
        if ([responseDict[@"errcode"] isEqual:@(0)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // 获取cell在self.view的rect
                UICollectionViewCell * cell = (UICollectionViewCell *)[weakSelf.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:3]];
                CGRect cellAtCollectionViewRect = [weakSelf.collectionView convertRect:cell.frame toView:weakSelf.collectionView];
                CGRect cellAtViewRect = [weakSelf.collectionView convertRect:cellAtCollectionViewRect toView:weakSelf.view];
                UIView *view = [[UIView alloc] initWithFrame:cellAtViewRect];
                [view.layer setContents:(id)((UIImage *)productDataDict[@"productImage"]).CGImage];
                
                HSAddToCartAnimation *addToCartAnimation = [HSAddToCartAnimation shareInstance];
                [addToCartAnimation startAnimationWithView:view rect:cellAtViewRect finishPoint:CGPointMake(SCREEN_WIDTH / 5 * 3.5, SCREEN_HEIGHT - 49) finishBlock:^(BOOL finish) {
                    NSLog(@"动画完成播放！");
                    // 获取需要抖动的图标
                    UIView *cartTabBarItemView = (UIView *)[weakSelf.tabBarController.tabBar.items[3] valueForKey:@"_view"];
                    [HSAddToCartAnimation shakeAnimation:cartTabBarItemView];
                }];
            });
        }
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.view makeToast:@"获取失败，接口请求错误！" duration:3 position:CSToastPositionCenter];
        });
        NSLog(@"%@", error);
    }];
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
    [self.loadMoreView setBackgroundColor:[UIColor whiteColor]];
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
    [self.loadMoreView setHidden:YES];
    
    [self initTitleView];
    
    [self initGotoTopView];
    
    [self initCategorySectionHeaderView];
    
    [self initQiangGouSectionHeaderView];
    
    [self initPinTuanSectionHeaderView];
    
    [self initProductSectionHeaderView];
}

- (void)initTitleView {
    self.titleView = [[UIView alloc] initWithFrame:CGRectMake(20, 46, [UIScreen mainScreen].bounds.size.width - 40, 40)];
    UIImageView *messageImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"app_message"]];
    [self.titleView addSubview:messageImageView];
    [messageImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(45, 45));
        make.right.mas_equalTo(self.titleView).mas_offset(5);
        make.centerY.mas_equalTo(self.titleView);
    }];
    UIView *searchView = [UIView new];
    [searchView setBackgroundColor:[UIColor whiteColor]];
    [searchView.layer setCornerRadius:5.f];
    [self.titleView addSubview:searchView];
    [searchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleView);
        make.right.mas_equalTo(messageImageView.mas_left).mas_offset(-15);
        make.height.mas_equalTo(35);
        make.centerY.mas_equalTo(self.titleView);
    }];
    // 添加点击事件
    UITapGestureRecognizer *gotoSearchTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoSearchAction)];
    [gotoSearchTapGesture setNumberOfTapsRequired:1];
    [searchView setUserInteractionEnabled:YES];
    [searchView addGestureRecognizer:gotoSearchTapGesture];
    
    UIImageView *searchImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search_iocn"]];
    [searchView addSubview:searchImageView];
    [searchImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(searchView).mas_offset(5);
        make.size.mas_equalTo(CGSizeMake(25, 25));
        make.centerY.mas_equalTo(searchView);
    }];
    UILabel *searchTitleLabel = [UILabel new];
    [searchTitleLabel setTextColor:[UIColor colorWithRed:154.0/255 green:154.0/255 blue:154.0/255 alpha:1.0]];
    [searchTitleLabel setText:@"搜索商品"];
    [searchView addSubview:searchTitleLabel];
    [searchTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(searchImageView.mas_right).mas_offset(5);
        make.centerY.mas_equalTo(searchView);
    }];
}

- (void)initGotoTopView {
    self.gotoTopImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"goto_top"]];
    [self.gotoTopImageView.layer setCornerRadius:22.5f];
    [self.view addSubview:self.gotoTopImageView];
    [self.gotoTopImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(45, 45));
        make.right.mas_equalTo(self.view).mas_offset(-30);
        make.bottom.mas_equalTo(self.view).mas_offset(-83-30);
    }];
    // 添加点击事件
    UITapGestureRecognizer *gotoTopTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoTopAction)];
    [gotoTopTapGesture setNumberOfTapsRequired:1];
    [self.gotoTopImageView setUserInteractionEnabled:YES];
    [self.gotoTopImageView addGestureRecognizer:gotoTopTapGesture];
    [self.gotoTopImageView setHidden:YES];
}

- (void)initCategorySectionHeaderView {
    self.categorySectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, mCategorySectionHeaderHeight)];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main_navigationbar_background"]];
    [self.categorySectionHeaderView addSubview:backgroundImageView];
    [backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake([UIScreen mainScreen].bounds.size.width, 180));
        make.top.mas_equalTo(self.categorySectionHeaderView).mas_offset(-mRefreshViewHeight);
        make.left.mas_equalTo(self.categorySectionHeaderView);
    }];
    
    self.carouselView = [UIView new];
    [self.categorySectionHeaderView addSubview:self.carouselView];
    [self.carouselView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.categorySectionHeaderView).mas_offset(20);
        make.right.mas_equalTo(self.categorySectionHeaderView).mas_offset(-20);
        make.top.mas_equalTo(self.categorySectionHeaderView).mas_offset(10);
        make.height.mas_equalTo(140);
    }];
    self.carouselScrollView = [UIScrollView new];
    [self.carouselScrollView setDelegate:self];
    [self.carouselScrollView setPagingEnabled:YES];
    [self.carouselScrollView setBackgroundColor:[UIColor grayColor]];
    [self.carouselScrollView setShowsHorizontalScrollIndicator:NO];
    [self.carouselScrollView setContentSize:CGSizeMake(([UIScreen mainScreen].bounds.size.width - 40) * 3, 0)];
    [self.carouselView addSubview:self.carouselScrollView];
    [self.carouselScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(self.carouselView);
        make.center.mas_equalTo(self.carouselView);
    }];
    self.carouselLeftImageView = [UIImageView new];
    [self.carouselScrollView addSubview:self.carouselLeftImageView];
    [self.carouselLeftImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(self.carouselScrollView);
        make.left.mas_equalTo(self.carouselScrollView);
        make.top.mas_equalTo(self.carouselScrollView);
    }];
    self.carouselCurrentImageView = [UIImageView new];
    [self.carouselScrollView addSubview:self.carouselCurrentImageView];
    [self.carouselCurrentImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(self.carouselScrollView);
        make.left.mas_equalTo(self.carouselLeftImageView.mas_right);
        make.top.mas_equalTo(self.carouselScrollView);
    }];
    // 添加点击事件
    UITapGestureRecognizer *gotoCarouselDetailTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoCarouselImageDetailAction)];
    [gotoCarouselDetailTapGesture setNumberOfTapsRequired:1];
    [self.carouselCurrentImageView setUserInteractionEnabled:YES];
    [self.carouselCurrentImageView addGestureRecognizer:gotoCarouselDetailTapGesture];
    
    self.carouselRightImageView = [UIImageView new];
    [self.carouselScrollView addSubview:self.carouselRightImageView];
    [self.carouselRightImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(self.carouselScrollView);
        make.left.mas_equalTo(self.carouselCurrentImageView.mas_right);
        make.top.mas_equalTo(self.carouselScrollView);
    }];
    self.carouselPageControl = [UIPageControl new];
    [self.carouselPageControl setNumberOfPages:3];
    [self.carouselPageControl setPageIndicatorTintColor:[UIColor whiteColor]];
    [self.carouselPageControl setCurrentPageIndicatorTintColor:[UIColor orangeColor]];
    [self.carouselPageControl addTarget:self action:@selector(pageControlChangeAction) forControlEvents:UIControlEventValueChanged];
    [self.carouselView addSubview:self.carouselPageControl];
    [self.carouselPageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.carouselView);
        make.height.mas_equalTo(15);
        make.bottom.mas_equalTo(self.carouselView).mas_offset(-15);
    }];
    // 会员充值view
    self.memberInfoView = [UIView new];
    [self.memberInfoView setBackgroundColor:[UIColor colorWithRed:237.0/255 green:237.0/255 blue:237.0/255 alpha:1.0]];
    [self.categorySectionHeaderView addSubview:self.memberInfoView];
    [self.memberInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.carouselView);
        make.right.mas_equalTo(self.carouselView);
        make.top.mas_equalTo(self.carouselView.mas_bottom).mas_offset(10);
        make.height.mas_equalTo(mMemberInfoViewHeight);
    }];
    self.memberImageView = [UIImageView new];
    [self.memberInfoView addSubview:self.memberImageView];
    [self.memberImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(45, 45));
        make.centerY.mas_equalTo(self.memberInfoView);
        make.left.mas_equalTo(self.memberInfoView).mas_offset(10);
    }];
    self.memberNameLabel = [UILabel new];
    [self.memberNameLabel setText:@"138****3293"];
    [self.memberInfoView addSubview:self.memberNameLabel];
    [self.memberNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.memberImageView.mas_right).mas_offset(10);
        make.top.mas_equalTo(self.memberImageView);
    }];
    UIImageView *memberIconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"vip_icon"]];
    [self.memberInfoView addSubview:memberIconImageView];
    [memberIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(15, 15));
        make.left.mas_equalTo(self.memberNameLabel.mas_right).mas_offset(10);
        make.centerY.mas_equalTo(self.memberNameLabel);
    }];
    self.memberTypeLabel = [UILabel new];
    [self.memberTypeLabel setText:@"普通会员"];
    [self.memberTypeLabel setTextColor:[UIColor colorWithRed:159.0/255 green:159.0/255 blue:159.0/255 alpha:1.0]];
    [self.memberTypeLabel setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];
    [self.memberInfoView addSubview:self.memberTypeLabel];
    [self.memberTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.memberNameLabel);
        make.top.mas_equalTo(self.memberNameLabel.mas_bottom).mas_offset(10);
    }];
    self.memberRechargeLabel = [UILabel new];
    [self.memberRechargeLabel setBackgroundColor:[UIColor redColor]];
    [self.memberRechargeLabel setFont:[UIFont systemFontOfSize:[UIFont systemFontSize] - 2]];
    [self.memberRechargeLabel setText:@"充值"];
    [self.memberRechargeLabel setTextAlignment:NSTextAlignmentCenter];
    [self.memberRechargeLabel setTextColor:[UIColor whiteColor]];
    [self.memberInfoView addSubview:self.memberRechargeLabel];
    [self.memberRechargeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.memberInfoView).mas_offset(-10);
        make.size.mas_equalTo(CGSizeMake(35, 20));
        make.centerY.mas_equalTo(self.memberInfoView);
    }];
    // 添加点击事件
    UITapGestureRecognizer *gotoMemberWalletTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoMemberWalletAction)];
    [gotoMemberWalletTapGesture setNumberOfTapsRequired:1];
    [self.memberRechargeLabel setUserInteractionEnabled:YES];
    [self.memberRechargeLabel addGestureRecognizer:gotoMemberWalletTapGesture];
}

- (void)initQiangGouSectionHeaderView {
    self.qiangGouSectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, mQiangGouSectionHeaderHeight)];
    UILabel *qiangGouTitleLabel = [UILabel new];
    [qiangGouTitleLabel setFont:[UIFont systemFontOfSize:[UIFont systemFontSize] + 5]];
    [qiangGouTitleLabel setText:@"限时抢购"];
    [self.qiangGouSectionHeaderView addSubview:qiangGouTitleLabel];
    [qiangGouTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.qiangGouSectionHeaderView);
        make.width.mas_lessThanOrEqualTo(self.qiangGouSectionHeaderView);
    }];
    UILabel *qiangGouDetailLabel = [UILabel new];
    [qiangGouDetailLabel setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];
    [qiangGouDetailLabel setTextColor:[UIColor grayColor]];
    [qiangGouDetailLabel setText:@"查看全部 >"];
    [self.qiangGouSectionHeaderView addSubview:qiangGouDetailLabel];
    [qiangGouDetailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.qiangGouSectionHeaderView).mas_offset(-20);
        make.centerY.mas_equalTo(self.qiangGouSectionHeaderView);
    }];
    // 添加点击事件
    UITapGestureRecognizer *gotoQiangGouTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoQiangGouDetailAction)];
    [gotoQiangGouTapGesture setNumberOfTapsRequired:1];
    [qiangGouDetailLabel setUserInteractionEnabled:YES];
    [qiangGouDetailLabel addGestureRecognizer:gotoQiangGouTapGesture];
}

- (void)initPinTuanSectionHeaderView {
    self.pinTuanSectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, mPinTuanSectionHeaderHeight)];
    UILabel *pinTuanTitleLabel = [UILabel new];
    [pinTuanTitleLabel setFont:[UIFont systemFontOfSize:[UIFont systemFontSize] + 5]];
    [pinTuanTitleLabel setText:@"拼团专区"];
    [self.pinTuanSectionHeaderView addSubview:pinTuanTitleLabel];
    [pinTuanTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.pinTuanSectionHeaderView);
        make.width.mas_lessThanOrEqualTo(self.pinTuanSectionHeaderView);
    }];
    UILabel *pinTuanDetailLabel = [UILabel new];
    [pinTuanDetailLabel setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];
    [pinTuanDetailLabel setTextColor:[UIColor grayColor]];
    [pinTuanDetailLabel setText:@"全部拼团 >"];
    [self.pinTuanSectionHeaderView addSubview:pinTuanDetailLabel];
    [pinTuanDetailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.pinTuanSectionHeaderView).mas_offset(-20);
        make.centerY.mas_equalTo(self.pinTuanSectionHeaderView);
    }];
    // 添加点击事件
    UITapGestureRecognizer *gotoPinTuanTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoPinTuanDetailAction)];
    [gotoPinTuanTapGesture setNumberOfTapsRequired:1];
    [pinTuanDetailLabel setUserInteractionEnabled:YES];
    [pinTuanDetailLabel addGestureRecognizer:gotoPinTuanTapGesture];
}

- (void)initProductSectionHeaderView {
    self.productSectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, mProductSectionHeaderHeight)];
    UILabel *productTitleLabel = [UILabel new];
    [productTitleLabel setFont:[UIFont systemFontOfSize:[UIFont systemFontSize] + 5]];
    [productTitleLabel setText:@"推荐商品"];
    [self.productSectionHeaderView addSubview:productTitleLabel];
    [productTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.productSectionHeaderView);
        make.width.mas_lessThanOrEqualTo(self.productSectionHeaderView);
    }];
}

- (void)getIndexData {
    HSNetworkManager *manager = [HSNetworkManager shareManager];
    __weak __typeof__(self) weakSelf = self;
    [manager postDataWithUrl:kGetIndexDataUrl parameters:@{} success:^(NSDictionary *responseDict) {
        // 获取成功
        if ([responseDict[@"errcode"] isEqual:@(0)]) {
            [weakSelf.bannerArray removeAllObjects];
            if (![responseDict[@"banner"] isEqual:[NSNull null]]) {
                [weakSelf.bannerArray addObjectsFromArray:responseDict[@"banner"]];
            }

            [weakSelf initCategoryArray:responseDict[@"category"]];
            
            [weakSelf.qiangGouArray removeAllObjects];
            if (![responseDict[@"qianggou"] isEqual:[NSNull null]]) {
                [weakSelf.qiangGouArray addObjectsFromArray:responseDict[@"qianggou"]];
            }
            // 抢购这个section只显示一列，所以需要计算一行屏幕能显示cell数量，20是边距
            mQiangGouCellCount = ([UIScreen mainScreen].bounds.size.width - 20) / (mQiangGouCellWidth + 20);
            
            [weakSelf.pinTuanArray removeAllObjects];
            if (![responseDict[@"pintuan"] isEqual:[NSNull null]]) {
                [weakSelf.pinTuanArray addObjectsFromArray:responseDict[@"pintuan"]];
            }
            
            weakSelf.nextProductPage = 2;
            [weakSelf.productArray removeAllObjects];
            if (![responseDict[@"shoplist"] isEqual:[NSNull null]]) {
                [weakSelf.productArray addObjectsFromArray:responseDict[@"shoplist"]];
            }
            
            weakSelf.recipeArray = responseDict[@"recipe"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.collectionView performBatchUpdates:^{
                    [weakSelf.loadMoreView setHidden:YES];
                    [weakSelf carouselViewLoadData];
                    [weakSelf.collectionView reloadSections:[[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(0, 4)]];
                } completion:^(BOOL finished) {
                    [weakSelf updateLoadMoreView];
                }];
            });
        }
        NSLog(@"接口 url = %@ 返回数据 responseDict = %@", kGetIndexDataUrl, responseDict);
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.view makeToast:@"接口请求错误！"];
        });
        NSLog(@"url = %@, error = %@", kGetIndexDataUrl, error);
    }];
}

- (void)carouselViewLoadData {
    [self.carouselPageControl setNumberOfPages:[self.bannerArray count]];
    [self.carouselScrollView setContentOffset:CGPointMake(self.carouselScrollView.bounds.size.width, 0)];
    [self.carouselPageControl setCurrentPage:0];
    [self updateCarouselUi];
    [self startCarouselAutoChange];
}

- (void)updateCarouselUi {
    if (self.bannerArray != nil && [self.bannerArray count] != 0) {
        NSInteger currentPage = self.carouselPageControl.currentPage;
        NSInteger leftPage = (currentPage + [self.bannerArray count] - 1) % [self.bannerArray count];
        NSInteger rightPage = (currentPage + 1) % [self.bannerArray count];
        
        NSDictionary *currentBannerDict = self.bannerArray[currentPage];
        if ([[currentBannerDict allKeys] containsObject:@"bannerImage"]) {
            [self.carouselCurrentImageView setImage:currentBannerDict[@"bannerImage"]];
        } else {
            __weak __typeof__(self) weakSelf = self;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSURL *bannerImageUrl = [NSURL URLWithString:currentBannerDict[@"image"]];
                NSData *bannerImageData = [NSData dataWithContentsOfURL:bannerImageUrl];
                UIImage *bannerImage = [UIImage imageWithData:bannerImageData];
                // 缓存至bannerArray中
                NSMutableDictionary *bannerDataMutableDict = currentBannerDict.mutableCopy;
                bannerDataMutableDict[@"bannerImage"] = bannerImage;
                weakSelf.bannerArray[currentPage] = bannerDataMutableDict.copy;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.carouselCurrentImageView setImage:bannerImage];
                });
            });
        }
        
        NSDictionary *leftBannerDict = self.bannerArray[leftPage];
        if ([[leftBannerDict allKeys] containsObject:@"bannerImage"]) {
            [self.carouselLeftImageView setImage:leftBannerDict[@"bannerImage"]];
        } else {
            __weak __typeof__(self) weakSelf = self;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSURL *bannerImageUrl = [NSURL URLWithString:leftBannerDict[@"image"]];
                NSData *bannerImageData = [NSData dataWithContentsOfURL:bannerImageUrl];
                UIImage *bannerImage = [UIImage imageWithData:bannerImageData];
                // 缓存至bannerArray中
                NSMutableDictionary *bannerDataMutableDict = leftBannerDict.mutableCopy;
                bannerDataMutableDict[@"bannerImage"] = bannerImage;
                weakSelf.bannerArray[leftPage] = bannerDataMutableDict.copy;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.carouselLeftImageView setImage:bannerImage];
                });
            });
        }
        
        NSDictionary *rightBannerDict = self.bannerArray[rightPage];
        if ([[rightBannerDict allKeys] containsObject:@"bannerImage"]) {
            [self.carouselRightImageView setImage:rightBannerDict[@"bannerImage"]];
        } else {
            __weak __typeof__(self) weakSelf = self;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSURL *bannerImageUrl = [NSURL URLWithString:rightBannerDict[@"image"]];
                NSData *bannerImageData = [NSData dataWithContentsOfURL:bannerImageUrl];
                UIImage *bannerImage = [UIImage imageWithData:bannerImageData];
                // 缓存至bannerArray中
                NSMutableDictionary *bannerDataMutableDict = rightBannerDict.mutableCopy;
                bannerDataMutableDict[@"bannerImage"] = bannerImage;
                weakSelf.bannerArray[rightPage] = bannerDataMutableDict.copy;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.carouselRightImageView setImage:bannerImage];
                });
            });
        }
    }
}

- (void)stopCarouselAutoChange {
    mCarouselChangeContinue = NO;
}

- (void)startCarouselAutoChange {
    if (mCarouselChangeContinue) {
        // mCarouselChangeContinue == YES,默认认为已经在自动轮播
        return;
    }
    mCarouselChangeContinue = YES;
    __weak __typeof__ (self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"自动轮播动作开始");
        while (mCarouselChangeContinue) {
            if ([weakSelf.bannerArray count] == 0) {
                mCarouselChangeContinue = NO;
                break;
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, mCarouselChangeInterval * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                // 触动carouselScrollView旋转
                [UIView animateWithDuration:0.5 animations:^{
                    [weakSelf.carouselScrollView setContentOffset:CGPointMake(weakSelf.carouselScrollView.bounds.size.width * 2, 0)];
                }];
                // 手动触发ScrollView协议方法
                [weakSelf scrollViewDidEndDecelerating:weakSelf.carouselScrollView];
                NSLog(@"一次轮播动作完成");
            });
            [NSThread sleepForTimeInterval:mCarouselChangeInterval];
        };
        NSLog(@"自动轮播动作结束");
    });
}

- (void)initCategoryArray:(NSArray *)tempArray {
    [self.categoryArray removeAllObjects];
    if (tempArray == nil || [tempArray count] == 0) {
        return;
    }
    NSMutableArray *categoryMutableArray = tempArray.mutableCopy;
    // 挑选出需要显示的分类
    for (int i = (int)[tempArray count] - 1; i >= 0; --i) {
        NSDictionary *dict = tempArray[i];
        if ([dict[@"show"] integerValue] != 1) {
            [categoryMutableArray removeObjectAtIndex:i];
        }
    }
    [self.categoryArray addObjectsFromArray:categoryMutableArray];
    [self sendDataToSortViewController];
}

- (void)getShopProductByPage:(NSInteger)page {
    HSNetworkManager *manager = [HSNetworkManager shareManager];
    NSString *url = [kGetIndexProductDataUrl stringByAppendingFormat:@"?page=%ld", page];
    __weak __typeof__(self) weakSelf = self;
    [manager getDataWithUrl:url parameters:@{} success:^(NSDictionary *responseDict) {
        // 获取成功
        if ([responseDict[@"errcode"] isEqual:@(0)]) {
            if (page == 1) {
                // 获取首页，则清空所有
                [weakSelf.productArray removeAllObjects];
            }
            NSArray *listData = responseDict[@"shoplist"];
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
                    [weakSelf.collectionView reloadSections:[[NSIndexSet alloc] initWithIndex:3]];
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

- (void)sendDataToSortViewController {
    HSSortCollectionViewController *controller = self.tabBarController.childViewControllers[1];
    [controller setCategoryArray:self.categoryArray.mutableCopy];
}

- (void)memberInfoViewSetData {
    HSUserAccountManger *manager = [HSUserAccountManger shareManager];
    NSDictionary *userInfoDict = manager.userInfoDict;
    [self.memberNameLabel setText:userInfoDict[@"nickname"]];
    [self.memberTypeLabel setText:userInfoDict[@"levelid_str"]];
    // 设置用户头像
    if (manager.avatarPath != nil) {
        NSString *path_sandox = NSHomeDirectory();
        NSString *avatarPath = [path_sandox stringByAppendingPathComponent:manager.avatarPath];
        UIImage *avatarImage = [UIImage imageWithContentsOfFile:avatarPath];
        [self.memberImageView setImage:avatarImage];
    } else {
        // 设置默认头像
        [self.memberImageView setImage:[UIImage imageNamed:@"noavatar"]];
    }
}

@end
