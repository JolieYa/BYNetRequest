//
//  ViewController.m
//  BYNetRequest
//
//  Created by admin on 2017/8/1.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "ViewController.h"
#import "JZMDataService.h"
#import "JZMCommonTools.h"

#import "MJExtension.h"

@interface ViewController ()

@property (nonatomic, strong) UILabel *label;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadData];
    
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor redColor];
    label.frame = (CGRect){20, 100, 300, 300};
    label.numberOfLines = 0;
    [self.view addSubview:label];
    _label = label;
}



-(void)loadData
{
    NSDictionary *paramtersDict = @{@"phone":@"13168749865",
                                    @"password":[JZMCommonTools md5String:@"12345678"]
                                    };
    
    [JZMDataService requestWithURL:@"v1/auth/login"
                       requestType:XPRequestMethodPost
                           typeUrl:@"other"
                            params:paramtersDict
                           success:^(NSDictionary *responseObject) {
                               if ([[responseObject objectForKey:@"state"] integerValue]==200) {
                                   NSDictionary*data=[responseObject objectForKey:@"data"];
                                   if (data && data.count) {
                                       NSString *companyName = [data objectForKey:@"companyName"];
                                       _label.text = companyName;
                                   }
                               } else {
                                   NSString *msg = [responseObject objectForKey:@"msg"];
                                   _label.text = msg;
                               }
                           } failure:^(NSError *error) {
                               _label.text = @"请求失败";
                           }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
