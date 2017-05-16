//
//  WH_DemoHander.h
//  10-Demo 天空盒
//
//  Created by xuwenhao on 17/5/3.
//  Copyright © 2017年 Hiniu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/glext.h>
#import <GLKit/GLKit.h>

@interface WH_DemoHander : NSObject

@property (nonatomic, assign) GLKVector3 center;
@property (nonatomic, assign) GLfloat xSize;
@property (nonatomic, assign) GLfloat ySize;
@property (nonatomic, assign) GLfloat zSize;

@property (strong, nonatomic, readonly) GLKEffectPropertyTexture
*textureCubeMap;

@property (strong, nonatomic, readonly) GLKEffectPropertyTransform
*transform;

- (void) prepareToDraw;
- (void) draw;

@end
