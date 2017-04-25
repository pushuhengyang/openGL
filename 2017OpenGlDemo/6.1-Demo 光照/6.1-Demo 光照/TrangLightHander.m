//
//  TrangLightHander.m
//  6.1-Demo 光照
//
//  Created by xuwenhao on 17/4/5.
//  Copyright © 2017年 Hiniu. All rights reserved.
//

#import "TrangLightHander.h"

SceneTriangle SceneTriangleMake(
                                const SceneVertex vertexA,
                                const SceneVertex vertexB,
                                const SceneVertex vertexC)
{
    SceneTriangle   result;
    
    result.vertices[0] = vertexA;
    result.vertices[1] = vertexB;
    result.vertices[2] = vertexC;
    
    return result;
}

//一个平面的法向量
GLKVector3 SceneTriangleFaceNormal(
                                   const SceneTriangle triangle)
{
    GLKVector3 vectorA = GLKVector3Subtract(
                                            triangle.vertices[1].position,
                                            triangle.vertices[0].position);
    GLKVector3 vectorB = GLKVector3Subtract(
                                            triangle.vertices[2].position,
                                            triangle.vertices[0].position);
    
    return SceneVector3UnitNormal(
                                  vectorA,
                                  vectorB);
}

//两个向量的法向量  就是叉积
GLKVector3 SceneVector3UnitNormal(
                                  const GLKVector3 vectorA,
                                  const GLKVector3 vectorB)
{
    return GLKVector3Normalize(
                               GLKVector3CrossProduct(vectorA, vectorB));
}

//更新法向量 这个不是用平均值
void SceneTrianglesUpdateFaceNormals(
                                     SceneTriangle someTriangles[],int num)
{
    
    for (int i=0; i<num; i++)
    {
        GLKVector3 faceNormal = SceneTriangleFaceNormal(
                                                        someTriangles[i]);
        
        someTriangles[i].vertices[0].normal = faceNormal;
        someTriangles[i].vertices[1].normal = faceNormal;
        someTriangles[i].vertices[2].normal = faceNormal;
    }
}

void SceneTrianglesNormalLinesUpdate(
                                     const SceneTriangle someTriangles[],
                                     GLKVector3 lightPosition,
                                     GLKVector3 someNormalLineVertices[],
                                     int num)
{
    int                       trianglesIndex;
    int                       lineVetexIndex = 0;
    
    
    for (trianglesIndex = 0; trianglesIndex < num;
         trianglesIndex++)
    {
        someNormalLineVertices[lineVetexIndex++] =
        someTriangles[trianglesIndex].vertices[0].position;
        someNormalLineVertices[lineVetexIndex++] =
        GLKVector3Add(
                      someTriangles[trianglesIndex].vertices[0].position,
                      GLKVector3MultiplyScalar(
                                               someTriangles[trianglesIndex].vertices[0].normal,
                                               0.5));
        someNormalLineVertices[lineVetexIndex++] =
        someTriangles[trianglesIndex].vertices[1].position;
        someNormalLineVertices[lineVetexIndex++] =
        GLKVector3Add(
                      someTriangles[trianglesIndex].vertices[1].position,
                      GLKVector3MultiplyScalar(
                                               someTriangles[trianglesIndex].vertices[1].normal,
                                               0.5));
        someNormalLineVertices[lineVetexIndex++] =
        someTriangles[trianglesIndex].vertices[2].position;
        someNormalLineVertices[lineVetexIndex++] =
        GLKVector3Add(
                      someTriangles[trianglesIndex].vertices[2].position,
                      GLKVector3MultiplyScalar(
                                               someTriangles[trianglesIndex].vertices[2].normal,
                                               0.5));
    }
    
    // Add a line to indicate light direction
//    someNormalLineVertices[lineVetexIndex++] =
//    lightPosition;
//    
//    someNormalLineVertices[lineVetexIndex] = GLKVector3Make(
//                                                            0.0,
//                                                            0.0,
//                                                            -0.5);
}

@implementation TrangLightHander

@end
