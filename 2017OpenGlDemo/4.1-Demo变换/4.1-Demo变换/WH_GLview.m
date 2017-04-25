//
//  WH_GLview.m
//  4.1-Demo变换
//
//  Created by xuwenhao on 17/4/5.
//  Copyright © 2017年 Hiniu. All rights reserved.
//

#import "WH_GLview.h"
#import <GLKit/GLKit.h>
#import <OpenGLES/ES2/gl.h>
//#import "GLESMath.h"

@interface WH_GLview ()
{
    CGFloat degreey;
}
@property (nonatomic , strong) EAGLContext* myContext;   //上下文
@property (nonatomic , strong) CAEAGLLayer* myEagLayer;   //layer
@property (nonatomic , assign) GLuint       myProgram;  //


@property (nonatomic , assign) GLuint myColorRenderBuffer;
@property (nonatomic , assign) GLuint myColorFrameBuffer;

@end


@implementation WH_GLview

static    //做一个立方体的 8个顶点 6个面 12个三角形 暂时先完成效果暂时不考虑纹理显示
GLfloat attrArr[] =
{
    -0.5f, 0.5f,  0.5f,  1.0f,1.0f,0.0f,   0.0f, 1.0f,   //左上
    -0.5f,-0.5f,  0.5f,  1.0f,0.0f,1.0f,   0.0f, 0.0f,    //左下
     0.5f,-0.5f,  0.5f,  0.0f,1.0f,1.0f,   1.0f, 0.0f,//右下
     0.5f, 0.5f,  0.5f,  0.0f,0.0f,1.0f,   1.0f, 1.0f,//右上
    
    -0.5f, 0.5f,  -0.5f,  0.0f,1.0f,1.0f,   1.0f, 1.0f,
    -0.5f,-0.5f,  -0.5f,  0.0f,0.0f,1.0f,   1.0f, 0.0f,
     0.5f,-0.5f,  -0.5f,  1.0f,1.0f,0.0f,   0.0f, 0.0f,
     0.5f, 0.5f,  -0.5f,  1.0f,0.0f,1.0f,   0.0f, 1.0f,
    
};



static     //顶点索引 12个
GLuint indexArry[]={
    0, 3, 4,
    3, 4, 7,
    
    1, 2, 6,
    1, 6, 5,
    
    0, 1, 2,
    0, 2, 3,
    
    3, 2, 6,
    3, 6, 7,
    
    7, 6, 5,
    7, 5, 4,
    
    0, 1, 4,
    1, 4, 5,
    

};


+(Class)layerClass{
    return [CAEAGLLayer class];
}

