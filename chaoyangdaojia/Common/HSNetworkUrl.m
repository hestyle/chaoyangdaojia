//
//  HSNetworkUrl.m
//  chaoyangdaojia
//
//  Created by hestyle on 2020/12/25.
//  Copyright © 2020 hestyle. All rights reserved.
//

#import "HSNetworkUrl.h"

// 获取验证码
NSString * const kGetTelCodeUrl = @"http://app.sunnysct.cn/api/home/send/telcode";
// 验证码验证
NSString * const kCheckVerifyCode = @"http://app.sunnysct.cn/api/home/userinfo/check_msgcode";
// 登录
NSString * const kLoginUrl = @"http://app.sunnysct.cn/api/home/userlogin/login";
// 获取账号信息
NSString * const kGetUserInfoUrl = @"http://app.sunnysct.cn/api/home/userinfo/getinfo";
// 修改账号信息
NSString * const kModifyUserInfoUrl = @"http://app.sunnysct.cn/api/home/userinfo/upuinfo";
// 获取头像上传路径
NSString * const kGetOOSInfoUrl = @"http://app.sunnysct.cn/api/home/userinfo/getoosinfo?path=avatar";
// 获取亲友生日by page
NSString * const kGetFriendBirthdaysByPageUrl = @"http://app.sunnysct.cn/api/home/userinfo/birthday_list";
// 添加亲友生日提醒
NSString * const kAddFriendBirthdayRemind = @"http://app.sunnysct.cn/api/home/userinfo/birthday_add";
// 删除亲友生日提醒
NSString * const kDeleteFriendBirthdayRemind = @"http://app.sunnysct.cn/api/home/userinfo/birthday_del";
// 设置交易密码
NSString * const kSetPayPassword = @"http://app.sunnysct.cn/api/home/userinfo/setjymm";
// 获取常见问题by page
NSString * const kGetCommonProblemByPage = @"http://app.sunnysct.cn/api/home/index/help_list";
// 反馈问题
NSString * const kFeedbackProblem = @"http://app.sunnysct.cn/api/home/userinfo/fankui";
@implementation HSNetworkUrl

@end
