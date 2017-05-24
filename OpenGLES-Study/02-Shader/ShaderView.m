//
//  ShaderView.m
//  OpenGLES-Study
//
//  Created by huang on 2017/5/3.
//  Copyright © 2017年 huang. All rights reserved.
//

#import "ShaderView.h"
#import <OpenGLES/ES2/gl.h>
#import "GLESMath.h"

@interface ShaderView ()

@property (nonatomic, strong) NSLock *lock;

@property (nonatomic, strong) CAEAGLLayer *eAGLLayer;

@property (nonatomic, strong) EAGLContext *context;

@property (nonatomic, assign) GLuint framebuffers;

@property (nonatomic, assign) GLuint renderbuffers;

@property (nonatomic, assign) GLuint program;

@property (nonatomic, assign) GLuint vertices;

@end

@implementation ShaderView

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (void)dealloc {
    [self deleteFrameAndRenderBuffers];
}

- (instancetype)initWithFrame:(CGRect)frame bundleName:(NSString *)bundleName {
    self = [super initWithFrame:frame];
    if (self) {
        _lock = [[NSLock alloc] init];
        
        [self deleteFrameAndRenderBuffers];
        
        [self setupFrameAndRenderBuffers];
        
        [self linkProgram:bundleName];
    }
    
    return self;
}

- (void)deleteFrameAndRenderBuffers {
    glDeleteFramebuffers(1, &_framebuffers);
    _framebuffers = 0;
    glDeleteRenderbuffers(1, &_renderbuffers);
    _renderbuffers = 0;
}

- (void)setupFrameAndRenderBuffers {
    
    // EAGLContext初始化必须在着色前
    EAGLContext *context = self.context;
    
    GLuint renderbuffers;
    glGenRenderbuffers(1, &renderbuffers);
    _renderbuffers = renderbuffers;
    glBindRenderbuffer(GL_RENDERBUFFER, _renderbuffers);
    
    BOOL storageSuccess = [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.eAGLLayer];
    if (!storageSuccess) {
#ifdef DEBUG
        NSLog(@"renderbufferStorageFail");
#endif
    }
    
    GLuint framebuffers;
    glGenFramebuffers(1, &framebuffers);
    _framebuffers = framebuffers;
    glBindFramebuffer(GL_FRAMEBUFFER, _framebuffers);
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderbuffers);
}

- (void)linkProgram:(NSString *)bundleName {
    NSBundle *bundle = [[NSBundle alloc] initWithPath:[[NSBundle mainBundle] pathForResource:bundleName ofType:@"bundle"]];
    NSString *vFilePath = [bundle pathForResource:@"shaderv" ofType:@"glsl"];
    NSString *fFilePath = [bundle pathForResource:@"shaderf" ofType:@"glsl"];
    
    if (_program) {
        glDeleteProgram(_program);
        _program = 0;
    }
    
    _program = [self loadShaders:vFilePath fragment:fFilePath];
    glLinkProgram(_program);
    GLint success;
    glGetProgramiv(_program, GL_LINK_STATUS, &success);
    if (success == GL_FALSE) {
        GLchar message[256];
        glGetProgramInfoLog(_program, sizeof(message), 0, &message[0]);
        NSString *error = [NSString stringWithUTF8String:message];
#ifdef DEBUG
        NSLog(@"linkError:%@", error);
#endif
    } else {
        glUseProgram(_program);
    }
}

