//
//  WH_GLView.m
//  2-Demo 着色器
//
//  Created by xuwenhao on 17/3/27.
//  Copyright © 2017年 Hiniu. All rights reserved.
//

#import "WH_GLView.h"
#import <OpenGLES/ES2/gl.h>
#import "GLESMath.h"

@interface WH_GLView ()

@property (nonatomic , strong) EAGLContext* myContext;   //上下文
@property (nonatomic , strong) CAEAGLLayer* myEagLayer;   //layer
@property (nonatomic , assign) GLuint       myProgram;  //


@property (nonatomic , assign) GLuint myColorRenderBuffer;
@property (nonatomic , assign) GLuint myColorFrameBuffer;

@end


@implementation WH_GLView
+(Class)layerClass{
    return [CAEAGLLayer class];
}

-(void)layoutSubviews{
    //设置layer
    [self setupLayer];
    //设置上下文
    [self setUpContent];
    //设置缓存
    [self destoryRandAndFormBuffer];
    [self setUpRanderBufferAndFramBuffer];
    
    [self renderLink];//链接着色器
    [self openDrew];
}

-(void)setupLayer{
    _myEagLayer = (CAEAGLLayer *)self.layer;
    [self setContentScaleFactor:[UIScreen mainScreen].scale];
    _myEagLayer.opaque = YES;
    
    // 设置描绘属性，在这里设置不维持渲染内容以及颜色格式为 RGBA8
    _myEagLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
}

-(void)setUpContent{
    
    _myContext = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:_myContext];
    
}
//重置缓存
-(void)destoryRandAndFormBuffer{
    glDeleteFramebuffers(1, &_myColorFrameBuffer);
    _myColorFrameBuffer = 0;
    glDeleteRenderbuffers(1, &_myColorRenderBuffer);
    _myColorRenderBuffer = 0;
}

-(void)setUpRanderBufferAndFramBuffer{
    glGenRenderbuffers(1, &_myColorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _myColorRenderBuffer);
    [_myContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:_myEagLayer];
    
    glGenFramebuffers(1, &_myColorFrameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _myColorFrameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                              GL_RENDERBUFFER, _myColorFrameBuffer);
}

//创建着色器
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
        //要使用连接好的shader程序你需要用下面的回调函数将它设置到管线声明中
        //这个程序将在所有的draw call中一直生效直到你用另一个替换掉它或者使用glUseProgram指令将其置NULL明确地禁用它。如果你创建的shader程序只包含一种类型的shader（只是为某一个阶段添加的自定义shader），那么在其他阶段的该操作将会使用它们默认的固定功能操作
        GLint success;
        // 检查验证在当前的管线状态程序是否可以被执行
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

-(void)openDrew{
    //前三个是顶点坐标， 后面两个是纹理坐标  纹理坐标超出范围 有几种模式

    GLfloat attrArr[] =
    {
//        0.5f, -0.5f, -1.0f,     1.0f, 0.0f,
//        -0.5f, 0.5f, -1.0f,     0.0f, 1.0f,
//        -0.5f, -0.5f, -1.0f,    0.0f, 0.0f,
//        0.5f, 0.5f, -1.0f,      1.0f, 1.0f,
//        -0.5f, 0.5f, -1.0f,     0.0f, 1.0f,
//        0.5f, -0.5f, -1.0f,     1.0f, 0.0f,
          -0.5, 0.5f, 1.0f,  1.0f,1.0f,0.0f,   0.0f, 1.0f,    //左上
          -0.5f, -0.5, 0.0f,  1.0f,0.0f,1.0f,  0.0f, 0.0f,    //左下
          0.5f, -0.5, 0.0f, 0.0f,1.0f,1.0f,   1.0f, 0.0f,       //右下
          0.5f, 0.5,  0.0f, 0.0f,.0f,1.0f,   1.0f, 1.0f,       //右上
          0.f,  0.f,  1.0f, 0.5 ,0.5, 0.5,    0.5,0.5, //中间
   
    };
    
    //顶点索引
    GLuint indexArry[]={
        0, 1, 2,
        0, 2, 3,
        0, 1, 4,
        0, 4, 3,
        3, 4, 2,
        1, 4, 3,
    };

    //顶点缓存
    GLuint attBuffer;
    glGenBuffers(1, &attBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, attBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(attrArr), attrArr, GL_DYNAMIC_DRAW);
    
    //索引缓存
    GLuint index;
    glGenBuffers(1, &index);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, index);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indexArry), indexArry, GL_STATIC_DRAW);
    
    
    //坐标的位置
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
    //获取纹理入口0
    glActiveTexture(GL_TEXTURE0);//在绑定纹理之前先激活纹理单元
    glBindTexture(GL_TEXTURE_2D, texture0);
    glUniform1i(glGetUniformLocation(_myProgram, "courTexture"), 0);
    //纹理1
