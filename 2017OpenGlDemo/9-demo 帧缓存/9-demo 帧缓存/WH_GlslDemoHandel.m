//
//  WH_GlslDemoHandel.m
//  9-demo 帧缓存
//
//  Created by xuwenhao on 17/4/21.
//  Copyright © 2017年 Hiniu. All rights reserved.
//

#import "WH_GlslDemoHandel.h"

@interface WH_GlslDemoHandel ()
{
    GLuint prame;
    
}

@property (nonatomic , strong) GLKBaseEffect* mBaseEffect;//这个相当于缓存

@property(strong,nonatomic) GLKBaseEffect *extEffect;



@end

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
                0, 2, 4,
                0, 4, 1,
                2, 3, 4,
                1, 4, 3,
    };
    
    GLuint buffer;
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(attrArr), attrArr, GL_STATIC_DRAW);
    
    GLuint index;
    glGenBuffers(1, &index);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, index);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    //位置
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 8, (GLfloat *)NULL);
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 4 * 8, (GLfloat *)NULL + 6);
    
//        glEnableVertexAttribArray(GLKVertexAttribColor);
//        glVertexAttribPointer(GLKVertexAttribColor, 3, GL_FLOAT, GL_FALSE, 4 * 8, (GLfloat *)NULL + 3);
//    
    _mBaseEffect=[GLKBaseEffect new];
    _extEffect=[GLKBaseEffect new];

    glEnable(GL_DEPTH_TEST);

    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"22222" ofType:@"jpg"];
    NSDictionary* options = [NSDictionary dictionaryWithObjectsAndKeys:@(1), GLKTextureLoaderOriginBottomLeft, nil];
    
    GLKTextureInfo* textureInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:nil];
    _mBaseEffect.texture2d0.enabled=GL_TRUE;
    _mBaseEffect.texture2d0.name=textureInfo.name;
    _mBaseEffect.transform.modelviewMatrix = GLKMatrix4Rotate(GLKMatrix4Identity, GLKMathRadiansToDegrees(20.f), 0.f, 1.f, 0.f);
    
    _extEffect.texture2d0.enabled=GL_TRUE;
    _extEffect.texture2d0.name=textureInfo.name;
    
    CGFloat width, height;
    width = [UIScreen mainScreen].bounds.size.width ;
    height = [UIScreen mainScreen].bounds.size.height ;
    [self extraInitWithWidth:width height:height]; //特别注意这里的大小

}

//帧缓存的创造
- (void)extraInitWithWidth:(GLint)width height:(GLint)height {
   
    GLuint fbo;
    glGenFramebuffers(1, &fbo);
    glBindFramebuffer(GL_FRAMEBUFFER, fbo);
    
    /*
     绑定到GL_FRAMEBUFFER目标后，接下来所有的读、写帧缓冲的操作都会影响到当前绑定的帧缓冲。也可以把帧缓冲分开绑定到读或写目标上，分别使用GL_READ_FRAMEBUFFER或GL_DRAW_FRAMEBUFFER来做这件事。如果绑定到了GL_READ_FRAMEBUFFER，就能执行所有读取操作，像glReadPixels这样的函数使用了；绑定到GL_DRAW_FRAMEBUFFER上，就允许进行渲染、清空和其他的写入操作。大多数时候你不必分开用，通常把两个都绑定到GL_FRAMEBUFFER上就行。
     
     建构一个完整的帧缓冲必须满足以下条件：
     
     我们必须往里面加入至少一个附件（颜色、深度、模板缓冲）。
     其中至少有一个是颜色附件。
     所有的附件都应该是已经完全做好的（已经存储在内存之中）。
     每个缓冲都应该有同样数目的样本。
     */
    
    //帧缓存纹理附件
    GLuint text;
    glGenTextures(1, &text);
    glBindTexture(GL_TEXTURE_2D, text);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, NULL);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    //绑定到帧缓存上
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, text, 0);
    

}


-(void)prewDraw{

    if (prame==0) {
        [self loadShade];
    }
    if (prame==0) {
        return;
    }
    

    
}






-(void)draw{

    glClearColor(0.3, 0.3, 0.3, 1);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    
    [self.mBaseEffect prepareToDraw];
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);

}

-(void)loadShade{

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
