//
//  HSNetworkManager.h
//  chaoyangdaojia
//
//  Created by hestyle on 2020/12/25.
//  Copyright © 2020 hestyle. All rights reserved.
//

#import <Foundation/Foundation.h>

//block回调传值
/**
 * 请求成功回调json数据
 *
 * @param responseDict dict串
 */
typedef void(^Success)(NSDictionary *responseDict);

/**
 *  请求失败回调错误信息
 *
 *  @param error error错误信息
 */
typedef void(^Failure)(NSError *error);

NS_ASSUME_NONNULL_BEGIN

@interface HSNetworkManager : NSObject
/**
 *  单例模式
 */
+ (HSNetworkManager *)shareManager;

/**
 *  GET请求
 *
 *  @param url       NSString 请求url
 *  @param paramters NSDictionary 参数
 *  @param success   void(^Success)(id json)回调
 *  @param failure   void(^Failure)(NSError *error)回调
 */
- (void)getDataWithUrl:(NSString *)url parameters:(NSDictionary *)paramters success:(Success)success failure:(Failure)failure;

/**
 *  POST请求
 *
 *  @param url       NSString 请求url
 *  @param paramters NSDictionary 参数
 *  @param success   void(^Success)(id json)回调
 *  @param failure   void(^Failure)(NSError *error)回调
 */
- (void)postDataWithUrl:(NSString *)url parameters:(NSDictionary *)paramters success:(Success)success failure:(Failure)failure;

/**
 *  文件上传
 *
 *  @param url       NSString 请求url
 *  @param paramters NSDictionary 参数
 *  @param success   void(^Success)(id json)回调
 *  @param failure   void(^Failure)(NSError *error)回调
 */
- (void)uploadFileWithUrl:(NSString *)url parameters:(NSDictionary *)paramters fileDataDict:(NSDictionary *)fileDataDict success:(Success)success failure:(Failure)failure;

/*
 * 获取token
 */
- (NSString *)getXAppToken;
/*
 * 移除token
 */
- (void)removeXAppToken;

@end

NS_ASSUME_NONNULL_END
