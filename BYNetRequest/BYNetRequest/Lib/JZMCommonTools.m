//
//  JZMCommonTools.m
//  JZMProject
//
//  Created by 金掌门科技 on 16/7/15.
//  Copyright © 2016年 金掌门科技. All rights reserved.
//

#import "JZMCommonTools.h"

#define fileManager [NSFileManager defaultManager]

//用户信息
static NSString *userDataFileName = @"userData.txt";
static NSString *userDataKey = @"userInfo";
static NSDictionary *userData = nil;

@implementation JZMCommonTools

// 
+ (JZMCommonTools *)shareDataManager {
    static JZMCommonTools *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[JZMCommonTools alloc] init];
    });
    return manager;
}

// 判断当前是否可以连接到网络
+ (BOOL)connectedToNetwork {
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    
    if (!didRetrieveFlags) {
        return NO;
    }
    
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    BOOL nonWifi = flags & kSCNetworkReachabilityFlagsTransientConnection;
    BOOL moveNet = flags & kSCNetworkReachabilityFlagsIsWWAN;
    
    return ((isReachable && !needsConnection) || nonWifi || moveNet) ? YES : NO;
}

// 空对象
+ (BOOL)isEmpty:(id)object {
    if (![object isKindOfClass:[NSString class]]) {
        return YES;
    }
    
    return object == nil || [object isEqualToString:@"null"] || [object isEqualToString:@"(null)"]
    || [object isKindOfClass:[NSNull class]]
    || ([object respondsToSelector:@selector(length)]
        && [(NSData *)object length] == 0)
    || ([object respondsToSelector:@selector(count)]
        && [(NSArray *)object count] == 0);
}

// 空字符串
+ (NSString*)emptyString:(id)object {
    if([self isEmpty:object]){
        return @"";
    }
    return object;
}


//验证手机号码格式
- (BOOL)isMobileNumber:(NSString *)mobileNum {
    /*
     手机号码
     移动: 134[0-8], 135, 136, 137, 138, 139, 150, 151, 158, 159, 182, 187, 188,183
     联通: 130, 131, 132, 152, 155, 156, 185, 186
     电信: 133, 1349, 153, 180, 189
     */
    
    
    NSString * MOBILE = @"@^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    /*
     中国移动: China Mobile
     移动: 134[0-8], 135, 136, 137, 138, 139, 150, 151, 158, 159, 182, 187, 188, 183
     */
    
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[2378])\\d)\\d{7}$";
    /*
     中国联通: China Unicom
     联通: 130, 131, 132, 152, 155, 156, 185, 186
     */
    
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    /*
     中国电信: China Telecom
     电信: 133, 1349, 153, 180, 189
     */
    
    NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
    /*
     大陆地区固定电话及小灵通
     区号: 010, 020, 021, 022, 023, 024, 025, 027, 028, 029
     号码: 七位或八位
     */
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",CT];
    
    if (([regextestmobile evaluateWithObject:mobileNum] == YES)
        || ([regextestcm evaluateWithObject:mobileNum] == YES)
        || ([regextestcu evaluateWithObject:mobileNum] == YES)
        || ([regextestct evaluateWithObject:mobileNum] == YES))
    {
        return YES;
    }else {
        return NO;
    }
}

// 正则表达式判断手机号
+ (BOOL)isPhoneNumber:(NSString *)phoneNumber{
    //NSString *MOBILE = @"^1(3[0-9]|4[0-9]|5[0-9]|8[0-9]|7[0-9])\\d{8}$";
    NSString *MOBILE = @"^1(3|4|5|8|7)[0-9]\\d{8}$";

    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",MOBILE];
    BOOL isMatch = [pred evaluateWithObject:phoneNumber];
    return isMatch;
}

// 正则表达式判断密码
+ (BOOL)isPassword:(NSString *)passWord {
    NSString *passWordRegex = @"^[A-Za-z0-9]{6,14}$";
    NSPredicate *passWordPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",passWordRegex];
    return [passWordPredicate evaluateWithObject:passWord];
}

