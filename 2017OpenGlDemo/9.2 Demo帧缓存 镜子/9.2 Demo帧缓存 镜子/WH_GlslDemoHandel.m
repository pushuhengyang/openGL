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
    GLuint frameBuffer_0;//帧缓存的标识
    GLuint frameBuffer_1;//帧缓存的标识

    GLuint texture_0;
    GLuint texture_1;//两个帧缓存纹理

    
    GLuint maTex;//纹理采集
    GLuint maMax;//变换矩阵
    CGFloat delegate_y;//角度

    NSTimer *timer;
    
}

@property (nonatomic , strong) GLKBaseEffect* mBaseEffect;
@property (strong  ,nonatomic) GLKBaseEffect *extEffect0;  //第一个帧缓存
@property (strong  ,nonatomic) GLKBaseEffect *extEffect1;  //第一个帧缓存


@property(strong,nonatomic) WH_OpenGlHander *hander0;

@end

@implementation WH_GlslDemoHandel

GLfloat attrArr1[] =
{
    -1.0f, 1.0f, 0.0f,      0.0f, 0.0f, 1.0f,       0.0f, 1.0f,//左上
    1.0f, 1.0f, 0.0f,       0.0f, 1.0f, 0.0f,       1.0f, 1.0f,//右上
    -1.0f, -1.0f, 0.0f,     1.0f, 0.0f, 1.0f,       0.0f, 0.0f,//左下
    1.0f, -1.0f, 0.0f,      0.0f, 0.0f, 1.0f,       1.0f, 0.0f,//右下
    0.0f, 0.0f,  5.0f,       1.0f, 1.0f, 1.0f,       0.5f, 0.5f,//顶点
};

GLfloat attrArr2[] =
{
    -1.0f, 1.0f, 0.0f,      0.0f, 0.0f, 1.0f,       0.0f, 1.0f,//左上
    1.0f, 1.0f, 0.0f,       0.0f, 1.0f, 0.0f,       1.0f, 1.0f,//右上
    -1.0f, -1.0f, 0.0f,     1.0f, 0.0f, 1.0f,       0.0f, 0.0f,//左下
    1.0f, -1.0f, 0.0f,      0.0f, 0.0f, 1.0f,       1.0f, 0.0f,//右下
    0.0f, 0.0f,  -5.0f,       1.0f, 1.0f, 1.0f,       0.5f, 0.5f,//顶点
};



GLfloat attrArr[] =
{
    -0.5f, 0.5f, 0.0f,      0.0f, 0.0f, 1.0f,       0.0f, 1.0f,//左上
    0.5f, 0.5f, 0.0f,       0.0f, 1.0f, 0.0f,       1.0f, 1.0f,//右上
    -0.5f, -0.5f, 0.0f,     1.0f, 0.0f, 1.0f,       0.0f, 0.0f,//左下
    0.5f, -0.5f, 0.0f,      0.0f, 0.0f, 1.0f,       1.0f, 0.0f,//右下
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
        [self setUPOrignUI];
    }
    return self;
}

-(void)setIsForce:(BOOL)isForce{
    _isForce = isForce;
}


-(void)setUPOrignUI{
//    [self loadShade];
    _isForce = YES;
    glEnable(GL_DEPTH_TEST);
    
    GLuint index;
    glGenBuffers(1, &index);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, index);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    
    //创建帧缓存
    frameBuffer_0 = [self getNewFrameBuffer:0];
    frameBuffer_1 = [self getNewFrameBuffer:1];
    
    
    _hander0 =[[WH_OpenGlHander alloc]initWithAttribStride:sizeof(GLfloat)*8 numberOfVertices:6 bytes:attrArr usage:GL_STATIC_DRAW];
    _mBaseEffect = [GLKBaseEffect new];
    _mBaseEffect.texture2d0.enabled = GL_TRUE;
    
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"22222" ofType:@"jpg"];
    
    NSString* filePath1 = [[NSBundle mainBundle] pathForResource:@"11111" ofType:@"jpg"];

    
    NSDictionary* options = [NSDictionary dictionaryWithObjectsAndKeys:@(1), GLKTextureLoaderOriginBottomLeft, nil];

    GLKTextureInfo *texinfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:nil];
    
    GLKTextureInfo *texinfo1 = [GLKTextureLoader textureWithContentsOfFile:filePath1 options:options error:nil];

    
    _extEffect0 = [GLKBaseEffect new];
    _extEffect0.texture2d0.enabled  =GL_TRUE;
    _extEffect0.texture2d0.name = texinfo.name;
    
    
    _extEffect1 = [GLKBaseEffect new];
    _extEffect1.texture2d0.enabled  =GL_TRUE;
    _extEffect1.texture2d0.name = texinfo1.name;
    
    
    CGSize size = [UIScreen mainScreen].bounds.size;
    float aspect = fabs(size.width / size.height);
    GLKMatrix4 _lookMatrix =  GLKMatrix4MakePerspective(GLKMathDegreesToRadians(10.0), aspect, 1.0f, 200.f);
    _extEffect0.transform.projectionMatrix = _lookMatrix;
    _extEffect1.transform.projectionMatrix = _lookMatrix;
 
    
    [self setVbo];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(delegateChange) userInfo:nil repeats:YES];
    
    
}

