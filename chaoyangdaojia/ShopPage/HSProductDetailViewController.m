//
//  HSProductDetailViewController.m
//  chaoyangdaojia
//
//  Created by hestyle on 2021/1/20.
//  Copyright © 2021 hestyle. All rights reserved.
//

#import "HSProductDetailViewController.h"
#import "HSCommentTableViewController.h"
#import "HSProductSpecificationView.h"
#import "HSNetwork.h"
#import "HSTools.h"
#import <Masonry/Masonry.h>
#import <Toast/Toast.h>

@interface HSProductDetailViewController ()

@property (nonatomic) NSInteger productId;
@property (nonatomic) NSInteger selectIndex;
@property (nonatomic) NSInteger sectionCount;
@property (nonatomic) NSInteger currentImagePage;
@property (nonatomic, strong) NSMutableDictionary *productDataDict;
@property (nonatomic, strong) NSMutableArray *commentArray;
@property (nonatomic, strong) NSMutableDictionary *suyuanDataDict;
@property (nonatomic, strong) NSMutableDictionary *pinTuanDataDict;

@property (nonatomic, strong) UISegmentedControl *productSegmentedControl;

@property (nonatomic, strong) UIView *productInfoSectionHeaderView;
@property (nonatomic, strong) UIView *carouselView;
@property (nonatomic, strong) NSMutableArray *productImageArray;
@property (nonatomic, strong) UIScrollView *carouselScrollView;
@property (nonatomic, strong) UIImageView *carouselLeftImageView;
@property (nonatomic, strong) UIImageView *carouselCurrentImageView;
@property (nonatomic, strong) UIImageView *carouselRightImageView;
@property (nonatomic, strong) UILabel *imagePageInfoLabel;

@property (nonatomic, strong) UIView *specificationInfoSectionHeaderView;
@property (nonatomic, strong) UILabel *specificationLabel;

@property (nonatomic, strong) UIView *commentSectionHeaderView;
@property (nonatomic, strong) UILabel *commentTitleLabel;

@property (nonatomic) CGFloat productDescriptionCellHeight;
@property (nonatomic, strong) UIView *productDecriptionSectionHeaderView;
@property (nonatomic, strong) UIView *productDecriptionCellView;
@property (nonatomic, strong) WKWebView *contentWebView;

@property (nonatomic, strong) UIView *suyuanInfoSectionHeaderView;

@property (nonatomic, strong) UIView *tableViewFooterView;

@property (nonatomic, strong) UIView *refreshView;
@property (nonatomic, strong) UIImageView *refreshImageView;
@property (nonatomic, strong) UILabel *refreshLabel;
@property (nonatomic, strong) UILabel *lastRefreshTimeLabel;

@property (nonatomic, strong) HSProductSpecificationView *productSpecificationView;

@end

@implementation HSProductDetailViewController

/* 轮播转动间隔 */
static BOOL mCarouselChangeContinue = NO;
static CGFloat mCarouselChangeInterval = 3.0;

static NSString * const reuseCellIdentifier = @"reusableCell";
static const CGFloat mProductInfoSectionHeaderHeight = 340.f;
static const CGFloat mSpecificationInfoSectionHeaderHeight = 50.f;
static const CGFloat mCommentInfoSectionHeaderHeight = 50.f;
static const CGFloat mProductDescriptionSectionHeaderHeight = 50.f;
static const CGFloat mSuyuanInfoSectionHeaderHeight = 50.f;

static const CGFloat mProductInfoCellHeight = 155.f;
static const CGFloat mCommentInfoCellHeight = 100.f;

static const CGFloat mSectionFooterHeight = 8.f;
static const CGFloat mTableViewFooterHeight = 80.f;

static const NSInteger mRefreshViewHeight = 60;
/* navigationBar高度44、状态栏（狗啃屏）高度44，contentInsetAdjustmentBehavior */
static const NSInteger mTableViewBaseContentOffsetY = -88;

