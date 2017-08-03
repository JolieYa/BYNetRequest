//
//  JZMDataService.m
//  JZMProject
//
//  Created by 金掌门科技 on 16/9/29.
//  Copyright © 2016年 金掌门科技. All rights reserved.
//

#import "JZMDataService.h"

// 外网
#define kAPIBaseOtherUrlString @"https://www.jzmsoft.com:8082/yunzhubao/"//业务逻辑

//#define kAPIBaseOtherUrlString @"http://api2.juheapi.com"
//#define kAPIBaseOtherUrlString @""

@interface JZMDataService()

@property(nonatomic, retain)AFHTTPSessionManager *manager;
@end
@implementation JZMDataService

+ (AFHTTPSessionManager *)shareManager {
    
    static AFHTTPSessionManager *manager = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^(void){
        
        // 1.证书
        // 验证证书是否在信任列表中，然后再对比服务端证书和客户端证书是否一致
//        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
        //是否允许使用自签名证书
//        securityPolicy.allowInvalidCertificates = YES;
        //是否需要验证域名，默认YES
//        [securityPolicy setValidatesDomainName:NO];
        
        // 2.manager
        manager = [AFHTTPSessionManager manager];
//        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//        manager.securityPolicy = securityPolicy;
        //设置超时
        [manager.requestSerializer willChangeValueForKey:@"timeoutinterval"];
        manager.requestSerializer.timeoutInterval = 60.f;
        [manager.requestSerializer didChangeValueForKey:@"timeoutinterval"];
        manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringCacheData;
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/xml",@"text/xml",@"text/plain",@"application/json",nil];
        
        
//        manager.securityPolicy.validatesCertificateChain = NO;
    });
    return manager;
}

+ (instancetype)share
{
    static JZMDataService *service = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^(void){
        
        service = [[self alloc] init];
    });
    return service;
}

- (void)initManager
{
    __weak typeof(self) weakSelf = self;
    [_manager setSessionDidReceiveAuthenticationChallengeBlock:^NSURLSessionAuthChallengeDisposition(NSURLSession *session, NSURLAuthenticationChallenge *challenge, NSURLCredential *__autoreleasing *_credential) {
        
        SecTrustRef serverTrust = [[challenge protectionSpace] serverTrust];
        
        /**
         *  导入多张CA证书
         */
        NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"ca" ofType:@"cer"];//自签名证书
        
        NSData* caCert = [NSData dataWithContentsOfFile:cerPath];
        NSArray *cerArray = @[caCert];
        weakSelf.manager.securityPolicy.pinnedCertificates = cerArray;
        SecCertificateRef caRef = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)caCert);
        
        NSCAssert(caRef != nil, @"caRef is nil");
        NSArray *caArray = @[(__bridge id)(caRef)];
        NSCAssert(caArray != nil, @"caArray is nil");
        
        OSStatus status = SecTrustSetAnchorCertificates(serverTrust, (__bridge CFArrayRef)caArray);
        
        SecTrustSetAnchorCertificatesOnly(serverTrust,NO);
        NSCAssert(errSecSuccess == status, @"SecTrustSetAnchorCertificates failed");
        NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
        
        __autoreleasing NSURLCredential *credential = nil;
        if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
            if ([weakSelf.manager.securityPolicy evaluateServerTrust:challenge.protectionSpace.serverTrust forDomain:challenge.protectionSpace.host]) {
                credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
                if (credential) {
                    disposition = NSURLSessionAuthChallengeUseCredential;
                } else {
                    disposition = NSURLSessionAuthChallengePerformDefaultHandling;
                }
            } else {
                disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
            }
        } else {
            disposition = NSURLSessionAuthChallengePerformDefaultHandling;
        }
        return disposition;
    }];
}

-(NSString *)deviceWANIPAddress:(NSString *)url
{
    //    NSURL *ipURL = [NSURL URLWithString:@"http://ip.taobao.com/service/getIpInfo.php?ip=myip"];
    NSURL *ipURL = [NSURL URLWithString:url];
    NSData *data = [NSData dataWithContentsOfURL:ipURL];
    NSDictionary *ipDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    return (ipDic[@"data"][@"ip"] ? ipDic[@"data"][@"ip"] : @"");
}


