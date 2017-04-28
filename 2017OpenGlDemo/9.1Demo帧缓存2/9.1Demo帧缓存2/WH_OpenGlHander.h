//
//  WH_OpenGlHander.h
//  5-Demo 投影
//
//  Created by xuwenhao on 17/3/29.
//  Copyright © 2017年 Hiniu. All rights reserved.
//  封装一下

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
@interface WH_OpenGlHander : NSObject

@property (readonly, nonatomic)GLuint  name;  //申请一个标识
@property (readonly, nonatomic)GLsizeiptr  bufferSizeBytes; //
@property (readonly, nonatomic)GLsizeiptr stride; //

+ (void)drawPreparedArraysWithMode:(GLenum)mode
                  startVertexIndex:(GLint)first
                  numberOfVertices:(GLsizei)count;



- (id)initWithAttribStride:(GLsizeiptr)stride
          numberOfVertices:(GLsizei)count
                     bytes:(const GLvoid *)dataPtr
                     usage:(GLenum)usage;

- (void)prepareToDrawWithAttrib:(GLuint)index
            numberOfCoordinates:(GLint)count
                   attribOffset:(GLsizeiptr)offset
                   shouldEnable:(BOOL)shouldEnable;

- (void)drawArrayWithMode:(GLenum)mode
         startVertexIndex:(GLint)first
         numberOfVertices:(GLsizei)count;

- (void)reinitWithAttribStride:(GLsizeiptr)stride
              numberOfVertices:(GLsizei)count
                         bytes:(const GLvoid *)dataPtr;


+ (GLuint)setupTexture:(NSString *)fileName;//纹理

@end
