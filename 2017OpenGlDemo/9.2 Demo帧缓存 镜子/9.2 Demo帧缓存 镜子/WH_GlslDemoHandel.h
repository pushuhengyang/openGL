//
//  WH_GlslDemoHandel.h
//  9-demo 帧缓存
//
//  Created by xuwenhao on 17/4/21.
//  Copyright © 2017年 Hiniu. All rights reserved.
// 

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
@interface WH_GlslDemoHandel : NSObject

@property (nonatomic , strong) EAGLContext* mContext;
@property (strong,nonatomic) GLKView *glkView;

@property (assign,nonatomic) BOOL isForce;


-(void)draw;

@end

//两种方式都试试 看哪种好