//    glActiveTexture(GL_TEXTURE1);
//    glBindTexture(GL_TEXTURE_2D, texture1);
//    glUniform1i(glGetUniformLocation(_myProgram, "courTexture1"), 1);
    
    
    KSMatrix4 _modeMatrix;
    ksMatrixLoadIdentity(&_modeMatrix);
    
//    ksPerspective(&_modeMatrix, 90.f, CGRectGetWidth(self.frame)/CGRectGetHeight(self.frame), 1.0, 100.f);
    
    GLuint modem = glGetUniformLocation(_myProgram, "modForm");
    glUniformMatrix4fv(modem, 1, GL_FALSE, &_modeMatrix.m[0][0]);
    

    //一个矩阵  不再强求   这里过不去
    KSMatrix4 _projectionMatrix;
    ksMatrixLoadIdentity(&_projectionMatrix);//单位矩阵
    //平移 （1 1 0）
    ksTranslate(&_projectionMatrix, 0.2, 0.2, 0.f);
    //逆时针旋转90度 绕Z轴
    ksRotate(&_projectionMatrix, -60.f, 0.f, 0.f, 1.f);
    ksScale(&_projectionMatrix, 1.0, 1.0, 1.0);
    
    GLuint tranfram = glGetUniformLocation(_myProgram, "transform");
    glUniformMatrix4fv(tranfram, 1, GL_FALSE, &_projectionMatrix.m[0][0]);
    
    //透视投影
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


/*
 向量矩阵基本用法 这里不再说明  
 缩放矩阵{Sx 0 0 0
      0 Sy 0 0
      0 0 Sz 0 
      0 0 0  1}
 位移矩阵{
      1 0 0 Tx
      0 1 0 Ty
      0 0 1 Tz
      0 0 0 1
 }
 旋转
 X轴{
 1   0      0       0
 0  cosθ  sinθ     0
 0  −sinθ cosθ     0
 0   0      0       1
 }
 Y轴{
 cosθ   0     −sinθ     0
 0      1       0       0
sinθ    0     cosθ      0
 0      0       0       1
 }
 Z轴
 {
 cosθ     sinθ      0    0 
 −sinθ    cosθ      0    0
 0         0        1    0
 0         0        0    1
 }
 
 任一轴
 {
 cosθ+Rx2(1−cosθ)      RyRx(1−cosθ)+Rzsinθ     RzRx(1−cosθ)−Rysinθ    0
 RxRy(1−cosθ)−Rzsinθ     cosθ+Ry2(1−cosθ)      RzRy(1−cosθ)+Rxsinθ    0
 RxRz(1−cosθ)+Rysinθ   RyRz(1−cosθ)−Rxsinθ       cosθ+Rz2(1−cosθ)     0
 0                           0                      0                  1
 }
 
 万向节死锁问题  暂时不讨论 四元数  尼玛牛逼了当初都没有证明过
 */


/*
 透视投影
 在保留物体深度立体感的前提下将3d世界的物体投影到2d平面上。
 
 对图形的透视变换需要提供四个参数：
 1.屏幕宽高比：举行屏幕的宽高比例是投影的目标；
 2.垂直视野：相机窗口看向3d世界的垂直方向上的角度；
 3.Z轴近平面的位置：近平面用于将离相机太近的物体裁剪掉；
 4.Z轴远平面的位置：远平面用于将离相机太远的物体裁剪掉；
 
 屏幕宽高比是一个必要的参数，因为我们要在一个宽高相等的单位化的盒子内展示所有的坐标系，而通常屏幕的宽度是大于屏幕的高度的，所以需要在水平方向上的轴线上布置更加密集的坐标点，竖直方向上相对稀疏。这样经过变换，我们就可以在保证看到更宽阔屏幕图像的需求下，根据X轴在单位盒子空间内的比例，在X方向上添加更多的X坐标。
 
 
 */