-(void)layoutSubviews{
    [self setOrignSeeting];
    [self renderLink];
    [self openDrew];
}
//初始化设置
-(void)setOrignSeeting{
    _myEagLayer = (CAEAGLLayer *)self.layer;
    [self setContentScaleFactor:[UIScreen mainScreen].scale];
    _myEagLayer.opaque = YES;
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LESS);
    // 设置描绘属性，在这里设置不维持渲染内容以及颜色格式为 RGBA8
    _myEagLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
    _myContext = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:_myContext];
    //清除缓存
    glDeleteFramebuffers(1, &_myColorFrameBuffer);
    _myColorFrameBuffer = 0;
    glDeleteRenderbuffers(1, &_myColorRenderBuffer);
    _myColorRenderBuffer = 0;
    
    //绑定缓存
    glGenRenderbuffers(1, &_myColorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _myColorRenderBuffer);
    [_myContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:_myEagLayer];
    
    glGenFramebuffers(1, &_myColorFrameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _myColorFrameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                              GL_RENDERBUFFER, _myColorFrameBuffer);
}
#pragma --mark  相关文件链接
-(void)renderLink{
    glClearColor(0, 1, 1, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    CGFloat scale = [UIScreen mainScreen].scale;
    glViewport(self.frame.origin.x * scale, self.frame.origin.y * scale, self.frame.size.width * scale, self.frame.size.height * scale); //设置视口大小
    //读取文件
    NSString* vertFile = [[NSBundle mainBundle] pathForResource:@"ver" ofType:@"glsl"];
    NSString* fragFile = [[NSBundle mainBundle] pathForResource:@"frag" ofType:@"glsl"];
    
    //创建着色器 （其实就是一种关联对象）
    _myProgram = [self loadShader:vertFile and:fragFile];
    //编译好所有的shader对象并将他们绑定到程序中后我就可以连接他们了
    glLinkProgram(_myProgram);
    GLint linkSuccess;
    glGetProgramiv(_myProgram, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess==GL_FALSE) {//链接错误
        GLchar messages[256];
        glGetProgramInfoLog(_myProgram, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"error=%@", messageString);
        return ;
    }else{
        NSLog(@"link OK");
        GLint success;
        glValidateProgram(_myProgram);
        glGetProgramiv(_myProgram, GL_VALIDATE_STATUS, &success);
        if (!success) {
            GLchar messages[256];
            glGetProgramInfoLog(_myProgram, sizeof(messages), NULL, &messages[0]);
            NSLog(@"error=%@",[NSString stringWithUTF8String:messages]);
            exit(1);
        }
        glUseProgram(_myProgram);//开始使用
    }

}

-(GLuint)loadShader:(NSString *)vert and:(NSString *)frag{
    GLuint verShader, fragShader;
    GLint program = glCreateProgram();
    
    //编译
    [self compileShader:&verShader type:GL_VERTEX_SHADER file:vert];
    [self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:frag];
    
    glAttachShader(program, verShader);
    glAttachShader(program, fragShader);
    
    
    //释放不需要的shader
    glDeleteShader(verShader);
    glDeleteShader(fragShader);
    
    return program;
    
    
}

-(void)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file{
    NSString *content = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    const GLchar* source = (GLchar *)[content UTF8String];
    //使用下面的函数创建shader着色器对象
    *shader = glCreateShader(type);
    //在编译shader对象之前我们必须先定义它的代码源  可以作为源码数组 这里只用一个元素表示
    glShaderSource(*shader, 1, &source, NULL);
    //编译
    glCompileShader(*shader);
    GLint status;
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status==GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(*shader, sizeof(messages), NULL, &messages[0]);
        NSLog(@"shaderError=%@",[NSString stringWithUTF8String:messages]);
        exit(1);
    }
}

//开始绘制
-(void)openDrew{
    degreey = 0.f;
    

    
    GLuint attBuffer;
    glGenBuffers(1, &attBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, attBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(attrArr), attrArr, GL_DYNAMIC_DRAW);
    
    //索引缓存
    GLuint index;
    glGenBuffers(1, &index);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, index);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indexArry), indexArry, GL_STATIC_DRAW);
    
    GLuint position =glGetAttribLocation(_myProgram, "Position");
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*8, NULL);
    glEnableVertexAttribArray(position);
    
    GLuint basColor = glGetAttribLocation(_myProgram, "baseColor");
    glVertexAttribPointer(basColor, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*8, (float*)NULL+3);
    glEnableVertexAttribArray(basColor);
    
    //纹理坐标缓存
    GLuint color = glGetAttribLocation(_myProgram, "textCoordinate");
    glVertexAttribPointer(color, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*8, (float *)NULL+6);
    glEnableVertexAttribArray(color);
    
    
    GLuint texture0;
    GLuint texture1;
    [self setupTexture:@"22222.jpg" and:&texture0];//生成纹理
    [self setupTexture:@"22222.jpg" and:&texture1];//另一个纹理
    
    glActiveTexture(GL_TEXTURE0);//在绑定纹理之前先激活纹理单元
    glBindTexture(GL_TEXTURE_2D, texture0);
    glUniform1i(glGetUniformLocation(_myProgram, "courTexture"), 0);
    //纹理1
        glActiveTexture(GL_TEXTURE1);
        glBindTexture(GL_TEXTURE_2D, texture1);
        glUniform1i(glGetUniformLocation(_myProgram, "courTexture1"), 1);
    
    
    GLKMatrix4 _projectionMatrix =GLKMatrix4Translate(GLKMatrix4Identity, 0.0f, 0.0f, 0.f);
    
    _projectionMatrix = GLKMatrix4Rotate(_projectionMatrix, GLKMathDegreesToRadians(degreey), 0.0, 1.0, 0.0);
    
    _projectionMatrix = GLKMatrix4Rotate(_projectionMatrix, GLKMathDegreesToRadians(-20.f), 0.0, 0.0, 1.0);

