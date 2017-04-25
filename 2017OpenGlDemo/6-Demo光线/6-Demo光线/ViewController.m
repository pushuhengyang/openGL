//
//  ViewController.m
//  6-Demo光线
//
//  Created by xuwenhao on 17/4/3.
//  Copyright © 2017年 Hiniu. All rights reserved.
//

#import "ViewController.h"
#import "sceneUtil.h"//三角形数据处理
#import "WH_OpenGlHander.h"

@interface ViewController ()
{
    SceneTriangle triangles[NUM_FACES];

}
@property(strong,nonatomic)EAGLContext *mContent;//上下文
@property(strong,nonatomic)GLKBaseEffect *mBaseFfect;//总设置
@property (strong, nonatomic) GLKBaseEffect *extraEffect; //光线设置

@property(strong,nonatomic)GLKTextureInfo *textInfo;//纹理
@property (strong, nonatomic) WH_OpenGlHander *vertexBuffer;
@property (strong, nonatomic) WH_OpenGlHander *extraBuffer;

@property (nonatomic) BOOL shouldUseFaceNormals;
@property (nonatomic) BOOL shouldDrawNormals;
@property (nonatomic) GLfloat centerVertexHeight;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUI];
}

-(void)setUI{
    _mContent = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    GLKView *view = (GLKView *)self.view;
    view.context = _mContent;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    [EAGLContext setCurrentContext:_mContent];
//    glEnable(GL_DEPTH_TEST);
    _mBaseFfect = [[GLKBaseEffect alloc]init];

    //光线   这里最多添加3种光线  用脚本可以添加更多光线
    /*
     发射光（emission）
     环境光（ambient)   //moren 黑色
     漫反射光（diffuse）
     镜面反射光（specular）默认 白色
     */
    _mBaseFfect.light0.enabled = GL_TRUE;
//    _mBaseFfect.light0.ambientColor = GLKVector4Make(1.0, 0.0, 0.0, 1.0);
    _mBaseFfect.light0.diffuseColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0);//物体漫反射颜色
    /*
       最后一个是0 表示前面三个为方向  如果不是0  表示前面的是位置 这里是方向
     */
    _mBaseFfect.light0.position = GLKVector4Make(1.0, 1.0, 0.5, 0.0);
    
    _extraEffect = [[GLKBaseEffect alloc]init];
    _extraEffect.useConstantColor = GL_TRUE;
    _extraEffect.constantColor = GLKVector4Make(1.0, 0.0, 1.0, 1.0);
    
    [self setClearColor:GLKVector4Make(0.0, 0.0, 0.0, 1.0)];
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeRotation(
                                                        GLKMathDegreesToRadians(-60.0f), 1.0f, 0.0f, 0.0f);
    modelViewMatrix = GLKMatrix4Rotate(
                                       modelViewMatrix,
                                       GLKMathDegreesToRadians(-40.0f), 0.0f, 0.0f, 1.0f);
    modelViewMatrix = GLKMatrix4Translate(
                                          modelViewMatrix,
                                          0.0f, 0.0f, 0.25f);
    
    
    _mBaseFfect.transform.modelviewMatrix = modelViewMatrix;
    _extraEffect.transform.modelviewMatrix = modelViewMatrix;
    
    [self drawNew];
    
}

-(void)drawNew{
    //8个三角形
    triangles[0] = SceneTriangleMake(vertexA, vertexB, vertexD);
    triangles[1] = SceneTriangleMake(vertexB, vertexC, vertexF);
    triangles[2] = SceneTriangleMake(vertexD, vertexB, vertexE);
    triangles[3] = SceneTriangleMake(vertexE, vertexB, vertexF);
    triangles[4] = SceneTriangleMake(vertexD, vertexE, vertexH);
    triangles[5] = SceneTriangleMake(vertexE, vertexF, vertexH);
    triangles[6] = SceneTriangleMake(vertexG, vertexD, vertexH);
    triangles[7] = SceneTriangleMake(vertexH, vertexF, vertexI);

    //放进缓存中
    _vertexBuffer = [[WH_OpenGlHander alloc]initWithAttribStride:sizeof(SceneVertex) numberOfVertices:sizeof(triangles)/sizeof(SceneVertex) bytes:triangles usage:GL_DYNAMIC_DRAW];//
    
    
    _extraBuffer = [[WH_OpenGlHander alloc]initWithAttribStride:sizeof(SceneVertex) numberOfVertices:0 bytes:NULL usage:GL_DYNAMIC_DRAW];
    

    self.centerVertexHeight = 0.0f;
    self.shouldUseFaceNormals = YES;
    
}