- (instancetype)initWithProductId:(NSInteger)productId {
    self = [super init];
    
    self.productId = productId;
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setEdgesForExtendedLayout:UIRectEdgeBottom];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.tableView setShowsVerticalScrollIndicator:NO];
    
    // Register cell classes
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:reuseCellIdentifier];
    
    self.selectIndex = 0;
    self.sectionCount = 3;
    self.currentImagePage = 0;
    self.productDescriptionCellHeight = 200.f;
    
    self.productDataDict = [NSMutableDictionary new];
    self.commentArray = [NSMutableArray new];
    self.pinTuanDataDict = [NSMutableDictionary new];
    self.suyuanDataDict = [NSMutableDictionary new];
    self.productImageArray = [NSMutableArray new];
    
    [self initView];
    
    [self getProductDetailDataById:self.productId];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setTitle:@"商品详情"];
    [self.navigationController setNavigationBarHidden:NO];
    
    [self startCarouselAutoChange];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.productSegmentedControl removeFromSuperview];
    [self setTitle:@"商品详情"];
    
    [self stopCarouselAutoChange];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return 0;
    } else if (section == 2 && [self.commentArray count] != 0) {
        return [self.commentArray count];
    } else if (section == 2 || (section == 3 && [self.commentArray count] != 0)) {
        return 1;
    } else if ([self.suyuanDataDict count] != 0) {
        return 1;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return mProductInfoCellHeight;
    } else if (indexPath.section == 1) {
        return 0.f;
    } else if (indexPath.section == 2 && [self.commentArray count] != 0) {
        return UITableViewAutomaticDimension;
    } else if (indexPath.section == 2 || (indexPath.section == 3 && [self.commentArray count] != 0)) {
        return self.productDescriptionCellHeight;
    } else if ([self.suyuanDataDict count] != 0) {
        return UITableViewAutomaticDimension;
    }
    return 0.f;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return mProductInfoCellHeight;
    } else if (indexPath.section == 1) {
        return 0.f;
    } else if (indexPath.section == 2 && [self.commentArray count] != 0) {
        return mCommentInfoCellHeight;
    } else if (indexPath.section == 2 || (indexPath.section == 3 && [self.commentArray count] != 0)) {
        return self.productDescriptionCellHeight;
    } else if ([self.suyuanDataDict count] != 0) {
        return 500;
    }
    return 0.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return mProductInfoSectionHeaderHeight;
    } else if (section == 1) {
        return mSpecificationInfoSectionHeaderHeight;
    } else if (section == 2 && [self.commentArray count] != 0) {
        return mCommentInfoSectionHeaderHeight;
    } else if (section == 2 || (section == 3 && [self.commentArray count] != 0)) {
        return mProductDescriptionSectionHeaderHeight;
    } else if ([self.suyuanDataDict count] != 0) {
        return mSuyuanInfoSectionHeaderHeight;
    }
    return 0.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return self.productInfoSectionHeaderView;
    } else if (section == 1) {
        return self.specificationInfoSectionHeaderView;
    } else if (section == 2 && [self.commentArray count] != 0) {
        return self.commentSectionHeaderView;
    } else if (section == 2 || (section == 3 && [self.commentArray count] != 0)) {
        return self.productDecriptionSectionHeaderView;
    } else if ([self.suyuanDataDict count] != 0) {
        return self.suyuanInfoSectionHeaderView;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseCellIdentifier forIndexPath:indexPath];
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if (indexPath.section == 0) {
        UIView *productInfoView = [UIView new];
        [cell.contentView addSubview:productInfoView];
        [productInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(cell.contentView);
            make.center.mas_equalTo(cell.contentView);
        }];
        UIView *priceInfoView = [UIView new];
        [productInfoView addSubview:priceInfoView];
        [priceInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(productInfoView);
            make.height.mas_equalTo(80);
            make.centerX.mas_equalTo(productInfoView);
            make.top.mas_equalTo(productInfoView).mas_offset(5);
        }];
        NSInteger htype = [self.productDataDict[@"htype"] integerValue];
        if (htype == 0) {
            // 普通商品
            UILabel *priceLabel = [UILabel new];
            [priceLabel setTextColor:[UIColor redColor]];
            [priceLabel setFont:[UIFont systemFontOfSize:[UIFont systemFontSize] + 15 weight:UIFontWeightSemibold]];
            [priceLabel setText:[NSString stringWithFormat:@"￥%@", self.productDataDict[@"price"]]];
            [priceInfoView addSubview:priceLabel];
            [priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(priceInfoView).mas_offset(20);
                make.centerY.mas_equalTo(priceInfoView);
            }];
            UILabel *recommendLabel = [UILabel new];
            [recommendLabel setTextColor:[UIColor redColor]];
            [recommendLabel.layer setBorderWidth:0.5];
            [recommendLabel.layer setBorderColor:[[UIColor redColor] CGColor]];
            [recommendLabel setTextAlignment:NSTextAlignmentCenter];
            [recommendLabel setFont:[UIFont systemFontOfSize:[UIFont systemFontSize] - 1.f]];
            [recommendLabel setText:@"推荐"];
            [priceInfoView addSubview:recommendLabel];
            [recommendLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(40, 22));
                make.right.mas_equalTo(priceInfoView).mas_offset(-20);
                make.centerY.mas_equalTo(priceInfoView);
            }];
        } else if (htype == 1) {
            // 特价商品
            [priceInfoView setBackgroundColor:[UIColor colorWithRed:231.0/255 green:82.0/255 blue:41.0/255 alpha:1.0]];
            UILabel *specialPriceLabel = [UILabel new];
            [specialPriceLabel setTextColor:[UIColor whiteColor]];
            [specialPriceLabel setText:@"限时特价"];
            [priceInfoView addSubview:specialPriceLabel];
            [specialPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(priceInfoView).mas_offset(20);
                make.top.mas_equalTo(priceInfoView).mas_offset(10);
            }];
            
            UILabel *nowPriceLabel = [UILabel new];
            NSString *priceString = [NSString stringWithFormat:@"￥%@", self.productDataDict[@"qg_price"]];
            NSString *danweiString = [NSString stringWithFormat:@"/%@", self.productDataDict[@"danwei"]];
            NSMutableAttributedString *priceAttributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", priceString, danweiString]];
            [priceAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, [priceString length] + [danweiString length])];
            [priceAttributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:[UIFont systemFontSize] + 15 weight:UIFontWeightSemibold] range:NSMakeRange(1, [priceString length] - 1)];
            [priceAttributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:[UIFont systemFontSize] - 1] range:NSMakeRange([priceString length], [danweiString length])];
            [nowPriceLabel setAttributedText:priceAttributedString];
            [priceInfoView addSubview:nowPriceLabel];
            [nowPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(specialPriceLabel);
                make.bottom.mas_equalTo(priceInfoView.mas_bottom).mas_offset(-10);
                make.right.mas_lessThanOrEqualTo(priceInfoView);
            }];
            UILabel *beforePriceLabel = [UILabel new];
            NSAttributedString *attributeString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"￥%@/%@", self.productDataDict[@"qg_scprice"], self.productDataDict[@"danwei"]] attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSStrikethroughStyleAttributeName:@(NSUnderlineStyleSingle | NSUnderlinePatternSolid), NSStrokeColorAttributeName:[UIColor grayColor], NSFontAttributeName:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]}];
            [beforePriceLabel setAttributedText:attributeString];
            [priceInfoView addSubview:beforePriceLabel];
            [beforePriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(nowPriceLabel.mas_right).mas_offset(10);
                make.bottom.mas_equalTo(nowPriceLabel.mas_bottom).mas_offset(-5);
            }];
            UILabel *qiangGouTimeLabel = [UILabel new];
            [qiangGouTimeLabel setTextColor:[UIColor whiteColor]];
            [qiangGouTimeLabel setFont:[UIFont systemFontOfSize:[UIFont systemFontSize] - 1]];
            [qiangGouTimeLabel setText:@"距离结束 99:23:15"];
            [priceInfoView addSubview:qiangGouTimeLabel];
            [qiangGouTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(priceInfoView).mas_offset(-20);
                make.centerY.mas_equalTo(specialPriceLabel);
            }];
            UIImageView *qiangGouTimeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"qianggou_time_white_icon"]];
            [priceInfoView addSubview:qiangGouTimeImageView];
            [qiangGouTimeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(17, 17));
                make.right.mas_equalTo(qiangGouTimeLabel.mas_left).mas_offset(-2);
                make.centerY.mas_equalTo(qiangGouTimeLabel).mas_offset(1);
            }];
            UIView *qiangGouProgressView = [UIView new];
            [qiangGouProgressView.layer setCornerRadius:6];
            [qiangGouProgressView setBackgroundColor:[UIColor colorWithRed:233/255.0 green:233/255.0 blue:233/255.0 alpha:1.0]];
            [priceInfoView addSubview:qiangGouProgressView];
            [qiangGouProgressView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(120);
                make.height.mas_equalTo(16);
                make.centerY.mas_equalTo(nowPriceLabel);
                make.right.mas_equalTo(qiangGouTimeLabel);
            }];
            NSInteger kuNum = [self.productDataDict[@"qg_ku_num"] integerValue];
            NSInteger buyNum = [self.productDataDict[@"qg_buy_num"] integerValue];
            UIView *qiangGouRemindProgressView = [UIView new];
            [qiangGouRemindProgressView.layer setCornerRadius:6];
            [qiangGouRemindProgressView setBackgroundColor:[UIColor orangeColor]];
            [qiangGouProgressView addSubview:qiangGouRemindProgressView];
            [qiangGouRemindProgressView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(qiangGouProgressView);
                make.height.mas_equalTo(qiangGouProgressView);
                make.top.mas_equalTo(qiangGouProgressView);
                make.width.mas_equalTo(120 * 1.0 * kuNum / (kuNum + buyNum));
            }];
            UILabel *qiangGouRemindLabel = [UILabel new];
            [qiangGouRemindLabel setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];
            [qiangGouRemindLabel setText:[NSString stringWithFormat:@"剩余%ld份", kuNum]];
            [qiangGouProgressView addSubview:qiangGouRemindLabel];
            [qiangGouRemindLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.mas_equalTo(qiangGouProgressView);
            }];
        } else if (htype == 2) {
            // 拼团商品
            UIImageView *pinTuanBackgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pingtuan_background"]];
            [priceInfoView addSubview:pinTuanBackgroundImageView];
            [pinTuanBackgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(priceInfoView);
                make.center.mas_equalTo(priceInfoView);
            }];
            UILabel *priceLabel = [UILabel new];
            NSString *nowPriceString = [NSString stringWithFormat:@"￥%@", self.productDataDict[@"qg_price"]];
            NSString *beforePriceString = [NSString stringWithFormat:@"￥%@", self.productDataDict[@"qg_scprice"]];
            NSMutableAttributedString *priceAttributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", nowPriceString, beforePriceString]];
            [priceAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, [nowPriceString length] + [beforePriceString length] + 1)];
            [priceAttributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:[UIFont systemFontSize] + 15 weight:UIFontWeightSemibold] range:NSMakeRange(1, [nowPriceString length] - 1)];
            [priceAttributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:[UIFont systemFontSize] - 1] range:NSMakeRange([nowPriceString length] + 1, [beforePriceString length])];
            [priceAttributedString addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlineStyleSingle | NSUnderlinePatternSolid) range:NSMakeRange([nowPriceString length] + 1, [beforePriceString length])];
            [priceAttributedString addAttribute:NSStrokeColorAttributeName value:[UIColor whiteColor] range:NSMakeRange([nowPriceString length] + 1, [beforePriceString length])];
            [priceLabel setAttributedText:priceAttributedString];
            [priceInfoView addSubview:priceLabel];
            [priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(priceInfoView).mas_offset(20);
                make.top.mas_equalTo(priceInfoView).mas_offset(10);
            }];
            UILabel *pinTuanLabel = [UILabel new];
            [pinTuanLabel setTextColor:[UIColor whiteColor]];
            [pinTuanLabel setFont:[UIFont systemFontOfSize:[UIFont systemFontSize] - 1]];
            [pinTuanLabel setText:@"限时拼团"];
            [priceInfoView addSubview:pinTuanLabel];
            [pinTuanLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(priceLabel);
                make.bottom.mas_equalTo(priceInfoView).mas_offset(-10);
            }];
            
            NSDate *nowDate = [NSDate new];
            NSInteger nowTimeStamp = (NSInteger)[nowDate timeIntervalSince1970];
            NSInteger startTimeStamp = [self.productDataDict[@"starttime"] integerValue];
            NSInteger endTimeStamp = [self.productDataDict[@"endtime"] integerValue];
            if (nowTimeStamp < startTimeStamp) {
                UILabel *tipLabel = [UILabel new];
                [tipLabel setText:@"暂未开始"];
                [priceInfoView addSubview:tipLabel];
                [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.right.mas_equalTo(priceInfoView).mas_offset(-10);
                    make.centerY.mas_equalTo(priceInfoView);
                }];
            } else if (nowTimeStamp > endTimeStamp) {
                UILabel *tipLabel = [UILabel new];
                [tipLabel setText:@"已结束"];
                [priceInfoView addSubview:tipLabel];
                [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.right.mas_equalTo(priceInfoView).mas_offset(-20);
                    make.centerY.mas_equalTo(priceInfoView);
                }];
            } else {
                UILabel *tipLabel = [UILabel new];
                [tipLabel setText:@"距离结束"];
                [priceInfoView addSubview:tipLabel];
                [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.right.mas_equalTo(priceInfoView).mas_offset(-5);
                    make.top.mas_equalTo(priceInfoView).mas_equalTo(15);
                }];
                UIImageView *nzImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pintuan_nz"]];
                [priceInfoView addSubview:nzImageView];
                [nzImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.size.mas_equalTo(CGSizeMake(20, 20));
                    make.right.mas_equalTo(tipLabel.mas_left).mas_offset(-2);
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
                [priceInfoView addSubview:timeLabel];
                [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.bottom.mas_equalTo(priceInfoView).mas_offset(-10);
                    make.right.mas_equalTo(priceInfoView).mas_offset(-10);
                }];
            }
        }
        UIView *titleInfoView = [UIView new];
        [productInfoView addSubview:titleInfoView];
        [titleInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(productInfoView);
            make.height.mas_equalTo(60);
            make.centerX.mas_equalTo(productInfoView);
            make.top.mas_equalTo(priceInfoView.mas_bottom).mas_offset(5);
        }];
        UILabel *titleLabel = [UILabel new];
        [titleLabel setFont:[UIFont systemFontOfSize:[UIFont systemFontSize] + 2 weight:UIFontWeightSemibold]];
        [titleLabel setNumberOfLines:2];
        [titleLabel setText:[NSString stringWithFormat:@"%@", self.productDataDict[@"title"]]];
        [titleInfoView addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(titleInfoView).mas_offset(20);
            make.right.mas_lessThanOrEqualTo(titleInfoView).mas_offset(-20);
            make.top.mas_equalTo(titleInfoView).mas_offset(5);
        }];
        if (![self.productDataDict[@"supplier_name"] isEqual:[NSNull null]] && self.productDataDict[@"supplier_name"] != nil) {
            UILabel *supplierNameLabel = [UILabel new];
            [supplierNameLabel setTextColor:[UIColor grayColor]];
            [supplierNameLabel setFont:[UIFont systemFontOfSize:[UIFont systemFontSize] - 1.f]];
            [supplierNameLabel setText:[NSString stringWithFormat:@"%@", self.productDataDict[@"supplier_name"]]];
            [titleInfoView addSubview:supplierNameLabel];
            [supplierNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(titleLabel);
                make.right.mas_lessThanOrEqualTo(titleLabel);
                make.bottom.mas_equalTo(titleInfoView).mas_offset(-10);
            }];
        }
        
    } else if (indexPath.section == 1) {
        
    } else if (indexPath.section == 2 && [self.commentArray count] != 0) {
        NSDictionary *commentDataDict = self.commentArray[0];
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
    } else if (indexPath.section == 2 || (indexPath.section == 3 && [self.commentArray count] != 0)) {
        [cell.contentView addSubview:self.productDecriptionCellView];
        [self.productDecriptionCellView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(cell.contentView);
            make.left.mas_equalTo(cell.contentView);
            make.width.mas_equalTo(cell.contentView);
            make.bottom.mas_equalTo(cell.contentView);
        }];
    } else if ([self.suyuanDataDict count] != 0) {
        if (indexPath.row != 0) {
            return cell;
        }
        UIView *baseInfoView = [UIView new];
        [cell.contentView addSubview:baseInfoView];
        [baseInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(cell.contentView).mas_offset(-40);
            make.centerX.mas_equalTo(cell.contentView);
            make.top.mas_equalTo(cell.contentView);
        }];
        
        UILabel *baseInfoTitleLabel = [UILabel new];
        [baseInfoTitleLabel setText:@"基本信息"];
        [baseInfoView addSubview:baseInfoTitleLabel];
        [baseInfoTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(baseInfoView);
            make.top.mas_equalTo(baseInfoView);
            make.height.mas_equalTo(30);
        }];
        UILabel *baseInfoContentLabel = [UILabel new];
        [baseInfoContentLabel setNumberOfLines:0];
        [baseInfoContentLabel setFont:[UIFont systemFontOfSize:[UIFont systemFontSize] - 1]];
        [baseInfoContentLabel setText:[NSString stringWithFormat:@"批发市场名称：%@\n销售市场：朝阳农贸市场\n批发商姓名：%@\n批发商卡号：%@\n采购方姓名：%@\n采购方卡号：%@\n商户名称：%@\n商户类型：零售摊位商\n批发交易时间：%@\n批次号：%@\n产地：%@", self.suyuanDataDict[@"market"], self.suyuanDataDict[@"sellerName"], self.suyuanDataDict[@"sellerCard"], self.suyuanDataDict[@"buyerName"], self.suyuanDataDict[@"buyerCard"], self.suyuanDataDict[@"supplier_name"], self.suyuanDataDict[@"tradeTime"], self.suyuanDataDict[@"batchId"], self.suyuanDataDict[@"origin"]]];
        [baseInfoView addSubview:baseInfoContentLabel];
        [baseInfoContentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(baseInfoView).mas_offset(5);
            make.top.mas_equalTo(baseInfoTitleLabel.mas_bottom).mas_offset(5);
            make.bottom.mas_equalTo(baseInfoView);
            make.right.mas_equalTo(baseInfoView);
        }];
        
        UIView *blockchainView = [UIView new];
        [cell.contentView addSubview:blockchainView];
        
        UILabel *blockchainTitleLabel = [UILabel new];
        [blockchainTitleLabel setText:@"区块链信息"];
        [blockchainView addSubview:blockchainTitleLabel];
        [blockchainTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(blockchainView);
            make.top.mas_equalTo(blockchainView);
        }];
        UILabel *blockchainContentLabel = [UILabel new];
        [blockchainContentLabel setNumberOfLines:0];
        [blockchainContentLabel setFont:[UIFont systemFontOfSize:[UIFont systemFontSize] - 1]];
        [blockchainContentLabel setText:[NSString stringWithFormat:@"区块高度：%@\n区块哈希值：%@", self.suyuanDataDict[@"bcNumber"], self.suyuanDataDict[@"bcHash"]]];
        [blockchainView addSubview:blockchainContentLabel];
        [blockchainContentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(blockchainView).mas_offset(5);
            make.top.mas_equalTo(blockchainTitleLabel.mas_bottom).mas_offset(5);
            make.bottom.mas_equalTo(blockchainView);
            make.right.mas_equalTo(blockchainView);
        }];
        [blockchainView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(cell.contentView).mas_offset(-40);
            make.centerX.mas_equalTo(cell.contentView);
            make.top.mas_equalTo(baseInfoView.mas_bottom).mas_equalTo(10);
            make.bottom.mas_equalTo(cell.contentView).mas_offset(-10);
        }];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section != self.sectionCount - 1) {
        return mSectionFooterHeight;
    } else {
        return 0.f;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section != self.sectionCount - 1) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, mSectionFooterHeight)];
        [view setBackgroundColor:[UIColor colorWithRed:220.0/255 green:220.0/255 blue:220.0/255 alpha:1.0]];
        return view;
    } else {
        return nil;
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.carouselScrollView) {
        NSInteger currentPage = self.currentImagePage;
        if (scrollView.contentOffset.x > scrollView.frame.size.width) {
            // 向右滑
            currentPage = (currentPage + 1);
            if ([self.productImageArray count] != 0) {
                currentPage %= [self.productImageArray count];
            } else {
                currentPage %= 3;
            }
        } else if (scrollView.contentOffset.x == 0){
            // 向左滑
            currentPage = currentPage - 1;
            if ([self.productImageArray count] != 0) {
                currentPage = (currentPage + [self.productImageArray count]) % [self.productImageArray count];
            } else {
                currentPage = (currentPage + 3) % [self.productImageArray count];
            }
        } else {
            // 未滑动
            return;
        }
        self.currentImagePage = currentPage;
        [self updateCarouselUi];
        scrollView.contentOffset = CGPointMake(scrollView.bounds.size.width, 0);
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    static BOOL isSetContentInset = NO;
    if (scrollView == self.tableView) {
        // 更新底部吸附footerview
        if (self.tableView.contentOffset.y >= self.tableView.contentSize.height + mTableViewFooterHeight - [UIScreen mainScreen].bounds.size.height - mTableViewBaseContentOffsetY) {
            if (!isSetContentInset) {
                [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, mTableViewFooterHeight, 0)];
                isSetContentInset = YES;
            }
            [self.tableViewFooterView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.tableView.mas_top).mas_offset(self.tableView.contentSize.height);
            }];
        } else {
            if (isSetContentInset) {
                [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
                isSetContentInset = NO;
            }
            [self.tableViewFooterView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.tableView.mas_top).mas_offset(self.tableView.contentOffset.y + [UIScreen mainScreen].bounds.size.height + mTableViewBaseContentOffsetY - mTableViewFooterHeight);
            }];
        }
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
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    if (scrollView == self.tableView) {
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
            [self getProductDetailDataById:self.productId];
        }
        NSLog(@"scrollView.contentOffset.y = %f", scrollView.contentOffset.y);
    }
}

