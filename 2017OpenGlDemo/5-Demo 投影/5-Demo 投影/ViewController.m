//
//  ViewController.m
//  5-Demo 投影
//
//  Created by xuwenhao on 17/3/29.
//  Copyright © 2017年 Hiniu. All rights reserved.
//

#import "ViewController.h"
#import "WH_OpenGlHander.h"
@interface ViewController ()
{

    GLKTextureInfo *texInfo0;
    GLKTextureInfo *texInfo1;

}
@property (nonatomic , strong) EAGLContext* mContext;


@property (strong, nonatomic) WH_OpenGlHander *vertexPositionBuffer;
@property (strong, nonatomic) WH_OpenGlHander *vertexNormalBuffer;
@property (strong, nonatomic) WH_OpenGlHander *vertexTextureCoordBuffer;

@property (strong, nonatomic) GLKBaseEffect *baseEffect;
@property (strong, nonatomic) GLKTextureInfo *earthTextureInfo;
@property (strong, nonatomic) GLKTextureInfo *moonTextureInfo;

@property (nonatomic) GLKMatrixStackRef modelviewMatrixStack;
@property (nonatomic) GLfloat earthRotationAngleDegrees;
@property (nonatomic) GLfloat moonRotationAngleDegrees;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUI];

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)setUI{
    _mContext = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    GLKView *view = (GLKView *)self.view;
    view.context = _mContext;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    glEnable(GL_DEPTH_TEST);//打开深度测试
    [EAGLContext setCurrentContext:_mContext];

    [self drawNew];
}

-(void)drawNew{
    
    GLfloat attrArr[] =
    {
        -0.5f, 0.5f, 0.0f,      0.0f, 0.0f, 1.0f,       0.0f, 1.0f,//左上
        0.5f, 0.5f, 0.0f,       1.0f, 0.0f, 0.0f,       1.0f, 1.0f,//右上
        -0.5f, -0.5f, 0.0f,     0.0f, 0.0f, 0.5f,       0.0f, 0.0f,//左下
        0.5f, -0.5f, 0.0f,      0.0f, 0.5f, 0.0f,       1.0f, 0.0f,//右下
        0.0f, 0.0f, 1.0f,       1.0f, 1.0f, 1.0f,       0.5f, 0.5f,//顶点
    };
    //顶点索引
    GLuint indices[] =
    {
        0, 3, 2,
        0, 1, 3,
        0, 2, 4,
        0, 4, 1,
        2, 3, 4,
        1, 4, 3,
    };
    
    //顶点  索引 缓存
    GLuint verBuff ;
    glGenBuffers(1, &verBuff);
    glBindBuffer(GL_ARRAY_BUFFER, verBuff);
    glBufferData(GL_ARRAY_BUFFER, sizeof(attrArr), attrArr, GL_STATIC_DRAW);
    
    GLuint index;
    glGenBuffers(1, &index);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, index);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    
    //位置 纹理 颜色 输入
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3,  GL_FLOAT, GL_FALSE, sizeof(GLfloat)*8, (GLfloat *)NULL);
    
//    glEnableVertexAttribArray(GLKVertexAttribColor);
//    glVertexAttribPointer(GLKVertexAttribColor, 3,  GL_FLOAT, GL_FALSE, sizeof(GLfloat)*8, (GLfloat *)NULL+3);
  
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2,  GL_FLOAT, GL_FALSE, sizeof(GLfloat)*8, (GLfloat *)NULL+6);
    
//    glEnableVertexAttribArray(GLKVertexAttribTexCoord1);
//    glVertexAttribPointer(GLKVertexAttribTexCoord1, 2,  GL_FLOAT, GL_FALSE, sizeof(GLfloat)*8, (GLfloat *)NULL+6);

    //纹理
    NSString *imgPath1 = [[NSBundle mainBundle]pathForResource:@"leaves" ofType:@"gif"];
    NSString *imgPath = [[NSBundle mainBundle]pathForResource:@"beetle" ofType:@"png"];

    NSDictionary *option = [NSDictionary dictionaryWithObjectsAndKeys:@(1),GLKTextureLoaderOriginBottomLeft, nil];
    texInfo0 = [GLKTextureLoader textureWithContentsOfFile:imgPath options:option error:nil];

    texInfo1 =[GLKTextureLoader textureWithContentsOfFile:imgPath1 options:option error:nil];

    _baseEffect = [[GLKBaseEffect alloc] init];

    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    //多重纹理
//    GLint iunits;
//    glGetIntegerv(GL_MAX_TEXTURE_IMAGE_UNITS, &iunits);
//    
    
    /*
     
     GLKTextureEnvModeReplace	给第二个纹理设置该模式，只显示第二个纹理
     GLKTextureEnvModeModulate	默认使用，几乎总是产生最好的结果。它会让所有的为灯光和其他效果计算出来的颜色与从一个纹理取样的颜色相混合。
     GLKTextureEnvModeDecal	开启多重纹理，启用一个和 glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)类似的方程式来混合两个纹理
     */
    
//    _baseEffect.texture2d0.enabled = GL_TRUE;
//    _baseEffect.texture2d0.name = texInfo0.name;
//    _baseEffect.texture2d0.target = texInfo0.target;
//    
//    _baseEffect.texture2d1.name = texInfo1.name;
//    _baseEffect.texture2d1.target = texInfo1.target;
//    _baseEffect.texture2d1.envMode = GLKTextureEnvModeDecal;

//    
    CGSize size = self.view.bounds.size;
    float aspect = fabs(size.width / size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90.0), aspect, 1.0f, 100.f);
    
    projectionMatrix = GLKMatrix4Scale(projectionMatrix, 1.0f, 1.0f, 1.0f);
    _baseEffect.transform.projectionMatrix = projectionMatrix;
    GLKMatrix4 modelViewMatrix = GLKMatrix4Translate(GLKMatrix4Identity, 0.0f, 0.0f, -2.0f);
    _baseEffect.transform.modelviewMatrix = GLKMatrix4Rotate(modelViewMatrix, 0.2, 0.5, 0.5, 0.1);
  
}


-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    glClearColor(0.3f, 0.3f, 0.3f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT );
    
    _baseEffect.texture2d0.name = texInfo0.name;
    _baseEffect.texture2d0.target = texInfo0.target;
    [_baseEffect prepareToDraw];
    glDrawElements(GL_TRIANGLES, 18, GL_UNSIGNED_INT, 0);

    _baseEffect.texture2d0.name = texInfo1.name;
    _baseEffect.texture2d0.target = texInfo1.target;
    [_baseEffect prepareToDraw];
    glDrawElements(GL_TRIANGLES, 18, GL_UNSIGNED_INT, 0);
}

-(void)dealloc{
    if (_baseEffect) {
        //删除缓存
//        glDeleteBuffers(<#GLsizei n#>, <#const GLuint *buffers#>)
    }
}

@end