-(void)delegateChange{
    delegate_y += 5.0;
    if (delegate_y >= 360.f) {
        delegate_y = 0.f;
    }

}


-(void)changeDelegate_y{
    
    if (_isForce) {
        GLKMatrix4 matr = GLKMatrix4Translate(GLKMatrix4Identity, 0.f, 0.f, -100.f);
        _extEffect0.transform.modelviewMatrix =GLKMatrix4Rotate(matr, GLKMathDegreesToRadians(delegate_y), 0.f, 1.f, 0.f);
        
    }else{
        GLKMatrix4 matr = GLKMatrix4Identity;
        matr.m22 = -1;
        GLKMatrix4 trans = GLKMatrix4Translate(GLKMatrix4Identity, 0.f, 0.f, -100.f);
        GLKMatrix4 roat =GLKMatrix4Rotate(GLKMatrix4Identity, GLKMathDegreesToRadians(delegate_y), 0.f, 1.f, 0.f);
        _extEffect1.transform.modelviewMatrix =GLKMatrix4Multiply(trans, GLKMatrix4Multiply(roat, matr));
    }
}


-(GLuint)getNewFrameBuffer:(NSInteger)index{
    float width, height,scron;
    scron = [UIScreen mainScreen].scale;
    width = [UIScreen mainScreen].bounds.size.width*scron ;
    height = [UIScreen mainScreen].bounds.size.height*scron ;
    
    
    GLuint framBuffer;
    glGenFramebuffers(1, &framBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framBuffer);
    
    GLuint texture;
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, NULL);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texture, 0);
    
    if (index==0) {
        texture_0 = texture;
 
   
    }else{
        texture_1 = texture;
    }
    
    GLuint Fbo;
    glGenRenderbuffers(1, &Fbo);
    glBindRenderbuffer(GL_RENDERBUFFER, Fbo);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, width , height);
    
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, Fbo);//将缓冲对象附加到帧缓存上
    if(glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE){
        NSLog(@"帧缓冲失败error");
        return 0;
    }

    glBindTexture(GL_TEXTURE_2D, 0);
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    
    return framBuffer;
}


//第一个缓存
-(void)setVbo_0{
    [ _hander0 reinitWithAttribStride:sizeof(GLfloat)*8 numberOfVertices:18 bytes:_isForce?attrArr1:attrArr2];
    [_hander0 prepareToDrawWithAttrib:GLKVertexAttribPosition numberOfCoordinates:3 attribOffset:0*sizeof(GLfloat) shouldEnable:YES];
    [_hander0 prepareToDrawWithAttrib:GLKVertexAttribColor numberOfCoordinates:3 attribOffset:3*sizeof(GLfloat) shouldEnable:NO];
    [_hander0 prepareToDrawWithAttrib:GLKVertexAttribTexCoord0 numberOfCoordinates:2 attribOffset:6*sizeof(GLfloat) shouldEnable:YES];
}



-(void)setVbo{
    [ _hander0 reinitWithAttribStride:sizeof(GLfloat)*8 numberOfVertices:6 bytes:attrArr];
    [_hander0 prepareToDrawWithAttrib:GLKVertexAttribPosition numberOfCoordinates:3 attribOffset:0*sizeof(GLfloat) shouldEnable:YES];
    [_hander0 prepareToDrawWithAttrib:GLKVertexAttribColor numberOfCoordinates:3 attribOffset:3*sizeof(GLfloat) shouldEnable:NO];
    [_hander0 prepareToDrawWithAttrib:GLKVertexAttribTexCoord0 numberOfCoordinates:2 attribOffset:6*sizeof(GLfloat) shouldEnable:YES];

}



-(void)prewDraw{
     //先做一个帧缓存
    glBindFramebuffer(GL_FRAMEBUFFER, _isForce?frameBuffer_0:frameBuffer_1);
    [self setVbo_0];
    
    [self changeDelegate_y];
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glEnableVertexAttribArray(GLKVertexAttribColor);
    if (_isForce) {
        [_extEffect0 prepareToDraw];

    }else{
        [_extEffect1 prepareToDraw];

    }
    glDrawElements(GL_TRIANGLES, 18, GL_UNSIGNED_INT, 0);
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    self.mBaseEffect.texture2d0.name = _isForce?texture_0:texture_1;

}

-(void)draw{
    [self prewDraw];
    [_glkView bindDrawable];
    glClearColor(0.3, 0.3, 0.3, 1);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    [self setVbo];
    glDisableVertexAttribArray(GLKVertexAttribColor);

    [self.mBaseEffect prepareToDraw];
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);

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
    
    GLuint poisition=glGetAttribLocation(prame, "a_emissionPosition");
    glVertexAttribPointer(poisition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*8, NULL);
    glEnableVertexAttribArray(poisition);
    
    
    GLuint basColor = glGetAttribLocation(prame, "texCoords");
    glVertexAttribPointer(basColor, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*8, (float*)NULL+3);
    glEnableVertexAttribArray(basColor);
    
    //纹理坐标缓存
    GLuint color = glGetAttribLocation(prame, "textCoordinate");
    glVertexAttribPointer(color, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*8, (float *)NULL+6);
    glEnableVertexAttribArray(color);
    
    //纹理采样器
    maTex  = glGetUniformLocation(prame,"u_samplers2D");
    maMax  = glGetUniformLocation(prame,"u_mvpMatrix");


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
