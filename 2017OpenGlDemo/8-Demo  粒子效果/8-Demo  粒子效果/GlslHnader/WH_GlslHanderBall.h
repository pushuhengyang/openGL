//
//  WH_GlslHanderBall.h
//  8-Demo  粒子效果
//
//  Created by xuwenhao on 17/4/12.
//  Copyright © 2017年 Hiniu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

typedef struct
{
    GLKVector3 emissionPosition;//位置
    GLKVector2 size;//大小
    GLKVector2 emissionTimeAndLife;//第一个是当前寿命 第二个是最终时间
}
AGLSL_Attributes;


typedef enum : NSUInteger {
    AttPoisition = 0,
    AttSize,
    AttTimeLife,
} GlslVerAtter;


@interface WH_GlslHanderBall : NSObject

@property (strong,nonatomic) GLKTextureInfo *texture2d0;

-(void)draw;
@end
