//
//  HSSettingsTableViewController.m
//  chaoyangdaojia
//
//  Created by hestyle on 2021/1/2.
//  Copyright © 2021 hestyle. All rights reserved.
//

#import "HSSettingsTableViewController.h"
#import "HSPayPasswordSettingViewController.h"
#import <Masonry/Masonry.h>

@interface HSSettingsTableViewController ()

@property (nonatomic, strong) NSArray<UITableViewCell *> *cellArray;
@property (nonatomic, strong) UILabel *casheSizeLabel;
@property (nonatomic, strong) UISwitch *messagePushSwitch;
@property (nonatomic, strong) UIButton *logoutButton;

@end

/* cell高度 */
static const NSInteger mHeightForRow = 50;

@implementation HSSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self setTitle:@"设置"];
    [self.navigationController setNavigationBarHidden:NO];
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    [self initCellArray];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.cellArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return mHeightForRow;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != 0 || indexPath.row >= [self.cellArray count]) {
        return;
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        // 支付密码设置
        HSPayPasswordSettingViewController *controller = [HSPayPasswordSettingViewController new];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != 0 || indexPath.row >= [self.cellArray count]) {
        return nil;
    }
    return self.cellArray[indexPath.row];
}

#pragma mark - Event
- (void)logoutAction {
    NSLog(@"点击了退出登录！");
}

