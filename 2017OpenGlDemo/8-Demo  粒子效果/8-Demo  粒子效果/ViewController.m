//
//  ViewController.m
//  8-Demo  粒子效果
//
//  Created by xuwenhao on 17/4/7.
//  Copyright © 2017年 Hiniu. All rights reserved.
//

#import "ViewController.h"
#import "WH_GlslHanderBall.h"


@interface ViewController ()

@property (nonatomic , strong) EAGLContext* mContext;
@property(strong,nonatomic)WH_GlslHanderBall *glslHander;
@property (strong,nonatomic) GLKBaseEffect *mBaseEffer;

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
    
    NSString *path = [[NSBundle bundleForClass:[self class]]
                      pathForResource:@"ball" ofType:@"png"];
    NSAssert(nil != path, @"ball texture image not found");
    NSError *error = nil;
    GLKTextureInfo *ballParticleTexture = [GLKTextureLoader
                                textureWithContentsOfFile:path
                                options:nil
                                error:&error];
    
    
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    _glslHander = [[WH_GlslHanderBall alloc]init];
    _glslHander.texture2d0 = ballParticleTexture;
    
    
}

-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    glClearColor(0.3, 0.3, 0.3, 1);
 
    [_glslHander draw];
    
}



@end
