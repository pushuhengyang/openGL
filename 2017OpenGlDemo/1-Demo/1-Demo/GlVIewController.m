//
//  GlVIewController.m
//  1-Demo
//
//  Created by xuwenhao on 17/3/26.
//  Copyright © 2017年 Hiniu. All rights reserved.
//  一切从新开始

#import "GlVIewController.h"

@interface GlVIewController ()

@property(strong,nonatomic)EAGLContext *context;//这个是上下文 跟随指令的
@property (nonatomic , strong) GLKBaseEffect* mEffect;


@end


@implementation GlVIewController

-(void)viewDidLoad{
    [super viewDidLoad];
    
    _context = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    GLKView *view = (GLKView *)self.view;
    view.context = _context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    view.drawableColorFormat=GLKViewDrawableColorFormatRGBA8888;//颜色缓冲区格式
    [EAGLContext setCurrentContext:_context];
    
     glClearColor(0.3f, 0.6f, 1.f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    
    //顶点索引 方式
    //顶点数据，前三个是顶点坐标，后面两个是纹理坐标
    GLfloat squareVertexData[] =
    {
        0.5, 0.5, 0, 1.0,0.f,0.f,
        -0.5, 0, 0.0f,0.0,1.f,0.f,
        0, -0.5, 0.0f,0.0,0.f,1.f,
    };
    /*
     #define GL_POINTS                                        0x0000
     #define GL_LINES                                         0x0001
     #define GL_LINE_LOOP                                     0x0002
     #define GL_LINE_STRIP                                    0x0003
     #define GL_TRIANGLES                                     0x0004
     #define GL_TRIANGLE_STRIP                                0x0005
     #define GL_TRIANGLE_FAN                                  0x0006
     */
    GLuint indices[]={
        0, 1, 2,
        1, 3, 0
    };
    
    
    
    //顶点数据缓存
    GLuint buffer;  //一个全局变量 引用
    glGenBuffers(1, &buffer); //申请一个handers 之后不再重复 除非删除 或者重置
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    /*
     目标名GL_ARRAY_BUFFER意思是这个buffer将存储一个顶点的数组。另外一个有用的目标是GL_ELEMENT_ARRAY_BUFFER,这个的意思是这个buffer存储的是另一个buffer中顶点的标记
     */
    
    /**
    绑定了我们的对象之后，我们要往里面添加数据。这个回调函数取得我们之前绑定的目标名参数GL_ARRAY_BUFFER，还有数据的比特数参数，顶点数组的地址，还有一个表示这个数据模式的标志变量。因为我们不会去改变这个buffer的内容所以这里用了GL_STATIC_DRAW标志，相反的标志是GL_DYNAMIIC_DRAW, 这个只是给OpenGL的一个提示来给一些觉得合理的标志量使用，驱动程序可以通过它来进行启发式的优化（比如：内存中哪个位置最合适存储这个buffer缓冲）。
     */
    glBufferData(GL_ARRAY_BUFFER, sizeof(squareVertexData), squareVertexData, GL_STATIC_DRAW);
    
    
 //   索引缓存
    GLuint index;
    glGenBuffers(1, &index);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, index);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    
    
    
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*6, (GLfloat *)NULL+0);
    
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*6, (GLfloat *)NULL+3);
    
    _mEffect = [[GLKBaseEffect alloc] init];
//    _mEffect.texture2d0.enabled = GL_TRUE;
//    _mEffect.texture2d0.name =
  
}

-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    glClearColor(0.3f, 0.6f, 1.f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    [self.mEffect prepareToDraw];
    
    
/*
 最后，我们调用函数回调来绘制几何图形。之前所有的指令都非常重要，但它们只是设置了绘制指令的每一步的准备工作。这个指令才是GPU真正开始工作的地方。这个指令将整合这个指令收到的绘制参数和之前为这一个点的图形建立的状态数据来将结果渲染在屏幕上
 
 OpenGL提供了集中不同类型的draw call绘制回调，每一种各自适用于不同的案例情况。一般情况下可以将他们分成两类：顺序绘制和索引绘制。顺序绘制较简单，GPU经过你的顶点缓冲区，一个一个的挨着处理每一个顶点，并根据draw call中定义的拓扑结构来解析他们。
 
 索引绘制相比顺序绘制更加复杂而且额外有一个索引缓冲区。索引缓冲区存储着顶点缓冲区中顶点的索引标志。GPU以和上面描述的类似的模式扫描索引缓冲区，索引0-2表示第一个三角形等等以此类推。如果两个三角形共用一个顶点只需要在索引缓冲区定义两次这个顶点的索引即可，顶点缓冲区只需要存储一个顶点数据。在游戏中索引绘制更常用，因为多数游戏模型是使用三角形图元来组成模型的表面（人的皮肤，城堡的墙等等），这些相连的三角形很多要共用一个顶点。
 */
//    glDrawArrays(GL_LINE_LOOP, 0, 4);   //顺序绘制
    glDrawElements(GL_TRIANGLE_FAN, 6, GL_UNSIGNED_INT, 0);
    
//    glDisableVertexAttribArray(0);//停止绘制

    
}

@end














