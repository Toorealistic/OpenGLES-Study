//
//  SceneUtil.h
//  OpenGLES-Study
//
//  Created by Hwl on 2017/5/23.
//  Copyright © 2017年 huang. All rights reserved.
//

#import <GLKit/GLKit.h>

typedef struct {
    GLKVector3 position;
    GLKVector3 normal;
} SceneVertex;

typedef struct {
    SceneVertex vertices[3];
} SceneTriangle;

static const SceneVertex vertexA = {{-0.5,  0.5, -0.5}, {0.0, 0.0, 1.0}};
static const SceneVertex vertexB = {{-0.5,  0.0, -0.5}, {0.0, 0.0, 1.0}};
static const SceneVertex vertexC = {{-0.5, -0.5, -0.5}, {0.0, 0.0, 1.0}};
static const SceneVertex vertexD = {{ 0.0,  0.5, -0.5}, {0.0, 0.0, 1.0}};
static const SceneVertex vertexE = {{ 0.0,  0.0, -0.5}, {0.0, 0.0, 1.0}};
static const SceneVertex vertexF = {{ 0.0, -0.5, -0.5}, {0.0, 0.0, 1.0}};
static const SceneVertex vertexG = {{ 0.5,  0.5, -0.5}, {0.0, 0.0, 1.0}};
static const SceneVertex vertexH = {{ 0.5,  0.0, -0.5}, {0.0, 0.0, 1.0}};
static const SceneVertex vertexI = {{ 0.5, -0.5, -0.5}, {0.0, 0.0, 1.0}};

#define NUM_FACES (8)

SceneTriangle SceneTriangleMake(const SceneVertex vertexA,
                                const SceneVertex vertexB,
                                const SceneVertex vertexC) {
    SceneTriangle triangle;
    
    triangle.vertices[0] = vertexA;
    triangle.vertices[1] = vertexB;
    triangle.vertices[2] = vertexC;
    
    return triangle;
}

// 根据两条不共线的直线取对应面的法向量
GLKVector3 SceneVector3UnitNormal(const GLKVector3 vectorA,
                                  const GLKVector3 vectorB) {
    return GLKVector3Normalize(GLKVector3CrossProduct(vectorA, vectorB));
}

// 取面上的3个顶点，成两条不共线的直线，来取当前面的法向量
GLKVector3 SceneTriangleFaceNormal(const SceneTriangle triangle) {
    GLKVector3 vectorA = GLKVector3Subtract(triangle.vertices[1].position,
                                            triangle.vertices[0].position);
    GLKVector3 vectorB = GLKVector3Subtract(triangle.vertices[2].position,
                                            triangle.vertices[0].position);
    
    return SceneVector3UnitNormal(vectorA,
                                  vectorB);
}

// 更新每个面上的3个顶点对应的法向量
void SceneTrianglesUpdateFaceNormals(SceneTriangle someTriangles[NUM_FACES]) {
    for (int i = 0; i < NUM_FACES; i++) {
        GLKVector3 faceNormal = SceneTriangleFaceNormal(someTriangles[i]);
        someTriangles[i].vertices[0].normal = faceNormal;
        someTriangles[i].vertices[1].normal = faceNormal;
        someTriangles[i].vertices[2].normal = faceNormal;
    }
}

void SceneTrianglesUpdateVertexNormals(SceneTriangle someTriangles[NUM_FACES]) {
    SceneVertex newVertexA = vertexA;
    SceneVertex newVertexB = vertexB;
    SceneVertex newVertexC = vertexC;
    SceneVertex newVertexD = vertexD;
    SceneVertex newVertexE = someTriangles[3].vertices[0];
    SceneVertex newVertexF = vertexF;
    SceneVertex newVertexG = vertexG;
    SceneVertex newVertexH = vertexH;
    SceneVertex newVertexI = vertexI;
    GLKVector3 faceNormals[NUM_FACES];
    
    for (int i = 0; i < NUM_FACES; i++) {
        faceNormals[i] = SceneTriangleFaceNormal(someTriangles[i]);
    }
    
    //通过平均值求出每个点的法向量
    newVertexA.normal = faceNormals[0];
    newVertexB.normal = GLKVector3MultiplyScalar(
                                                 GLKVector3Add(
                                                               GLKVector3Add(
                                                                             GLKVector3Add(
                                                                                           faceNormals[0],
                                                                                           faceNormals[1]),
                                                                             faceNormals[2]),
                                                               faceNormals[3]), 0.25);
    newVertexC.normal = faceNormals[1];
    newVertexD.normal = GLKVector3MultiplyScalar(
                                                 GLKVector3Add(
                                                               GLKVector3Add(
                                                                             GLKVector3Add(
                                                                                           faceNormals[0],
                                                                                           faceNormals[2]),
                                                                             faceNormals[4]),
                                                               faceNormals[6]), 0.25);
    newVertexE.normal = GLKVector3MultiplyScalar(
                                                 GLKVector3Add(
                                                               GLKVector3Add(
                                                                             GLKVector3Add(
                                                                                           faceNormals[2],
                                                                                           faceNormals[3]),
                                                                             faceNormals[4]),
                                                               faceNormals[5]), 0.25);
    newVertexF.normal = GLKVector3MultiplyScalar(
                                                 GLKVector3Add(
                                                               GLKVector3Add(
                                                                             GLKVector3Add(
                                                                                           faceNormals[1],
                                                                                           faceNormals[3]),
                                                                             faceNormals[5]),
                                                               faceNormals[7]), 0.25);
    newVertexG.normal = faceNormals[6];
    newVertexH.normal = GLKVector3MultiplyScalar(
                                                 GLKVector3Add(
                                                               GLKVector3Add(
                                                                             GLKVector3Add(
                                                                                           faceNormals[4],
                                                                                           faceNormals[5]),
                                                                             faceNormals[6]),
                                                               faceNormals[7]), 0.25);
    newVertexI.normal = faceNormals[7];
    
    //用新的点创建三角形
    someTriangles[0] = SceneTriangleMake(
                                         newVertexA,
                                         newVertexB,
                                         newVertexD);
    someTriangles[1] = SceneTriangleMake(
                                         newVertexB,
                                         newVertexC,
                                         newVertexF);
    someTriangles[2] = SceneTriangleMake(
                                         newVertexD,
                                         newVertexB,
                                         newVertexE);
    someTriangles[3] = SceneTriangleMake(
                                         newVertexE,
                                         newVertexB,
                                         newVertexF);
    someTriangles[4] = SceneTriangleMake(
                                         newVertexD,
                                         newVertexE,
                                         newVertexH);
    someTriangles[5] = SceneTriangleMake(
                                         newVertexE,
                                         newVertexF,
                                         newVertexH);
    someTriangles[6] = SceneTriangleMake(
                                         newVertexG,
                                         newVertexD,
                                         newVertexH);
    someTriangles[7] = SceneTriangleMake(
                                         newVertexH,
                                         newVertexF,
                                         newVertexI);
}
