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
    //前三个是顶点坐标， 后面两个是纹理坐标
    GLfloat attrArr[] =
    {
//        0.5f, -0.5f, -1.0f,     1.0f, 0.0f,
//        -0.5f, 0.5f, -1.0f,     0.0f, 1.0f,
//        -0.5f, -0.5f, -1.0f,    0.0f, 0.0f,
//        0.5f, 0.5f, -1.0f,      1.0f, 1.0f,
//        -0.5f, 0.5f, -1.0f,     0.0f, 1.0f,
//        0.5f, -0.5f, -1.0f,     1.0f, 0.0f,
        
        
                0, 0.5f, -1.0f,     1.0f, 0.0f,
                0.5f, -0.5f, -1.0f,     0.0f, 1.0f,
                -0.5f, -0.5f, -1.0f,    0.0f, 0.0f,
    };
    
    //顶点缓存
    GLuint attBuffer;
    glGenBuffers(1, &attBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, attBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(attrArr), attrArr, GL_DYNAMIC_DRAW);
    
    
    //坐标的位置
    GLuint position =glGetAttribLocation(_myProgram, "Position");
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, NULL);
    glEnableVertexAttribArray(position);
    
    
    
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, sizeof(attrArr));
    [_myContext presentRenderbuffer:GL_RENDERBUFFER];
}



@end












