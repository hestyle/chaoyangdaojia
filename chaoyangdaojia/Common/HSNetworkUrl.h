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
NS_ASSUME_NONNULL_BEGIN

@interface HSNetworkUrl : NSObject

@end

NS_ASSUME_NONNULL_END
