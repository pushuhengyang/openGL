//
//  WH_GlslDemoHandel.m
//  9-demo 帧缓存
//
//  Created by xuwenhao on 17/4/21.
//  Copyright © 2017年 Hiniu. All rights reserved.
//

#import "WH_GlslDemoHandel.h"
#import "WH_OpenGlHander.h"

@interface WH_GlslDemoHandel ()
{
    GLuint prame;
    GLuint prame1;
    
    GLuint frameBuffer;//帧缓存的标识
    GLuint fbo;//缓存对象
    GLuint texture;
    GLuint texture1;


    GLuint buffer;

}

@property(strong,nonatomic) WH_OpenGlHander *hander0;//一个东西
@property(strong,nonatomic) WH_OpenGlHander *hander1;//一个东西


@end

typedef enum : NSUInteger {
    Poisition,
    BaseColor,
    Texoted,
} ShaderType;


@implementation WH_GlslDemoHandel

GLfloat attrArr[] =
{
    -0.5f, 0.5f, 0.0f,      0.0f, 0.0f, 1.0f,       0.0f, 1.0f,//左上
    0.5f, 0.5f, 0.0f,       0.0f, 1.0f, 0.0f,       1.0f, 1.0f,//右上
    -0.5f, -0.5f, 0.0f,     1.0f, 0.0f, 1.0f,       0.0f, 0.0f,//左下
    0.5f, -0.5f, 0.0f,      0.0f, 0.0f, 1.0f,       1.0f, 0.0f,//右下
    0.0f, 0.0f, 1.0f,       1.0f, 1.0f, 1.0f,       0.5f, 0.5f,//顶点
    
};

GLuint indices[] =
{
    0, 3, 2,
    0, 1, 3,
    //可以去掉注释
                    0, 2, 4,
                    0, 4, 1,
                    2, 3, 4,
                    1, 4, 3,
};


-(instancetype)init{
    if (self = [super init]) {
        prame=0;
        prame1=0;
        [self setUPOrignUI];
    }
    return self;
}


-(void)setUPOrignUI{
    
    _hander0 =[[WH_OpenGlHander alloc]initWithAttribStride:sizeof(GLfloat)*8 numberOfVertices:6 bytes:attrArr usage:GL_DYNAMIC_DRAW];
    _hander1 =[[WH_OpenGlHander alloc]initWithAttribStride:sizeof(GLfloat)*8 numberOfVertices:6 bytes:attrArr usage:GL_DYNAMIC_DRAW];

    GLuint index;
    glGenBuffers(1, &index);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, index);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    

    
    glEnable(GL_DEPTH_TEST);

    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"22222" ofType:@"jpg"];
    
    texture = [WH_OpenGlHander setupTexture:filePath];
    
    CGFloat width, height,scron;
    scron = [UIScreen mainScreen].scale;
    width = [UIScreen mainScreen].bounds.size.width*scron/2 ;
    height = [UIScreen mainScreen].bounds.size.height*scron/2 ;
    [self extraInitWithWidth:100 height:100]; //特别注意这里的大小

}




//帧缓存的创造
- (void)extraInitWithWidth:(GLint)width height:(GLint)height {
    glDeleteFramebuffers(1, &frameBuffer);
    frameBuffer = 0;
    glDeleteRenderbuffers(1, &fbo);
    
    fbo=0;
    glGenFramebuffers(1, &frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    
    glGenTextures(1, &texture1);
    glBindTexture(GL_TEXTURE_2D, texture1);

    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, NULL);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    
    //绑定到帧缓存上
    
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texture1, 0);
    
    //缓冲对象
    glGenRenderbuffers(1, &fbo);
    glBindRenderbuffer(GL_RENDERBUFFER, fbo);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_RGBA4, width , height);
    
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, fbo);//将缓冲对象附加到帧缓存上
    if(glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE){
        NSLog(@"帧缓冲失败error");
        return;
    }
    
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    glBindTexture(GL_TEXTURE_2D, 0);

}