#pragma mark - WKUIDelegate
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self.contentWebView evaluateJavaScript:@"document.documentElement.scrollHeight" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        CGFloat height = [result doubleValue];
        self.productDescriptionCellHeight = height;
        [self.contentWebView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.productDecriptionCellView).mas_offset(5);
            make.left.mas_equalTo(self.productDecriptionCellView);
            make.width.mas_equalTo(self.productDecriptionCellView);
            make.height.mas_equalTo(height);
        }];
        if ([self.commentArray count] != 0) {
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationNone];
        } else {
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
        }
    }];
}

#pragma mark - Event
- (void)productSegmentedControlChangeAction:(UISegmentedControl *)segmentedControl {
    NSInteger sectionIndex = segmentedControl.selectedSegmentIndex;
    if (sectionIndex > 0) {
        sectionIndex += 1;
    }
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:sectionIndex] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)gotoAllCommentAction {
    HSCommentTableViewController *controller = [[HSCommentTableViewController alloc] initWithProductId:self.productId];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)selectSpecificationAction {
    UIView *contentView = [UIView new];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo([UIScreen mainScreen].bounds.size.width - 40);
    }];
    if ([self.productDataDict[@"hid"] isEqual:[NSNull null]]) {
        [self.productSpecificationView getProductSpecificationWithId:[self.productDataDict[@"id"] integerValue] hid:0];
    } else {
        [self.productSpecificationView getProductSpecificationWithId:[self.productDataDict[@"id"] integerValue] hid:[self.productDataDict[@"hid"] integerValue]];
    }
    [contentView addSubview:self.productSpecificationView];
    [self.productSpecificationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(contentView).mas_offset(10);
        make.width.mas_equalTo(contentView);
        make.centerX.mas_equalTo(contentView);
    }];
    
    UIView *actionView = [UIView new];
    [contentView addSubview:actionView];
    [actionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(contentView);
        make.centerX.mas_equalTo(contentView);
        make.top.mas_equalTo(self.productSpecificationView.mas_bottom).mas_offset(10);
        make.height.mas_equalTo(40);
        
        make.bottom.mas_equalTo(contentView).mas_offset(-10);
    }];
    
    UILabel *addToCartLabel = [UILabel new];
    [addToCartLabel setTextColor:[UIColor whiteColor]];
    [addToCartLabel setBackgroundColor:[UIColor orangeColor]];
    [addToCartLabel setText:@"加入购物车"];
    [addToCartLabel setTextAlignment:NSTextAlignmentCenter];
    [actionView addSubview:addToCartLabel];
    [addToCartLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(actionView);
        make.right.mas_equalTo(actionView.mas_centerX);
        make.height.mas_equalTo(actionView);
        make.centerY.mas_equalTo(actionView);
    }];
    
    UILabel *buyLabel = [UILabel new];
    [buyLabel setTextColor:[UIColor whiteColor]];
    [buyLabel setBackgroundColor:[UIColor redColor]];
    [buyLabel setText:@"立即购买"];
    [buyLabel setTextAlignment:NSTextAlignmentCenter];
    [actionView addSubview:buyLabel];
    [buyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(addToCartLabel.mas_right);
        make.right.mas_equalTo(actionView);
        make.height.mas_equalTo(actionView);
        make.centerY.mas_equalTo(actionView);
    }];

    HSAlertView *alertView = [[HSAlertView alloc] initWithCommonView:contentView];
    [alertView show];
}

