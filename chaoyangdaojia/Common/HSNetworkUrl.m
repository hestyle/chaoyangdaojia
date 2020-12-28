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
// 登录
NSString * const kLoginUrl = @"http://app.sunnysct.cn/api/home/userlogin/login";
// 获取账号信息
NSString * const kGetUserInfoUrl = @"http://app.sunnysct.cn/api/home/userinfo/getinfo";
// 修改账号信息
NSString * const kModifyUserInfoUrl = @"http://app.sunnysct.cn/api/home/userinfo/upuinfo";
// 获取头像上传路径
NSString * const kGetOOSInfoUrl = @"http://app.sunnysct.cn/api/home/userinfo/getoosinfo?path=avatar";
@implementation HSNetworkUrl

@end
