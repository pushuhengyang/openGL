//
//  WH_GlslHanderBall.m
//  8-Demo  粒子效果
//
//  Created by xuwenhao on 17/4/12.
//  Copyright © 2017年 Hiniu. All rights reserved.
//

#import "WH_GlslHanderBall.h"
#import <GLKit/GLKit.h>

@interface WH_GlslHanderBall ()
{
    GLuint program;
    GLuint maMatx;//变换矩阵
    GLuint maTex;
    float off_x;
    float degree;
}


@end

@implementation WH_GlslHanderBall

static GLfloat pointEls[] = {1.f,0.f,-50.f,};//一个坐标5

-(void)prewDraw{
    if(0 == program)
    {
        off_x=0;
        degree = 0.f;
        [self loadShaders];
    }
    
    if (program!=0) {
        if (degree>=360) {
            degree = 0.f;
        }
        off_x += 0.05;
     
//        if (off_x>10.f) {
//            off_x=-10.f;
//        }
        degree += 5.0;
        glUseProgram(program);
     
        GLuint attBuffer;
        glGenBuffers(1, &attBuffer);
        
        glBindBuffer(GL_ARRAY_BUFFER,attBuffer);
        glBufferData(GL_ARRAY_BUFFER, sizeof(pointEls), pointEls, GL_STATIC_DRAW);
        glVertexAttribPointer(AttPoisition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*3, NULL);
        glEnableVertexAttribArray(AttPoisition);
        
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, _texture2d0.name);
//

    }
}

-(void)draw{
    [self prewDraw];
    CGSize size = [UIScreen mainScreen].bounds.size;
    float aspect = fabs(size.width / size.height);

    GLKMatrix4 _lookMatrix =  GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90.0), aspect, 5.0f, 200.f);
    
    GLKMatrix4 _projectionMatrix =GLKMatrix4Translate(GLKMatrix4Identity, off_x, 0.0f, 0.0f);
    
    GLKMatrix4 _transMatrix = GLKMatrix4Rotate(GLKMatrix4Identity, GLKMathDegreesToRadians(degree), 0.f, 0.f, 1.f);
    
    
    _projectionMatrix = GLKMatrix4Multiply(_transMatrix, _projectionMatrix);
    _projectionMatrix =GLKMatrix4Multiply(_lookMatrix, _projectionMatrix);
    glUniformMatrix4fv(maMatx, 1, GL_FALSE, &_projectionMatrix.m[0]);//位置变换矩阵
  
    glUniform1i(maTex, 0);
    glDrawArrays(GL_POINTS, 0, 1);
    
}


#pragma --mark  链接program

-(BOOL)loadShaders{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    program = glCreateProgram();
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:
                          @"Ver" ofType:@"glsl"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER
                        file:vertShaderPathname])
    {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:
                          @"Color" ofType:@"glsl"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER
                        file:fragShaderPathname])
    {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    glAttachShader(program, vertShader);
    glAttachShader(program, fragShader);
    
    if (![self linkProgram:program])
    {
        NSLog(@"Failed to link program: %d", program);
        
        if (vertShader)
        {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader)
        {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (program)
        {
            glDeleteProgram(program);
            program = 0;
        }
        
        return NO;
    }
//    这里相当于绑定位置
    glBindAttribLocation(program, AttPoisition,
                         "a_emissionPosition");

    glBindAttribLocation(program, AttSize,
                         "a_size");
    glBindAttribLocation(program, AttTimeLife,
                         "a_emissionAndDeathTimes");
    
//
//
    maMatx = glGetUniformLocation(program,"u_mvpMatrix");
    maTex  = glGetUniformLocation(program,"u_samplers2D");


//    uniforms[AGLKGravity] = glGetUniformLocation(program,"u_gravity");
//    uniforms[AGLKElapsedSeconds] = glGetUniformLocation(program,
//                                                        "u_elapsedSeconds");
    
    
    if (vertShader)
    {
        glDetachShader(program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader)
    {
        glDetachShader(program, fragShader);
        glDeleteShader(fragShader);
    }
    return YES;
}

- (BOOL)compileShader:(GLuint *)shader
                 type:(GLenum)type
                 file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file
                                                  encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source)
    {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0)
    {
        glDeleteShader(*shader);
        return NO;
    }
    return YES;
}


- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0)
    {
        return NO;
    }
    
    return YES;
}



@end