#pragma mark - Private
- (void)initView {
    [self initRefreshView];
    [self initProductSegmentedControl];
    [self initProductInfoSectionHeaderView];
    [self initSpecificationSectionHeaerView];
    [self initCommentSectionHeaderView];
    [self initProductDecriptionSectionHeaderView];
    [self initProductDecriptionCellView];
    [self initSuyuanInfoSectionHeaderView];
    [self initTableFooterView];
    
    self.productSpecificationView = [[HSProductSpecificationView alloc] init];
}

- (void)initRefreshView {
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
}

- (void)initProductSegmentedControl {
    NSMutableArray *titleArray = [NSMutableArray new];
    self.sectionCount = 3;
    [titleArray addObject:@"商品"];
    if ([self.commentArray count] != 0) {
        [titleArray addObject:@"评价"];
        self.sectionCount += 1;
    }
    [titleArray addObject:@"详情"];
    if ([self.suyuanDataDict count] != 0) {
        [titleArray addObject:@"溯源"];
        self.sectionCount += 1;
    }
    self.productSegmentedControl = [[UISegmentedControl alloc] initWithItems:titleArray];
    [self.productSegmentedControl setTintColor:[UIColor clearColor]];
    [self.productSegmentedControl setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor orangeColor]} forState:UIControlStateSelected];
    [self.productSegmentedControl setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]} forState:UIControlStateNormal];
    [self.productSegmentedControl setSelectedSegmentIndex:self.selectIndex];
    [self.productSegmentedControl addTarget:self action:@selector(productSegmentedControlChangeAction:) forControlEvents:UIControlEventValueChanged];
    
    [self.navigationItem setTitleView:self.productSegmentedControl];
}

