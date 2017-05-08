//
//  GLKitStudyController.m
//  OpenGLES-Study
//
//  Created by huang on 2017/5/3.
//  Copyright © 2017年 huang. All rights reserved.
//

#import "GLKitStudyController.h"
#import <GLKit/GLKit.h>

@interface GLKitStudyController ()<GLKViewDelegate>

@property (nonatomic, strong) EAGLContext *context;

@property (nonatomic, strong) GLKBaseEffect *effect;

@end

@implementation GLKitStudyController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupConfig];
    
    [self setupVertexAttribArrayAndTexture];
}

- (void)setupVertexAttribArrayAndTexture {
    GLfloat vertexAttribArray[] = {
        0.5, -0.5,    1.0f, 0.0f,
        0.5, 0.5,     1.0f, 1.0f,
        -0.0, 0.5,    0.0f, 1.0f,
        
        0.5, -0.5,    1.0f, 0.0f,
        -0.0, 0.5,    0.0f, 1.0f,
        -0.0, -0.5,   0.0f, 0.0f,
        
        0.0, 0.5,     0.0f, 1.0f,
        -0.5, 0.5,    1.0f, 1.0f,
        0.0, -0.5,    0.0f, 0.0f,
        
        -0.5, 0.5,    1.0f, 1.0f,
        0.0, -0.5,    0.0f, 0.0f,
        -0.5, -0.5,   1.0f, 0.0f,
    };
    
    GLuint buffer;
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertexAttribArray), vertexAttribArray, GL_STREAM_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 4, (GLfloat *)NULL + 0);
    
    
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 4, (GLfloat *)NULL + 2);
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"panda" ofType:@"jpg"];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:@1, GLKTextureLoaderOriginBottomLeft, nil];
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:nil];
    self.effect.texture2d0.enabled = YES;
    self.effect.texture2d0.name = textureInfo.name;
}

- (void)setupConfig {
    GLKView *glkView = [[GLKView alloc] initWithFrame:self.view.frame context:self.context];
    [self.view addSubview:glkView];
    glkView.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    glkView.drawableDepthFormat = GLKViewDrawableDepthFormatNone;
    glkView.drawableStencilFormat = GLKViewDrawableStencilFormatNone;
    glkView.drawableMultisample = GLKViewDrawableMultisampleNone;
    glkView.delegate = self;
    [EAGLContext setCurrentContext:self.context];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClearColor(0.2f, 0.2f, 0.2f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    [self.effect prepareToDraw];
    glDrawArrays(GL_TRIANGLES, 0, 12);
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
