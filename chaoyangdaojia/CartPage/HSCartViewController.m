//
//  HSCartViewController.m
//  chaoyangdaojia
//
//  Created by hestyle on 2020/12/24.
//  Copyright © 2020 hestyle. All rights reserved.
//

#import "HSCartViewController.h"
#import "HSProductDetailViewController.h"
#import "HSLoginViewController.h"
#import "HSAccount.h"
#import "HSNetwork.h"
#import "HSCommon.h"
#import <Masonry/Masonry.h>
#import <Toast/Toast.h>

@interface HSCartViewController ()

@property (nonatomic, strong) NSMutableArray *checkStatusArray;
@property (nonatomic, strong) NSMutableArray *productArray;

@property (nonatomic, strong) UIView *refreshView;
@property (nonatomic, strong) UIImageView *refreshImageView;
@property (nonatomic, strong) UILabel *refreshLabel;
@property (nonatomic, strong) UILabel *lastRefreshTimeLabel;

@property (nonatomic) NSInteger hadSelectedCount;
@property (nonatomic, strong) UIView *tableViewFooterView;
@property (nonatomic, strong) UIImageView *selectAllImageView;
@property (nonatomic, strong) UILabel *sumPriceLabel;
@property (nonatomic, strong) UIButton *settlementButton;

@property (nonatomic, strong) NSMutableArray *buyCountArray;
@property (nonatomic) NSInteger settlementCount;
@property (nonatomic) CGFloat settlementPrice;

@property (nonatomic, strong) UIBarButtonItem *rightDeleteButtonItem;

@end

static const CGFloat mCellHeight = 120.f;
static NSString * const reuseCellIdentifier = @"reusableCell";

static BOOL isHadGotoLoginViewController = NO;

static const CGFloat mTableViewFooterViewHeight = 45.f;

static const NSInteger mRefreshViewHeight = 60;
/* navigationBar高度44、状态栏（狗啃屏）高度44，contentInsetAdjustmentBehavior */
static const NSInteger mTableViewBaseContentOffsetY = -88;

@implementation HSCartViewController