- (void)render {
    CGFloat scale = [[UIScreen mainScreen] scale];
    glViewport(self.frame.origin.x * scale, self.frame.origin.y * scale, self.frame.size.width * scale, self.frame.size.height * scale);
    
    GLfloat vertexAttribArray[] = {
        0.5f, -0.5f, -1.0f,     0.0f, 1.0f,
        0.5f, 0.5f, -1.0f,      0.0f, 0.0f,
        -0.5f, 0.5f, -1.0f,     1.0f, 0.0f,
        
        0.5f, -0.5f, -1.0f,     0.0f, 1.0f,
        -0.5f, 0.5f, -1.0f,     1.0f, 0.0f,
        -0.5f, -0.5f, -1.0f,    1.0f, 1.0f,
    };
    
    GLuint buffer;
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertexAttribArray), vertexAttribArray, GL_STREAM_DRAW);
    
    GLuint position = glGetAttribLocation(self.program, "position");
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat *)NULL + 0);
    glEnableVertexAttribArray(position);
    
    GLuint texCoord = glGetAttribLocation(self.program, "texCoord");
    glVertexAttribPointer(texCoord, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat *)NULL + 3);
    glEnableVertexAttribArray(texCoord);
    
    [self setupTexture];
    
    GLuint matrix = glGetUniformLocation(self.program, "matrix");
    float radians = M_PI_4;
    float s = sin(radians);
    float c = cos(radians);
    //z轴旋转矩阵
    GLfloat zRotation[16] = {
        c, -s, 0, 0.0,
        s, c, 0, 0.0,
        0, 0, 1.0, 0,
        0, 0, 0, 1.0,
    };
    glUniformMatrix4fv(matrix, 1, GL_FALSE, (GLfloat *)&zRotation[0]);
    
    glClearColor(0.2f, 0.2f, 0.2f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glDrawArrays(GL_TRIANGLES, 0, 6);
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)render3D {
    CGFloat scale = [[UIScreen mainScreen] scale];
    glViewport(self.frame.origin.x * scale, self.frame.origin.y * scale, self.frame.size.width * scale, self.frame.size.height * scale);
    
    // 4个等边三角形
    GLuint indices[] = {
        0, 2, 1,
        0, 1, 3,
        0, 3, 2,
        1, 2, 3,
    };
    
    float AX = 0.0;
    float AY = sqrtf(3.0) / 3.0;
    float AZ = 0.0;
    float BX = -0.5;
    float BY = -(sqrtf(3.0) / 6.0);
    float BZ = 0.0;
    float CX = -BX;
    float CY = BY;
    float CZ = BZ;
    float DX = AX;
    float DY = 0.0;
    float DZ = sqrtf(6.0) / 3.0;
    GLfloat vertexAttribArray[] = {
        AX, AY, AZ,  0.0f, 0.0f, 1.0f,
        BX, BY, BZ,  0.0f, 1.0f, 0.0f,
        CX, CY, CZ,  1.0f, 0.0f, 0.0f,
        DX, DY, DZ,  1.0f, 1.0f, 1.0f,
    };
    
//    GLuint indices[] = {
//        0, 3, 2,
//        0, 1, 3,
//        0, 2, 4,
//        0, 4, 1,
//        1, 4, 3,
//        2, 3, 4,
//    };
//
//    GLfloat vertexAttribArray[] = {
//        -0.5, 0.5, 0.0,  0.0f, 0.0f, 1.0f,
//        0.5, 0.5, 0.0,  0.0f, 1.0f, 0.0f,
//        -0.5, -0.5, 0.0,  1.0f, 0.0f, 0.0f,
//        0.5, -0.5, 0.0,  1.0f, 1.0f, 1.0f,
//        0.0, 0.0, 0.5,  1.0f, 0.0f, 1.0f,
//    };
    
    if (_vertices == 0) {
        glGenBuffers(1, &_vertices);
    }
    glBindBuffer(GL_ARRAY_BUFFER, _vertices);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertexAttribArray), vertexAttribArray, GL_DYNAMIC_DRAW);
    
    GLuint position = glGetAttribLocation(self.program, "position");
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 6, (GLfloat *)NULL + 0);
    glEnableVertexAttribArray(position);
    
    GLuint positionColor = glGetAttribLocation(self.program, "positionColor");
    glVertexAttribPointer(positionColor, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 6, (float *)NULL + 3);
    glEnableVertexAttribArray(positionColor);
    
    GLuint projectionMatrixSlot = glGetUniformLocation(self.program, "projectionMatrix");
    GLuint modelViewMatrixSlot = glGetUniformLocation(self.program, "modelViewMatrix");
    
    float width = self.frame.size.width;
    float height = self.frame.size.height;
    float aspect = width / height;
    
    KSMatrix4 _projectionMatrix;
    ksMatrixLoadIdentity(&_projectionMatrix);
    ksPerspective(&_projectionMatrix, 30.0, aspect, 5.0f, 20.0f); //透视变换，视角30°
    glUniformMatrix4fv(projectionMatrixSlot, 1, GL_FALSE, (GLfloat*)&_projectionMatrix.m[0][0]);
    glEnable(GL_CULL_FACE);
    
    KSMatrix4 _modelViewMatrix;
    ksMatrixLoadIdentity(&_modelViewMatrix);
    ksTranslate(&_modelViewMatrix, 0.0, 0.0, -10.0);
    
    KSMatrix4 _rotationMatrix;
    ksMatrixLoadIdentity(&_rotationMatrix);
    ksRotate(&_rotationMatrix, _angle, 1.0, 0.0, 0.0); //绕X轴
