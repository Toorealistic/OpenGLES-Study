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

@property (nonatomic, strong) AGLKVertexAttribArrayBuffer *vertexAttribPosition;
@property (nonatomic, strong) AGLKVertexAttribArrayBuffer *vertexAttribTexCoord0;

@end

@implementation GLKitStudyController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupConfig];
    
    [self setupVertexAttribArrayAndTexture];
}

- (void)setupVertexAttribArrayAndTexture {
    GLfloat position[] = {
        0.5, -0.5,
        0.5, 0.5,
        -0.0, 0.5,
        
        0.5, -0.5,
        -0.0, 0.5,
        -0.0, -0.5,
        
        0.0, 0.5,
        -0.5, 0.5,
        0.0, -0.5,
        
        -0.5, 0.5,
        0.0, -0.5,
        -0.5, -0.5,
    };
    
    GLfloat texCoord0[] = {
        1.0f, 0.0f,
        1.0f, 1.0f,
        0.0f, 1.0f,
        
        1.0f, 0.0f,
        0.0f, 1.0f,
        0.0f, 0.0f,
        
        0.0f, 1.0f,
        1.0f, 1.0f,
        0.0f, 0.0f,
        
        1.0f, 1.0f,
        0.0f, 0.0f,
        1.0f, 0.0f,
    };
    
    _vertexAttribPosition = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:2 * sizeof(GLfloat)
                                                                     numberOfVertices:sizeof(position) / (2 * sizeof(GLfloat))
                                                                                bytes:position
                                                                                usage:GL_STATIC_DRAW];
    [_vertexAttribPosition prepareToDrawWithAttrib:AGLKVertexAttribPosition
                               numberOfCoordinates:2
                                      attribOffset:0
                                      shouldEnable:YES];
    
    _vertexAttribTexCoord0 = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:2 * sizeof(GLfloat)
                                                                      numberOfVertices:sizeof(texCoord0) / (2 * sizeof(GLfloat))
                                                                                 bytes:texCoord0
                                                                                 usage:GL_STATIC_DRAW];
    [_vertexAttribTexCoord0 prepareToDrawWithAttrib:AGLKVertexAttribTexCoord0
                                numberOfCoordinates:2
                                       attribOffset:0
                                       shouldEnable:YES];
    
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
    
    [AGLKVertexAttribArrayBuffer drawPreparedArraysWithMode:GL_TRIANGLES
                                           startVertexIndex:0
                                           numberOfVertices:12];
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
