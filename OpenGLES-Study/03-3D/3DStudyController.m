//
//  3DStudyController.m
//  OpenGLES-Study
//
//  Created by huang on 2017/5/5.
//  Copyright © 2017年 huang. All rights reserved.
//

#import "3DStudyController.h"
#import "ShaderView.h"

@interface _DStudyController ()

@property (nonatomic, strong) ShaderView *shaderView;

@property (nonatomic, strong) dispatch_source_t timer;


@end

@implementation _DStudyController

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    dispatch_source_cancel(_timer);
    _timer = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _shaderView = [[ShaderView alloc] initWithFrame:self.view.frame bundleName:@"3D"];
    [self.view addSubview:_shaderView];
    
    // 因为是UI动画渲染，所以必须在主线程队列里进行执行
    dispatch_queue_t queue = dispatch_get_main_queue();
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_timer, DISPATCH_TIME_NOW, 0.05 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(_timer, ^{
        [self render3D];
    });
    dispatch_resume(_timer);
}

- (void)render3D {
    _shaderView.angle += 5;
    [_shaderView render3D];
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
