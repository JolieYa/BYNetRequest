//
//  JZMCommonTools.h
//  JZMProject
//
//  Created by 金掌门科技 on 16/7/15.
//  Copyright © 2016年 金掌门科技. All rights reserved.
//

#import <Foundation/Foundation.h>
//需要用到UIKit框架里的文件
#import <UIKit/UIKit.h>

//针对判断是否有网络需要的头文件
#import <CommonCrypto/CommonHMAC.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <netdb.h>
#import <arpa/inet.h>

@interface JZMCommonTools : NSObject

//
+ (JZMCommonTools *)shareDataManager;

// 判断当前是否可以连接到网络
+ (BOOL)connectedToNetwork;

// 空对象
+ (BOOL)isEmpty:(id)object;

// 空字符串
+ (NSString *)emptyString:(id)object;

- (BOOL)isMobileNumber:(NSString *)mobileNum;

// 正则表达式判断手机号
+ (BOOL)isPhoneNumber:(NSString *)phoneNumber;

// 正则表达式判断密码
+ (BOOL)isPassword:(NSString *)passWord;

// 拨打电话
+ (void)callPhoneNumber:(NSString *)phoneNum inView:(UIView *)view;

// 从十六进制字符串获取颜色 color:支持@“#123456”、 @“0X123456”、 @“123456”三种格式
+ (UIColor *)colorWithHexString:(NSString *)color;

//
+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha;

// MD5加密
+ (NSString *)md5String:(NSString *)str;

//归档用户信息
+ (void)archiverUserInfoWithDic:(NSDictionary *)dic;

//反归档用户信息
+ (NSDictionary *)unArchiverUserInfo;

//删除用户信息
+ (void)removeUserInfoFromSandbox;

//+ (void)changeActionsheetBottomTitleColor;

@end
