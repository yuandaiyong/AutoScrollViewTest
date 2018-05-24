//
//  ViewController.m
//  AutoScrollViewTest
//
//  Created by Clover on 2018/5/14.
//  Copyright © 2018年 Clover. All rights reserved.
//

#import "ViewController.h"
#import "AutoScrollView.h"
@interface ViewController ()

@property (nonatomic,strong) AutoScrollView         *scrollView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    self.scrollView = [[AutoScrollView alloc] initWithFrame:CGRectMake(0, 20, CGRectGetWidth(rect), 300)];
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.showTitle = YES;
    [self.view addSubview:self.scrollView];
    
    NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:0];
    for(int i = 0;i < 6;i ++) {
        ScrollImageModel *image = [[ScrollImageModel alloc] init];
        image.image_path = [NSString stringWithFormat:@"1-%d.jpg",i + 1];
        image.title = [NSString stringWithFormat:@"图片 - %d",i + 1];
        [list addObject:image];
    }
    self.scrollView.images = [[NSArray alloc] initWithArray:list];
    self.scrollView.scrollInterval = 3.;
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.scrollView.frame), 100, 40)];
    [btn setTitle:@"刷新" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    [btn addTarget:self action:@selector(refresh) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)refresh {
    NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:0];
    for(int i = 0;i < 4;i ++) {
        ScrollImageModel *image = [[ScrollImageModel alloc] init];
        image.image_path = [NSString stringWithFormat:@"2-%d.jpg",i + 1];
        image.title = [NSString stringWithFormat:@"图片 - %d",i + 1];
        [list addObject:image];
    }
    self.scrollView.images = [[NSArray alloc] initWithArray:list];
    [self.scrollView reloadImages];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
