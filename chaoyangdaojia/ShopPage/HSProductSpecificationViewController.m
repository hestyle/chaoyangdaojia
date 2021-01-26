//
//  HSProductSpecificationViewController.m
//  chaoyangdaojia
//
//  Created by hestyle on 2021/1/24.
//  Copyright © 2021 hestyle. All rights reserved.
//

#import "HSProductSpecificationViewController.h"
#import "HSNetwork.h"
#import "HSTools.h"
#import "HSCommon.h"
#import <Masonry/Masonry.h>
#import <Toast/Toast.h>

@interface HSProductSpecificationViewController ()

@property (nonatomic) NSInteger productId;
@property (nonatomic) NSInteger hid;

@property (nonatomic) NSInteger buyCount;
@property (nonatomic) NSIndexPath *selectIndexPath;
@property (nonatomic) NSString *selectSpecificationKey;

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic) NSInteger stockCount;
@property (nonatomic, strong) UIImageView *productImageView;
@property (nonatomic, strong) UILabel *productTitleLabel;
@property (nonatomic, strong) UILabel *stockLabel;
@property (nonatomic, strong) UILabel *priceLabel;
@property (nonatomic, strong) UILabel *buyCountLabel;

@property (nonatomic, strong) UIButton *subBuyCountButton;
@property (nonatomic, strong) UIButton *addBuyCountButton;

@property (nonatomic, strong) UIButton *addToCartButton;
@property (nonatomic, strong) UIButton *buyNowButton;

@property (nonatomic, strong) UICollectionView *specificationCollection;

@property (nonatomic, strong) NSMutableDictionary *dataDict;
@property (nonatomic, strong) NSArray *specificationTitleArray;
@property (nonatomic, strong) NSArray<NSArray *> *valArray;
@property (nonatomic, strong) NSMutableDictionary *specificationDict;

@end

static NSString * const reuseCellIdentifier = @"reusableCell";
static NSString * const reuseHeaderIdentifier = @"reusableHeaderView";

@implementation HSProductSpecificationViewController

- (instancetype)init {
    self = [super init];
    
    self.buyCount = 1;
    self.selectIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    self.dataDict = [NSMutableDictionary new];
    self.specificationTitleArray = [NSArray new];
    self.valArray = [NSArray new];
    self.specificationDict = [NSMutableDictionary new];
    
    [self initView];
    
    [self.specificationCollection registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseCellIdentifier];
    [self.specificationCollection registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseHeaderIdentifier];
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [UIView animateWithDuration:0.1 animations:^{
        [self.view setBackgroundColor:[UIColor colorWithWhite:0.3 alpha:0.5f]];
    }];
    // 设置上次选择的规格
    if (self.selectIndexPath.section >= [self.specificationTitleArray count] || self.selectIndexPath.row >= [self.valArray[self.selectIndexPath.section] count]) {
        // 若不存在该规格，则默认选择[0, 0]
        if (self.selectIndexPath.section == 0 && self.selectIndexPath.row == 0) {
            return;
        } else {
            self.selectIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        }
    }
    // 选中该indexpath，并且手动调用该方法
    [self.specificationCollection selectItemAtIndexPath:self.selectIndexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    [self collectionView:self.specificationCollection didSelectItemAtIndexPath:self.selectIndexPath];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIView animateWithDuration:0.05 animations:^{
        [self.view setBackgroundColor:[UIColor clearColor]];
    }];
}

