//
//  HSUserAccountManger.m
//  chaoyangdaojia
//
//  Created by hestyle on 2021/1/4.
//  Copyright © 2021 hestyle. All rights reserved.
//

#import "HSUserAccountManger.h"
#import "HSNetwork.h"

@interface HSUserAccountManger ()

@property (nonatomic, strong) NSMutableSet *collectionSet;

@end

/* 全局单例 */
static HSUserAccountManger *userAccountManger = nil;
static NSString * const mUserInfoKey = @"USER_INFO";
static NSString * const mAvatarFilePath = @"/Documents/avatar.png";
static NSString * const mAvatarKey = @"AVATAR_PATH";
static NSString * const mCollectionKey = @"COLLECTION";

@implementation HSUserAccountManger

+ (HSUserAccountManger *)shareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        userAccountManger = [[HSUserAccountManger alloc] init];
        // 读取收藏
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSArray *collectionArray = [userDefaults objectForKey:mCollectionKey];
        if (collectionArray == nil) {
            userAccountManger.collectionSet = [NSMutableSet new];
        } else {
            userAccountManger.collectionSet = [[NSMutableSet alloc] initWithArray:collectionArray];
        }
        // 读取app-token，验证是否登录了
        HSNetworkManager *networkManager = [HSNetworkManager shareManager];
        NSString *xAppTokenString = [networkManager getXAppToken];
        if (xAppTokenString == nil || [xAppTokenString length] == 0) {
            [userAccountManger notLoginInfoSet];
        } else {
            [userAccountManger hadLoginInfoSet];
        }
    });
    return userAccountManger;
}

- (void)notLoginInfoSet {
    isLogin = NO;
    userInfoDict = nil;
    avatarPath = nil;
}

- (void)hadLoginInfoSet {
    isLogin = YES;
    [self readUserInfoFromCache];
}

/*
 * 刷新userInfo
 */
- (void)refreshUserInfoFromNetWork {
    HSNetworkManager *manager = [HSNetworkManager shareManager];
    __weak __typeof__(self) weakSelf = self;
    [manager postDataWithUrl:kGetUserInfoUrl parameters:@{} success:^(NSDictionary *responseDict) {
        // 账号信息获取成功
        if ([responseDict[@"errcode"] isEqual:@(0)]) {
            [weakSelf updateUserInfo:responseDict[@"uinfo"]];
        }
        NSLog(@"接口 url = %@ 返回数据 responseDict = %@", kGetUserInfoUrl, responseDict);
    } failure:^(NSError *error) {
        NSLog(@"url = %@, error = %@", kGetUserInfoUrl, error);
    }];
}

/*
 * 更新UserInfo
 */
- (void)updateUserInfo:(NSDictionary *)mUserInfoDict {
    userInfoDict = [mUserInfoDict copy];
    avatarPath = mAvatarFilePath;
    [self writeUserInfoToCache];
}

/*
 * 登录成功
 */
- (void)loginSuccess:(NSDictionary *)mUserInfo {
    isLogin = YES;
    [self updateUserInfo:mUserInfo];
}

/*
 * 退出登录
 */
- (void)logoutSuccess {
    isLogin = NO;
    userInfoDict = nil;
    avatarPath = nil;
    // 移除token
    HSNetworkManager *networkManager = [HSNetworkManager shareManager];
    [networkManager removeXAppToken];
    // 删除userInfo缓存
    [self writeUserInfoToCache];
}

/*
 * 从cache读取userInfo
 */
- (void)readUserInfoFromCache {
    // 1、读取账号缓存
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    userInfoDict = [userDefaults objectForKey:mUserInfoKey];
    if (userAccountManger.userInfoDict == nil) {
        // 未读取到则访问网络
        [userAccountManger refreshUserInfoFromNetWork];
    } else {
        NSLog(@"读取userInfo缓存 userInfoDict = %@", self.userInfoDict);
    }
    // 2、读取头像路径
    avatarPath = [userDefaults objectForKey:mAvatarKey];
}

/*
 * 更新本地userInfo缓存
 */
- (void)writeUserInfoToCache {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if (userInfoDict != nil) {
        NSMutableDictionary *realUserInfoDict = [NSMutableDictionary new];
        // 挑选value ！= nil的key/value
        for (NSString *keyString in [userInfoDict allKeys]) {
            if (![userInfoDict[keyString] isEqual:[NSNull null]]) {
                realUserInfoDict[keyString] = self.userInfoDict[keyString];
            }
        }
        [userDefault setObject:realUserInfoDict.copy forKey:mUserInfoKey];
        NSLog(@"更新账号信息缓存，userInfoDict = %@", realUserInfoDict);
    } else {
        [userDefault removeObjectForKey:mUserInfoKey];
    }
    // 更新头像缓存
    if (avatarPath != nil && [[userInfoDict allKeys] containsObject:@"avatar"] && ![userInfoDict[@"avatar"] isEqual:[NSNull null]]) {
        // 缓存图片到本地
        NSURL *avatarUrl = [NSURL URLWithString:self.userInfoDict[@"avatar"]];
        NSData *avatarData = [NSData dataWithContentsOfURL:avatarUrl];
        NSString *path_sandox = NSHomeDirectory();
        NSString *newPath = [path_sandox stringByAppendingPathComponent:mAvatarFilePath];
        [avatarData writeToFile:newPath atomically:YES];
        [userDefault setObject:mAvatarFilePath forKey:mAvatarKey];
    } else {
        avatarPath = nil;
        [userDefault removeObjectForKey:mAvatarKey];
    }
}

- (void)saveCollectionCache {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *collectionArray = [self.collectionSet allObjects];
    [userDefaults setValue:collectionArray forKey:mCollectionKey];
}

- (BOOL)isLogin {
    return isLogin;
}
- (NSDictionary *)userInfoDict {
    return [userInfoDict copy];
}
- (NSString *)avatarPath {
    return avatarPath;
}
- (void)setLogin:(BOOL)mIsLogin {
    isLogin = mIsLogin;
}
- (void)updateAvatar:(NSData *)imageData {
    NSString *path_sandox = NSHomeDirectory();
    NSString *newPath = [path_sandox stringByAppendingPathComponent:mAvatarFilePath];
    [imageData writeToFile:newPath atomically:YES];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:mAvatarFilePath forKey:mAvatarKey];
    avatarPath = mAvatarFilePath;
}

- (BOOL)isCollected:(NSInteger)productId {
    if ([self.collectionSet containsObject:@(productId)]) {
        return YES;
    } else {
        return NO;
    }
}
- (void)addCollectionById:(NSInteger)productId {
    if (![self.collectionSet containsObject:@(productId)]) {
        [self.collectionSet addObject:@(productId)];
        [self saveCollectionCache];
    }
}
- (void)cancelCollectionById:(NSInteger)productId {
    if ([self.collectionSet containsObject:@(productId)]) {
        [self.collectionSet removeObject:@(productId)];
        [self saveCollectionCache];
    }
}
@end