//    KSMatrix4 _projectionMatrix;
//    ksMatrixLoadIdentity(&_projectionMatrix);//单位矩阵
//    //平移 （1 1 0）
//    ksTranslate(&_projectionMatrix, 0.2, 0.2, 0.f);
//    //逆时针旋转90度 绕Z轴
//    ksRotate(&_projectionMatrix, -60.f, 0.f, 0.f, 1.f);
//    ksScale(&_projectionMatrix, 1.0, 1.0, 1.0);
//    
    GLuint tranfram = glGetUniformLocation(_myProgram, "transform");
    glUniformMatrix4fv(tranfram, 1, GL_FALSE, &_projectionMatrix.m[0]);
//
    glDrawElements(GL_TRIANGLES, sizeof(indexArry)/sizeof(GLuint), GL_UNSIGNED_INT, 0);
    
    [_myContext presentRenderbuffer:GL_RENDERBUFFER];
    [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(drawNew) userInfo:nil repeats:YES];
}

-(void)drawNew{
    glClearColor(0.1, 0.1, 0.1, 1.0);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT); //更新
    
    GLKMatrix4 _projectionMatrix =GLKMatrix4Translate(GLKMatrix4Identity, 0.0f, 0.0f, 0.f);
    degreey = degreey+1;
    if (degreey>=360*100) {
        degreey=0;
    }
    _projectionMatrix = GLKMatrix4Rotate(_projectionMatrix, GLKMathDegreesToRadians(degreey), 0.0, 1.0, 0.0);
    _projectionMatrix = GLKMatrix4Rotate(_projectionMatrix, GLKMathDegreesToRadians(-20.f), 0.0, 0.0, 1.0);
    

    GLuint tranfram = glGetUniformLocation(_myProgram, "transform");
    glUniformMatrix4fv(tranfram, 1, GL_FALSE, &_projectionMatrix.m[0]);
    //
    glDrawElements(GL_TRIANGLES, sizeof(indexArry)/sizeof(GLuint), GL_UNSIGNED_INT, 0);
    [_myContext presentRenderbuffer:GL_RENDERBUFFER];

}



- (void)setupTexture:(NSString *)fileName and:(GLuint *)texTent{//纹理
    // 1获取图片的CGImageRef
    CGImageRef spriteImage = [UIImage imageNamed:fileName].CGImage;
    if (!spriteImage) {
        NSLog(@"Failed to load image %@", fileName);
        exit(1);
    }
    
    // 2 读取图片的大小
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    
    GLubyte * spriteData = (GLubyte *) calloc(width * height * 4, sizeof(GLubyte)); //rgba共4个byte
    
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4,
                                                       CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    
    // 3在CGContextRef上绘图
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
    
    CGContextRelease(spriteContext);
    
    /*
     glGenTextures函数首先需要输入生成纹理的数量，然后把它们储存在第二个参数的GLuint数组中
     */
    glGenTextures(1, texTent);
    glBindTexture(GL_TEXTURE_2D, *texTent);
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    float fw = width, fh = height;
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, fw, fh, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    
    glGenerateMipmap(GL_TEXTURE_2D);//自动生成多级纹理
    
    glBindTexture(GL_TEXTURE_2D, 0);//解绑纹理对象
    free(spriteData);
    
}






@end
