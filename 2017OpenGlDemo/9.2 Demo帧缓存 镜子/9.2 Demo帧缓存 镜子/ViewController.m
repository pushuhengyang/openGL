//
//  ViewController.m
//  9.2 Demo帧缓存 镜子
//
//  Created by xuwenhao on 17/4/28.
//  Copyright © 2017年 Hiniu. All rights reserved.
//

#import "ViewController.h"
#import "WH_GlslDemoHandel.h"


@interface ViewController ()

- (IBAction)switchCLick:(id)sender;
@property(strong,nonatomic)WH_GlslDemoHandel *glHandel;

@property (nonatomic , strong) EAGLContext* mContext;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    GLKView* view = (GLKView *)self.view;
    view.context = self.mContext;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    [EAGLContext setCurrentContext:self.mContext];
    
    _glHandel = [[WH_GlslDemoHandel alloc]init];
    _glHandel.mContext = _mContext;
    _glHandel.glkView = view;
}


-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    [_glHandel draw];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)switchCLick:(id)sender {
    UISwitch *sw = sender;
    _glHandel.isForce = sw.isOn;
}
@end