- (instancetype)init {
    self = [super init];
    
    // 注册接收购物车中商品数量变更的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCartCountAction:) name:kUpdateCartCountNotificationKey object:nil];
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setEdgesForExtendedLayout:UIRectEdgeBottom];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    [self.tableView setAllowsMultipleSelectionDuringEditing:YES];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:reuseCellIdentifier];
    
    self.hadSelectedCount = 0;
    self.settlementCount = 0;
    self.settlementPrice = 0.f;
    self.checkStatusArray = [NSMutableArray new];
    self.productArray = [NSMutableArray new];
    self.buyCountArray = [NSMutableArray new];
    
    // 绘制view
    [self initView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 显示两侧的tabBar按钮
    [self.tabBarController setTitle:@"购物车"];
    [self.navigationController setNavigationBarHidden:NO];
    [self.tabBarController.navigationItem setRightBarButtonItem:self.rightDeleteButtonItem];
    
    if ([self.productArray count] == 0) {
        HSUserAccountManger *userAccoutManager = [HSUserAccountManger shareManager];
        if (!userAccoutManager.isLogin) {
            // 未登录
            if (!isHadGotoLoginViewController) {
                // 之前未到登录页面，则直接跳转到登录页面
                HSLoginViewController *loginViewController = [HSLoginViewController new];
                [self.navigationController pushViewController:loginViewController animated:YES];
                isHadGotoLoginViewController = YES;
            } else {
                // 之前已到登录页面，跳转到首页
                isHadGotoLoginViewController = NO;
                [self.tabBarController setSelectedIndex:0];
            }
            return;
        }
        [self getCartData];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // 移除tabBarController两侧的按钮
    [self.navigationController.navigationItem setLeftBarButtonItem:nil];
    [self.navigationController.navigationItem setRightBarButtonItem:nil];
}

- (void)dealloc {
    // 注销购物车中商品数量变更的通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kUpdateCartCountNotificationKey object:nil];
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
    
    UIImageView *chechImageView = [UIImageView new];
    [chechImageView setTag:indexPath.row];
    if ([self.checkStatusArray[indexPath.row] boolValue]) {
        [chechImageView setImage:[UIImage imageNamed:@"check_on_red_icon"]];
    } else {
        [chechImageView setImage:[UIImage imageNamed:@"check_off_icon"]];
    }
    [cell.contentView addSubview:chechImageView];
    [chechImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(25, 25));
        make.centerY.mas_equalTo(cell.contentView);
        make.left.mas_equalTo(cell.contentView).mas_offset(15);
    }];
    // 添加点击事件
    UITapGestureRecognizer *selectProductTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectProductAction:)];
    [selectProductTapGesture setNumberOfTapsRequired:1];
    [chechImageView setUserInteractionEnabled:YES];
    [chechImageView addGestureRecognizer:selectProductTapGesture];
    
    UIView *productInfoView = [UIView new];
    [productInfoView setTag:indexPath.row];
    [cell.contentView addSubview:productInfoView];
    [productInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(chechImageView.mas_right).mas_offset(15);
        make.right.mas_equalTo(cell.contentView).mas_offset(-15);
        make.height.mas_equalTo(cell.contentView).mas_offset(-20);
        make.centerY.mas_equalTo(cell.contentView);
    }];
    // 添加点击事件
    UITapGestureRecognizer *gotoProductDetailTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoProductDetailAction:)];
    [gotoProductDetailTapGesture setNumberOfTapsRequired:1];
    [productInfoView setUserInteractionEnabled:YES];
    [productInfoView addGestureRecognizer:gotoProductDetailTapGesture];
    
    UIImageView *productImageView = [UIImageView new];
    [productInfoView addSubview:productImageView];
    [productImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(100, 100));
        make.left.mas_equalTo(productInfoView);
        make.centerY.mas_equalTo(productInfoView);
    }];
    UILabel *productTitleLabel = [UILabel new];
    [productTitleLabel setFont:[UIFont systemFontOfSize:[UIFont systemFontSize] + 2 weight:UIFontWeightSemibold]];
    [productTitleLabel setText:[NSString stringWithFormat:@"%@", productDataDict[@"title"]]];
    [productInfoView addSubview:productTitleLabel];
    [productTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(productImageView);
        make.left.mas_equalTo(productImageView.mas_right).mas_offset(10);
        make.right.mas_lessThanOrEqualTo(productInfoView);
    }];
    
    UILabel *productSpecificationLabel = [UILabel new];
    [productSpecificationLabel setTextColor:[UIColor grayColor]];
    [productSpecificationLabel setFont:[UIFont systemFontOfSize:[UIFont systemFontSize] - 1]];
    NSString *specificationKey = productDataDict[@"key"];
    if (specificationKey == nil || [specificationKey isEqualToString:@"no"]) {
        specificationKey = @"默认规格";
    }
    [productSpecificationLabel setText:[NSString stringWithFormat:@"%@ ∨", specificationKey]];
    [productInfoView addSubview:productSpecificationLabel];
    [productSpecificationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(productImageView);
        make.left.mas_equalTo(productTitleLabel);
        make.right.mas_lessThanOrEqualTo(productInfoView);
    }];
    
    UILabel *productPriceLabel = [UILabel new];
    [productPriceLabel setTextColor:[UIColor redColor]];
    [productPriceLabel setFont:[UIFont systemFontOfSize:[UIFont systemFontSize] + 4 weight:UIFontWeightSemibold]];
    [productPriceLabel setText:[NSString stringWithFormat:@"￥%@", productDataDict[@"price"]]];
    [productInfoView addSubview:productPriceLabel];
    [productPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(productImageView);
        make.left.mas_equalTo(productTitleLabel);
        make.right.mas_lessThanOrEqualTo(productInfoView).mas_offset(-100);
    }];
    UIImageView *settingCountImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"count_sub_add"]];
    [settingCountImageView setUserInteractionEnabled:YES];
    [productInfoView addSubview:settingCountImageView];
    [settingCountImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(90, 25));
        make.right.mas_equalTo(productInfoView);
        make.centerY.mas_equalTo(productPriceLabel);
    }];
    
    UIButton *subBuyCountButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [subBuyCountButton setTag:indexPath.row];
    [subBuyCountButton setBackgroundColor:[UIColor clearColor]];
    [subBuyCountButton addTarget:self action:@selector(subBuyCountAction:) forControlEvents:UIControlEventTouchUpInside];
    [settingCountImageView addSubview:subBuyCountButton];
    [subBuyCountButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(25, 25));
        make.centerY.mas_equalTo(settingCountImageView);
        make.left.mas_equalTo(settingCountImageView);
    }];
    
    UIButton *addBuyCountButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [addBuyCountButton setTag:indexPath.row];
    [addBuyCountButton setBackgroundColor:[UIColor clearColor]];
    [addBuyCountButton addTarget:self action:@selector(addBuyCountAction:) forControlEvents:UIControlEventTouchUpInside];
    [settingCountImageView addSubview:addBuyCountButton];
    [addBuyCountButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(25, 25));
        make.centerY.mas_equalTo(settingCountImageView);
        make.right.mas_equalTo(settingCountImageView);
    }];
    
    UILabel *buyCountLabel = [UILabel new];
    [buyCountLabel setText:[NSString stringWithFormat:@"%@", self.buyCountArray[indexPath.row]]];
    [settingCountImageView addSubview:buyCountLabel];
    [buyCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(settingCountImageView);
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
    [cell setTintColor:[UIColor redColor]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"点击了cell row = %ld", indexPath.row);
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    static BOOL isSetContentInset = NO;
    // 更新底部吸附footerview
    if (self.tableView.contentOffset.y >= self.tableView.contentSize.height + mTableViewFooterViewHeight - [UIScreen mainScreen].bounds.size.height - mTableViewBaseContentOffsetY) {
        if (!isSetContentInset) {
            [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, mTableViewFooterViewHeight, 0)];
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
            make.top.mas_equalTo(self.tableView.mas_top).mas_offset(self.tableView.contentOffset.y + [UIScreen mainScreen].bounds.size.height + mTableViewBaseContentOffsetY - mTableViewFooterViewHeight);
        }];
    }
    if (scrollView.contentOffset.y <= -mRefreshViewHeight + mTableViewBaseContentOffsetY) {
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
        [self getCartData];
    }
    NSLog(@"scrollView.contentOffset.y = %f", scrollView.contentOffset.y);
}