#pragma mark - Private
- (void)initCellArray{
    self.cellArray = [NSArray new];
    
    UIImage *gotoDetailImage = [UIImage imageNamed:@"goto_detail"];
    
    UITableViewCell *paymentPasswordCell = [UITableViewCell new];
    UILabel *paymentPasswordTitleLabel = [UILabel new];
    [paymentPasswordTitleLabel setText:@"支付密码设置"];
    [paymentPasswordCell.contentView addSubview:paymentPasswordTitleLabel];
    [paymentPasswordTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(30);
        make.left.mas_equalTo(paymentPasswordCell.contentView).mas_offset(20);
        make.centerY.mas_equalTo(paymentPasswordCell.contentView);
    }];
    UIImageView *paymentPasswordDetailImageView = [[UIImageView alloc] initWithImage:gotoDetailImage];
    [paymentPasswordCell.contentView addSubview:paymentPasswordDetailImageView];
    [paymentPasswordDetailImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(paymentPasswordCell.contentView);
        make.right.mas_equalTo(paymentPasswordCell.contentView.mas_right).offset(-20);
        make.size.mas_equalTo(CGSizeMake(15, 15));
    }];
    
    UITableViewCell *checkUpdateCell = [UITableViewCell new];
    UILabel *checkUpdateTitleLabel = [UILabel new];
    [checkUpdateTitleLabel setText:@"检查更新"];
    [checkUpdateCell.contentView addSubview:checkUpdateTitleLabel];
    [checkUpdateTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(30);
        make.left.mas_equalTo(checkUpdateCell.contentView).mas_offset(20);
        make.centerY.mas_equalTo(checkUpdateCell.contentView);
    }];
    UIImageView *checkUpdateDetailImageView = [[UIImageView alloc] initWithImage:gotoDetailImage];
    [checkUpdateCell.contentView addSubview:checkUpdateDetailImageView];
    [checkUpdateDetailImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(checkUpdateCell.contentView);
        make.right.mas_equalTo(checkUpdateCell.contentView.mas_right).offset(-20);
        make.size.mas_equalTo(CGSizeMake(15, 15));
    }];
    
    UITableViewCell *cleanCasheCell = [UITableViewCell new];
    UILabel *cleanCasheTitleLabel = [UILabel new];
    [cleanCasheTitleLabel setText:@"清除缓存"];
    [cleanCasheCell.contentView addSubview:cleanCasheTitleLabel];
    [cleanCasheTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(30);
        make.left.mas_equalTo(cleanCasheCell.contentView).mas_offset(20);
        make.centerY.mas_equalTo(cleanCasheCell.contentView);
    }];
    UIImageView *cleanCasheDetailImageView = [[UIImageView alloc] initWithImage:gotoDetailImage];
    [cleanCasheCell.contentView addSubview:cleanCasheDetailImageView];
    [cleanCasheDetailImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(cleanCasheCell.contentView);
        make.right.mas_equalTo(cleanCasheCell.contentView.mas_right).offset(-20);
        make.size.mas_equalTo(CGSizeMake(15, 15));
    }];
    self.casheSizeLabel = [UILabel new];
    [self.casheSizeLabel setText:@"30.3M"];
    [self.casheSizeLabel setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];
    [cleanCasheCell.contentView addSubview:self.casheSizeLabel];
    [self.casheSizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(cleanCasheCell.contentView);
        make.right.mas_equalTo(cleanCasheDetailImageView.mas_left).offset(-5);
    }];
    
    UITableViewCell *messagePushCell = [UITableViewCell new];
    UILabel *messagePushTitleLabel = [UILabel new];
    [messagePushTitleLabel setText:@"消息推送"];
    [messagePushCell.contentView addSubview:messagePushTitleLabel];
    [messagePushTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(30);
        make.left.mas_equalTo(messagePushCell.contentView).mas_offset(20);
        make.centerY.mas_equalTo(messagePushCell.contentView);
    }];
    self.messagePushSwitch = [[UISwitch alloc] init];
    [self.messagePushSwitch setOn:YES];
    [self.messagePushSwitch setOnTintColor:[UIColor orangeColor]];
    [messagePushCell.contentView addSubview:self.messagePushSwitch];
    [self.messagePushSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(messagePushCell.contentView);
        make.right.mas_equalTo(messagePushCell.contentView.mas_right).offset(-20);
        make.size.mas_equalTo(CGSizeMake(50, 30));
    }];
    
    UITableViewCell *shareAppCell = [UITableViewCell new];
    UILabel *shareAppTitleLabel = [UILabel new];
    [shareAppTitleLabel setText:@"分享App"];
    [shareAppCell.contentView addSubview:shareAppTitleLabel];
    [shareAppTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(30);
        make.left.mas_equalTo(shareAppCell.contentView).mas_offset(20);
        make.centerY.mas_equalTo(shareAppCell.contentView);
    }];
    UIImageView *shareAppDetailImageView = [[UIImageView alloc] initWithImage:gotoDetailImage];
    [shareAppCell.contentView addSubview:shareAppDetailImageView];
    [shareAppDetailImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(shareAppCell.contentView);
        make.right.mas_equalTo(shareAppCell.contentView.mas_right).offset(-20);
        make.size.mas_equalTo(CGSizeMake(15, 15));
    }];
    
    UITableViewCell *commonProblemCell = [UITableViewCell new];
    UILabel *commonProblemTitleLabel = [UILabel new];
    [commonProblemTitleLabel setText:@"常见问题"];
    [commonProblemCell.contentView addSubview:commonProblemTitleLabel];
    [commonProblemTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(30);
        make.left.mas_equalTo(commonProblemCell.contentView).mas_offset(20);
        make.centerY.mas_equalTo(commonProblemCell.contentView);
    }];
    UIImageView *commonProblemDetailImageView = [[UIImageView alloc] initWithImage:gotoDetailImage];
    [commonProblemCell.contentView addSubview:commonProblemDetailImageView];
    [commonProblemDetailImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(commonProblemCell.contentView);
        make.right.mas_equalTo(commonProblemCell.contentView.mas_right).offset(-20);
        make.size.mas_equalTo(CGSizeMake(15, 15));
    }];
    
    UITableViewCell *feedBackCell = [UITableViewCell new];
    UILabel *feedBackTitleLabel = [UILabel new];
    [feedBackTitleLabel setText:@"意见反馈"];
    [feedBackCell.contentView addSubview:feedBackTitleLabel];
    [feedBackTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(30);
        make.left.mas_equalTo(feedBackCell.contentView).mas_offset(20);
        make.centerY.mas_equalTo(feedBackCell.contentView);
    }];
    UIImageView *feedBackDetailImageView = [[UIImageView alloc] initWithImage:gotoDetailImage];
    [feedBackCell.contentView addSubview:feedBackDetailImageView];
    [feedBackDetailImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(feedBackCell.contentView);
        make.right.mas_equalTo(feedBackCell.contentView.mas_right).offset(-20);
        make.size.mas_equalTo(CGSizeMake(15, 15));
    }];
    
    UITableViewCell *aboutUsCell = [UITableViewCell new];
    UILabel *aboutUsTitleLabel = [UILabel new];
    [aboutUsTitleLabel setText:@"关于我们"];
    [aboutUsCell.contentView addSubview:aboutUsTitleLabel];
    [aboutUsTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(30);
        make.left.mas_equalTo(aboutUsCell.contentView).mas_offset(20);
        make.centerY.mas_equalTo(aboutUsCell.contentView);
    }];
    UIImageView *aboutUsDetailImageView = [[UIImageView alloc] initWithImage:gotoDetailImage];
    [aboutUsCell.contentView addSubview:aboutUsDetailImageView];
    [aboutUsDetailImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(aboutUsCell.contentView);
        make.right.mas_equalTo(aboutUsCell.contentView.mas_right).offset(-20);
        make.size.mas_equalTo(CGSizeMake(15, 15));
    }];
    
    UITableViewCell *contactUsCell = [UITableViewCell new];
    UILabel *contactUsTitleLabel = [UILabel new];
    [contactUsTitleLabel setText:@"联系我们"];
    [contactUsCell.contentView addSubview:contactUsTitleLabel];
    [contactUsTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(30);
        make.left.mas_equalTo(contactUsCell.contentView).mas_offset(20);
        make.centerY.mas_equalTo(contactUsCell.contentView);
    }];
    UIImageView *contactUsDetailImageView = [[UIImageView alloc] initWithImage:gotoDetailImage];
    [contactUsCell.contentView addSubview:contactUsDetailImageView];
    [contactUsDetailImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(contactUsCell.contentView);
        make.right.mas_equalTo(contactUsCell.contentView.mas_right).offset(-20);
        make.size.mas_equalTo(CGSizeMake(15, 15));
    }];
    
    UITableViewCell *userAgreementPrivacyPolicyCell = [UITableViewCell new];
    UILabel *userAgreementPrivacyPolicyTitleLabel = [UILabel new];
    [userAgreementPrivacyPolicyTitleLabel setText:@"用户协议&隐私政策"];
    [userAgreementPrivacyPolicyCell.contentView addSubview:userAgreementPrivacyPolicyTitleLabel];
    [userAgreementPrivacyPolicyTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(30);
        make.left.mas_equalTo(userAgreementPrivacyPolicyCell.contentView).mas_offset(20);
        make.centerY.mas_equalTo(userAgreementPrivacyPolicyCell.contentView);
    }];
    UIImageView *userAgreementPrivacyPolicyDetailImageView = [[UIImageView alloc] initWithImage:gotoDetailImage];
    [userAgreementPrivacyPolicyCell.contentView addSubview:userAgreementPrivacyPolicyDetailImageView];
    [userAgreementPrivacyPolicyDetailImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(userAgreementPrivacyPolicyCell.contentView);
        make.right.mas_equalTo(userAgreementPrivacyPolicyCell.contentView.mas_right).offset(-20);
        make.size.mas_equalTo(CGSizeMake(15, 15));
    }];
    
    UITableViewCell *logoutCell = [UITableViewCell new];
    self.logoutButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.logoutButton setBackgroundImage:[UIImage imageNamed:@"common_background"] forState:UIControlStateNormal];
    [self.logoutButton.layer setCornerRadius:5];
    [self.logoutButton setTintColor:[UIColor blackColor]];
    [self.logoutButton setTitle:@"退出登录" forState:UIControlStateNormal];
    [self.logoutButton setTitle:@"" forState:UIControlStateHighlighted];
    [self.logoutButton addTarget:self action:@selector(logoutAction) forControlEvents:UIControlEventTouchUpInside];
    [logoutCell.contentView addSubview:self.logoutButton];
    [self.logoutButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(logoutCell.contentView);
        make.size.mas_equalTo(CGSizeMake(200, 35));
    }];
    
    self.cellArray = @[paymentPasswordCell, checkUpdateCell, cleanCasheCell, messagePushCell, shareAppCell, commonProblemCell, feedBackCell, aboutUsCell, contactUsCell, userAgreementPrivacyPolicyCell, logoutCell];
}

@end
