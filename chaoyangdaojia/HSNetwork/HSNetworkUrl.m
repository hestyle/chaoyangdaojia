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
// 关于我们
NSString * const kGetAboutUsInfo = @"http://app.sunnysct.cn/api/home/userlogin/aboutus";
// 获取用户协议
NSString * const kGetUserPolicy = @"http://app.sunnysct.cn/api/home/userlogin/xieyi";
// 获取会员说明
NSString * const kGetMemberExplain = @"http://app.sunnysct.cn/api/home/userinfo/membergz";
// 获取积分兑换list
NSString * const kGetExchangeBalanceList = @"http://app.sunnysct.cn/api/home/score/dhlist";
// 积分兑换
NSString * const kExchangeMoneyUrl = @"http://app.sunnysct.cn/api/home/score/duihuan";
// 获取商家店铺by page
NSString * const kGetShopsByPageUrl = @"http://app.sunnysct.cn/api/home/dian/getlist";
// 获取商家店铺详细信息
NSString * const kGetShopDetailByIdUrl = @"http://app.sunnysct.cn/api/home/dian/show";
// 获取店铺评论信息（需要店铺id、page）
NSString * const kGetShopCommentUrl = @"http://app.sunnysct.cn/api/home/shop/pinlunlist";
// 获取店铺商品（需要店铺id、page）
NSString * const kGetShopProductListUrl = @"http://app.sunnysct.cn/api/home/shop/lists";
// 获取首页数据
NSString * const kGetIndexDataUrl = @"http://app.sunnysct.cn/api/home/index/index";
// 获取首页推荐商品数据
NSString * const kGetIndexProductDataUrl = @"http://app.sunnysct.cn/api/home/index/index_list";
// 获取限时抢购商品数据
NSString * const kGetQiangGouProductDataUrl = @"http://app.sunnysct.cn/api/home/index/qianggou";
// 获取拼团商品数据
NSString * const kGetPinTuanProductDataUrl = @"http://app.sunnysct.cn/api/home/index/pintuan";
// 获取banner数据
NSString * const kGetBannerDetailDataUrl = @"http://app.sunnysct.cn/api/home/index/banner_show";
// 获取CategoryDetail数据
NSString * const kGetCategoryDetailDataUrl = @"http://app.sunnysct.cn/api/home/shop/lists";
// 获取ProductDetail数据
NSString * const kGetProductDetailDataUrl = @"http://app.sunnysct.cn/api/home/shop/show";
// 获取comment list数据
NSString * const kGetProductCommentDataUrl = @"http://app.sunnysct.cn/api/home/shop/pinlunlist";
// 获取product 规格、库存数据
NSString * const kGetProductSpecificationUrl = @"http://app.sunnysct.cn/api/home/shop/getinfo";
// 更新product收藏状态
NSString * const kUpdateProductCollectionStatusUrl = @"http://app.sunnysct.cn/api/home/shoucang/addcan";
// 获取收藏的Product
NSString * const kGetProductCollectionListUrl = @"http://app.sunnysct.cn/api/home/shoucang/getlist";
// 添加商品到购物车
NSString * const kAddProductToCartUrl = @"http://app.sunnysct.cn/api/home/cart/add";
// 获取购物车数据
NSString * const kGetCartDataUrl = @"http://app.sunnysct.cn/api/home/cart/carlist";
// 修改购物车中某商品的数量数据
NSString * const kEditCartProductBuyNumUrl = @"http://app.sunnysct.cn/api/home/cart/edit_num";
// 删除购物车中的某些商品
NSString * const kDelCartProductUrl = @"http://app.sunnysct.cn/api/home/cart/del";
// 获取当前购物车中的商品数
NSString * const kGetCartProductCountUrl = @"http://app.sunnysct.cn/api/home/cart/getcartnum";

@implementation HSNetworkUrl

@end
