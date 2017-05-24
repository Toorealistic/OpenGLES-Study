//
//  PointeffectStudyController.m
//  OpenGLES-Study
//
//  Created by Hwl on 2017/5/24.
//  Copyright © 2017年 huang. All rights reserved.
//

#import "PointParticleEffectStudyController.h"
#import "AGLKPointParticleEffect.h"

@interface PointParticleEffectStudyController ()

@property (nonatomic, strong) GLKView *glkView;

@property (nonatomic, strong) EAGLContext *context;

@property (nonatomic, strong) AGLKPointParticleEffect *effect;

@property (assign, nonatomic) NSTimeInterval autoSpawnDelta;

@property (assign, nonatomic) NSTimeInterval lastSpawnTime;

@property (assign, nonatomic) NSInteger currentEmitterIndex;

@property (strong, nonatomic) NSArray *emitterBlocks;

@end

@implementation PointParticleEffectStudyController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupConfig];
    
    [self setupEffect];
    
    [self setupTransform];
    
    [self setupEmitterBlocks];
    
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc]
                                            initWithItems:@[@"1", @"2", @"3", @"4"]];
    [self.view addSubview:segmentedControl];
    segmentedControl.frame = CGRectMake(30, 10, 120, 30);
    [segmentedControl addTarget:self action:@selector(segmentedControlAct:) forControlEvents:UIControlEventValueChanged];
    segmentedControl.selectedSegmentIndex = 0;
}

- (void)segmentedControlAct:(UISegmentedControl *)sender {
    self.currentEmitterIndex = sender.selectedSegmentIndex;
}

- (void)setupConfig {
    self.currentEmitterIndex = 0;
    
    GLKView *glkView = self.glkView;
    glkView.context = self.context;
    [self.view addSubview:glkView];
    [EAGLContext setCurrentContext:self.context];
    
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
}

- (void)setupEffect {
    NSBundle *bundle = [[NSBundle alloc] initWithPath:[[NSBundle mainBundle] pathForResource:@"PointParticleEffect" ofType:@"bundle"]];
    NSString *filePath = [bundle pathForResource:@"ball" ofType:@"png"];
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:nil error:nil];
    self.effect = [[AGLKPointParticleEffect alloc] init];
    self.effect.texture2d0.enabled = YES;
    self.effect.texture2d0.name = textureInfo.name;
    self.effect.texture2d0.target = textureInfo.target;
}

- (void)setupTransform {
    CGSize size = self.view.bounds.size;
    float aspect = fabs(size.width / size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(85.0f), aspect, 0.1f, 20.f);
    self.effect.transform.projectionMatrix = projectionMatrix;
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeLookAt(
                                                      0.0f, 0.0f, 1.0f,
                                                      0.0f, 0.0f, 0.0f,
                                                      0.0f, 1.0f, 0.0f);
    self.effect.transform.modelviewMatrix = modelViewMatrix;
}

