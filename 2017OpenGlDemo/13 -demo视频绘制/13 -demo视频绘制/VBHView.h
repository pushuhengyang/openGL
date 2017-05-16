//
//  VBHView.h
//  13 -demo视频绘制
//
//  Created by xuwenhao on 17/5/11.
//  Copyright © 2017年 Hiniu. All rights reserved.
//  绘制视图view

#import <UIKit/UIKit.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@interface VBHView : UIView

@property GLfloat preferredRotation;
@property CGSize presentationRect;
@property GLfloat chromaThreshold;
@property GLfloat lumaThreshold;

- (void)setupGL;
- (void)displayPixelBuffer:(CVPixelBufferRef)pixelBuffer;


@end