- (void)getProductSpecificationWithId:(NSInteger)productId hid:(NSInteger)hid {
    self.productId = productId;
    self.hid = hid;
    HSNetworkManager *manager = [HSNetworkManager shareManager];
    NSString *url = [kGetProductSpecificationUrl stringByAppendingFormat:@"?id=%ld&hid=%ld", productId, hid];
    __weak __typeof__(self) weakSelf = self;
    [manager getDataWithUrl:url parameters:@{} success:^(NSDictionary *responseDict) {
        // 获取成功
        if ([responseDict[@"errcode"] isEqual:@(0)]) {
            if (![responseDict[@"gdata"] isEqual:[NSNull null]]) {
                [weakSelf.dataDict addEntriesFromDictionary:responseDict[@"gdata"]];
            }
            if (![responseDict[@"list"] isEqual:[NSNull null]]) {
                [weakSelf.specificationDict addEntriesFromDictionary:responseDict[@"list"]];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf updateView];
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

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake([UIScreen mainScreen].bounds.size.width, 25);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseHeaderIdentifier forIndexPath:indexPath];
        for (UIView *view in headerView.subviews) {
            [view removeFromSuperview];
        }
        UILabel *specificationTitleLabel = [UILabel new];
        [specificationTitleLabel setText:[NSString stringWithFormat:@"%@", self.specificationTitleArray[indexPath.section]]];
        [headerView addSubview:specificationTitleLabel];
        [specificationTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(headerView);
            make.left.mas_equalTo(headerView);
        }];
        return headerView;
    } else {
        return nil;
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.specificationTitleArray count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.valArray[section] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseCellIdentifier forIndexPath:indexPath];
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    NSString *specificationKey = self.valArray[indexPath.section][indexPath.row];
    if ([specificationKey isEqualToString:@"no"]) {
        specificationKey = @"默认规格";
    }
    UILabel *specificationTitleLabel = [UILabel new];
    [specificationTitleLabel setTextAlignment:NSTextAlignmentCenter];
    [specificationTitleLabel setText:specificationKey];
    [specificationTitleLabel setFont:[UIFont systemFontOfSize:[UIFont systemFontSize] - 1]];
    [specificationTitleLabel.layer setCornerRadius:8];
    [specificationTitleLabel setBackgroundColor:[UIColor colorWithRed:245.0/255 green:245.0/255 blue:245.0/255 alpha:0.5]];
    [cell.contentView addSubview:specificationTitleLabel];
    [specificationTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(cell.contentView);
        make.center.mas_equalTo(cell.contentView);
    }];
    UIView *selectedBackgroundView = [[UIView alloc] init];
    selectedBackgroundView.backgroundColor = [UIColor orangeColor];
    [cell setSelectedBackgroundView:selectedBackgroundView];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(100, 25);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 10, 10, 10);
};

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 15;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 15;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *specificationKey = self.valArray[indexPath.section][indexPath.row];
    // 注意key要转成小写（查看规格接口返回的数据！！！）
    NSDictionary *dict = self.specificationDict[specificationKey.lowercaseString];
    
    // 记录选择的规格信息
    self.selectIndexPath = indexPath.copy;
    self.selectSpecificationKey = specificationKey.lowercaseString.copy;
    
    [self.productTitleLabel setText:[NSString stringWithFormat:@"%@", dict[@"title"]]];
    self.stockCount = [dict[@"num"] integerValue];
    [self.stockLabel setText:[NSString stringWithFormat:@"库存：%ld", self.stockCount]];
    [self.priceLabel setText:[NSString stringWithFormat:@"￥%@", dict[@"price"]]];
    if (self.stockCount < self.buyCount) {
        self.buyCount = self.stockCount;
    }
    [self.buyCountLabel setText:[NSString stringWithFormat:@"%ld", self.buyCount]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *imageUrl = [NSURL URLWithString:dict[@"image"]];
        NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
        UIImage *image = [UIImage imageWithData:imageData];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.productImageView setImage:image];
        });
    });
}

