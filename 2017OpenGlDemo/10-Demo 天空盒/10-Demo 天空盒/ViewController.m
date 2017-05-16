//
//  ViewController.m
//  10-Demo 天空盒
//
//  Created by xuwenhao on 17/5/2.
//  Copyright © 2017年 Hiniu. All rights reserved.
//

#import "ViewController.h"
#import "starship.h"
#import "WH_DemoHander.h"

@interface ViewController ()

{
    BOOL isTouch;
    CGPoint oldPoint;
    
}

@property (nonatomic , strong) EAGLContext* mContext;

@property (strong, nonatomic) GLKBaseEffect *baseEffect;
@property (strong, nonatomic) WH_DemoHander *skyboxEffect;
@property (assign, nonatomic, readwrite) GLKVector3 eyePosition;
@property (assign, nonatomic) GLKVector3 lookAtPosition;
@property (assign, nonatomic) GLKVector3 upVector;
@property (assign, nonatomic) float angle;
@property (assign, nonatomic) float angle_y;


// BUFFER
@property (assign, nonatomic) GLuint mPositionBuffer;
@property (assign, nonatomic) GLuint mNormalBuffer;


@end

@implementation ViewController

-(void)viewDidLoad{
    
    [super viewDidLoad];
    _mContext = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    GLKView *view = (GLKView *)self.view;
    view.context  =_mContext;
    [EAGLContext setCurrentContext:_mContext];
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    isTouch = NO;
    oldPoint = CGPointZero;
    
    
    
    //观测
    _eyePosition = GLKVector3Make(0.0, 5.0, 5.0);
    _lookAtPosition = GLKVector3Make(0.0, 0.0, 0.0);
    _upVector = GLKVector3Make(0.0, 1.0, 0.0);
    
    self.baseEffect = [[GLKBaseEffect alloc] init];

    
    _angle_y = 0.0f;
    _angle = 0.1;
    [self setMatrices];
    
    //缓存
    GLuint buffer;
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(starshipPositions), starshipPositions, GL_STATIC_DRAW);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 0, NULL);
    
    glEnable(GL_CULL_FACE);
    glEnable(GL_DEPTH_TEST);
    
    NSString *path = [[NSBundle bundleForClass:[self class]]
                      pathForResource:@"image" ofType:@"png"];
    NSAssert(nil != path, @"Path to skybox image not found");
    NSError *error = nil;
  GLKTextureInfo*  textureInfo = [GLKTextureLoader
                                   cubeMapWithContentsOfFile:path
                                   options:nil
                                   error:&error];

    self.skyboxEffect = [[WH_DemoHander alloc] init];
    self.skyboxEffect.textureCubeMap.name = textureInfo.name;
    self.skyboxEffect.textureCubeMap.target = textureInfo.target;
    
    // 天空盒的长宽高
    self.skyboxEffect.xSize = 6.0f;
    self.skyboxEffect.ySize = 6.0f;
    self.skyboxEffect.zSize = 6.0f;
    
    
    
}

- (void)setMatrices
{
    const GLfloat aspectRatio = (GLfloat)(self.view.bounds.size.width) / (GLfloat)(self.view.bounds.size.height);
    self.baseEffect.transform.projectionMatrix =
    
    GLKMatrix4MakePerspective(GLKMathDegreesToRadians(85.0f),
                              aspectRatio,
                              0.1f,
                              20.0f);
    
    
        self.baseEffect.transform.modelviewMatrix =
        GLKMatrix4MakeLookAt(
                             self.eyePosition.x,
                             self.eyePosition.y,
                             self.eyePosition.z,
                             self.lookAtPosition.x,
                             self.lookAtPosition.y,
                             self.lookAtPosition.z,
                             self.upVector.x,
                             self.upVector.y,
                             self.upVector.z);
        
        // 增加角度
       self.angle += isTouch?0:0.01;
    
        // 调整眼睛的位置
        self.eyePosition = GLKVector3Make(-5.0f * sinf(self.angle),
                                          5.0f * sinf(self.angle_y),
                                          -5.0f * cosf(self.angle));
//    _eyePosition = GLKVector3Make(0.0, 0.0, 0.0);

        // 调整观察的位置
    _lookAtPosition = GLKVector3Make(0.0, 0.0, 0.0);
//        self.lookAtPosition = GLKVector3Make(0.0,
//                                             1.5 + -5.0f * sinf(0.3 * self.angle),
//                                             0.0);
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    isTouch = YES;
    oldPoint = CGPointZero;

}

-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    isTouch = NO;
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    isTouch = NO;
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = touches.allObjects.lastObject;
    CGPoint point1 = [touch locationInView:self.view];
    //暂时用x轴
    if (CGPointEqualToPoint(oldPoint, CGPointZero)) {
        oldPoint = point1;
        return;
    }
    CGFloat off_x = point1.x-oldPoint.x;
    CGFloat off_y = -point1.y+oldPoint.y;
    NSLog(@"off_x=%f",off_x);
    _angle_y += off_y/CGRectGetHeight(self.view.bounds);
    self.angle += off_x/CGRectGetWidth(self.view.bounds);
    oldPoint = point1;
}





-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{

    glClearColor(0.5f, 0.1f, 0.1f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    [self setMatrices];
    self.skyboxEffect.center = self.eyePosition;
    self.skyboxEffect.transform.projectionMatrix = self.baseEffect.transform.projectionMatrix;
    self.skyboxEffect.transform.modelviewMatrix = self.baseEffect.transform.modelviewMatrix;
    
    [self.skyboxEffect prepareToDraw];
    glDepthMask(false);
    [self.skyboxEffect draw];
    glDepthMask(true);
    
    // DEBUG
    {
        GLenum error = glGetError();
        if(GL_NO_ERROR != error)
        {
            NSLog(@"GL Error: 0x%x", error);
        }
    }
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    glBindTexture(GL_TEXTURE_CUBE_MAP, 0);
    // 需要重新设置顶点数据，不需要缓存
    glBindVertexArrayOES(self.mPositionBuffer);
    //    glBindBuffer(GL_ARRAY_BUFFER, self.mPositionBuffer);
    //    glEnableVertexAttribArray(GLKVertexAttribPosition);
    //    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 0, NULL);
    //    glBindVertexArrayOES(self.mNormalBuffer);
    //    glBindBuffer(GL_ARRAY_BUFFER, self.mNormalBuffer);
    //    glEnableVertexAttribArray(GLKVertexAttribNormal);
    //    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 0, NULL);
    
    // 绘制
//    for(int i=0; i<starshipMaterials; i++)
//    {
//        // 设置材质
//        self.baseEffect.material.diffuseColor = GLKVector4Make(starshipDiffuses[i][0], starshipDiffuses[i][1], starshipDiffuses[i][2], 1.0f);
//        self.baseEffect.material.specularColor = GLKVector4Make(starshipSpeculars[i][0], starshipSpeculars[i][1], starshipSpeculars[i][2], 1.0f);
//        
//        [self.baseEffect prepareToDraw];
//        
//        glDrawArrays(GL_TRIANGLES, starshipFirsts[i], starshipCounts[i]);
//    }


}


@end
















