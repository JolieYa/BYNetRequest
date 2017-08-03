//
//  BYNavScaleViewController.m
//  BYNetRequest
//
//  Created by admin on 2017/8/1.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "BYNavScaleViewController.h"
#import "UINavigationBar+Awesome.h"

#define ImageWidth [[UIScreen mainScreen] bounds].size.width
static CGFloat imageH = 200;
static CGFloat navH = 64;

@interface BYNavScaleViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;
@property (nonatomic, strong) UIImageView *headerView;
@property (nonatomic, strong) UIImage *shadowImage;

@end

@implementation BYNavScaleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:nil];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:nil];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.contentInset = UIEdgeInsetsMake(imageH, 0, 0, 0);
    [self.view addSubview:self.tableView];
    
    self.headerView = [[UIImageView alloc]init];
    self.headerView.frame = CGRectMake(0, -imageH, ImageWidth, imageH);
    self.headerView.image = [UIImage imageNamed:@"IMG_0106.JPG"];
    self.headerView.contentMode = UIViewContentModeScaleAspectFill;
    [self.tableView addSubview:self.headerView];
    [self.tableView insertSubview:self.headerView atIndex:0];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.shadowImage = self.navigationController.navigationBar.shadowImage;
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    
    CGFloat offsetY = self.tableView.contentOffset.y;
    [self changeNavAlphaWithConnentOffset:offsetY];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.navigationController.navigationBar lt_reset];
    self.navigationController.navigationBar.shadowImage = self.shadowImage;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 50;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"XXXX";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *vc = [[UIViewController alloc]init];
    vc.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offsetY = scrollView.contentOffset.y;
    NSLog(@"%f",offsetY);
    
    if (offsetY < -imageH) {
        NSLog(@"开始改变");
        CGRect f = self.headerView.frame;
        f.origin.y = offsetY;
        f.size.height =  -offsetY;
        self.headerView.frame = f;
    }
    
    [self changeNavAlphaWithConnentOffset:offsetY];
}

-(void)changeNavAlphaWithConnentOffset:(CGFloat)offsetY
{
    UIColor *color = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1];
    if (offsetY > -navH * 2 ) {
        NSLog(@"渐渐不透明");
        CGFloat alpha = MIN(1, 1 - ((-navH * 2 + navH - offsetY) / navH));
        [self.navigationController.navigationBar lt_setBackgroundColor:[color colorWithAlphaComponent:alpha]];
        self.title = @"个人主页";
    }
    else {
        NSLog(@"渐渐透明");
        [self.navigationController.navigationBar lt_setBackgroundColor:[color colorWithAlphaComponent:0]];
        self.title = @"";
    }
}


@end
