//
//  IlluminationStudyController.m
//  OpenGLES-Study
//
//  Created by Hwl on 2017/5/23.
//  Copyright © 2017年 huang. All rights reserved.
//

#import "IlluminationStudyController.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "SceneUtil.h"

@interface IlluminationStudyController ()<GLKViewDelegate>

@property (nonatomic, strong) GLKView *glkView;

@property (nonatomic, strong) EAGLContext *context;

@property (nonatomic, strong) GLKBaseEffect *baseEffect;

@property (nonatomic, strong) AGLKVertexAttribArrayBuffer *vertexAttribBuffer;

@property (nonatomic, strong) AGLKVertexAttribArrayBuffer *extraAttribBuffer;

@property (nonatomic) BOOL shouldUseFaceNormals;
@property (nonatomic) GLfloat centerVertexHeight;

@end

@implementation IlluminationStudyController
{
    SceneTriangle triangles[NUM_FACES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupConfig];
    
    [self setupLight];
    
    [self setupTransform];
    
    [self setupVertexAttribArray];
    
    self.shouldUseFaceNormals = YES;
    
    self.centerVertexHeight = 0.0f;
    
    UISlider *slider = [[UISlider alloc] init];
    [self.view addSubview:slider];
    slider.frame = CGRectMake(30, 10, ScreenWidth - 60, 30);
    [slider addTarget:self action:@selector(sliderAct:) forControlEvents:UIControlEventValueChanged];
    slider.minimumValue = -0.5f;
    slider.maximumValue = 0.0f;
    slider.value = self.centerVertexHeight;
    
    UISwitch *faceSwitch = [[UISwitch alloc] init];
    [self.view addSubview:faceSwitch];
    faceSwitch.frame = CGRectMake(30, 40, ScreenWidth - 60, 30);
    [faceSwitch addTarget:self action:@selector(faceSwitchAct:) forControlEvents:UIControlEventValueChanged];
    faceSwitch.on = self.shouldUseFaceNormals;
}

- (void)sliderAct:(UISlider *)sender {
    GLfloat num = sender.value;
    self.centerVertexHeight = num;
}

- (void)faceSwitchAct:(UISwitch *)sender {
    self.shouldUseFaceNormals = sender.on;
}

- (void)setupConfig {
    GLKView *glkView = self.glkView;
    [self.view addSubview:glkView];
    [EAGLContext setCurrentContext:self.context];
}

- (void)setupLight {
    self.baseEffect.light0.enabled = GL_TRUE;
    self.baseEffect.light0.diffuseColor = GLKVector4Make(0.8f, 0.8f, 0.8f, 1.0f);
    self.baseEffect.light0.position = GLKVector4Make(1.0f, 1.0f, 0.5f, 0.0f);
}

- (void)setupTransform {
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(-60.0f), 1.0f, 0.0f, 0.0f);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(-30.f), 0.0f, 0.0f, 1.0f);
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0.0f, 0.0f, 0.25f);
    self.baseEffect.transform.modelviewMatrix = modelViewMatrix;
}

- (void)setupVertexAttribArray {
    triangles[0] = SceneTriangleMake(vertexA, vertexB, vertexD);
    triangles[1] = SceneTriangleMake(vertexB, vertexC, vertexF);
    triangles[2] = SceneTriangleMake(vertexD, vertexB, vertexE);
    triangles[3] = SceneTriangleMake(vertexE, vertexB, vertexF);
    triangles[4] = SceneTriangleMake(vertexD, vertexE, vertexH);
    triangles[5] = SceneTriangleMake(vertexE, vertexF, vertexH);
    triangles[6] = SceneTriangleMake(vertexG, vertexD, vertexH);
    triangles[7] = SceneTriangleMake(vertexH, vertexF, vertexI);
    
    _vertexAttribBuffer = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:sizeof(SceneVertex)
                                                                   numberOfVertices:sizeof(triangles) / sizeof(SceneVertex)
                                                                              bytes:triangles
                                                                              usage:GL_STATIC_DRAW];
    _extraAttribBuffer = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:sizeof(SceneVertex)
                                                                  numberOfVertices:0
                                                                             bytes:NULL
                                                                             usage:GL_STATIC_DRAW];
}


- (EAGLContext *)context {
    if (!_context) {
        _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    }
    
    return _context;
}

- (GLKView *)glkView {
    if (!_glkView) {
        _glkView = [[GLKView alloc] initWithFrame:self.view.frame context:self.context];
        _glkView.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
        _glkView.drawableDepthFormat = GLKViewDrawableDepthFormat24;
        _glkView.drawableStencilFormat = GLKViewDrawableStencilFormatNone;
        _glkView.drawableMultisample = GLKViewDrawableMultisampleNone;
        _glkView.delegate = self;
    }
    
    return _glkView;
}

- (GLKBaseEffect *)baseEffect {
    if (!_baseEffect) {
        _baseEffect = [[GLKBaseEffect alloc] init];
    }
    
    return _baseEffect;
}

- (void)update {
    [_glkView display];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClearColor(0.2f, 0.2f, 0.2f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    [self.baseEffect prepareToDraw];
    
    [_vertexAttribBuffer prepareToDrawWithAttrib:AGLKVertexAttribPosition
                             numberOfCoordinates:3
                                    attribOffset:offsetof(SceneVertex, position)
                                    shouldEnable:YES];
    [_vertexAttribBuffer prepareToDrawWithAttrib:GLKVertexAttribNormal
                             numberOfCoordinates:3
                                    attribOffset:offsetof(SceneVertex, normal)
                                    shouldEnable:YES];
    [_vertexAttribBuffer drawArrayWithMode:GL_TRIANGLES
                          startVertexIndex:0
                          numberOfVertices:sizeof(triangles) / sizeof(SceneVertex)];
    
}

- (void)updateNormals {
    if(_shouldUseFaceNormals) {
        SceneTrianglesUpdateFaceNormals(triangles);
    } else {
        SceneTrianglesUpdateVertexNormals(triangles);
    }
    
    [_vertexAttribBuffer reinitWithAttribStride:sizeof(SceneVertex)
                               numberOfVertices:sizeof(triangles) / sizeof(SceneVertex)
                                          bytes:triangles];
}

- (void)setCenterVertexHeight:(GLfloat)centerVertexHeight {
    if (_centerVertexHeight != centerVertexHeight) {
        _centerVertexHeight = centerVertexHeight;
    }
    
    SceneVertex newVertexE = vertexE;
    newVertexE.position.z = _centerVertexHeight;
    
    triangles[2] = SceneTriangleMake(vertexD, vertexB, newVertexE);
    triangles[3] = SceneTriangleMake(newVertexE, vertexB, vertexF);
    triangles[4] = SceneTriangleMake(vertexD, newVertexE, vertexH);
    triangles[5] = SceneTriangleMake(newVertexE, vertexF, vertexH);
    
    [self updateNormals];
}

- (void)setShouldUseFaceNormals:(BOOL)shouldUseFaceNormals {
    if (_shouldUseFaceNormals != shouldUseFaceNormals) {
        _shouldUseFaceNormals = shouldUseFaceNormals;
        [self updateNormals];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
