//
//  WH_GLView.m
//  2-Demo 着色器
//
//  Created by xuwenhao on 17/3/27.
//  Copyright © 2017年 Hiniu. All rights reserved.
//

#import "WH_GLView.h"
#import <OpenGLES/ES2/gl.h>

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
    NSString* vertFile = [[NSBundle mainBundle] pathForResource:@"shader" ofType:@"vsh"];
    NSString* fragFile = [[NSBundle mainBundle] pathForResource:@"shader" ofType:@"fsh"];
    
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
          -0.5, 0.5f, 0.0f,  1.0f,1.0f,0.0f,   1.0f, 0.0f,    //左上
          -0.5f, -0.5, 0.0f,  1.0f,0.0f,1.0f,  1.0f, 1.0f,    //左下
          0.5f, -0.5, 0.0f, 0.0f,1.0f,1.0f,   0.0f, 1.0f,       //右下
          0.5f, 0.5, 0.0f, 0.0f,.0f,1.0f,   0.0f, 0.0f,       //右上
   
    };
    
    //顶点索引
    GLuint indexArry[]={
        0,1,2,
        2,3,0,
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
      [self setupTexture:@"222 2.jpg" and:&texture0];//生成纹理
    [self setupTexture:@"11111.jpg" and:&texture1];//另一个纹理
    //获取纹理入口0
    glActiveTexture(GL_TEXTURE0);//在绑定纹理之前先激活纹理单元
    glBindTexture(GL_TEXTURE_2D, texture0);
    glUniform1i(glGetUniformLocation(_myProgram, "courTexture"), 0);
//    //纹理1
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, texture1);
    glUniform1i(glGetUniformLocation(_myProgram, "courTexture1"), 1);
//
    glDrawElements(GL_TRIANGLE_STRIP, sizeof(indexArry)/sizeof(GLuint), GL_UNSIGNED_INT, 0);
    
//    glDrawArrays(GL_TRIANGLE_STRIP, 0, sizeof(attrArr));
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
    /*纹理环绕模式
     GL_REPEAT	对纹理的默认行为。重复纹理图像。
     GL_MIRRORED_REPEAT	和GL_REPEAT一样，但每次重复图片是镜像放置的。
     GL_CLAMP_TO_EDGE	纹理坐标会被约束在0到1之间，超出的部分会重复纹理坐标的边缘，产生一种边缘被拉伸的效果。
     GL_CLAMP_TO_BORDER	超出的坐标为用户指定的边缘颜色。
     */
    /*
     如果使用GL_CLAMP_TO_BORDER 模式 需要加一个函数指定颜色
     float borderColor[] = { 1.0f, 1.0f, 0.0f, 1.0f };
     glTexParameterfv(GL_TEXTURE_2D, GL_TEXTURE_BORDER_COLOR, borderColor);
     xyzw  位置
     spqt   纹理
     rgba   颜色
     
     glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_MIRRORED_REPEAT);
     glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_MIRRORED_REPEAT);

     */

   /*
       纹理过滤  一般两种 就近与线性 即GL_NEAREST（靠近纹理坐标的颜色）、GL_LINEAR（周围颜色的混合 ）
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    */
    
    /*
     多级渐远纹理
     GL_NEAREST_MIPMAP_NEAREST	使用最邻近的多级渐远纹理来匹配像素大小，并使用邻近插值进行纹理采样
     GL_LINEAR_MIPMAP_NEAREST	使用最邻近的多级渐远纹理级别，并使用线性插值进行采样
     GL_NEAREST_MIPMAP_LINEAR	在两个最匹配像素大小的多级渐远纹理之间进行线性插值，使用邻近插值进行采样
     GL_LINEAR_MIPMAP_LINEAR	在两个邻近的多级渐远纹理之间使用线性插值，并使用线性插值进行采样
     */
    
    /*
     纹理单元
     你可能会奇怪为什么sampler2D变量是个uniform，我们却不用glUniform给它赋值。使用glUniform1i，我们可以给纹理采样器分配一个位置值，这样的话我们能够在一个片段着色器中设置多个纹理。一个纹理的位置值通常称为一个纹理单元(Texture Unit)。一个纹理的默认纹理单元是0，它是默认的激活纹理单元，所以教程前面部分我们没有分配一个位置值。
     
     纹理单元的主要目的是让我们在着色器中可以使用多于一个的纹理。通过把纹理单元赋值给采样器，我们可以一次绑定多个纹理，只要我们首先激活对应的纹理单元。就像glBindTexture一样，我们可以使用glActiveTexture激活纹理单元，传入我们需要使用的纹理单元：
     glActiveTexture(GL_TEXTURE0); //在绑定纹理之前先激活纹理单元
     glBindTexture(GL_TEXTURE_2D, texture);
     激活纹理单元之后，接下来的glBindTexture函数调用会绑定这个纹理到当前激活的纹理单元，纹理单元GL_TEXTURE0默认总是被激活，所以我们在前面的例子里当我们使用glBindTexture的时候，无需激活任何纹理单元
     OpenGL至少保证有16个纹理单元供你使用，也就是说你可以激活从GL_TEXTURE0到GL_TEXTRUE15。它们都是按顺序定义的，所以我们也可以通过GL_TEXTURE0 + 8的方式获得GL_TEXTURE8，这在当我们需要循环一些纹理单元的时候会很有用。
     */
    
    
}

@end












