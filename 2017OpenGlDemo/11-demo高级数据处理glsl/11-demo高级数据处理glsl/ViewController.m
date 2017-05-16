//
//  ViewController.m
//  11-demo高级数据处理glsl
//
//  Created by xuwenhao on 17/5/10.
//  Copyright © 2017年 Hiniu. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic , assign) GLuint       myProgram;  //
@property (nonatomic , strong) EAGLContext* context;   //上下文


@end

@implementation ViewController

GLfloat basColor[] = {
    0.0, 0.0, 0.0,
    0.2, 0.0, 0.4,
    0.3, 0.6, 0.0,
    0.4, 0.5, 0.2,
    0.5, 0.3, 0.9,
    0.6, 0.2, 0.8,
    0.7, 0.1, 0.6,
    0.8, 0.4, 0.7,
};


//GLfloat vertices[] = {
//    -0.5, -0.5,  0.5,
//    0.5, -0.5,  0.5,
//    -0.5,  0.5,  0.5,
//    0.5,  0.5,  0.5,
//    -0.5, -0.5, -0.5,
//    0.5, -0.5, -0.5,
//    -0.5,  0.5, -0.5,
//    0.5,  0.5, -0.5,
//};

//
GLfloat vertices[] = {
    -0.5, -0.5,  0.5,   0.1, 0.8, 0.5,   0.0,0.0,
     0.5, -0.5,  0.5,   0.2, 0.0, 0.4,   1.0,0.0,
    -0.5,  0.5,  0.5,   0.3, 0.6, 0.0,   0.0,1.0,
     0.5,  0.5,  0.5,   0.4, 0.5, 0.2,   1.0,1.0,
    -0.5, -0.5, -0.5,   0.5, 0.3, 0.9,   1.0,0.0,
     0.5, -0.5, -0.5,   0.6, 0.2, 0.8,   0.0,0.0,
    -0.5,  0.5, -0.5,   0.7, 0.1, 0.6,   1.0,1.0,
     0.5,  0.5, -0.5,   0.8, 0.4, 0.7,   0.0,1.0,
};


//纹理
CGFloat norm1[]={
    0.0,0.0,
    1.0,0.0,
    0.0,1.0,
    1.0,1.0,
    
    1.0,0.0,
    0.0,0.0,
    1.0,1.0,
    0.0,1.0,
    
};

GLfloat norm2[]={
    0.0,0.0,
    1.0,0.0,
    0.0,0.0,
    1.0,0.0,
    
    0.0,1.0,
    1.0,1.0,
    0.0,1.0,
    1.0,1.0,
    
};

GLuint indices[36]={
    0,1,2,
    1,3,2,
    1,5,3,
    5,7,3,
    5,7,4,
    7,6,4,
    6,2,4,
    2,0,4,
    2,3,7,
    7,6,2,
    0,1,5,
    0,5,4,
};

GLuint indices2[12]={
    
    2,3,7,
    7,6,2,
    0,1,5,
    0,5,4,
};


- (void)viewDidLoad {
    [super viewDidLoad];
   
    [self setUI];
    [self renderLink];
 

//    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"22222" ofType:@"jpg"];
//  
    GLuint texture0;
    [self setupTexture:@"22222.jpg" and:&texture0];//生成纹理

    
    
//    NSDictionary* options = [NSDictionary dictionaryWithObjectsAndKeys:@(1), GLKTextureLoaderOriginBottomLeft, nil];
//    
//    GLKTextureInfo *texinfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:nil];
//    
//    
    if (_myProgram==0) {
        return;
    }
    
    
    glEnable(GL_DEPTH_TEST);
    glClearColor(0.3f, 0.6f, 0.1f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    GLuint buffer;
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER,sizeof(vertices) , vertices, GL_DYNAMIC_DRAW);

    
    GLuint index;
    glGenBuffers(1, &index);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, index);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    
    
       GLuint position =glGetAttribLocation(_myProgram, "Position");

        glEnableVertexAttribArray(position);
        glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*8, (GLfloat *)NULL+0);
    
    GLuint basColor = glGetAttribLocation(_myProgram, "baseColor");

    glEnableVertexAttribArray(basColor);
        glVertexAttribPointer(basColor, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*8, (GLfloat *)NULL+3);
    
    GLuint color = glGetAttribLocation(_myProgram, "textCoordinate");

    glEnableVertexAttribArray(color);
        glVertexAttribPointer(color, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*8, (GLfloat *)NULL+6);

    
    
    
//    glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(vertices), vertices);
//    glBufferSubData(GL_ARRAY_BUFFER, sizeof(vertices), sizeof(basColor), basColor);
//    glBufferSubData(GL_ARRAY_BUFFER, sizeof(vertices)+sizeof(basColor), sizeof(norm1), norm1);
//
//    
//    
//    GLuint position =glGetAttribLocation(_myProgram, "Position");
//    glEnableVertexAttribArray(position);
//
//    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*3, (GLvoid *)(NULL));
//    
//    GLuint basCo = glGetAttribLocation(_myProgram, "baseColor");
//    glVertexAttribPointer(basCo, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*3, (GLvoid *)(sizeof(vertices)));
//    glEnableVertexAttribArray(basCo);
//    
////    纹理坐标缓存
//    GLuint color = glGetAttribLocation(_myProgram, "textCoordinate");
//    glEnableVertexAttribArray(color);
//    glVertexAttribPointer(color, 2, GL_FLOAT, GL_FALSE,2*sizeof(GLfloat), (GLvoid *)(NULL)+48);
//    

    
    glActiveTexture(GL_TEXTURE0);//在绑定纹理之前先激活纹理单元
    glBindTexture(GL_TEXTURE_2D, texture0);
    glUniform1i(glGetUniformLocation(_myProgram, "courTexture"), 0);
    
    
}


-(void)setUI{
    _context = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    GLKView *view = (GLKView *)self.view;
    view.context = _context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    view.drawableColorFormat=GLKViewDrawableColorFormatRGBA8888;//颜色缓冲区格式
    [EAGLContext setCurrentContext:_context];
    
}



-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    glClearColor(0.3f, 0.6f, 1.f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);

    glDrawElements(GL_TRIANGLES, 36, GL_UNSIGNED_INT, 0);
    
    ;

}







-(void)renderLink{
    glClearColor(0, 1, 1, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    CGRect rect = [UIScreen mainScreen].bounds;
    CGFloat scale = [UIScreen mainScreen].scale;
    glViewport(rect.origin.x * scale, rect.origin.y * scale, rect.size.width * scale, rect.size.height * scale); //设置视口大小
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
//        if (!success) {
//            GLchar messages[256];
//            glGetProgramInfoLog(_myProgram, sizeof(messages), NULL, &messages[0]);
//            NSLog(@"error=%@",[NSString stringWithUTF8String:messages]);
//            exit(1);
//        }
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
