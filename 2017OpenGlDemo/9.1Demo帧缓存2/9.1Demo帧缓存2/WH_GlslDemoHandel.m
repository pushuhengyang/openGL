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
    GLuint frameBuffer;//帧缓存的标识
    GLuint fbo;//缓存对象
    GLuint texture;
    GLuint texture1;
    GLuint maTex;//纹理采样
    GLKTextureInfo* textureInfo;
    GLint _mDefaultFBO;
    GLuint buffer;

}

@end

typedef enum : NSUInteger {
    Poisition,
    BaseColor,
    Texoted,
} ShaderType;


@implementation WH_GlslDemoHandel


-(instancetype)init{
    if (self = [super init]) {
        prame=0;
        [self setUPOrignUI];
    }
    return self;
}


-(void)setUPOrignUI{
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
//                0, 2, 4,
//                0, 4, 1,
//                2, 3, 4,
//                1, 4, 3,
    };
    
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(attrArr), attrArr, GL_STATIC_DRAW);
    
    GLuint index;
    glGenBuffers(1, &index);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, index);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    //位置
//
//    glEnableVertexAttribArray(GLKVertexAttribPosition);
//    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 8, (GLfloat *)NULL);
//    
//    glEnableVertexAttribArray(GLKVertexAttribColor);
//    glVertexAttribPointer(GLKVertexAttribColor, 3, GL_FLOAT, GL_FALSE, 4 * 8, (GLfloat *)NULL + 3);
//    
//    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
//    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 4 * 8, (GLfloat *)NULL + 6);
//    

    
    glEnable(GL_DEPTH_TEST);

    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"22222" ofType:@"jpg"];
    
//    NSDictionary* options = [NSDictionary dictionaryWithObjectsAndKeys:@(1), GLKTextureLoaderOriginBottomLeft, nil];
    
//    GLKTextureInfo *texinfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:nil];
    
    texture = [WH_OpenGlHander setupTexture:filePath];
    
    CGFloat width, height,scron;
    scron = [UIScreen mainScreen].scale;
//    scron=1.0;
    width = [UIScreen mainScreen].bounds.size.width*scron ;
    height = [UIScreen mainScreen].bounds.size.height*scron ;
    [self extraInitWithWidth:width height:height]; //特别注意这里的大小

}




//帧缓存的创造
- (void)extraInitWithWidth:(GLint)width height:(GLint)height {
    glDeleteFramebuffers(1, &frameBuffer);
    frameBuffer = 0;
    glDeleteRenderbuffers(1, &fbo);
    fbo=0;

    
    glGetIntegerv(GL_FRAMEBUFFER_BINDING, &_mDefaultFBO);

    glGenFramebuffers(1, &frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    
    /*
     绑定到GL_FRAMEBUFFER目标后，接下来所有的读、写帧缓冲的操作都会影响到当前绑定的帧缓冲。也可以把帧缓冲分开绑定到读或写目标上，分别使用GL_READ_FRAMEBUFFER或GL_DRAW_FRAMEBUFFER来做这件事。如果绑定到了GL_READ_FRAMEBUFFER，就能执行所有读取操作，像glReadPixels这样的函数使用了；绑定到GL_DRAW_FRAMEBUFFER上，就允许进行渲染、清空和其他的写入操作。大多数时候你不必分开用，通常把两个都绑定到GL_FRAMEBUFFER上就行。
     
     建构一个完整的帧缓冲必须满足以下条件：
     
     我们必须往里面加入至少一个附件（颜色、深度、模板缓冲）。
     其中至少有一个是颜色附件。
     所有的附件都应该是已经完全做好的（已经存储在内存之中）。
     每个缓冲都应该有同样数目的样本。
     */
    
    //帧缓存纹理附件
    //    texture = [WH_OpenGlHander setupTexture:filePath];

    
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
    
    glBindFramebuffer(GL_FRAMEBUFFER, _mDefaultFBO);
    glBindTexture(GL_TEXTURE_2D, 0);

}


-(void)prewDraw{
    if (prame==0) {
        [self loadShade];
    }
    if (prame==0) {
        return;
    }
    
    glUseProgram(prame);
    
    
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
//    glViewport(0, 0,100, 100);
    
    [self setVBO1];

//
    glUniform1i(glGetUniformLocation(prame,"u_samplers2D"), 0);
//
//
    glVertexAttribPointer(BaseColor, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*8, (float*)NULL+3);
    glEnableVertexAttribArray(BaseColor);
    
    glVertexAttribPointer(Texoted, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*8, (float *)NULL+6);
    glEnableVertexAttribArray(Texoted);
//
    
    
    
    
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindFramebuffer(GL_FRAMEBUFFER, _mDefaultFBO);
    glBindTexture(GL_TEXTURE_2D, 0);

}

-(void)setVBO1{
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBindTexture(GL_TEXTURE_2D, texture);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
}


-(void)draw{
    [self prewDraw];
    [_glkView bindDrawable];
    
    glUseProgram(prame);

    

    glClearColor(0.0, 0.3, 0.3, 1);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    
    glActiveTexture(GL_TEXTURE1);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBindTexture(GL_TEXTURE_2D, texture);


    glUniform1i(glGetUniformLocation(prame,"u_samplers2D"), 0);
//
    glVertexAttribPointer(Poisition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*8, NULL);
    glEnableVertexAttribArray(Poisition);
    
    glVertexAttribPointer(BaseColor, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*8, (float*)NULL+3);
    glEnableVertexAttribArray(BaseColor);
//    glDisableVertexAttribArray(BaseColor);
    glVertexAttribPointer(Texoted, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*8, (float *)NULL+6);
    glEnableVertexAttribArray(Texoted);
////

    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
    
//    [_glkView.context presentRenderbuffer:GL_RENDERBUFFER];
}

-(BOOL)loadShade{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    prame = glCreateProgram();
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
    glAttachShader(prame, vertShader);
    glAttachShader(prame, fragShader);
    
    if (![self linkProgram:prame])
    {
        NSLog(@"Failed to link program: %d", prame);
        
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
        if (prame)
        {
            glDeleteProgram(prame);
            prame = 0;
        }
        
        return NO;
    }
    glBindAttribLocation(prame, Poisition, "a_emissionPosition");
//    GLuint poisition=glGetAttribLocation(prame, "a_emissionPosition");
    glVertexAttribPointer(Poisition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*8, NULL);
    glEnableVertexAttribArray(Poisition);
    
    
    glBindAttribLocation(prame, BaseColor, "texCoords");

//    GLuint basColor = glGetAttribLocation(prame, "texCoords");
    glVertexAttribPointer(BaseColor, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*8, (float*)NULL+3);
    glEnableVertexAttribArray(BaseColor);
    
    //纹理坐标缓存
    glBindAttribLocation(prame, Texoted, "texCoords");

//    GLuint color = glGetAttribLocation(prame, "textCoordinate");
    glVertexAttribPointer(Texoted, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*8, (float *)NULL+6);
    glEnableVertexAttribArray(Texoted);
    
    //纹理采样器
    maTex  = glGetUniformLocation(prame,"u_samplers2D");

    if (vertShader)
    {
        glDetachShader(prame, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader)
    {
        glDetachShader(prame, fragShader);
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