#pragma mark - Private
- (void)initView {
    [self.view setFrame:[UIScreen mainScreen].bounds];
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    self.contentView = [UIView new];
    [self.contentView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.view);
    }];
    
    self.productImageView = [UIImageView new];
    [self.contentView addSubview:self.productImageView];
    [self.productImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(100, 100));
        make.top.mas_equalTo(self.contentView).mas_offset(20);
        make.left.mas_equalTo(self.contentView).mas_offset(20);
    }];
    self.productTitleLabel = [UILabel new];
    [self.productTitleLabel setFont:[UIFont systemFontOfSize:[UIFont systemFontSize] + 2 weight:UIFontWeightSemibold]];
    [self.contentView addSubview:self.productTitleLabel];
    [self.productTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.productImageView);
        make.left.mas_equalTo(self.productImageView.mas_right).mas_offset(10);
        make.right.mas_lessThanOrEqualTo(self.contentView).mas_offset(-20);
    }];

    self.stockLabel = [UILabel new];
    [self.stockLabel setTextColor:[UIColor grayColor]];
    [self.stockLabel setText:@"库存:0"];
    [self.contentView addSubview:self.stockLabel];
    [self.stockLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.productImageView);
        make.left.mas_equalTo(self.productTitleLabel);
        make.right.mas_lessThanOrEqualTo(self.contentView).mas_offset(-20);
    }];

    self.priceLabel = [UILabel new];
    [self.priceLabel setTextColor:[UIColor redColor]];
    [self.priceLabel setFont:[UIFont systemFontOfSize:[UIFont systemFontSize] + 4 weight:UIFontWeightSemibold]];
    [self.priceLabel setText:@"￥0.00"];
    [self.contentView addSubview:self.priceLabel];
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.productImageView);
        make.left.mas_equalTo(self.productTitleLabel);
        make.right.mas_lessThanOrEqualTo(self.contentView).mas_offset(-20);
    }];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    self.specificationCollection = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    [self.specificationCollection setDelegate:self];
    [self.specificationCollection setDataSource:self];
    [self.specificationCollection setBackgroundColor:[UIColor whiteColor]];
    [self.contentView addSubview:self.specificationCollection];
    [self.specificationCollection mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.productImageView);
        make.width.mas_equalTo(self.contentView).mas_offset(-40);
        make.centerX.mas_equalTo(self.contentView);
        make.top.mas_equalTo(self.productImageView.mas_bottom).mas_offset(10);
        make.height.mas_equalTo(100);
    }];


    UIView *countView = [UIView new];
    [self.contentView addSubview:countView];
    [countView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.contentView).mas_offset(-40);
        make.centerX.mas_equalTo(self.contentView);
        make.top.mas_equalTo(self.specificationCollection.mas_bottom).mas_offset(10);
        make.height.mas_equalTo(50);
    }];
    
    UILabel *countTitleLabel = [UILabel new];
    [countTitleLabel setText:@"数量"];
    [countView addSubview:countTitleLabel];
    [countTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(countView);
        make.centerY.mas_equalTo(countView);
    }];
    
    UIImageView *settingCountImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"count_sub_add"]];
    [countView addSubview:settingCountImageView];
    [settingCountImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(100, 25));
        make.right.mas_equalTo(countView);
        make.centerY.mas_equalTo(countView);
    }];
    
    self.subBuyCountButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.subBuyCountButton setBackgroundColor:[UIColor clearColor]];
    [self.subBuyCountButton addTarget:self action:@selector(subBuyCountAction) forControlEvents:UIControlEventTouchUpInside];
    [countView addSubview:self.subBuyCountButton];
    [self.subBuyCountButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(25, 25));
        make.centerY.mas_equalTo(settingCountImageView);
        make.left.mas_equalTo(settingCountImageView);
    }];
    
    self.addBuyCountButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.addBuyCountButton setBackgroundColor:[UIColor clearColor]];
    [self.addBuyCountButton addTarget:self action:@selector(addBuyCountAction) forControlEvents:UIControlEventTouchUpInside];
    [countView addSubview:self.addBuyCountButton];
    [self.addBuyCountButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(25, 25));
        make.centerY.mas_equalTo(settingCountImageView);
        make.right.mas_equalTo(settingCountImageView);
    }];
    
    self.buyCountLabel = [UILabel new];
    [self.buyCountLabel setText:[NSString stringWithFormat:@"%ld", self.buyCount]];
    [countView addSubview:self.buyCountLabel];
    [self.buyCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(settingCountImageView);
    }];
    
    UIView *actionView = [UIView new];
    [self.contentView addSubview:actionView];
    [actionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.contentView).mas_offset(-40);
        make.centerX.mas_equalTo(self.contentView);
        make.top.mas_equalTo(countView.mas_bottom).mas_offset(10);
        make.height.mas_equalTo(40);
        
        make.bottom.mas_equalTo(self.contentView).mas_offset(-20);
    }];
    
    self.addToCartButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.addToCartButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.addToCartButton setBackgroundColor:[UIColor orangeColor]];
    [self.addToCartButton setTitle:@"加入购物车" forState:UIControlStateNormal];
    [self.addToCartButton addTarget:self action:@selector(addToCartAction) forControlEvents:UIControlEventTouchUpInside];
    [actionView addSubview:self.addToCartButton];
    [self.addToCartButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(actionView);
        make.right.mas_equalTo(actionView.mas_centerX);
        make.height.mas_equalTo(actionView);
        make.top.mas_equalTo(actionView);
    }];
    
    self.buyNowButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.buyNowButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.buyNowButton setBackgroundColor:[UIColor redColor]];
    [self.buyNowButton setTitle:@"立即购买" forState:UIControlStateNormal];
    [actionView addSubview:self.buyNowButton];
    [self.buyNowButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.addToCartButton.mas_right);
        make.right.mas_equalTo(actionView);
        make.height.mas_equalTo(actionView);
        make.top.mas_equalTo(actionView);
    }];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view);
        make.centerX.mas_equalTo(self.view);
    }];
    
    [self addCloseIcon];
}