-(void)prewDraw{
    if (prame==0) {
      prame = [self loadShade];
    }
    if (prame==0) {
        return;
    }
    
    glUseProgram(prame);
    
    
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    [self setVBO1];

    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
    
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, texture1);


}

-(void)setVBO1{

    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    glActiveTexture(GL_TEXTURE0);

    glBindTexture(GL_TEXTURE_2D, texture);
    GLuint poisition=glGetAttribLocation(prame, "a_emissionPosition");
    
    GLuint basColor = glGetAttribLocation(prame, "texCoords");
    
    GLuint color = glGetAttribLocation(prame, "textCoordinate");
    
    [ _hander0 reinitWithAttribStride:sizeof(GLfloat)*8 numberOfVertices:6 bytes:attrArr];
    [_hander0 prepareToDrawWithAttrib:poisition numberOfCoordinates:3 attribOffset:0*sizeof(GLfloat) shouldEnable:YES];
    [_hander0 prepareToDrawWithAttrib:basColor numberOfCoordinates:3 attribOffset:3*sizeof(GLfloat) shouldEnable:NO];
    [_hander0 prepareToDrawWithAttrib:color numberOfCoordinates:2 attribOffset:6*sizeof(GLfloat) shouldEnable:YES];
    
    glUniform1i(glGetUniformLocation(prame,"u_samplers2D"), 0);

    

}


-(void)setVBO{
 
    GLuint poisition=glGetAttribLocation(prame1, "a_emissionPosition");
    
    GLuint basColor = glGetAttribLocation(prame1, "texCoords");
    
    GLuint color = glGetAttribLocation(prame1, "textCoordinate");
    
    [ _hander1 reinitWithAttribStride:sizeof(GLfloat)*8 numberOfVertices:6 bytes:attrArr];
    [_hander1 prepareToDrawWithAttrib:poisition numberOfCoordinates:3 attribOffset:0*sizeof(GLfloat) shouldEnable:YES];
    [_hander1 prepareToDrawWithAttrib:basColor numberOfCoordinates:3 attribOffset:3*sizeof(GLfloat) shouldEnable:NO];
    [_hander1 prepareToDrawWithAttrib:color numberOfCoordinates:2 attribOffset:6*sizeof(GLfloat) shouldEnable:YES];
    
    glUniform1i(glGetUniformLocation(prame1,"u_samplers2D"), 0);

}


-(void)draw{
    [self prewDraw];
    [_glkView bindDrawable];
    
    if (prame1==0) {
        prame1 = [self loadShade];
    }
    if (prame1==0) {
        return;
    }
    
    glUseProgram(prame1);
    
    glClearColor(0.0, 0.3, 0.3, 1);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, texture1);
    [self setVBO];

    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
    
    
//    [_glkView.context presentRenderbuffer:GL_RENDERBUFFER];

    
    
}

-(GLuint)loadShade{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    GLuint temprame;
    temprame = glCreateProgram();
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:
                          @"Ver" ofType:@"glsl"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER
                        file:vertShaderPathname])
    {
        NSLog(@"Failed to compile vertex shader");
        return 0;
    }
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:
                          @"Color" ofType:@"glsl"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER
                        file:fragShaderPathname])
    {
        NSLog(@"Failed to compile fragment shader");
        return 0;
    }
    glAttachShader(temprame, vertShader);
    glAttachShader(temprame, fragShader);
    
    if (![self linkProgram:temprame])
    {
        NSLog(@"Failed to link program: %d", temprame);
        
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
        if (temprame)
        {
            glDeleteProgram(temprame);
            temprame = 0;
        }
        
        return 0;
    }

    if (vertShader)
    {
        glDetachShader(temprame, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader)
    {
        glDetachShader(temprame, fragShader);
        glDeleteShader(fragShader);
    }
    
    return temprame;
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