- (void)initProductInfoSectionHeaderView {
    self.productInfoSectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, mProductInfoSectionHeaderHeight)];
    self.carouselView = [UIView new];
    [self.carouselView setBackgroundColor:[UIColor whiteColor]];
    [self.productInfoSectionHeaderView addSubview:self.carouselView];
    [self.carouselView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(self.productInfoSectionHeaderView);
        make.center.mas_equalTo(self.productInfoSectionHeaderView);
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
    
    self.carouselRightImageView = [UIImageView new];
    [self.carouselScrollView addSubview:self.carouselRightImageView];
    [self.carouselRightImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(self.carouselScrollView);
        make.left.mas_equalTo(self.carouselCurrentImageView.mas_right);
        make.top.mas_equalTo(self.carouselScrollView);
    }];
    
    self.imagePageInfoLabel = [UILabel new];
    [self.imagePageInfoLabel setTextAlignment:NSTextAlignmentCenter];
    [self.imagePageInfoLabel setFont:[UIFont systemFontOfSize:[UIFont systemFontSize] - 1.0]];
    [self.imagePageInfoLabel.layer setCornerRadius:10];
    [self.imagePageInfoLabel.layer setBackgroundColor:[[UIColor colorWithRed:179.0/255 green:179.0/255 blue:179.0/255 alpha:0.8] CGColor]];
    [self.imagePageInfoLabel setText:@"0/0"];
    [self.carouselView addSubview:self.imagePageInfoLabel];
    [self.imagePageInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.carouselView).mas_offset(-10);
        make.bottom.mas_equalTo(self.carouselView).mas_offset(-10);
        make.size.mas_equalTo(CGSizeMake(32, 22));
    }];
}

