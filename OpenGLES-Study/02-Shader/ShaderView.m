//
//  ShaderView.m
//  OpenGLES-Study
//
//  Created by huang on 2017/5/3.
//  Copyright © 2017年 huang. All rights reserved.
//

#import "ShaderView.h"
#import <OpenGLES/ES2/gl.h>

@interface ShaderView ()

@property (nonatomic, strong) NSLock *lock;

@property (nonatomic, strong) CAEAGLLayer *eAGLLayer;

@property (nonatomic, strong) EAGLContext *context;

@property (nonatomic, assign) GLuint framebuffers;

@property (nonatomic, assign) GLuint renderbuffers;

@property (nonatomic, assign) GLuint program;

@end

@implementation ShaderView

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (void)dealloc {
    [self deleteFrameAndRenderBuffers];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _lock = [[NSLock alloc] init];
        
        [self deleteFrameAndRenderBuffers];
        
        [self setupFrameAndRenderBuffers];
        
        if ([self linkProgram]) {
            [self presentRender];
        }
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
    GLuint renderbuffers;
    glGenRenderbuffers(1, &renderbuffers);
    _renderbuffers = renderbuffers;
    glBindRenderbuffer(GL_RENDERBUFFER, _renderbuffers);
    
    BOOL storageSuccess = [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.eAGLLayer];
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

- (BOOL)linkProgram {
    NSString *vFilePath = [[NSBundle mainBundle] pathForResource:@"shaderv" ofType:@"vsh"];
    NSString *fFilePath = [[NSBundle mainBundle] pathForResource:@"shaderf" ofType:@"fsh"];
    
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
        return NO;
    } else {
        glUseProgram(_program);
        
        return YES;
    }
}

- (void)presentRender {
//    CGFloat scale = [[UIScreen mainScreen] scale];
//    glViewport(self.frame.origin.x * scale, self.frame.origin.y * scale, self.frame.size.width * scale, self.frame.size.height * scale);
//    
//    GLfloat vertexAttribArray[] = {
//        0.5f, -0.5f, -1.0f,     1.0f, 0.0f,
//        -0.5f, 0.5f, -1.0f,     0.0f, 1.0f,
//        -0.5f, -0.5f, -1.0f,    0.0f, 0.0f,
//        
//        0.5f, 0.5f, -1.0f,      1.0f, 1.0f,
//        -0.5f, 0.5f, -1.0f,     0.0f, 1.0f,
//        0.5f, -0.5f, -1.0f,     1.0f, 0.0f,
//    };
//    
//    GLuint buffer;
//    glGenBuffers(1, &buffer);
//    glBindBuffer(GL_ARRAY_BUFFER, buffer);
//    glBufferData(GL_ARRAY_BUFFER, sizeof(vertexAttribArray), vertexAttribArray, GL_STREAM_DRAW);
//    
//    GLuint position = glGetAttribLocation(self.program, "position");
//    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat *)NULL + 0);
//    glEnableVertexAttribArray(position);
//    
//    GLuint texCoord = glGetAttribLocation(self.program, "texCoord");
//    glVertexAttribPointer(texCoord, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat *)NULL + 3);
//    glEnableVertexAttribArray(texCoord);
//    
//    [self setupTexture];
    
//    GLuint matrix = glGetUniformLocation(self.program, "matrix");
//    
//    float radians = 10 * 3.14159f / 180.0f;
//    float s = sin(radians);
//    float c = cos(radians);
//    
//    //z轴旋转矩阵
//    GLfloat zRotation[16] = { //
//        c, -s, 0, 0.0, //
//        s, c, 0, 0.0,//
//        0, 0, 1.0, 0,//
//        0, 0, 0, 1.0,//
//    };
//    
//    glUniformMatrix4fv(matrix, 1, GL_FALSE, (GLfloat *)&zRotation[0]);
    
    
    glClearColor(0.0f, 1.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glDrawArrays(GL_TRIANGLES, 0, 6);
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

- (void)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file {
    NSString *content = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    const GLchar *source = (GLchar *)[content UTF8String];
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
}

- (void)setupTexture {
    NSString *fileName = @"panda.jpg";
    CGImageRef spriteImage = [UIImage imageNamed:fileName].CGImage;
    if (!spriteImage) {
        NSLog(@"Failed to load image %@", fileName);
        exit(1);
    }
    
    // 2 读取图片的大小
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    
    GLubyte * spriteData = (GLubyte *) calloc(width * height * 4, sizeof(GLubyte)); //rgba共4个byte
    
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4,
                                                       CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    
    // 3在CGContextRef上绘图
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
    
    CGContextRelease(spriteContext);
    
    // 4绑定纹理到默认的纹理ID（这里只有一张图片，故而相当于默认于片元着色器里面的colorMap，如果有多张图不可以这么做）
    glBindTexture(GL_TEXTURE_2D, 0);
    
    
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    float fw = width, fh = height;
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, fw, fh, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    
    glBindTexture(GL_TEXTURE_2D, 0);
    
    free(spriteData);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
