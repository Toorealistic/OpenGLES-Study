//
//  AGLKPointParticleEffect.h
//  OpenGLES-Study
//
//  Created by Hwl on 2017/5/24.
//  Copyright © 2017年 huang. All rights reserved.
//

#import <GLKit/GLKit.h>

extern const GLKVector3 AGLKDefaultGravity;

@interface AGLKPointParticleEffect : GLKBaseEffect

@property (nonatomic, assign) GLKVector3 gravity;

@property (nonatomic, assign) GLfloat elapsedSeconds;

- (void)addParticleAtPosition:(GLKVector3)position
                     velocity:(GLKVector3)velocity
                        force:(GLKVector3)force
                         size:(float)size
              lifeSpanSeconds:(NSTimeInterval)span
          fadeDurationSeconds:(NSTimeInterval)duration;

- (void)prepareToDraw;

- (void)draw;

@end