#pragma mark - Event
- (void)selectProductAction:(UITapGestureRecognizer *)sender {
    NSInteger index = sender.view.tag;
    NSDictionary *productData = self.productArray[index];
    NSString *productPrice = productData[@"price"];
    if (![self.checkStatusArray[index] boolValue]) {
        self.hadSelectedCount += 1;
        self.checkStatusArray[index] = @(YES);
        
        self.settlementCount += [self.buyCountArray[index] integerValue];
        self.settlementPrice += [self.buyCountArray[index] integerValue] * [productPrice floatValue];
    } else {
        self.hadSelectedCount -= 1;
        self.checkStatusArray[index] = @(NO);
        
        self.settlementCount -= [self.buyCountArray[index] integerValue];
        self.settlementPrice -= [self.buyCountArray[index] integerValue] * [productPrice floatValue];
    }
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    
    if (self.hadSelectedCount == [self.productArray count]) {
        [self.selectAllImageView setImage:[UIImage imageNamed:@"check_on_red_icon"]];
    } else {
        [self.selectAllImageView setImage:[UIImage imageNamed:@"check_off_icon"]];
    }
    
    [self updateTableFooterViewData];
}

- (void)selectAllProductAction {
    BOOL chechStatus = YES;
    if (self.hadSelectedCount == [self.productArray count]) {
        // 每个取消选择
        chechStatus = NO;
        self.hadSelectedCount = 0;
        [self.selectAllImageView setImage:[UIImage imageNamed:@"check_off_icon"]];
    } else {
        // 每个都选择
        chechStatus = YES;
        self.hadSelectedCount = [self.productArray count];
        [self.selectAllImageView setImage:[UIImage imageNamed:@"check_on_red_icon"]];
    }
    self.settlementCount = 0;
    self.settlementPrice = 0.f;
    for (int i = 0; i < [self.productArray count]; ++i) {
        self.checkStatusArray[i] = @(chechStatus);
        if (chechStatus) {
            NSDictionary *productData = self.productArray[i];
            NSString *productPrice = productData[@"price"];
            self.settlementCount += [self.buyCountArray[i] integerValue];
            self.settlementPrice += [self.buyCountArray[i] integerValue] * [productPrice floatValue];
        }
    }
    [self.tableView reloadData];
    
    [self updateTableFooterViewData];
}

