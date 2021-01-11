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
+ (HSNetworkManager *)shareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        hsNetworkManager = [[HSNetworkManager alloc] init];
        afHttpSessionManager = [AFHTTPSessionManager manager];
        
        AFSecurityPolicy * securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        //allowInvalidCertificates 是否允许无效证书（也就是自建的证书），默认为NO
        //如果是需要验证自建证书，需要设置为YES
        securityPolicy.allowInvalidCertificates = YES;
        //validatesDomainName 是否需要验证域名，默认为YES；
        //假如证书的域名与你请求的域名不一致，需把该项设置为NO
        //主要用于这种情况：客户端请求的是子域名，而证书上的是另外一个域名。因为SSL证书上的域名是独立的，假如证书上注册的域名是www.google.com，那么mail.google.com是无法验证通过的；当然，有钱可以注册通配符的域名*.google.com，但这个还是比较贵的。
        securityPolicy.validatesDomainName = NO;
        //validatesCertificateChain 是否验证整个证书链，默认为YES
        //设置为YES，会将服务器返回的Trust Object上的证书链与本地导入的证书进行对比，这就意味着，假如你的证书链是这样的：
        //GeoTrust Global CA
        //    Google Internet Authority G2
        //        *.google.com
        //那么，除了导入*.google.com之外，还需要导入证书链上所有的CA证书（GeoTrust Global CA, Google Internet Authority G2）；
        //如是自建证书的时候，可以设置为YES，增强安全性；假如是信任的CA所签发的证书，则建议关闭该验证；
        //securityPolicy.validatesCertificateChain = NO;
        [afHttpSessionManager setSecurityPolicy:securityPolicy];
        
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
 *上传图片
 */
- (void)uploadFileWithUrl:(NSString *)url parameters:(NSDictionary *)paramters fileDataDict:(NSDictionary *)fileDataDict success:(Success)success failure:(Failure)failure {
    [afHttpSessionManager POST:url parameters:nil headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        // 将参数放入formData
        for (NSString *key in paramters) {
            NSString *valueString = paramters[key];
            [formData appendPartWithFileData:[valueString dataUsingEncoding:NSUTF8StringEncoding] name:key fileName:@"" mimeType:@"text/plain; charset=UTF-8"];
        }
        // 将文件内容放入formData
        [formData appendPartWithFileData:fileDataDict[@"fileData"] name:@"file" fileName:fileDataDict[@"fileName"] mimeType:fileDataDict[@"mimeType"]];
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject == nil) {
            success(nil);
        } else {
            // 将返回的结果转成dict
            NSError *error = nil;
            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&error];
            if (error != nil) {
                success(nil);
            } else {
                success(responseDict);
            }
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

/**
*  获取token
*/
- (NSString *)getXAppToken {
    return mutableHeaders[@"X-AppToken"];
}

/*
 * 移除token
 */
- (void)removeXAppToken {
    [mutableHeaders removeObjectForKey:@"X-AppToken"];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:mutableHeaders.copy forKey:@"NETWORK_HEADERS"];
}
@end