- (void)initSpecificationSectionHeaerView {
    self.specificationInfoSectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, mSpecificationInfoSectionHeaderHeight)];
    [self.specificationInfoSectionHeaderView setBackgroundColor:[UIColor whiteColor]];
    UILabel *specificationTitleLabel = [UILabel new];
    [specificationTitleLabel setText:@"规格"];
    [self.specificationInfoSectionHeaderView addSubview:specificationTitleLabel];
    [specificationTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.specificationInfoSectionHeaderView).mas_offset(20);
        make.centerY.mas_equalTo(self.specificationInfoSectionHeaderView);
    }];
    UIImageView *selectSpecificationImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"goto_detail"]];
    [self.specificationInfoSectionHeaderView addSubview:selectSpecificationImageView];
    [selectSpecificationImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.specificationInfoSectionHeaderView);
        make.right.mas_equalTo(self.specificationInfoSectionHeaderView).offset(-20);
        make.size.mas_equalTo(CGSizeMake(15, 15));
    }];
    self.specificationLabel = [UILabel new];
    [self.specificationLabel setTextColor:[UIColor grayColor]];
    [self.specificationLabel setFont:[UIFont systemFontOfSize:[UIFont systemFontSize] - 1]];
    if (self.productDataDict[@"isguige"] != nil && [self.productDataDict[@"isguige"] integerValue] == 2) {
        [self.specificationLabel setText:@"请选择"];
    } else {
        [self.specificationLabel setText:@"默认规格"];
    }
    [self.specificationInfoSectionHeaderView addSubview:self.specificationLabel];
    [self.specificationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.specificationInfoSectionHeaderView);
        make.right.mas_equalTo(selectSpecificationImageView.mas_left).offset(-5);
    }];
    // 添加点击事件
    UITapGestureRecognizer *selectSpecificationTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectSpecificationAction)];
    [selectSpecificationTapGesture setNumberOfTapsRequired:1];
    [self.specificationInfoSectionHeaderView setUserInteractionEnabled:YES];
    [self.specificationInfoSectionHeaderView addGestureRecognizer:selectSpecificationTapGesture];
}

- (void)initCommentSectionHeaderView {
    self.commentSectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, mCommentInfoSectionHeaderHeight)];
    [self.commentSectionHeaderView setBackgroundColor:[UIColor whiteColor]];
    self.commentTitleLabel = [UILabel new];
    [self.commentTitleLabel setText:@"用户评价"];
    [self.commentSectionHeaderView addSubview:self.commentTitleLabel];
    [self.commentTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.commentSectionHeaderView).mas_offset(20);
        make.center.mas_equalTo(self.commentSectionHeaderView);
    }];
    UIImageView *checkAllCommentImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"goto_detail"]];
    [self.commentSectionHeaderView addSubview:checkAllCommentImageView];
    [checkAllCommentImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.commentSectionHeaderView);
        make.right.mas_equalTo(self.commentSectionHeaderView).offset(-20);
        make.size.mas_equalTo(CGSizeMake(15, 15));
    }];
    UILabel *checkAllCommentTitleLabel = [UILabel new];
    [checkAllCommentTitleLabel setText:@"查看全部评价"];
    [checkAllCommentTitleLabel setTextColor:[UIColor grayColor]];
    [checkAllCommentTitleLabel setFont:[UIFont systemFontOfSize:[UIFont systemFontSize] - 1]];
    [self.commentSectionHeaderView addSubview:checkAllCommentTitleLabel];
    [checkAllCommentTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.commentSectionHeaderView);
        make.right.mas_equalTo(checkAllCommentImageView.mas_left).offset(-5);
    }];
    // 添加点击事件
    UITapGestureRecognizer *gotoAllCommentTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoAllCommentAction)];
    [gotoAllCommentTapGesture setNumberOfTapsRequired:1];
    [self.commentSectionHeaderView setUserInteractionEnabled:YES];
    [self.commentSectionHeaderView addGestureRecognizer:gotoAllCommentTapGesture];
}