- (void)addCloseIcon {
    UIImageView *closeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"close_icon"]];
    [self.contentView addSubview:closeImageView];
    [closeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(20, 20));
        make.top.mas_equalTo(self.contentView).mas_offset(10);
        make.right.mas_equalTo(self.contentView).mas_offset(-10);
    }];
    // 添加点击事件
    UITapGestureRecognizer *closeTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    [closeTapGesture setNumberOfTapsRequired:1];
    [closeImageView setUserInteractionEnabled:YES];
    [closeImageView addGestureRecognizer:closeTapGesture];
}

- (void)updateView {
    NSArray *tempArray = self.dataDict[@"val"];
    if (tempArray == nil || [tempArray count] == 0) {
        self.valArray = @[@[@"no"]];
        self.specificationTitleArray = @[@"规格分类"];
    } else {
        self.valArray = tempArray.copy;
        self.specificationTitleArray = ((NSArray *)self.dataDict[@"tit"]).copy;
    }
    [self.specificationCollection reloadData];
}

#pragma mark - Event
- (void)dismiss {
    // 发送完成商品规格选择的通知
    [[NSNotificationCenter defaultCenter] postNotificationName:kChooseProductSpecificationNotificationKey object:self userInfo:@{@"productId":@(self.productId), @"specificationKey":self.selectSpecificationKey, @"buyCount":@(self.buyCount)}];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)subBuyCountAction {
    if (self.buyCount < 2) {
        [self.view makeToast:@"至少购买一件！"];
    } else {
        self.buyCount -= 1;
        [self.buyCountLabel setText:[NSString stringWithFormat:@"%ld", self.buyCount]];
    }
}

- (void)addBuyCountAction {
    if (self.buyCount >= self.stockCount) {
        [self.view makeToast:[NSString stringWithFormat:@"只剩余%ld件！", self.stockCount]];
    } else {
        self.buyCount += 1;
        [self.buyCountLabel setText:[NSString stringWithFormat:@"%ld", self.buyCount]];
    }
}

- (void)addToCartAction {
    NSDictionary *parameters = @{@"buynum":@(self.buyCount), @"gkey":self.selectSpecificationKey, @"sid":[NSString stringWithFormat:@"%ld", self.productId], @"hid":[NSString stringWithFormat:@"%ld", self.hid]};
    
    HSNetworkManager *manager = [HSNetworkManager shareManager];
    __weak __typeof__(self) weakSelf = self;
    [manager postDataWithUrl:kAddProductToCartUrl parameters:parameters success:^(NSDictionary *responseDict) {
        if ([responseDict[@"errcode"] isEqual:@(0)]) {
            // 添加成功
            [weakSelf getCartProductCount];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.contentView makeToast:responseDict[@"msg"] duration:3 position:CSToastPositionCenter];
            });
        }
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.contentView makeToast:@"获取失败，接口请求错误！" duration:3 position:CSToastPositionCenter];
        });
        NSLog(@"%@", error);
    }];
}

- (void)getCartProductCount {
    HSNetworkManager *manager = [HSNetworkManager shareManager];
    __weak __typeof__(self) weakSelf = self;
    [manager getDataWithUrl:kGetCartProductCountUrl parameters:@{} success:^(NSDictionary *responseDict) {
        if ([responseDict[@"errcode"] isEqual:@(0)]) {
            // 添加成功
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf dismiss];
            });
            // 发送通知
            [[NSNotificationCenter defaultCenter] postNotificationName:kAddProductToCartNotificationKey object:weakSelf userInfo:@{@"productId":@(weakSelf.productId), @"specificationKey":weakSelf.selectSpecificationKey, @"buyCount":@(weakSelf.buyCount), @"cartCount":responseDict[@"cartnum"]}];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.contentView makeToast:responseDict[@"msg"] duration:3 position:CSToastPositionCenter];
            });
        }
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.contentView makeToast:@"获取失败，接口请求错误！" duration:3 position:CSToastPositionCenter];
        });
        NSLog(@"%@", error);
    }];
}

@end