// 拨打电话
+ (void)callPhoneNumber:(NSString *)phoneNum inView:(UIView *)view {
    NSString *callingPhoneNum = [NSString stringWithFormat:@"tel:%@",phoneNum];
    UIWebView *callWebView;
    if (!callWebView) {
        callWebView = [[UIWebView alloc]init];
        [view addSubview:callWebView];
    }
    [callWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:callingPhoneNum]]];
}

// 从十六进制字符串获取颜色 color:支持@“#123456”、 @“0X123456”、 @“123456”三种格式 默认alpha值为1
+ (UIColor *)colorWithHexString:(NSString *)color {
    return [self colorWithHexString:color alpha:1.0f];
}

//
+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha {
    //删除字符串中的空格
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    if ([cString length] < 6)
    {
        return [UIColor clearColor];
    }
    // strip 0X if it appears
    //如果是0x开头的，那么截取字符串，字符串从索引为2的位置开始，一直到末尾
    if ([cString hasPrefix:@"0X"])
    {
        cString = [cString substringFromIndex:2];
    }
    //如果是#开头的，那么截取字符串，字符串从索引为1的位置开始，一直到末尾
    if ([cString hasPrefix:@"#"])
    {
        cString = [cString substringFromIndex:1];
    }
    if ([cString length] != 6)
    {
        return [UIColor clearColor];
    }
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    //r
    NSString *rString = [cString substringWithRange:range];
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float)r / 255.0f) green:((float)g / 255.0f) blue:((float)b / 255.0f) alpha:alpha];
}

// MD5加密
+ (NSString *)md5String:(NSString *)str {
    const char *passwd = [str UTF8String];
    unsigned char mdc[CC_MD5_DIGEST_LENGTH];
    CC_MD5 (passwd, (CC_LONG) strlen (passwd), mdc);
    NSMutableString *md5String = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i< CC_MD5_DIGEST_LENGTH; i++) {
        [md5String appendFormat:@"%02x", mdc[i]];
    }
    return md5String;
}

// 归档用户信息
+ (void)archiverUserInfoWithDic:(NSDictionary *)dic {
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:dic forKey:userDataKey];
    [archiver finishEncoding];
    [data writeToFile:[[self class] getFilePathWithSuffix:userDataFileName] atomically:YES];
    userData = dic;
}

// 反归档用户信息
+ (NSDictionary *)unArchiverUserInfo {
    if (userData) {
        return userData;
    }else{
        NSMutableData *data = [[NSMutableData alloc] initWithContentsOfFile:[[self class] getFilePathWithSuffix:userDataFileName]];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        NSDictionary *userDataDic = [unarchiver decodeObjectForKey:userDataKey];
        [unarchiver finishDecoding];
        userData = userDataDic;
        return userDataDic;
    }
}

// 删除用户信息
+ (void)removeUserInfoFromSandbox {
    userData = nil;
    NSFileManager *fileMg = [[NSFileManager alloc] init];
    NSError *error = nil;
    [fileMg removeItemAtPath:[[self class] getFilePathWithSuffix:userDataFileName] error:&error];
}

// 获取沙盒路径
+ (NSString *)getFilePathWithSuffix:(NSString *)suffix {
    NSString *sandoxPath = [NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES) firstObject];
    return [sandoxPath stringByAppendingString:suffix];
}

//+ (void)changeActionsheetBottomTitleColor {
//    unsigned int count = 0;
//    Ivar *ivars = class_copyIvarList([UIAlertAction class], &count);
//    for (int i = 0; i < count; i++) {
//        // 取出成员变量
//        // Ivar ivar = *(ivars + i);
//        Ivar ivar = ivars[i];
//        // 打印成员变量名字
//        NSLog(@"%s------%s", ivar_getName(ivar),ivar_getTypeEncoding(ivar));
//    }
//}

@end