- (void)setShouldUseFaceNormals:(BOOL)aValue
{
    if(aValue != _shouldUseFaceNormals)
    {
        _shouldUseFaceNormals = aValue;
        
        [self updateNormals];
    }
}

- (void)setClearColor:(GLKVector4)clearColorRGBA
{
    glClearColor(
                 clearColorRGBA.r,
                 clearColorRGBA.g,
                 clearColorRGBA.b,
                 clearColorRGBA.a);
}

- (void)setCenterVertexHeight:(GLfloat)aValue
{
    _centerVertexHeight = aValue;
    
    SceneVertex newVertexE = vertexE;
    newVertexE.position.z = _centerVertexHeight;
    
    triangles[2] = SceneTriangleMake(vertexD, vertexB, newVertexE);
    triangles[3] = SceneTriangleMake(newVertexE, vertexB, vertexF);
    triangles[4] = SceneTriangleMake(vertexD, newVertexE, vertexH);
    triangles[5] = SceneTriangleMake(newVertexE, vertexF, vertexH);
    
    [self updateNormals];
}

- (void)updateNormals
{
    if(self.shouldUseFaceNormals)
    {
        SceneTrianglesUpdateFaceNormals(triangles);
    }
    else
    {
        SceneTrianglesUpdateVertexNormals(triangles);
    }
    
    [self.vertexBuffer
     reinitWithAttribStride:sizeof(SceneVertex)
     numberOfVertices:sizeof(triangles) / sizeof(SceneVertex)
     bytes:triangles];
}


-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    [_mBaseFfect prepareToDraw];
    [_vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition numberOfCoordinates:3 attribOffset:offsetof(SceneVertex, position) shouldEnable:YES];
    
    [_vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribNormal
                           numberOfCoordinates:3
                                  attribOffset:offsetof(SceneVertex, normal)
                                  shouldEnable:YES];
    
    [_vertexBuffer drawArrayWithMode:GL_TRIANGLES
                        startVertexIndex:0
                        numberOfVertices:sizeof(triangles) / sizeof(SceneVertex)];
    if(self.shouldDrawNormals)
    {
        [self drawNormals];
    }
}

- (void)drawNormals
{
    GLKVector3  normalLineVertices[NUM_LINE_VERTS];
    //光照量
    SceneTrianglesNormalLinesUpdate(triangles,
                                    GLKVector3MakeWithArray(self.mBaseFfect.light0.position.v),
                                    normalLineVertices);
    
    [self.extraBuffer reinitWithAttribStride:sizeof(GLKVector3)
                            numberOfVertices:NUM_LINE_VERTS
                                       bytes:normalLineVertices];
    
    [self.extraBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition
                          numberOfCoordinates:3
                                 attribOffset:0
                                 shouldEnable:YES];
    
    
    self.extraEffect.useConstantColor = GL_TRUE;
    self.extraEffect.constantColor =
    GLKVector4Make(0.0, 1.0, 0.0, 1.0);
    
    [self.extraEffect prepareToDraw];
    
    [self.extraBuffer drawArrayWithMode:GL_LINES
                       startVertexIndex:0
                       numberOfVertices:NUM_NORMAL_LINE_VERTS];
    
    self.extraEffect.constantColor =
    GLKVector4Make(1.0, 1.0, 0.0, 1.0);
    
    [self.extraEffect prepareToDraw];
    
    [self.extraBuffer drawArrayWithMode:GL_LINES
                       startVertexIndex:NUM_NORMAL_LINE_VERTS
                       numberOfVertices:(NUM_LINE_VERTS - NUM_NORMAL_LINE_VERTS)];
}

@end