- (void)initProductDecriptionSectionHeaderView {
    self.productDecriptionSectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, mProductInfoSectionHeaderHeight)];
    [self.productDecriptionSectionHeaderView setBackgroundColor:[UIColor whiteColor]];
    UILabel *productDecriptionTitleLabel = [UILabel new];
    [productDecriptionTitleLabel setText:@"商品详情"];
    [self.productDecriptionSectionHeaderView addSubview:productDecriptionTitleLabel];
    [productDecriptionTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.productDecriptionSectionHeaderView);
        make.left.mas_equalTo(self.productDecriptionSectionHeaderView).mas_offset(20);
    }];
}

- (void)initProductDecriptionCellView {
    self.productDecriptionCellView = [[UIView alloc] init];
    self.contentWebView = [WKWebView new];
    [self.contentWebView setNavigationDelegate:self];
    [self.productDecriptionCellView addSubview:self.contentWebView];
    [self.contentWebView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.productDecriptionCellView).mas_offset(5);
        make.left.mas_equalTo(self.productDecriptionCellView);
        make.width.mas_equalTo(self.tableView.frame.size.width);
        make.height.mas_equalTo(200);
    }];
}

- (void)initSuyuanInfoSectionHeaderView {
    self.suyuanInfoSectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, mSuyuanInfoSectionHeaderHeight)];
    [self.suyuanInfoSectionHeaderView setBackgroundColor:[UIColor whiteColor]];
    UILabel *suyuanInfoTitleLabel = [UILabel new];
    [suyuanInfoTitleLabel setText:@"溯源信息"];
    [self.suyuanInfoSectionHeaderView addSubview:suyuanInfoTitleLabel];
    [suyuanInfoTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.suyuanInfoSectionHeaderView);
        make.left.mas_equalTo(self.suyuanInfoSectionHeaderView).mas_offset(20);
    }];
}

- (void)initTableFooterView {
    self.tableViewFooterView = [UIView new];
    [self.tableViewFooterView.layer setZPosition:MAXFLOAT];
    [self.tableViewFooterView setBackgroundColor:[UIColor whiteColor]];
    [self.tableView addSubview:self.tableViewFooterView];
    [self.tableViewFooterView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.tableView);
        make.centerX.mas_equalTo(self.tableView);
        make.height.mas_equalTo(mTableViewFooterHeight);
        make.top.mas_equalTo(self.tableView.contentOffset.y + [UIScreen mainScreen].bounds.size.height + mTableViewBaseContentOffsetY - mTableViewFooterHeight);
    }];
    UILabel *buyLabel = [UILabel new];
    [buyLabel setBackgroundColor:[UIColor colorWithRed:230.0/255 green:82.0/255 blue:41.0/255 alpha:1.0]];
    [buyLabel setTextColor:[UIColor whiteColor]];
    [buyLabel setText:@"立即购买"];
    [buyLabel setTextAlignment:NSTextAlignmentCenter];
    [self.tableViewFooterView addSubview:buyLabel];
    [buyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(90, 40));
        make.right.mas_equalTo(self.tableViewFooterView).mas_offset(-20);
        make.top.mas_equalTo(self.tableViewFooterView).mas_offset(10);
    }];
    UILabel *addToCartLabel = [UILabel new];
    [addToCartLabel setBackgroundColor:[UIColor colorWithRed:245.0/255 green:163.0/255 blue:25.0/255 alpha:1.0]];
    [addToCartLabel setTextColor:[UIColor whiteColor]];
    [addToCartLabel setText:@"加入购物车"];
    [addToCartLabel setTextAlignment:NSTextAlignmentCenter];
    [self.tableViewFooterView addSubview:addToCartLabel];
    [addToCartLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(100, 40));
        make.right.mas_equalTo(buyLabel.mas_left).mas_offset(-10);
        make.centerY.mas_equalTo(buyLabel);
    }];
    CGFloat distance = ([UIScreen mainScreen].bounds.size.width - 220.0 - 80) / 2;
    
    UIView *supplierView = [UIView new];
    [self.tableViewFooterView addSubview:supplierView];
    [supplierView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(buyLabel);
        make.centerX.mas_equalTo(self.tableViewFooterView.mas_left).mas_offset(40);
    }];
    UIImageView *supplierImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"supplier_icon"]];
    [supplierView addSubview:supplierImageView];
    [supplierImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(25, 25));
        make.centerX.mas_equalTo(supplierView);
        make.top.mas_equalTo(supplierView);
    }];
    UILabel *supplierLabel = [UILabel new];
    [supplierLabel setText:@"供应商"];
    [supplierLabel setFont:[UIFont systemFontOfSize:[UIFont systemFontSize] - 1]];
    [supplierView addSubview:supplierLabel];
    [supplierLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(supplierView);
        make.top.mas_equalTo(supplierImageView.mas_bottom);
        make.bottom.mas_equalTo(supplierView);
        make.width.mas_equalTo(supplierView);
    }];
    
    UIView *collectionView = [UIView new];
    [self.tableViewFooterView addSubview:collectionView];
    [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(buyLabel);
        make.centerX.mas_equalTo(supplierView).mas_offset(distance);
    }];
    UIImageView *collectionImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"collection_icon"]];
    [collectionView addSubview:collectionImageView];
    [collectionImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(25, 25));
        make.centerX.mas_equalTo(collectionView);
        make.top.mas_equalTo(collectionView);
    }];
    UILabel *collectionLabel = [UILabel new];
    [collectionLabel setText:@"收藏"];
    [collectionLabel setFont:[UIFont systemFontOfSize:[UIFont systemFontSize] - 1]];
    [collectionView addSubview:collectionLabel];
    [collectionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(collectionView);
        make.top.mas_equalTo(collectionImageView.mas_bottom);
        make.bottom.mas_equalTo(collectionView);
        make.width.mas_equalTo(collectionView);
    }];
    
    UIView *cartView = [UIView new];
    [self.tableViewFooterView addSubview:cartView];
    [cartView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(buyLabel);
        make.centerX.mas_equalTo(collectionView).mas_offset(distance);
    }];
    UIImageView *cartImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cart_icon"]];
    [cartView addSubview:cartImageView];
    [cartImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(25, 25));
        make.centerX.mas_equalTo(cartView);
        make.top.mas_equalTo(cartView);
    }];
    UILabel *cartLabel = [UILabel new];
    [cartLabel setText:@"购物车"];
    [cartLabel setFont:[UIFont systemFontOfSize:[UIFont systemFontSize] - 1]];
    [cartView addSubview:cartLabel];
    [cartLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(cartView);
        make.top.mas_equalTo(cartImageView.mas_bottom);
        make.bottom.mas_equalTo(cartView);
        make.width.mas_equalTo(cartView);
    }];
}

