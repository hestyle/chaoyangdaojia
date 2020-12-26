//
//  HSNetworkManager.m
//  chaoyangdaojia
//
//  Created by hestyle on 2020/12/25.
//  Copyright © 2020 hestyle. All rights reserved.
//

#import "HSNetworkManager.h"
#import <AFNetworking/AFNetworking.h>

static HSNetworkManager * hsNetworkManager = nil;
static AFHTTPSessionManager *afHttpSessionManager = nil;
static NSMutableDictionary <NSString *, NSString *> *mutableHeaders = nil;

@implementation HSNetworkManager

/**
 * 创建单例对象
 */
+ (HSNetworkManager *)manager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        hsNetworkManager = [[HSNetworkManager alloc] init];
        afHttpSessionManager = [AFHTTPSessionManager manager];
        [afHttpSessionManager setRequestSerializer:[AFJSONRequestSerializer serializer]];
        [afHttpSessionManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [afHttpSessionManager setResponseSerializer:[AFHTTPResponseSerializer serializer]];
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        mutableHeaders = [userDefault dictionaryForKey:@"NETWORK_HEADERS"].mutableCopy;
        if (mutableHeaders == nil) {
            mutableHeaders = [NSMutableDictionary new];
            // 如果未读取到请求信息，则覆盖默认
            mutableHeaders[@"X-AppInfo"] = @"{\"sysVer\":\"6.0.1\",\"appVer\":\"1.3.0\",\"devModel\":\"VIVO X20 Plus\",\"devId\":\"353285002696086\",\"appId\":\"A6095902173353\",\"osType\":\"android\",\"fwPort\":\"app\"}";
            mutableHeaders[@"User-Agent"] = @"Mozilla/5.0 (Linux; Android 6.0.1; VIVO X20 Plus Build/V417IR; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0";
            mutableHeaders[@"X-AppToken"] = @"";
            [userDefault setObject:mutableHeaders.copy forKey:@"NETWORK_HEADERS"];
        }
    });
    return hsNetworkManager;
}

/**
 *处理get请求
 */
- (void)getDataWithUrl:(NSString *)url parameters:(NSDictionary *)paramters success:(Success)success failure:(Failure)failure {
    [afHttpSessionManager GET:url parameters:paramters headers:mutableHeaders.copy progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        // 将返回的结果转成dict
        NSError *error = nil;
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseObject
                                                            options:NSJSONReadingMutableContainers
                                                              error:&error];
        // 更新cookie
        [self updateHeaders:task.response];
        if (error != nil) {
            failure(error);
        } else {
            success(responseDict);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}

/**
 *处理post请求
 */
- (void)postDataWithUrl:(NSString *)url parameters:(NSDictionary *)paramters success:(Success)success failure:(Failure)failure {
    // afHttpSessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    [afHttpSessionManager POST:url parameters:paramters headers:mutableHeaders.copy progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        // 将返回的结果转成dict
        NSError *error = nil;
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseObject
                                                            options:NSJSONReadingMutableContainers
                                                              error:&error];
        // 更新cookie
        [self updateHeaders:task.response];
        if (error != nil) {
            failure(error);
        } else {
            if ([url hasSuffix:@"/userlogin/login"]) {
                // 登录的请求，需要更新access_token
                mutableHeaders[@"X-AppToken"] = responseDict[@"access_token"];
                NSLog(@"X-AppToken: = %@", responseDict[@"access_token"]);
                // 更新userDefault
                NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
                [userDefault setObject:mutableHeaders.copy forKey:@"NETWORK_HEADERS"];
            }
            success(responseDict);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}

/**
 *更新cookie
 */
- (void)updateHeaders:(NSURLResponse *) response{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSDictionary * responseHeaderDict = httpResponse.allHeaderFields;
    // 包含cookie设置，更新缓存
    if ([[responseHeaderDict allKeys] containsObject:@"Set-Cookie"]) {
        NSString *setCookieString = responseHeaderDict[@"Set-Cookie"];
        setCookieString = [setCookieString substringFromIndex:[setCookieString rangeOfString:@"PHPSESSID="].location];
        setCookieString = [setCookieString substringToIndex:[setCookieString rangeOfString:@";"].location];
        mutableHeaders[@"Cookie"] = setCookieString;
        NSLog(@"Set-Cookie: = %@", setCookieString);
        // 更新userDefault
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault setObject:mutableHeaders.copy forKey:@"NETWORK_HEADERS"];
    }
}
@end
