//
//  JZMDataService.h
//  JZMProject
//
//  Created by 金掌门科技 on 16/9/29.
//  Copyright © 2016年 金掌门科技. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <AFNetworking/AFNetworking.h>
#import "AFNetworking.h"

//typedef void(^SuccessBlock)(AFHTTPRequestOperation *operation, id responseObject);
//typedef void(^FailureBlock)(AFHTTPRequestOperation *operation, NSError *error);

typedef enum : NSInteger {
    XPRequestMethodGet,
    XPRequestMethodPost,
    XPRequestMethodPut
} XPRequestMethod;

typedef void(^Success)(NSDictionary *responseObject);
typedef void(^Failure)(NSError *error);

@interface JZMDataService : NSObject

//@property(nonatomic,assign)XPRequestMethod requestMethod;
//- (AFHTTPRequestOperation *)requestWithFunction:(NSString *)function
//                                    requestType:(NSString*)requestUrl
//                                         params:(NSDictionary *)params
//                                   successBlock:(SuccessBlock)successBlock
//                                   failureBlock:(FailureBlock)failureBlock;

//- (AFHTTPRequestOperation *)requestWithFunction:(NSString *)function
//                                    requestType:(NSString*)requestUrl
//                                          image:(UIImage *)image
//                                         params:(NSDictionary *)params
//                                   successBlock:(SuccessBlock)successBlock
//                                   failureBlock:(FailureBlock)failureBlock;

#pragma mark - 最新

// 其它请求方式
+ (void)requestWithURL:(NSString *)url
           requestType:(XPRequestMethod)requestType
               typeUrl:(NSString*)typeUrl
                params:(NSDictionary *)params
               success:(Success)success
               failure:(Failure)failure;

// 图片请求方式
+ (void)requestWithURL:(NSString *)url
                 image:(UIImage *)image
               typeUrl:(NSString*)typeUrl
                params:(NSDictionary *)params
               success:(Success)success
               failure:(Failure)failure;

@end