//    ksRotate(&_rotationMatrix, _angle, 0.0, 1.0, 0.0); //绕Y轴
//    ksRotate(&_rotationMatrix, _angle, 0.0, 0.0, 1.0); //绕Z轴
    
    //把变换矩阵相乘，注意先后顺序
    ksMatrixMultiply(&_modelViewMatrix, &_rotationMatrix, &_modelViewMatrix);
    
    glUniformMatrix4fv(modelViewMatrixSlot, 1, GL_FALSE, (GLfloat*)&_modelViewMatrix.m[0][0]);
    
    
    glClearColor(0.2f, 0.2f, 0.2f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glDrawElements(GL_TRIANGLES, sizeof(indices) / sizeof(indices[0]), GL_UNSIGNED_INT, indices);
    
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

- (CAEAGLLayer *)eAGLLayer {
    if (!_eAGLLayer) {
        [_lock lock];
        _eAGLLayer = (CAEAGLLayer *)self.layer;
        [self setContentScaleFactor:[[UIScreen mainScreen] scale]];
        _eAGLLayer.opaque = YES;
        _eAGLLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSNumber numberWithBool:NO],
                                         kEAGLDrawablePropertyRetainedBacking,
                                         kEAGLColorFormatRGBA8,
                                         kEAGLDrawablePropertyColorFormat,
                                         nil];
        [_lock unlock];
    }
    
    return _eAGLLayer;
}

- (EAGLContext *)context {
    if (!_context) {
        [_lock lock];
        _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        
        BOOL success = [EAGLContext setCurrentContext:_context];
        if (!success) {
#ifdef DEBUG
            NSLog(@"setCurrentContextFail");
#endif
        }
        [_lock unlock];
    }
    
    return _context;
}

- (GLuint)loadShaders:(NSString *)vertex fragment:(NSString *)fragment {
    GLuint vShader, fShader;
    GLint program = glCreateProgram();
    
    //编译
    [self compileShader:&vShader type:GL_VERTEX_SHADER file:vertex];
    [self compileShader:&fShader type:GL_FRAGMENT_SHADER file:fragment];
    
    glAttachShader(program, vShader);
    glAttachShader(program, fShader);
    
    glDeleteShader(vShader);
    glDeleteShader(fShader);
    
    return program;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file {
    NSString *content = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    const GLchar *source = (GLchar *)[content UTF8String];
    
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
    GLint status;
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0)
    {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

- (void)setupTexture {
    
    NSString *fileName = @"panda.jpg";
    CGImageRef imageRef = [UIImage imageNamed:fileName].CGImage;
    if (!imageRef) {
#ifdef DEBUG
        NSLog(@"no image");
#endif
    }
    
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    GLubyte *data = (GLubyte *)calloc(width * height * 4, sizeof(GLubyte)); //rgba共4个byte
    CGContextRef contextRef = CGBitmapContextCreate(data, width, height, 8, width * 4, CGImageGetColorSpace(imageRef), kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(contextRef, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(contextRef);
    
    //(这里只有一张图片，故而相当于默认于片元着色器里面的colorMap，如果有多张图不可以这么做）
    glBindTexture(GL_TEXTURE_2D, 0);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    float fw = width, fh = height;
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, fw, fh, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
    glBindTexture(GL_TEXTURE_2D, 0);
    free(data);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
