//
//  ViewController.m
//  6.1-Demo 光照
//
//  Created by xuwenhao on 17/4/5.
//  Copyright © 2017年 Hiniu. All rights reserved.
//

#import "ViewController.h"
#import "WH_OpenGlHander.h"
#import "TrangLightHander.h"

#define NUM_FACES 6

@interface ViewController ()
{
    SceneTriangle triangles[NUM_FACES];
}

@property(strong,nonatomic)EAGLContext *mContext;//上下文
@property(strong,nonatomic)GLKBaseEffect *mBaseEffect;//基本是处理位置与颜色的
@property(strong,nonatomic)GLKBaseEffect *mLightEffect;//处理光照的
@property(strong,nonatomic)GLKTextureInfo *textInfo;//纹理
@property(strong,nonatomic)WH_OpenGlHander *verBuffer;
@property(strong,nonatomic)WH_OpenGlHander *lightBuffer;

@property (nonatomic) BOOL shouldUseFaceNormals;//那种方式绘制光线

@end

@implementation ViewController

static const SceneVertex vertexA = {{-0.5,  0.5, -0.5}, {0.0, 0.0, 1.0},{0.0,1.0}};
static const SceneVertex vertexB = {{-0.5, -0.5, -0.5}, {0.0, 0.0, 1.0},{0.0,0.0}};
static const SceneVertex vertexC = {{ 0.5,  0.5, -0.5}, {0.0, 0.0, 1.0},{1.0,1.0}};
static const SceneVertex vertexD = {{ 0.5, -0.5, -0.5}, {0.0, 0.0, 1.0},{1.0,0.0}};
static const SceneVertex vertexE = {{ 0.0,  0.0,  0.5}, {0.0, 0.0, 1.0},{0.5,0.5}};





- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUI];

}

-(void)setUI{
    _mContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    GLKView *view = (GLKView *)self.view;
    view.context = _mContext;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;//这个就已经开启了深度缓存 我曹
    [EAGLContext setCurrentContext:_mContext];
    _mBaseEffect = [[GLKBaseEffect alloc]init];
    _mBaseEffect.light0.enabled = GL_TRUE;
    _mBaseEffect.light0.diffuseColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0);//物体漫反射颜色
    _mBaseEffect.light0.ambientColor = GLKVector4Make(0.2, 0.2, 0.2, 1.0);
    _mBaseEffect.light0.position = GLKVector4Make(1.0, 1.0, 0.5, 0.0);
    _mLightEffect = [[GLKBaseEffect alloc]init];
    _mLightEffect.useConstantColor = GL_TRUE;
    _mLightEffect.constantColor = GLKVector4Make(1.0, 0.0, 1.0, 1.0);
   
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeRotation(
                                                        GLKMathDegreesToRadians(-60.0f), 1.0f, 0.0f, 0.0f);
    modelViewMatrix = GLKMatrix4Rotate(
                                       modelViewMatrix,
                                       GLKMathDegreesToRadians(-40.0f), 0.0f, 0.0f, 1.0f);
//    modelViewMatrix = GLKMatrix4Translate(
//                                          modelViewMatrix,
//                                          0.0f, 0.0f, 0.25f);
    _mBaseEffect.transform.modelviewMatrix = modelViewMatrix;
    _mLightEffect.transform.modelviewMatrix = modelViewMatrix;
    [self drawNew];
}

