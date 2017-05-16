//
//  ViewController.m
//  11-demo 高级数据处理
//
//  Created by xuwenhao on 17/5/8.
//  Copyright © 2017年 Hiniu. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

{
    CGFloat _angle;
}

@property (nonatomic , strong) EAGLContext* context;   //上下文
@property (nonatomic , strong) GLKBaseEffect* mEffect;


@end

@implementation ViewController
GLfloat basColor[] = {
    0.1, 0.8, 0.5,
    0.2, 0.0, 0.4,
    0.3, 0.6, 0.0,
    0.4, 0.5, 0.2,
    0.5, 0.3, 0.9,
    0.6, 0.2, 0.8,
    0.7, 0.1, 0.6,
    0.8, 0.4, 0.7,
};


GLfloat vertices[] = {
    -0.5, -0.5,  0.5,
    0.5, -0.5,  0.5,
    -0.5,  0.5,  0.5,
    0.5,  0.5,  0.5,
    -0.5, -0.5, -0.5,
    0.5, -0.5, -0.5,
    -0.5,  0.5, -0.5,
    0.5,  0.5, -0.5,
};

//
//GLfloat vertices[] = {
//    -0.5, -0.5,  0.5,   0.1, 0.8, 0.5,   0.0,0.0,
//     0.5, -0.5,  0.5,   0.2, 0.0, 0.4,   1.0,0.0,
//    -0.5,  0.5,  0.5,   0.3, 0.6, 0.0,   0.0,1.0,
//     0.5,  0.5,  0.5,   0.4, 0.5, 0.2,   1.0,1.0,
//    -0.5, -0.5, -0.5,   0.5, 0.3, 0.9,   1.0,0.0,
//     0.5, -0.5, -0.5,   0.6, 0.2, 0.8,   0.0,0.0,
//    -0.5,  0.5, -0.5,   0.7, 0.1, 0.6,   1.0,1.0,
//     0.5,  0.5, -0.5,   0.8, 0.4, 0.7,   0.0,1.0,
//};


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
}

-(void)setUI{
    _angle = 0.f;
    _context = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    GLKView *view = (GLKView *)self.view;
    view.context = _context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    view.drawableColorFormat=GLKViewDrawableColorFormatRGBA8888;//颜色缓冲区格式
    [EAGLContext setCurrentContext:_context];
    
    
    _mEffect = [GLKBaseEffect new];
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"22222" ofType:@"jpg"];
    
    NSDictionary* options = [NSDictionary dictionaryWithObjectsAndKeys:@(1), GLKTextureLoaderOriginBottomLeft, nil];
    
    GLKTextureInfo *texinfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:nil];
    
    _mEffect.texture2d0.enabled = GL_TRUE;
    _mEffect.texture2d0.name = texinfo.name;
    
    CGSize size = self.view.bounds.size;
    float aspect = fabs(size.width / size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90.0), aspect, 0.1f, 100.f);
    
    projectionMatrix = GLKMatrix4Scale(projectionMatrix, 1.0f, 1.0f, 1.0f);
    _mEffect.transform.projectionMatrix = projectionMatrix;
    
    
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4Translate(GLKMatrix4RotateY(GLKMatrix4Identity, _angle), 0.0f, 0.0f, -2.0f);
    
    _mEffect.transform.modelviewMatrix = modelViewMatrix;

    
    
    glEnable(GL_DEPTH_TEST);
    glClearColor(0.3f, 0.6f, 1.f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    GLuint buffer;
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER,sizeof(vertices)+sizeof(basColor)+sizeof(norm1), NULL, GL_DYNAMIC_DRAW);
    
//    glEnableVertexAttribArray(GLKVertexAttribPosition);
//    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*8, (GLfloat *)NULL+0);
//    glEnableVertexAttribArray(GLKVertexAttribColor);
//    glVertexAttribPointer(GLKVertexAttribColor, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*8, (GLfloat *)NULL+3);
//    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
//    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*8, (GLfloat *)NULL+6);

    
    
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(vertices), &vertices);
    
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glBufferSubData(GL_ARRAY_BUFFER, 24*sizeof(GLfloat), sizeof(basColor), &basColor);
    
    
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glBufferSubData(GL_ARRAY_BUFFER, 48*sizeof(GLfloat), sizeof(norm1), &norm1);
    
    
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*3, (GLvoid *)NULL+0);

    
    glVertexAttribPointer(GLKVertexAttribColor, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*3, (GLvoid *)(24*sizeof(GLfloat)));
    
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*2, (GLvoid *)(48*sizeof(GLfloat)));
    
    
    
    GLuint index;
    glGenBuffers(1, &index);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, index);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    
    
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timeChange) userInfo:nil repeats:YES];
    
    
}

-(void)dealloc{

}

-(void)timeChange{
    if (_angle>720) {
        _angle = 0.0;
    }
    _angle += 0.001;
}


-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    glClearColor(0.3f, 0.6f, 1.f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4RotateY(GLKMatrix4Translate(GLKMatrix4Identity, 0.0f, 0.0f, -2.0f), GLKMathRadiansToDegrees(_angle));
    
    _mEffect.transform.modelviewMatrix = GLKMatrix4RotateX(modelViewMatrix, 0);

    
    
    
//    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
//    glBufferSubData(GL_ARRAY_BUFFER, sizeof(vertices)+sizeof(basColor), sizeof(norm1), &norm1);
//    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*2, (GLfloat *)(sizeof(vertices)+sizeof(basColor)));
//    
//    glBufferSubData(GL_ELEMENT_ARRAY_BUFFER, 0, sizeof(indices), &indices);
    [_mEffect prepareToDraw];
    
    glDrawElements(GL_TRIANGLES, 36, GL_UNSIGNED_INT, 0);
    
    ;
    return;
//    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
//
//    
//    glBufferSubData(GL_ARRAY_BUFFER, sizeof(vertices)+sizeof(basColor), sizeof(norm2), &norm2);
//    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*2, (GLfloat *)(sizeof(vertices)+sizeof(basColor)));
//    
//    glBufferSubData(GL_ELEMENT_ARRAY_BUFFER, 0, sizeof(indices2), indices2);
//    
//    [_mEffect prepareToDraw];
//    glDrawElements(GL_TRIANGLES, 12, GL_UNSIGNED_INT, 0);

}


@end
