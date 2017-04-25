//
//  ViewController.m
//  7-Demo 地球旋转模型
//
//  Created by xuwenhao on 17/4/6.
//  Copyright © 2017年 Hiniu. All rights reserved.
//

#import "ViewController.h"
#import "WH_OpenGlHander.h"
#import "sphere.h"

@interface ViewController ()

@property (nonatomic , strong) EAGLContext* mContext;

@property (strong, nonatomic) WH_OpenGlHander *vertexPositionBuffer;
@property (strong, nonatomic) WH_OpenGlHander *vertexNormalBuffer;
@property (strong, nonatomic) WH_OpenGlHander *vertexTextureCoordBuffer;

@property (strong, nonatomic) GLKBaseEffect *baseEffect;
@property (strong, nonatomic) GLKTextureInfo *earthTextureInfo;
@property (strong, nonatomic) GLKTextureInfo *moonTextureInfo;

@property (nonatomic) GLKMatrixStackRef modelviewMatrixStack;  //一个矩阵堆
@property (nonatomic) GLfloat earthRotationAngleDegrees;

- (IBAction)slideChange:(id)sender;





@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self orignSetting];
}

-(void)orignSetting{
    _mContext = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    GLKView *view=(GLKView *)self.view;
    view.context=_mContext;
    view.drawableColorFormat=GLKViewDrawableColorFormatRGBA8888;
    view.drawableDepthFormat=GLKViewDrawableDepthFormat24;
    [EAGLContext setCurrentContext:_mContext];
    glEnable(GL_DEPTH_TEST);
    _baseEffect=[GLKBaseEffect new];
    _baseEffect.light0.enabled=GL_TRUE;
    _baseEffect.light0.diffuseColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0);//漫反射光
    _baseEffect.light0.position = GLKVector4Make(1.0, 0.0, 0.8, 0.0);
    _baseEffect.light0.ambientColor = GLKVector4Make(0.2, 0.2, 0.2, 1.0);//环境光
    
    _baseEffect.light1.enabled = GL_TRUE;
    _baseEffect.light1.diffuseColor = GLKVector4Make(1.0, 0.0, 0.0, 1.0);//漫反射光
    _baseEffect.light1.position = GLKVector4Make(-1.0, 0.0, 0.8, 0.0);
    _baseEffect.light1.ambientColor = GLKVector4Make(0.2, 0.2, 0.2, 1.0);//环境光
    
    
    
    CGSize size = [UIScreen mainScreen].bounds.size;
    GLfloat  aspectRatio =size.width/size.height;
    //正视投影
    _baseEffect.transform.projectionMatrix=  GLKMatrix4MakeOrtho(
                                                                 -1.0 * aspectRatio,
                                                                 1.0 * aspectRatio,
                                                                 -1.0,
                                                                 1.0,
                                                                 1.0,
                                                                 120.0);

    //变换矩阵
    _baseEffect.transform.modelviewMatrix=GLKMatrix4MakeTranslation(0.0f, 0.0f, -5.0);
    glClearColor(0.0, 0.0, 0.0, 1.0);
    [self bufferData];
    _earthRotationAngleDegrees = 0.f;
}

-(void)bufferData{
    _modelviewMatrixStack =GLKMatrixStackCreate(kCFAllocatorDefault);
    
    _vertexPositionBuffer = [[WH_OpenGlHander alloc]initWithAttribStride:3*sizeof(GLfloat) numberOfVertices:sizeof(sphereVerts)/(3*sizeof(GLfloat)) bytes:sphereVerts usage:GL_STATIC_DRAW];
    //顶点法线？
    _vertexNormalBuffer = [[WH_OpenGlHander alloc]
                           initWithAttribStride:(3 * sizeof(GLfloat))
                           numberOfVertices:sizeof(sphereNormals) / (3 * sizeof(GLfloat))
                           bytes:sphereNormals
                           usage:GL_STATIC_DRAW];
    
    _vertexTextureCoordBuffer = [[WH_OpenGlHander alloc]
                                 initWithAttribStride:(2 * sizeof(GLfloat))
                                 numberOfVertices:sizeof(sphereTexCoords) / (2 * sizeof(GLfloat))
                                 bytes:sphereTexCoords
                                 usage:GL_STATIC_DRAW];
    
    CGImageRef earthImageRef = [[UIImage imageNamed:@"Earth512x256.jpg"] CGImage];
    NSDictionary *options = @{GLKTextureLoaderOriginBottomLeft:@(1)};
    
    _earthTextureInfo = [GLKTextureLoader textureWithCGImage:earthImageRef options:options error:nil];
    GLKMatrixStackLoadMatrix4(_modelviewMatrixStack, _baseEffect.transform.modelviewMatrix);

}


-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    glClearColor(0.3f, 0.3f, 0.3f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    self.earthRotationAngleDegrees += 360.0f / 60.0f;//一次6度，，

    
    [self.vertexPositionBuffer
     prepareToDrawWithAttrib:GLKVertexAttribPosition
     numberOfCoordinates:3
     attribOffset:0
     shouldEnable:YES];
    [self.vertexNormalBuffer
     prepareToDrawWithAttrib:GLKVertexAttribNormal
     numberOfCoordinates:3
     attribOffset:0
     shouldEnable:YES];
    [self.vertexTextureCoordBuffer
     prepareToDrawWithAttrib:GLKVertexAttribTexCoord0
     numberOfCoordinates:2
     attribOffset:0
     shouldEnable:YES];

    [self drawEarth];
}

-(void)drawEarth{
    _baseEffect.texture2d0.name = _earthTextureInfo.name;
    _baseEffect.texture2d0.target=_earthTextureInfo.target;
    GLKMatrixStackLoadMatrix4(_modelviewMatrixStack, _baseEffect.transform.modelviewMatrix);
    GLKMatrixStackPush(_modelviewMatrixStack);//入栈
    GLKMatrixStackRotate(_modelviewMatrixStack, GLKMathDegreesToRadians(90.f), 1.0, 0.0, 0.0);
    
    GLKMatrixStackRotate(self.modelviewMatrixStack,
                         GLKMathDegreesToRadians(self.earthRotationAngleDegrees),
                         0.0, 1.0, 0.0);
    _baseEffect.transform.modelviewMatrix = GLKMatrixStackGetMatrix4(_modelviewMatrixStack);

    [_baseEffect prepareToDraw];
    [WH_OpenGlHander
     drawPreparedArraysWithMode:GL_TRIANGLES
     startVertexIndex:0
     numberOfVertices:sphereNumVerts];//渲染
    GLKMatrixStackPop(_modelviewMatrixStack); //出栈后跟进栈前是一样的
    _baseEffect.transform.modelviewMatrix = GLKMatrixStackGetMatrix4(_modelviewMatrixStack);

}

- (IBAction)slideChange:(id)sender {
    UISlider *slide = sender;
    CGFloat scr = 1.0-slide.value+0.1;
    GLKMatrix4 model =GLKMatrix4MakeTranslation(0.0f, 0.0f, -5.f);
    _baseEffect.transform.modelviewMatrix= GLKMatrix4ScaleWithVector3(model, GLKVector3Make(scr, scr, 1.0));
 

}
@end












