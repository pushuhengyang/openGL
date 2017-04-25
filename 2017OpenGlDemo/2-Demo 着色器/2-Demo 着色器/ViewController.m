//
//  ViewController.m
//  2-Demo 着色器
//
//  Created by xuwenhao on 17/3/27.
//  Copyright © 2017年 Hiniu. All rights reserved.
//

#import "ViewController.h"

#import "WH_GLView.h"

@interface ViewController ()
@property (nonatomic , strong) WH_GLView*   myView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.myView = (WH_GLView *)self.view;

    // Do any additional setup after loading the view, typically from a nib.
    
//    WH_GLView *view = [[WH_GLView alloc]initWithFrame:[UIScreen mainScreen].bounds];
//    [self.view addSubview:view];
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
