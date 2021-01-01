//
//  HSFriendBirthday.h
//  chaoyangdaojia
//
//  Created by hestyle on 2020/12/31.
//  Copyright © 2020 hestyle. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HSFriendBirthday : NSObject

@property (nonatomic) NSInteger id;
/* userId */
@property (nonatomic) NSInteger uid;
/* 亲友名称 */
@property (nonatomic, strong) NSString *name;
/* 尊称 */
@property (nonatomic, strong) NSString *zunchen;
/* 生日，只含月、日 */
@property (nonatomic, strong) NSString *birthday;
/* 生日，含年、月、日 */
@property (nonatomic, strong) NSString *txbirthday;
/* 添加时间 */
@property (nonatomic) NSInteger addtime;
/* 生日提醒类型     1、2、3 */
@property (nonatomic) NSInteger txtype;
/* 提醒类型字符串 生日当前提醒、生日前2天提醒、生日前1周提醒 */
@property (nonatomic, strong) NSString *txtype_str;

@end

NS_ASSUME_NONNULL_END
