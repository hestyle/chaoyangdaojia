//
//  HSNetworkUrl.h
//  chaoyangdaojia
//
//  Created by hestyle on 2020/12/25.
//  Copyright © 2020 hestyle. All rights reserved.
//

#import <Foundation/Foundation.h>

// 获取验证码
extern NSString * const kGetTelCodeUrl;
// 验证码验证
extern NSString * const kCheckVerifyCode;
// 登录
extern NSString * const kLoginUrl;
// 获取账号信息
extern NSString * const kGetUserInfoUrl;
// 修改账号信息
extern NSString * const kModifyUserInfoUrl;
// 获取头像上传路径
extern NSString * const kGetOOSInfoUrl;
// 获取亲友生日by page
extern NSString * const kGetFriendBirthdaysByPageUrl;
// 添加亲友生日提醒
extern NSString * const kAddFriendBirthdayRemind;
// 删除亲友生日提醒
extern NSString * const kDeleteFriendBirthdayRemind;
// 设置交易密码
extern NSString * const kSetPayPassword;
// 获取常见问题by page
extern NSString * const kGetCommonProblemByPage;
// 反馈问题
extern NSString * const kFeedbackProblem;
// 关于我们
extern NSString * const kGetAboutUsInfo;
// 获取用户协议
extern NSString * const kGetUserPolicy;
// 获取会员说明
extern NSString * const kGetMemberExplain;
// 获取积分兑换list
extern NSString * const kGetExchangeBalanceList;
// 积分兑换
extern NSString * const kExchangeMoneyUrl;
// 获取商家店铺by page
extern NSString * const kGetShopsByPageUrl;
// 获取商家店铺详细信息
extern NSString * const kGetShopDetailByIdUrl;
// 获取店铺评论信息（需要店铺id、page）
extern NSString * const kGetShopCommentUrl;
// 获取店铺商品（需要店铺id、page）
extern NSString * const kGetShopProductListUrl;

NS_ASSUME_NONNULL_BEGIN

@interface HSNetworkUrl : NSObject

@end

NS_ASSUME_NONNULL_END
