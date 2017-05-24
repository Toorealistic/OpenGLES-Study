//
//  EarthMoonStudyController.m
//  OpenGLES-Study
//
//  Created by huang on 2017/5/11.
//  Copyright © 2017年 huang. All rights reserved.
//

#import "EarthMoonStudyController.h"
#import "sphere.h"

@interface EarthMoonStudyController ()<GLKViewDelegate>

@property (nonatomic, strong) GLKView *glkView;

@property (nonatomic, strong) EAGLContext *context;

@property (nonatomic, strong) GLKBaseEffect *baseEffect;

@property (nonatomic) GLKMatrixStackRef matrixStackRef;

@property (nonatomic, strong) AGLKVertexAttribArrayBuffer *vertexAttribPosition;
@property (nonatomic, strong) AGLKVertexAttribArrayBuffer *vertexAttribNormal;
@property (nonatomic, strong) AGLKVertexAttribArrayBuffer *vertexAttribTexCoord0;

@property (nonatomic, strong) GLKTextureInfo *earthTextureInfo;

@property (nonatomic, strong) GLKTextureInfo *moonTextureInfo;

@property (nonatomic, assign) float earthRotationAngleDegrees;

@property (nonatomic, assign) float moonRotationAngleDegrees;

@end

@implementation EarthMoonStudyController

static const GLfloat SceneEarthAxialTiltDeg = 23.5f; // 与赤道的角度
static const GLfloat SceneDaysPerMoonOrbit = 27.32f; // 月球公转时间
static const GLfloat SceneMoonRadiusFractionOfEarth = 0.25;
static const GLfloat SceneMoonDistanceFromEarth = 2.0;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupConfig];
    
    [self setupLight];
    
    [self setupTransform];
    
    [self setupVertexAttribArrayAndTexture];
    
    UISlider *slider = [[UISlider alloc] init];
    [self.view addSubview:slider];
    slider.frame = CGRectMake(30, 10, ScreenWidth - 60, 30);
    [slider addTarget:self action:@selector(sliderAct:) forControlEvents:UIControlEventValueChanged];
    slider.minimumValue = 1.0;
    slider.maximumValue = 3.0;
}

- (void)sliderAct:(UISlider *)sender {
    float num = sender.value;
    CGSize size = self.view.bounds.size;
    float aspect = fabs(size.width / size.height);
    if (num == sender.minimumValue) {
        GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(-1.0 * aspect, 1.0 * aspect, -1.0, 1.0, 1.0, 120.0);
        self.baseEffect.transform.projectionMatrix = projectionMatrix;
    } else {
        GLKMatrix4 projectionMatrix = GLKMatrix4MakeFrustum(-1.0 * aspect, 1.0 * aspect, -1.0, 1.0, num, 120.0);
        self.baseEffect.transform.projectionMatrix = projectionMatrix;
    }
}

- (void)setupConfig {
    GLKView *glkView = self.glkView;
    [self.view addSubview:glkView];
    [EAGLContext setCurrentContext:self.context];
    
    glEnable(GL_DEPTH_TEST);
}

- (void)setupLight {
    self.baseEffect.light0.enabled = GL_TRUE;
    self.baseEffect.light0.diffuseColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
    self.baseEffect.light0.position = GLKVector4Make(1.0f, 0.0f, 0.8f, 0.0f);
    self.baseEffect.light0.ambientColor = GLKVector4Make(0.2f, 0.2f, 0.2f, 1.0f);
}

- (void)setupTransform {
    CGSize size = self.view.bounds.size;
    float aspect = fabs(size.width / size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(-1.0 * aspect, 1.0 * aspect, -1.0, 1.0, 1.0, 120.0);
    self.baseEffect.transform.projectionMatrix = projectionMatrix;
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0, 0.0, -5.0);
    self.baseEffect.transform.modelviewMatrix = modelViewMatrix;
    
    self.matrixStackRef = GLKMatrixStackCreate(kCFAllocatorDefault);
    
    GLKMatrixStackLoadMatrix4(self.matrixStackRef, self.baseEffect.transform.modelviewMatrix);
}