- (void)getProductDetailDataById:(NSInteger)productId {
    HSNetworkManager *manager = [HSNetworkManager shareManager];
    NSString *url = [kGetProductDetailDataUrl stringByAppendingFormat:@"?id=%ld", productId];
    __weak __typeof__(self) weakSelf = self;
    [manager getDataWithUrl:url parameters:@{} success:^(NSDictionary *responseDict) {
        // 获取成功
        if ([responseDict[@"errcode"] isEqual:@(0)]) {
            [weakSelf.productDataDict removeAllObjects];
            [weakSelf.productDataDict addEntriesFromDictionary:responseDict[@"sdata"]];
            [weakSelf.commentArray removeAllObjects];
            if (![responseDict[@"pinlist"] isEqual:[NSNull null]]) {
                [weakSelf.commentArray addObjectsFromArray:responseDict[@"pinlist"]];
            }
            [weakSelf.pinTuanDataDict removeAllObjects];
            if (![responseDict[@"tuandata"] isEqual:[NSNull null]]) {
                [weakSelf.pinTuanDataDict addEntriesFromDictionary:responseDict[@"tuandata"]];
            }
            [weakSelf.suyuanDataDict removeAllObjects];
            NSDictionary *sdataDict = responseDict[@"sdata"];
            if ([sdataDict[@"shuyuandata"] isKindOfClass:[NSDictionary class]]) {
                [weakSelf.suyuanDataDict addEntriesFromDictionary:sdataDict[@"shuyuandata"]];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf initProductSegmentedControl];
                [weakSelf carouselViewLoadData];
                [weakSelf updateSpecification];
                [weakSelf updateComment];
                [weakSelf updateContentWebView];
                [weakSelf.tableView reloadData];
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

- (void)carouselViewLoadData {
    self.productImageArray = [NSMutableArray new];
    if ([self.productDataDict[@"images"] isEqual:[NSNull null]]) {
        return;
    }
    for (NSString *imageUrl in self.productDataDict[@"images"]) {
        [self.productImageArray addObject:@{@"imageUrl":imageUrl}];
    }
    self.currentImagePage = 0;
    [self.carouselScrollView setContentOffset:CGPointMake(self.carouselScrollView.bounds.size.width, 0)];
    [self updateCarouselUi];
    [self startCarouselAutoChange];
}

- (void)updateCarouselUi {
    if ([self.productImageArray count] != 0) {
        [self.imagePageInfoLabel setText:[NSString stringWithFormat:@"%ld/%ld", self.currentImagePage + 1, [self.productImageArray count]]];
        NSInteger currentPage = self.currentImagePage;
        NSInteger leftPage = (currentPage + [self.productImageArray count] - 1) % [self.productImageArray count];
        NSInteger rightPage = (currentPage + 1) % [self.productImageArray count];
        
        NSDictionary *currentProductImageDict = self.productImageArray[currentPage];
        if ([[currentProductImageDict allKeys] containsObject:@"image"]) {
            [self.carouselCurrentImageView setImage:currentProductImageDict[@"image"]];
        } else {
            __weak __typeof__(self) weakSelf = self;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSURL *imageUrl = [NSURL URLWithString:currentProductImageDict[@"imageUrl"]];
                NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
                UIImage *image = [UIImage imageWithData:imageData];
                // 缓存至productImageArray中
                NSMutableDictionary *dataMutableDict = currentProductImageDict.mutableCopy;
                dataMutableDict[@"image"] = image;
                weakSelf.productImageArray[currentPage] = dataMutableDict.copy;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.carouselCurrentImageView setImage:image];
                });
            });
        }
        
        NSDictionary *leftProductImageDict = self.productImageArray[leftPage];
        if ([[leftProductImageDict allKeys] containsObject:@"image"]) {
            [self.carouselLeftImageView setImage:leftProductImageDict[@"image"]];
        } else {
            __weak __typeof__(self) weakSelf = self;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSURL *imageUrl = [NSURL URLWithString:leftProductImageDict[@"imageUrl"]];
                NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
                UIImage *image = [UIImage imageWithData:imageData];
                // 缓存至productImageArray中
                NSMutableDictionary *dataMutableDict = leftProductImageDict.mutableCopy;
                dataMutableDict[@"image"] = image;
                weakSelf.productImageArray[leftPage] = dataMutableDict.copy;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.carouselLeftImageView setImage:image];
                });
            });
        }
        
        NSDictionary *rightProductImageDict = self.productImageArray[rightPage];
        if ([[rightProductImageDict allKeys] containsObject:@"image"]) {
            [self.carouselRightImageView setImage:rightProductImageDict[@"image"]];
        } else {
            __weak __typeof__(self) weakSelf = self;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSURL *imageUrl = [NSURL URLWithString:rightProductImageDict[@"imageUrl"]];
                NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
                UIImage *image = [UIImage imageWithData:imageData];
                // 缓存至productImageArray中
                NSMutableDictionary *dataMutableDict = rightProductImageDict.mutableCopy;
                dataMutableDict[@"image"] = image;
                weakSelf.productImageArray[rightPage] = dataMutableDict.copy;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.carouselRightImageView setImage:image];
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
            if ([weakSelf.productImageArray count] == 0) {
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

- (void)updateSpecification {
    if (self.productDataDict[@"isguige"] != nil && [self.productDataDict[@"isguige"] integerValue] == 2) {
        [self.specificationLabel setText:@"请选择"];
    } else {
        [self.specificationLabel setText:@"默认规格"];
    }
}

- (void)updateComment {
    if (self.productDataDict[@"pinnum"] != nil && [self.productDataDict[@"pinnum"] integerValue] > 0) {
        [self.commentTitleLabel setText:[NSString stringWithFormat:@"用户评价(%@)", self.productDataDict[@"pinnum"]]];
    }
}

- (void)updateContentWebView {
    NSString *contentString = [NSString stringWithFormat:@"<header><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'><style>img{width:100%% !important;height:auto}</style></header>%@", self.productDataDict[@"content"]];
    [self.contentWebView loadHTMLString:contentString baseURL:nil];
}

@end
