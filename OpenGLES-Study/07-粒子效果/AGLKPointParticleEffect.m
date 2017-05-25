//
//  AGLKPointParticleEffect.m
//  OpenGLES-Study
//
//  Created by Hwl on 2017/5/24.
//  Copyright © 2017年 huang. All rights reserved.
//

#import "AGLKPointParticleEffect.h"
#import "AGLKVertexAttribArrayBuffer.h"

const GLKVector3 AGLKDefaultGravity = {0.0f, -9.80665f, 0.0f};

typedef struct
{
    GLKVector3 emissionPosition;
    GLKVector3 emissionVelocity;
    GLKVector3 emissionForce;
    GLKVector2 size;
    GLKVector2 emissionTimeAndLife;
}
AGLKParticleAttributes;

typedef enum {
    AGLKParticleEmissionPosition = 0,
    AGLKParticleEmissionVelocity,
    AGLKParticleEmissionForce,
    AGLKParticleSize,
    AGLKParticleEmissionTimeAndLife,
} AGLKParticleAttrib;

enum
{
    AGLKMVPMatrix,
    AGLKSamplers2D,
    AGLKElapsedSeconds,
    AGLKGravity,
    AGLKNumUniforms
};

@interface AGLKPointParticleEffect () {
    GLuint program;
    GLint uniforms[AGLKNumUniforms];
    GLfloat elapsedSeconds;
}

@property (nonatomic, assign) NSUInteger numberOfParticles;

@property (nonatomic, strong) NSMutableData *particleAttributesData;

@property (nonatomic, assign) BOOL particleDataWasUpdated;

@property (strong, nonatomic) AGLKVertexAttribArrayBuffer *particleAttributeBuffer;

@end

@implementation AGLKPointParticleEffect
@synthesize elapsedSeconds;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.gravity = AGLKDefaultGravity;
        self.elapsedSeconds = 0.0f;
        self.particleAttributesData = [NSMutableData data];
    }
    
    return self;
}

- (void)addParticleAtPosition:(GLKVector3)position
                     velocity:(GLKVector3)velocity
                        force:(GLKVector3)force
                         size:(float)size
              lifeSpanSeconds:(NSTimeInterval)span
          fadeDurationSeconds:(NSTimeInterval)duration {
    AGLKParticleAttributes newParticle;
    newParticle.emissionPosition = position;
    newParticle.emissionVelocity = velocity;
    newParticle.emissionForce = force;
    newParticle.size = GLKVector2Make(size, duration);
    newParticle.emissionTimeAndLife = GLKVector2Make(self.elapsedSeconds, self.elapsedSeconds + span);
    
    BOOL foundSlot = NO;
    long count = self.numberOfParticles;
    
    for (int i = 0; i < count && !foundSlot; i++) {
        AGLKParticleAttributes oldParticle = [self particleAtIndex:i];
        if (oldParticle.emissionTimeAndLife.y < self.elapsedSeconds) {
            [self setParticle:newParticle atIndex:i];
            foundSlot = YES;
        }
    }
    
    if (!foundSlot) {
        [self.particleAttributesData appendBytes:&newParticle
                                          length:sizeof(newParticle)];
        self.particleDataWasUpdated = YES;
    }
}

- (void)prepareToDraw {
    if (0 == program) {
        [self loadShaders];
    }
    
    if (0 != program) {
        glUseProgram(program);
        
        GLKMatrix4 modelViewProjectionMatrix = GLKMatrix4Multiply(self.transform.projectionMatrix, self.transform.modelviewMatrix);
        
        glUniformMatrix4fv(uniforms[AGLKMVPMatrix], 1, 0, modelViewProjectionMatrix.m);
        
        glUniform1i(uniforms[AGLKSamplers2D], 0);
        
        glUniform3fv(uniforms[AGLKGravity], 1, self.gravity.v);
        glUniform1fv(uniforms[AGLKElapsedSeconds], 1, &elapsedSeconds);
        
        if (self.particleDataWasUpdated) {
            if (self.particleAttributeBuffer == nil && self.particleAttributesData.length > 0) {
                self.particleAttributeBuffer = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:sizeof(AGLKParticleAttributes)
                                                                                        numberOfVertices:(int)self.particleAttributesData.length / sizeof(AGLKParticleAttributes)
                                                                                                   bytes:self.particleAttributesData.bytes
                                                                                                   usage:GL_DYNAMIC_DRAW];
            } else {
                [self.particleAttributeBuffer reinitWithAttribStride:sizeof(AGLKParticleAttributes)
                                                    numberOfVertices:(int)self.particleAttributesData.length / sizeof(AGLKParticleAttributes)
                                                               bytes:self.particleAttributesData.bytes];
            }
            
            self.particleDataWasUpdated = NO;
        }
        
        [self.particleAttributeBuffer prepareToDrawWithAttrib:AGLKParticleEmissionPosition
                                          numberOfCoordinates:3
                                                 attribOffset:offsetof(AGLKParticleAttributes, emissionPosition)
                                                 shouldEnable:YES];
        
        [self.particleAttributeBuffer prepareToDrawWithAttrib:AGLKParticleEmissionVelocity
                                          numberOfCoordinates:3
                                                 attribOffset:offsetof(AGLKParticleAttributes, emissionVelocity)
                                                 shouldEnable:YES];
        
        [self.particleAttributeBuffer prepareToDrawWithAttrib:AGLKParticleEmissionForce
                                          numberOfCoordinates:3
                                                 attribOffset:offsetof(AGLKParticleAttributes, emissionForce)
                                                 shouldEnable:YES];
        
        [self.particleAttributeBuffer prepareToDrawWithAttrib:AGLKParticleSize
                                          numberOfCoordinates:2
                                                 attribOffset:offsetof(AGLKParticleAttributes, size)
                                                 shouldEnable:YES];
        
        [self.particleAttributeBuffer prepareToDrawWithAttrib:AGLKParticleEmissionTimeAndLife
                                          numberOfCoordinates:2
                                                 attribOffset:offsetof(AGLKParticleAttributes, emissionTimeAndLife)
                                                 shouldEnable:YES];
        
        glActiveTexture(GL_TEXTURE0);
        if (self.texture2d0.name != 0 && self.texture2d0.enabled) {
            glBindTexture(GL_TEXTURE_2D, self.texture2d0.name);
        } else {
            glBindTexture(GL_TEXTURE_2D, 0);
        }
    }
}

