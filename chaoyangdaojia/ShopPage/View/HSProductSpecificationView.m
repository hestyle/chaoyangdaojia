//
//  HSProductSpecificationView.m
//  chaoyangdaojia
//
//  Created by hestyle on 2021/1/23.
//  Copyright © 2021 hestyle. All rights reserved.
//

#import "HSProductSpecificationView.h"
#import "HSNetwork.h"
#import "HSTools.h"
#import <Masonry/Masonry.h>
#import <Toast/Toast.h>

@interface HSProductSpecificationView ()

@property (nonatomic) NSInteger productId;
@property (nonatomic) NSInteger hid;

@property (nonatomic) NSInteger stockCount;
@property (nonatomic, strong) UIImageView *productImageView;
@property (nonatomic, strong) UILabel *productTitleLabel;
@property (nonatomic, strong) UILabel *stockLabel;
@property (nonatomic, strong) UILabel *priceLabel;
@property (nonatomic, strong) UILabel *buyCountLabel;

@property (nonatomic, strong) UIButton *subBuyCountButton;
@property (nonatomic, strong) UIButton *addBuyCountButton;

@property (nonatomic, strong) NSMutableDictionary *dataDict;
@property (nonatomic, strong) NSMutableDictionary *specificationDict;

@end


@implementation HSProductSpecificationView

- (instancetype)init {
    self = [super init];
    
    self.buyCount = 1;
    self.dataDict = [NSMutableDictionary new];
    self.specificationDict = [NSMutableDictionary new];
    
    [self initView];
    
    return self;
}

- (void)getProductSpecificationWithId:(NSInteger)productId hid:(NSInteger)hid {
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
                [weakSelf makeToast:responseDict[@"msg"] duration:3 position:CSToastPositionCenter];
            });
            NSLog(@"接口 %@ 返回数据格式错误! responseDict = %@", url, responseDict);
        }
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf makeToast:@"获取失败，接口请求错误！" duration:3 position:CSToastPositionCenter];
        });
        NSLog(@"%@", error);
    }];
}

#pragma mark - Private
- (void)initView {
    self.productImageView = [UIImageView new];
    [self addSubview:self.productImageView];
    [self.productImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(100, 100));
        make.top.mas_equalTo(self).mas_offset(10);
        make.left.mas_equalTo(self);
    }];
    self.productTitleLabel = [UILabel new];
    [self.productTitleLabel setFont:[UIFont systemFontOfSize:[UIFont systemFontSize] + 2 weight:UIFontWeightSemibold]];
    [self addSubview:self.productTitleLabel];
    [self.productTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.productImageView);
        make.left.mas_equalTo(self.productImageView.mas_right).mas_offset(10);
        make.right.mas_lessThanOrEqualTo(self);
    }];

    self.stockLabel = [UILabel new];
    [self.stockLabel setTextColor:[UIColor grayColor]];
    [self.stockLabel setText:@"库存:0"];
    [self addSubview:self.stockLabel];
    [self.stockLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.productImageView);
        make.left.mas_equalTo(self.productTitleLabel);
        make.right.mas_lessThanOrEqualTo(self);
    }];

    self.priceLabel = [UILabel new];
    [self.priceLabel setTextColor:[UIColor redColor]];
    [self.priceLabel setFont:[UIFont systemFontOfSize:[UIFont systemFontSize] + 4 weight:UIFontWeightSemibold]];
    [self.priceLabel setText:@"￥0.00"];
    [self addSubview:self.priceLabel];
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.productImageView);
        make.left.mas_equalTo(self.productTitleLabel);
        make.right.mas_lessThanOrEqualTo(self);
    }];

    UIView *countView = [UIView new];
    [self addSubview:countView];
    [countView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self);
        make.height.mas_equalTo(50);
        make.top.mas_equalTo(self.productImageView.mas_bottom).mas_offset(10);
        make.centerX.mas_equalTo(self);
        
        make.bottom.mas_equalTo(self);
    }];
    
    UILabel *countTitleLabel = [UILabel new];
    [countTitleLabel setText:@"数量"];
    [self addSubview:countTitleLabel];
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
    [self.buyCountLabel setText:@"1"];
    [countView addSubview:self.buyCountLabel];
    [self.buyCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(settingCountImageView);
    }];
}

- (void)updateView {
    NSArray *valArray = self.dataDict[@"val"];
    if (valArray == nil || [valArray count] == 0) {
        NSString *specificationKey = @"no";
        NSDictionary *dict = self.specificationDict[specificationKey];
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
}

#pragma mark - Event
- (void)subBuyCountAction {
    if (self.buyCount == 1) {
        [self makeToast:@"至少购买一件！"];
    } else {
        self.buyCount -= 1;
        [self.buyCountLabel setText:[NSString stringWithFormat:@"%ld", self.buyCount]];
    }
}

- (void)addBuyCountAction {
    if (self.buyCount >= self.stockCount) {
        [self makeToast:[NSString stringWithFormat:@"只剩余%ld件！", self.stockCount]];
    } else {
        self.buyCount += 1;
        [self.buyCountLabel setText:[NSString stringWithFormat:@"%ld", self.buyCount]];
    }
}

@end
