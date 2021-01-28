//
//  HSSortCollectionViewController.m
//  chaoyangdaojia
//
//  Created by hestyle on 2021/1/17.
//  Copyright © 2021 hestyle. All rights reserved.
//

#import "HSSortCollectionViewController.h"
#import "HSCategoryDetailViewController.h"
#import "HSNetwork.h"
#import <Masonry/Masonry.h>
#import <Toast/Toast.h>

@interface HSSortCollectionViewController ()

@property (nonatomic, strong) UIBarButtonItem *rightSearchButtonItem;

@end

@implementation HSSortCollectionViewController

static NSString * const reuseCellIdentifier = @"reusableCell";
static const CGFloat mCategoryCellWidth = 60.f;
static const CGFloat mCategoryCellHeight = 90.f;

- (instancetype)init {
    self.categoryArray = [NSMutableArray new];
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
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
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseCellIdentifier];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"common_background"] forBarMetrics:UIBarMetricsDefault];
    
    [self initView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationItem setTitle:@"分类"];
    
    [self.navigationItem setRightBarButtonItem:self.rightSearchButtonItem];
    [self.collectionView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.navigationItem setRightBarButtonItem:nil];
}

#pragma mark <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.categoryArray count];
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
    }
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return CGSizeMake(mCategoryCellWidth, mCategoryCellHeight);
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
    NSDictionary *categoryDataDict = self.categoryArray[indexPath.row];
    HSCategoryDetailViewController *controller = [[HSCategoryDetailViewController alloc] initWithCategoryData:categoryDataDict];
    [controller setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Event
- (void)gotoSearchAction {
    [self.view makeToast:@"点击了搜索图标！"];
}

#pragma mark - Private
- (void)initView {
    self.rightSearchButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search_white_iocn"] style:UIBarButtonItemStylePlain target:self action:@selector(gotoSearchAction)];
}

@end