- (void)setupVertexAttribArrayAndTexture {
    _vertexAttribPosition = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:3 * sizeof(GLfloat)
                                                                                                 numberOfVertices:sizeof(sphereVerts) / (3 * sizeof(GLfloat))
                                                                                                            bytes:sphereVerts
                                                                                                            usage:GL_STATIC_DRAW];
    [_vertexAttribPosition prepareToDrawWithAttrib:AGLKVertexAttribPosition
                               numberOfCoordinates:3
                                      attribOffset:0
                                      shouldEnable:YES];
    
    _vertexAttribNormal = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:3 * sizeof(GLfloat)
                                                                                                 numberOfVertices:sizeof(sphereNormals) / (3 * sizeof(GLfloat))
                                                                                                            bytes:sphereNormals
                                                                                                            usage:GL_STATIC_DRAW];
    [_vertexAttribNormal prepareToDrawWithAttrib:AGLKVertexAttribNormal
                             numberOfCoordinates:3
                                    attribOffset:0
                                    shouldEnable:YES];
    
    _vertexAttribTexCoord0 = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:2 * sizeof(GLfloat)
                                                                                                 numberOfVertices:sizeof(sphereTexCoords) / (2 * sizeof(GLfloat))
                                                                                                            bytes:sphereTexCoords
                                                                                                            usage:GL_STATIC_DRAW];
    [_vertexAttribTexCoord0 prepareToDrawWithAttrib:AGLKVertexAttribTexCoord0
                                numberOfCoordinates:2
                                       attribOffset:0
                                       shouldEnable:YES];
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

- (GLKTextureInfo *)earthTextureInfo {
    if (!_earthTextureInfo) {
        NSBundle *bundle = [[NSBundle alloc] initWithPath:[[NSBundle mainBundle] pathForResource:@"EarthMoon" ofType:@"bundle"]];
        NSString *filePath = [bundle pathForResource:@"Earth512x256" ofType:@"jpg"];
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:@1, GLKTextureLoaderOriginBottomLeft, nil];
        _earthTextureInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:nil];
    }
    
    return _earthTextureInfo;
}

- (GLKTextureInfo *)moonTextureInfo {
    if (!_moonTextureInfo) {
        NSBundle *bundle = [[NSBundle alloc] initWithPath:[[NSBundle mainBundle] pathForResource:@"EarthMoon" ofType:@"bundle"]];
        NSString *filePath = [bundle pathForResource:@"Moon256x128" ofType:@"png"];
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:@1, GLKTextureLoaderOriginBottomLeft, nil];
        _moonTextureInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:nil];
    }
    
    return _moonTextureInfo;
}

- (void)update {
    [_glkView display];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClearColor(0.2f, 0.2f, 0.2f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    self.earthRotationAngleDegrees += 360.0f / 60.0f;
    self.moonRotationAngleDegrees += (360.0f / 60.0f) / SceneDaysPerMoonOrbit;
    
    [self drawEarth];
    [self drawMoon];
}

- (void)drawEarth {
    self.baseEffect.texture2d0.name = self.earthTextureInfo.name;
    self.baseEffect.texture2d0.target = self.earthTextureInfo.target;
    
    GLKMatrixStackPush(self.matrixStackRef);
    
    GLKMatrixStackRotate(self.matrixStackRef, GLKMathDegreesToRadians(SceneEarthAxialTiltDeg), 1.0, 0.0, 0.0);
    
    GLKMatrixStackRotate(self.matrixStackRef, GLKMathDegreesToRadians(self.earthRotationAngleDegrees), 0.0, 1.0, 0.0);
    
    self.baseEffect.transform.modelviewMatrix = GLKMatrixStackGetMatrix4(self.matrixStackRef);
    [self.baseEffect prepareToDraw];
    
    [AGLKVertexAttribArrayBuffer drawPreparedArraysWithMode:GL_TRIANGLES
                                           startVertexIndex:0
                                           numberOfVertices:sphereNumVerts];
    
    GLKMatrixStackPop(self.matrixStackRef);
}

- (void)drawMoon {
    self.baseEffect.texture2d0.name = self.moonTextureInfo.name;
    self.baseEffect.texture2d0.target = self.moonTextureInfo.target;
    
    GLKMatrixStackPush(self.matrixStackRef);
    
    GLKMatrixStackRotate(self.matrixStackRef, GLKMathDegreesToRadians(self.moonRotationAngleDegrees), 0.0, 1.0, 0.0);
    
    GLKMatrixStackTranslate(self.matrixStackRef, 0.0, 0.0, SceneMoonDistanceFromEarth);
    
    GLKMatrixStackScale(self.matrixStackRef, SceneMoonRadiusFractionOfEarth, SceneMoonRadiusFractionOfEarth, SceneMoonRadiusFractionOfEarth);
    
    self.baseEffect.transform.modelviewMatrix = GLKMatrixStackGetMatrix4(self.matrixStackRef);
    [self.baseEffect prepareToDraw];
    
    [AGLKVertexAttribArrayBuffer drawPreparedArraysWithMode:GL_TRIANGLES
                                           startVertexIndex:0
                                           numberOfVertices:sphereNumVerts];
    
    GLKMatrixStackPop(self.matrixStackRef);
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