- (void)gotoProductDetailAction:(UITapGestureRecognizer *)sender {
    NSInteger index = sender.view.tag;
    NSDictionary *productDataDict = self.productArray[index];
    HSProductDetailViewController *controller = [[HSProductDetailViewController alloc] initWithProductId:[productDataDict[@"sid"] integerValue]];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)deleteSelectedProduct {
    if (self.hadSelectedCount == 0) {
        [self.view makeToast:@"请选中需要删除的商品！" duration:3 position:CSToastPositionCenter];
        return;
    }
    NSMutableArray<NSString *> *selectedProductIdArray = [NSMutableArray new];
    for (int i = 0; i < [self.productArray count]; ++i) {
        if ([self.checkStatusArray[i] boolValue]) {
            NSDictionary *productData = self.productArray[i];
            [selectedProductIdArray addObject:[NSString stringWithFormat:@"%@", productData[@"id"]]];
        }
    }
    NSDictionary *parameters = @{@"data":selectedProductIdArray.copy};
    HSNetworkManager *manager = [HSNetworkManager shareManager];
    __weak __typeof__(self) weakSelf = self;
    [manager postDataWithUrl:kDelCartProductUrl parameters:parameters success:^(NSDictionary *responseDict) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.view makeToast:responseDict[@"msg"] duration:3 position:CSToastPositionCenter];
        });
        // 删除成功
        if ([responseDict[@"errcode"] isEqual:@(0)]) {
            [weakSelf getCartData];
            [weakSelf getCartProductCount];
        } else {
            NSLog(@"接口 %@ 返回数据格式错误! responseDict = %@", kDelCartProductUrl, responseDict);
        }
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.view makeToast:@"获取失败，接口请求错误！" duration:3 position:CSToastPositionCenter];
        });
        NSLog(@"%@", error);
    }];
}

- (void)subBuyCountAction:(UIButton *)sender {
    NSInteger index = sender.tag;
    if ([self.buyCountArray[index] integerValue] < 2) {
        [self.view makeToast:@"至少购买1件！" duration:3 position:CSToastPositionCenter];
        return;
    }
    NSDictionary *productDataDict = self.productArray[index];
    NSString *productPriceString = productDataDict[@"price"];
    NSDictionary *parameters = @{@"type":@"jian", @"id":[NSString stringWithFormat:@"%@", productDataDict[@"id"]]};
    
    HSNetworkManager *manager = [HSNetworkManager shareManager];
    __weak __typeof__(self) weakSelf = self;
    [manager postDataWithUrl:kEditCartProductBuyNumUrl parameters:parameters success:^(NSDictionary *responseDict) {
        // 获取成功
        if ([responseDict[@"errcode"] isEqual:@(0)]) {
            weakSelf.buyCountArray[index] = @([weakSelf.buyCountArray[index] integerValue] - 1);
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                if ([weakSelf.checkStatusArray[index] boolValue]) {
                    weakSelf.settlementCount -= 1;
                    weakSelf.settlementPrice -= [productPriceString floatValue];
                    [weakSelf updateTableFooterViewData];
                }
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.view makeToast:responseDict[@"msg"] duration:3 position:CSToastPositionCenter];
            });
            NSLog(@"接口 %@ 返回数据格式错误! responseDict = %@", kEditCartProductBuyNumUrl, responseDict);
        }
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.view makeToast:@"获取失败，接口请求错误！" duration:3 position:CSToastPositionCenter];
        });
        NSLog(@"%@", error);
    }];
}

- (void)addBuyCountAction:(UIButton *)sender {
    NSInteger index = sender.tag;
    NSDictionary *productDataDict = self.productArray[index];
    NSString *productPriceString = productDataDict[@"price"];
    NSDictionary *parameters = @{@"type":@"jia", @"id":[NSString stringWithFormat:@"%@", productDataDict[@"id"]]};
    
    HSNetworkManager *manager = [HSNetworkManager shareManager];
    __weak __typeof__(self) weakSelf = self;
    [manager postDataWithUrl:kEditCartProductBuyNumUrl parameters:parameters success:^(NSDictionary *responseDict) {
        // 获取成功
        if ([responseDict[@"errcode"] isEqual:@(0)]) {
            weakSelf.buyCountArray[index] = @([weakSelf.buyCountArray[index] integerValue] + 1);
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                if ([weakSelf.checkStatusArray[index] boolValue]) {
                    weakSelf.settlementCount += 1;
                    weakSelf.settlementPrice += [productPriceString floatValue];
                    [weakSelf updateTableFooterViewData];
                }
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.view makeToast:responseDict[@"msg"] duration:3 position:CSToastPositionCenter];
            });
            NSLog(@"接口 %@ 返回数据格式错误! responseDict = %@", kEditCartProductBuyNumUrl, responseDict);
        }
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.view makeToast:@"获取失败，接口请求错误！" duration:3 position:CSToastPositionCenter];
        });
        NSLog(@"%@", error);
    }];
}