-(void)drawNew{
    
   //三角形
    triangles[0] = SceneTriangleMake(vertexA, vertexB, vertexC);
    triangles[1] = SceneTriangleMake(vertexA, vertexB, vertexE);
    triangles[2] = SceneTriangleMake(vertexB, vertexD, vertexC);
    triangles[3] = SceneTriangleMake(vertexD, vertexB, vertexE);
    triangles[4] = SceneTriangleMake(vertexD, vertexE, vertexC);
    triangles[5] = SceneTriangleMake(vertexA, vertexE, vertexC);
    //放进缓存
    _verBuffer = [[WH_OpenGlHander alloc]initWithAttribStride:sizeof(SceneVertex) numberOfVertices:sizeof(triangles)/sizeof(SceneVertex) bytes:triangles usage:GL_DYNAMIC_DRAW];  //位置缓存
    
//    
    NSDictionary *option = [NSDictionary dictionaryWithObjectsAndKeys:@(1),GLKTextureLoaderOriginBottomLeft, nil];

    _textInfo = [GLKTextureLoader textureWithCGImage:[UIImage imageNamed:@"2222.jpg"].CGImage options:option error:nil];
    _mBaseEffect.texture2d0.enabled = GL_TRUE;
    _mBaseEffect.texture2d0.name = _textInfo.name;
    
    //光照缓存暂时没有数据 绘制的时候更新数据
     _lightBuffer = [[WH_OpenGlHander alloc]initWithAttribStride:sizeof(SceneVertex) numberOfVertices:0 bytes:NULL usage:GL_DYNAMIC_DRAW];
    
    self.shouldUseFaceNormals = YES;//用光照 （不是平均）
   
}

- (void)setShouldUseFaceNormals:(BOOL)aValue
{
    if(aValue != _shouldUseFaceNormals)
    {
        _shouldUseFaceNormals = aValue;
        
        [self updateNormals];
    }
}

- (void)updateNormals
{
    if(self.shouldUseFaceNormals)
    {
        SceneTrianglesUpdateFaceNormals(triangles,NUM_FACES);
    }
    else
    {
//        SceneTrianglesUpdateVertexNormals(triangles);
    }
    
    [self.verBuffer
     reinitWithAttribStride:sizeof(SceneVertex)
     numberOfVertices:sizeof(triangles) / sizeof(SceneVertex)
     bytes:triangles];
}

-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    glClearColor(0.3, 0.3, 0.3, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    [_mBaseEffect prepareToDraw];
    
    [_verBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition numberOfCoordinates:3 attribOffset:offsetof(SceneVertex, position) shouldEnable:GL_TRUE];
    
    [_verBuffer prepareToDrawWithAttrib:GLKVertexAttribTexCoord0 numberOfCoordinates:2 attribOffset:offsetof(SceneVertex, texTure) shouldEnable:GL_TRUE];

    [_verBuffer prepareToDrawWithAttrib:GLKVertexAttribNormal
                       numberOfCoordinates:3
                              attribOffset:offsetof(SceneVertex, normal)
                              shouldEnable:YES];
    
    [_verBuffer drawArrayWithMode:GL_TRIANGLES
                    startVertexIndex:0
                    numberOfVertices:sizeof(triangles) / sizeof(SceneVertex)];

//    if (self.shouldUseFaceNormals) {
//        
//    }
//    [self drawNorm];
}

//渲染光线
-(void)drawNorm{
    GLKVector3 normVertices[3*NUM_FACES];
    SceneTrianglesNormalLinesUpdate(triangles, GLKVector3MakeWithArray(self.mBaseEffect.light0.position.v), normVertices,NUM_FACES);
    
    [self.lightBuffer reinitWithAttribStride:sizeof(GLKVector3)
                            numberOfVertices:3*NUM_FACES
                                       bytes:normVertices];
    
    [self.lightBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition
                          numberOfCoordinates:3
                                 attribOffset:0
                                 shouldEnable:YES];
    
    self.mLightEffect.useConstantColor = GL_TRUE;
    self.mLightEffect.constantColor =
    GLKVector4Make(1.0, 1.0, 0.0, 1.0);
    
    [self.mLightEffect prepareToDraw];
    
    [self.lightBuffer drawArrayWithMode:GL_LINES
                       startVertexIndex:0
                       numberOfVertices:3*NUM_FACES];
    
    
    
    
}




















@end





















