//
//  WH_GlslHander.h
//  8-Demo  粒子效果
//
//  Created by xuwenhao on 17/4/7.
//  Copyright © 2017年 Hiniu. All rights reserved.
//  渲染glsl shading 语言的类

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
//重力加速度
extern const GLKVector3 AGLKDefaultGravity;

typedef struct
{
    GLKVector3 emissionPosition;
    GLKVector3 emissionVelocity;
    GLKVector3 emissionForce;
    GLKVector2 size;
    GLKVector2 emissionTimeAndLife;
}
AGLKParticleAttributes;


@interface WH_GlslHander : NSObject

@property (nonatomic, assign) GLKVector3 gravity;
@property (strong, nonatomic, readonly) GLKEffectPropertyTexture
*texture2d0;
@property (strong, nonatomic, readonly) GLKEffectPropertyTransform
*transform;

//添加位置 速度  大小 多长时间消失
- (void)addParticleAtPosition:(GLKVector3)aPosition
                     velocity:(GLKVector3)aVelocity
                        force:(GLKVector3)aForce
                         size:(float)aSize
              lifeSpanSeconds:(NSTimeInterval)aSpan
          fadeDurationSeconds:(NSTimeInterval)aDuration;

- (void)prepareToDraw;
- (void)draw;

@end