- (void)settlementAction {
    [self.view makeToast:@"点击了结算！" duration:3.f position:CSToastPositionCenter];
}

- (void)updateCartCountAction:(NSNotification *)notification {
    // 获取当前购物车中的商品数
    NSDictionary *specificationDataDict = notification.userInfo;
    NSInteger cartCount = 0;
    if (specificationDataDict[@"cartCount"] != nil && ![specificationDataDict[@"cartCount"] isEqual:[NSNull null]]) {
        cartCount = [specificationDataDict[@"cartCount"] integerValue];
    }
    if (cartCount != 0) {
        [self.tabBarItem setBadgeValue:[NSString stringWithFormat:@"%ld", cartCount]];
    } else {
        [self.tabBarItem setBadgeValue:@""];
    }
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
        make.centerX.mas_equalTo(self.tableView.mas_centerX).with.offset(10);
        make.size.mas_equalTo(CGSizeMake(180, 20));
    }];

    self.refreshImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"refresh_arrow"]];
    [self.refreshView addSubview:self.refreshImageView];
    [self.refreshImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.lastRefreshTimeLabel.mas_left).with.offset(-20);
        make.centerY.mas_equalTo(self.refreshView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(30, 50));
    }];
    
    [self initTableFooterView];
    
    UIButton *rightDeleteButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [rightDeleteButton setBackgroundImage:[UIImage imageNamed:@"del_white_icon"] forState:UIControlStateNormal];
    [[rightDeleteButton.widthAnchor constraintEqualToConstant:30.f] setActive:YES];
    [[rightDeleteButton.heightAnchor constraintEqualToConstant:30.f] setActive:YES];
    [rightDeleteButton addTarget:self action:@selector(deleteSelectedProduct) forControlEvents:UIControlEventTouchUpInside];
    self.rightDeleteButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightDeleteButton];
}

- (void)initTableFooterView {
    self.tableViewFooterView = [UIView new];
    [self.tableViewFooterView.layer setZPosition:MAXFLOAT];
    [self.tableViewFooterView setUserInteractionEnabled:YES];
    [self.tableViewFooterView setBackgroundColor:[UIColor whiteColor]];
    [self.tableView addSubview:self.tableViewFooterView];
    [self.tableViewFooterView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(mTableViewFooterViewHeight);
        make.width.mas_equalTo(self.tableView);
        make.top.mas_equalTo(self.tableView).mas_offset([UIScreen mainScreen].bounds.size.height - mTableViewFooterViewHeight + 3 * mTableViewBaseContentOffsetY);
        make.centerX.mas_equalTo(self.tableView);
    }];
    
    UIView *selectAllView = [UIView new];
    [self.tableViewFooterView addSubview:selectAllView];
    [selectAllView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.tableViewFooterView);
        make.centerY.mas_equalTo(self.tableViewFooterView);
    }];
    // 添加点击事件
    UITapGestureRecognizer *selectAllProductTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectAllProductAction)];
    [selectAllProductTapGesture setNumberOfTapsRequired:1];
    [selectAllView setUserInteractionEnabled:YES];
    [selectAllView addGestureRecognizer:selectAllProductTapGesture];
    
    self.selectAllImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check_off_icon"]];
    [selectAllView addSubview:self.selectAllImageView];
    [self.selectAllImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(25, 25));
        make.centerY.mas_equalTo(selectAllView);
        make.left.mas_equalTo(selectAllView).mas_offset(15);
    }];
    UILabel *selectAllTitleLabel = [UILabel new];
    [selectAllTitleLabel setText:@"全选"];
    [selectAllView addSubview:selectAllTitleLabel];
    [selectAllTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(selectAllView);
        make.centerY.mas_equalTo(selectAllView);
        make.left.mas_equalTo(self.selectAllImageView.mas_right).mas_offset(15);
        make.right.mas_equalTo(selectAllView);
    }];
    
    self.settlementButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.settlementButton setUserInteractionEnabled:YES];
    [self.settlementButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.settlementButton setTitle:@"结算(0)" forState:UIControlStateNormal];
    [self.settlementButton setBackgroundColor:[UIColor grayColor]];
    [self.settlementButton setEnabled:NO];
    [self.settlementButton addTarget:self action:@selector(settlementAction) forControlEvents:UIControlEventTouchUpInside];
    [self.tableViewFooterView addSubview:self.settlementButton];
    [self.settlementButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.tableViewFooterView).mas_offset(-10);
        make.width.mas_equalTo(90);
        make.height.mas_equalTo(self.tableViewFooterView);
        make.centerY.mas_equalTo(self.tableViewFooterView);
    }];
    self.sumPriceLabel = [UILabel new];
    [self.sumPriceLabel setTextColor:[UIColor redColor]];
    [self.sumPriceLabel setFont:[UIFont systemFontOfSize:[UIFont systemFontSize] + 6 weight:UIFontWeightSemibold]];
    [self.sumPriceLabel setText:@"￥0.00"];
    [self.tableViewFooterView addSubview:self.sumPriceLabel];
    [self.sumPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.settlementButton.mas_left).mas_offset(-10);
        make.centerY.mas_equalTo(self.tableViewFooterView);
    }];
    
    UILabel *sumTitleLabel = [UILabel new];
    [sumTitleLabel setText:@"合计"];
    [self.tableViewFooterView addSubview:sumTitleLabel];
    [sumTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.sumPriceLabel.mas_left).mas_offset(-10);
        make.centerY.mas_equalTo(self.tableViewFooterView);
    }];
}

