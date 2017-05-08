//
//  GLKitTwoStudyController.m
//  OpenGLES-Study
//
//  Created by huang on 2017/5/8.
//  Copyright © 2017年 huang. All rights reserved.
//

#import "GLKitTwoStudyController.h"


@interface GLKitTwoStudyController ()<GLKViewDelegate>

@property (nonatomic, strong) GLKView *glkView;

@property (nonatomic, strong) EAGLContext *context;

@property (nonatomic, strong) GLKBaseEffect *effect;

@property (nonatomic, strong) dispatch_source_t timer;

@property (nonatomic, assign) GLsizei count;

@property (nonatomic, assign) float xRadians;

@end

@implementation GLKitTwoStudyController

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (_timer) {
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupConfig];
    
    [self setupVertexAttribArrayAndTexture];
    
    [self startAnimation];
}

- (void)setupVertexAttribArrayAndTexture {
    // 4个等边三角形
    GLuint indices[] = {
        0, 3, 2,
        0, 1, 3,
        0, 2, 4,
        0, 4, 1,
        2, 3, 4,
        1, 4, 3,
    };
    
    _count = sizeof(indices) / sizeof(GLuint);
    
    GLfloat vertexAttribArray[] = {
        -0.5f, 0.5f, 0.0f,   0.0f, 1.0f,  0.0f, 0.0f, 0.5f,
        0.5f, 0.5f, 0.0f,    1.0f, 1.0f,  0.0f, 0.5f, 0.0f,
        -0.5f, -0.5f, 0.0f,  0.0f, 0.0f,  0.5f, 0.0f, 1.0f,
        0.5f, -0.5f, 0.0f,   1.0f, 0.0f,  0.0f, 0.0f, 0.5f,
        0.0f, 0.0f, 1.0f,    0.5f, 0.5f,  1.0f, 1.0f, 1.0f,
    };
    
    GLuint buffer;
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertexAttribArray), vertexAttribArray, GL_STATIC_DRAW);
    
    GLuint index;
    glGenBuffers(1, &index);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, index);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 8, (GLfloat *)NULL + 0);
    
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 8, (GLfloat *)NULL + 3);
    
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 8, (GLfloat *)NULL + 5);
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"panda" ofType:@"jpg"];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:@1, GLKTextureLoaderOriginBottomLeft, nil];
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:nil];
    self.effect.texture2d0.enabled = YES;
    self.effect.texture2d0.name = textureInfo.name;
    
    CGSize size = self.view.bounds.size;
    float aspect = fabs(size.width / size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(M_PI_2, aspect, 0.1f, 10.f);
    projectionMatrix = GLKMatrix4Scale(projectionMatrix, 1.0f, 1.0f, 1.0f);
    self.effect.transform.projectionMatrix = projectionMatrix;
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4Translate(GLKMatrix4Identity, 0.0f, 0.0f, -2.0f);
    self.effect.transform.modelviewMatrix = modelViewMatrix;
}

- (void)setupConfig {
    [self.view addSubview:self.glkView];
    [EAGLContext setCurrentContext:self.context];
    
    glEnable(GL_DEPTH_TEST);
}

- (void)startAnimation {
    dispatch_source_set_timer(self.timer, DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC, 0.0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(_timer, ^{
        self.xRadians -= 0.1;
    });
    dispatch_resume(_timer);
}

- (void)update {
    GLKMatrix4 modelViewMatrix = GLKMatrix4Translate(GLKMatrix4Identity, 0.0f, 0.0f, -2.0f);
    
    modelViewMatrix = GLKMatrix4RotateX(modelViewMatrix, self.xRadians);
    
    self.effect.transform.modelviewMatrix = modelViewMatrix;
    
    // 手动执行GLKView的绘制
    [_glkView display];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClearColor(0.2f, 0.2f, 0.2f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    [self.effect prepareToDraw];
    glDrawElements(GL_TRIANGLES, _count, GL_UNSIGNED_INT, 0);
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

- (EAGLContext *)context {
    if (!_context) {
        _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    }
    
    return _context;
}

- (GLKBaseEffect *)effect {
    if (!_effect) {
        _effect = [[GLKBaseEffect alloc] init];
    }
    
    return _effect;
}

- (dispatch_source_t)timer {
    if (!_timer) {
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    }
    
    return _timer;
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