- (void)requestWithURL:(NSString *)url
                 image:(UIImage *)image
           requestType:(XPRequestMethod)requestType
               typeUrl:(NSString *)typeUrl
                params:(NSDictionary *)params
               success:(Success)success
               failure:(Failure)failure
{
    _manager = [[self class] shareManager];
    
    if (image == nil) {
        _manager.responseSerializer = [AFJSONResponseSerializer serializer];
        _manager.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    else {
        _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        _manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    }
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@", kAPIBaseOtherUrlString, url];
    NSString *urlString = [requestUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    if (requestType == XPRequestMethodGet) {
        [_manager GET:urlString
           parameters:params
              success:^(NSURLSessionDataTask *task, id responseObject) {
                  if ([responseObject isKindOfClass:[NSDictionary class]]) {
                      success(responseObject);
                  } else {
//                      [MBProgressHUD showError:@"数据类型有问题"];
                  }
              } failure:^(NSURLSessionDataTask *task, NSError *error) {
                  failure(error);
              }];
    }
    else if(requestType == XPRequestMethodPost) {
        if (image == nil) {
            [_manager POST:urlString
                parameters:params
                   success:^(NSURLSessionDataTask *task, id responseObject) {
                       if ([responseObject isKindOfClass:[NSDictionary class]]) {
                           success(responseObject);
                       } else {
//                           [MBProgressHUD showError:@"数据类型有问题"];
                       }
                   } failure:^(NSURLSessionDataTask *task, NSError *error) {
                       failure(error);
                   }];
        } else {
            NSData *imgData;
            if (UIImagePNGRepresentation(image)) {
                imgData = UIImagePNGRepresentation(image);
            } else {
                imgData = UIImageJPEGRepresentation(image, 0.5);
            }
            
            [_manager POST:urlString
                parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                    if (imgData != nil) {
                        if (UIImagePNGRepresentation(image)) {
                            [formData appendPartWithFileData:imgData name:@"file" fileName:@"file.png" mimeType:@"image/png"];
                        } else {
                            [formData appendPartWithFileData:imgData name:@"file" fileName:@"file.jpg" mimeType:@"image/jpg"];
                        }
                    }
                } success:^(NSURLSessionDataTask *task, id responseObject) {
                    id responseData = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
                    if ([responseData isKindOfClass:[NSDictionary class]]) {
                        success(responseData);
                    } else {
//                        [MBProgressHUD showError:@"数据类型有问题"];
                    }
                } failure:^(NSURLSessionDataTask *task, NSError *error) {
                    failure(error);
                }];
        }
    }
    else if (requestType == XPRequestMethodPut) {
        [_manager PUT:urlString
           parameters:params
              success:^(NSURLSessionDataTask *task, id responseObject) {
                  if ([responseObject isKindOfClass:[NSDictionary class]]) {
                      success(responseObject);
                  } else {
//                      [MBProgressHUD showError:@"数据类型有问题"];
                  }
              } failure:^(NSURLSessionDataTask *task, NSError *error) {
                  failure(error);
              }];
    }
}

// 其它请求方式
+ (void)requestWithURL:(NSString *)url
           requestType:(XPRequestMethod)requestType
               typeUrl:(NSString*)typeUrl
                params:(NSDictionary *)params
               success:(Success)success
               failure:(Failure)failure
{
    [[self share] requestWithURL:url
                           image:nil
                     requestType:requestType
                         typeUrl:typeUrl
                          params:params
                         success:success
                         failure:failure];
}

// 图片请求方式
+ (void)requestWithURL:(NSString *)url
                 image:(UIImage *)image
               typeUrl:(NSString*)typeUrl
                params:(NSDictionary *)params
               success:(Success)success
               failure:(Failure)failure
{
    [[self share] requestWithURL:url
                           image:image
                     requestType:XPRequestMethodPost
                         typeUrl:typeUrl
                          params:params
                         success:success
                         failure:failure];

}

#pragma mark - 可能不要

//<key>NSAppTransportSecurity</key>
//<dict>
//<key>NSAllowsArbiraryLoads</key>
//<true/>
//</dict>



//<key>NSAppTransportSecurity</key>
//<dict>
//<key>NSExceptionDomains</key>
//<dict>
//<key>baidu.com</key>
//<dict>
//<key>NSIncludesSubdomains</key>
//<true/>
//<key>NSExceptionRequiresForwardSecrecy</key>
//<false/>
//<key>NSExceptionAllowsInsecureHTTPLoads</key>
//<true/>
//</dict>
//</dict>
//</dict>


@end

