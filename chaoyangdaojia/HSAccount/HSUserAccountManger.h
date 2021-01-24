//
//  HSUserAccountManger.h
//  chaoyangdaojia
//
//  Created by hestyle on 2021/1/4.
//  Copyright © 2021 hestyle. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HSUserAccountManger : NSObject

{
    BOOL isLogin;
    NSDictionary *userInfoDict;
    NSString *avatarPath;
}

/*
 * 获取单例对象
 */
+ (HSUserAccountManger *)shareManager;

/*
 * 刷新userInfo
 */
- (void)refreshUserInfoFromNetWork;

/*
 * 更新UserInfo
 */
- (void)updateUserInfo:(NSDictionary *)userInfo;

/*
 * 登录成功
 */
- (void)loginSuccess:(NSDictionary *)mUserInfo;

/*
 * 退出登录
 */
- (void)logoutSuccess;

/*
 * 更新头像
 */
- (void)updateAvatar:(NSData *)imageData;

- (BOOL)isLogin;
- (NSDictionary *)userInfoDict;
- (NSString *)avatarPath;

- (BOOL)isCollected:(NSInteger)productId;
- (void)addCollectionById:(NSInteger)productId;
- (void)cancelCollectionById:(NSInteger)productId;

@end

NS_ASSUME_NONNULL_END