- (void)draw {
    glDepthMask(GL_FALSE);
    [self.particleAttributeBuffer drawArrayWithMode:GL_POINTS
                                   startVertexIndex:0
                                   numberOfVertices:(int)self.numberOfParticles];
    glDepthMask(GL_TRUE);
}

- (NSUInteger)numberOfParticles {
    long num = self.particleAttributesData.length / sizeof(AGLKParticleAttributes);
    return num;
}

- (AGLKParticleAttributes)particleAtIndex:(NSUInteger)anIndex {
    NSParameterAssert(anIndex < self.numberOfParticles);
    
    const AGLKParticleAttributes *particlesPtr =
    (const AGLKParticleAttributes *)[self.particleAttributesData
                                     bytes];
    
    return particlesPtr[anIndex];
}

- (void)setParticle:(AGLKParticleAttributes)aParticle
            atIndex:(NSUInteger)anIndex {
    NSParameterAssert(anIndex < self.numberOfParticles);
    
    AGLKParticleAttributes *particlesPtr = (AGLKParticleAttributes *)[self.particleAttributesData
                               mutableBytes];
    particlesPtr[anIndex] = aParticle;
    
    self.particleDataWasUpdated = YES;
}

- (BOOL)loadShaders {
    NSBundle *bundle = [[NSBundle alloc] initWithPath:[[NSBundle mainBundle] pathForResource:@"PointParticleEffect" ofType:@"bundle"]];
    NSString *vFilePath = [bundle pathForResource:@"AGLKPointParticleShader" ofType:@"vsh"];
    NSString *fFilePath = [bundle pathForResource:@"AGLKPointParticleShader" ofType:@"fsh"];
    
    program = [self loadShaders:vFilePath fragment:fFilePath];
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(program, AGLKParticleEmissionPosition,
                         "a_emissionPosition");
    glBindAttribLocation(program, AGLKParticleEmissionVelocity,
                         "a_emissionVelocity");
    glBindAttribLocation(program, AGLKParticleEmissionForce,
                         "a_emissionForce");
    glBindAttribLocation(program, AGLKParticleSize,
                         "a_size");
    glBindAttribLocation(program, AGLKParticleEmissionTimeAndLife,
                         "a_emissionAndDeathTimes");

    
    glLinkProgram(program);
    GLint success;
    glGetProgramiv(program, GL_LINK_STATUS, &success);
    if (success == GL_FALSE) {
        GLchar message[256];
        glGetProgramInfoLog(program, sizeof(message), 0, &message[0]);
        NSString *error = [NSString stringWithUTF8String:message];
#ifdef DEBUG
        NSLog(@"linkError:%@", error);
#endif
        glDeleteProgram(program);
        program = 0;

        return NO;
    }
    
    uniforms[AGLKMVPMatrix] = glGetUniformLocation(program,
                                                   "u_mvpMatrix");
    uniforms[AGLKSamplers2D] = glGetUniformLocation(program,
                                                    "u_samplers2D");
    uniforms[AGLKGravity] = glGetUniformLocation(program,
                                                 "u_gravity");
    uniforms[AGLKElapsedSeconds] = glGetUniformLocation(program,
                                                        "u_elapsedSeconds");
    
    
    
    return YES;
}

- (GLuint)loadShaders:(NSString *)vertex fragment:(NSString *)fragment {
    GLuint vShader, fShader;
    GLint newProgram = glCreateProgram();
    
    //编译
    [self compileShader:&vShader type:GL_VERTEX_SHADER file:vertex];
    [self compileShader:&fShader type:GL_FRAGMENT_SHADER file:fragment];
    
    glAttachShader(newProgram, vShader);
    glAttachShader(newProgram, fShader);
    
    glDeleteShader(vShader);
    glDeleteShader(fShader);
    
    return newProgram;
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

@end