- (void)getCartData {
    HSNetworkManager *manager = [HSNetworkManager shareManager];
    __weak __typeof__(self) weakSelf = self;
    [manager getDataWithUrl:kGetCartDataUrl parameters:@{} success:^(NSDictionary *responseDict) {
        // 获取成功
        if ([responseDict[@"errcode"] isEqual:@(0)]) {
            [weakSelf.productArray removeAllObjects];
            NSArray *listData = responseDict[@"list"];
            // 判断是否有下一页
            if (![listData isEqual:[NSNull null]]) {
                [weakSelf.productArray addObjectsFromArray:listData];
            }
            [weakSelf.buyCountArray removeAllObjects];
            weakSelf.hadSelectedCount = 0;
            [weakSelf.checkStatusArray removeAllObjects];
            for (int i = 0; i < [weakSelf.productArray count]; ++i) {
                [weakSelf.checkStatusArray addObject:@(NO)];
                NSDictionary *dict = weakSelf.productArray[i];
                [weakSelf.buyCountArray addObject:dict[@"num"]];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.settlementCount = 0;
                weakSelf.settlementPrice = 0.f;
                [weakSelf updateTableFooterViewData];
                // 更新ui
                [weakSelf.tableView performBatchUpdates:^{
                    //[weakSelf.loadMoreView setHidden:YES];
                    [weakSelf.tableView reloadSections:[[NSIndexSet alloc] initWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
                } completion:^(BOOL finished) {
                    //[weakSelf updateLoadMoreView];
                }];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tableView makeToast:responseDict[@"msg"] duration:3 position:CSToastPositionCenter];
            });
            NSLog(@"接口 %@ 返回数据格式错误! responseDict = %@", kGetCartDataUrl, responseDict);
        }
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.tableView makeToast:@"获取失败，接口请求错误！" duration:3 position:CSToastPositionCenter];
        });
        NSLog(@"%@", error);
    }];
}

- (void)updateTableFooterViewData {
    if (self.settlementCount == 0) {
        [self.settlementButton setEnabled:NO];
        [self.settlementButton setBackgroundColor:[UIColor grayColor]];
    } else {
        [self.settlementButton setEnabled:YES];
        [self.settlementButton setBackgroundColor:[UIColor orangeColor]];
    }
    [self.settlementButton setTitle:[NSString stringWithFormat:@"结算(%ld)", self.settlementCount] forState:UIControlStateNormal];
    [self.sumPriceLabel setText:[NSString stringWithFormat:@"￥%0.2f", self.settlementPrice]];
}

- (void)getCartProductCount {
    HSNetworkManager *manager = [HSNetworkManager shareManager];
    __weak __typeof__(self) weakSelf = self;
    [manager getDataWithUrl:kGetCartProductCountUrl parameters:@{} success:^(NSDictionary *responseDict) {
        if ([responseDict[@"errcode"] isEqual:@(0)]) {
            // 发送通知
            [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCartCountNotificationKey object:weakSelf userInfo:@{@"cartCount":responseDict[@"cartnum"]}];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.view makeToast:responseDict[@"msg"] duration:3 position:CSToastPositionCenter];
            });
        }
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.view makeToast:@"获取失败，接口请求错误！" duration:3 position:CSToastPositionCenter];
        });
        NSLog(@"%@", error);
    }];
}

@end
