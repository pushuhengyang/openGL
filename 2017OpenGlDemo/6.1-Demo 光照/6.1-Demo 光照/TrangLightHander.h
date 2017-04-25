//
//  TrangLightHander.h
//  6.1-Demo 光照
//
//  Created by xuwenhao on 17/4/5.
//  Copyright © 2017年 Hiniu. All rights reserved.
//  三角形光照处理类

#import <GLKit/GLKit.h>

//一个顶点的量
typedef struct {
    GLKVector3 position;//位置
    GLKVector3 normal;//法线向量
    GLKVector2 texTure;//纹理坐标
} SceneVertex;

//三角形
typedef struct {
    SceneVertex vertices[3];
}
SceneTriangle;

//构成一个三角形
SceneTriangle SceneTriangleMake(
                                const SceneVertex vertexA,
                                const SceneVertex vertexB,
                                const SceneVertex vertexC);

GLKVector3 SceneTriangleFaceNormal(
                                   const SceneTriangle triangle);

GLKVector3 SceneVector3UnitNormal(
                                  const GLKVector3 vectorA,
                                  const GLKVector3 vectorB);

void SceneTrianglesUpdateFaceNormals(
                                     SceneTriangle someTriangles[],int num);

void SceneTrianglesNormalLinesUpdate(
                                     const SceneTriangle someTriangles[],
                                     GLKVector3 lightPosition,
                                     GLKVector3 someNormalLineVertices[],
                                     int num);



@interface TrangLightHander : NSObject

@end