- (void)setupEmitterBlocks {
    _emitterBlocks = [NSArray arrayWithObjects:[^{  // 1
        self.autoSpawnDelta = 0.5f;
        
        self.effect.gravity = AGLKDefaultGravity;
        
        float randomXVelocity = -0.5f + 1.0f *
        (float)random() / (float)RAND_MAX;
        
        [self.effect
         addParticleAtPosition:GLKVector3Make(0.0f, 0.0f, 0.9f)
         velocity:GLKVector3Make(randomXVelocity, 1.0f, -1.0f)
         force:GLKVector3Make(0.0f, 9.0f, 0.0f)
         size:4.0f
         lifeSpanSeconds:3.2f
         fadeDurationSeconds:0.5f];
    } copy], [^{  // 2
        self.autoSpawnDelta = 0.05f;
        
        self.effect.gravity = GLKVector3Make(
                                             0.0f, 0.5f, 0.0f);
        
        for(int i = 0; i < 20; i++)
        {
            float randomXVelocity = -0.1f + 0.2f *
            (float)random() / (float)RAND_MAX;
            float randomZVelocity = 0.1f + 0.2f *
            (float)random() / (float)RAND_MAX;
            
            [self.effect
             addParticleAtPosition:GLKVector3Make(0.0f, -0.5f, 0.0f)
             velocity:GLKVector3Make(
                                     randomXVelocity,
                                     0.0,
                                     randomZVelocity)
             force:GLKVector3Make(0.0f, 0.0f, 0.0f)
             size:16.0f
             lifeSpanSeconds:2.2f
             fadeDurationSeconds:3.0f];
        }
    } copy], [^{  // 3
        self.autoSpawnDelta = 0.5f;
        
        self.effect.gravity = GLKVector3Make(
                                             0.0f, 0.0f, 0.0f);
        
        for(int i = 0; i < 100; i++)
        {
            float randomXVelocity = -0.5f + 1.0f *
            (float)random() / (float)RAND_MAX;
            float randomYVelocity = -0.5f + 1.0f *
            (float)random() / (float)RAND_MAX;
            float randomZVelocity = -0.5f + 1.0f *
            (float)random() / (float)RAND_MAX;
            
            [self.effect
             addParticleAtPosition:GLKVector3Make(0.0f, 0.0f, 0.0f)
             velocity:GLKVector3Make(
                                     randomXVelocity,
                                     randomYVelocity,
                                     randomZVelocity)
             force:GLKVector3Make(0.0f, 0.0f, 0.0f)
             size:4.0f
             lifeSpanSeconds:3.2f
             fadeDurationSeconds:0.5f];
        }
    } copy],[^{  // 4
        self.autoSpawnDelta = 3.2f;
        
        self.effect.gravity = GLKVector3Make(
                                             0.0f, 0.0f, 0.0f);
        
        for(int i = 0; i < 100; i++)
        {
            float randomXVelocity = -0.5f + 1.0f * (float)random() / (float)RAND_MAX;
            float randomYVelocity = -0.5f + 1.0f * (float)random() / (float)RAND_MAX;
            GLKVector3 velocity = GLKVector3Normalize(
                                                      GLKVector3Make(
                                                                     randomXVelocity,
                                                                     randomYVelocity,
                                                                     0.0f));
            
            [self.effect
             addParticleAtPosition:GLKVector3Make(0.0f, 0.0f, 0.0f)
             velocity:velocity
             force:GLKVector3MultiplyScalar(velocity, -1.5f)
             size:4.0f
             lifeSpanSeconds:3.2f
             fadeDurationSeconds:0.1f];
        }
    } copy], nil];

}

- (EAGLContext *)context {
    if (!_context) {
        _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    }
    
    return _context;
}

- (GLKView *)glkView {
    if (!_glkView) {
        _glkView = [[GLKView alloc] initWithFrame:self.view.frame];
        _glkView.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
        _glkView.drawableDepthFormat = GLKViewDrawableDepthFormat24;
        _glkView.drawableStencilFormat = GLKViewDrawableStencilFormatNone;
        _glkView.drawableMultisample = GLKViewDrawableMultisampleNone;
        _glkView.delegate = self;
    }
    
    return _glkView;
}

- (void)update {
    [_glkView display];
    
    NSTimeInterval time = self.timeSinceFirstResume;
    NSLog(@"timeSinceFirstResume: %f", self.timeSinceFirstResume);
    
    self.effect.elapsedSeconds = time;
    
    if (self.autoSpawnDelta < (time - self.lastSpawnTime)) {
        self.lastSpawnTime = time;
        
        void(^emitterBlock)() = [self.emitterBlocks objectAtIndex: self.currentEmitterIndex];
        emitterBlock();
    }
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    glClearColor(0.3, 0.3, 0.3, 1);
    
    [self.effect prepareToDraw];
    [self.effect draw];
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
