//
//  BaseViewController.m
//  OpenGLES-Study
//
//  Created by huang on 2017/5/3.
//  Copyright © 2017年 huang. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    
    NSShadow *shadow = [NSShadow new];
    shadow.shadowColor = [UIColor clearColor];
    [shadow setShadowColor:[UIColor colorWithWhite:1.0f alpha:1.0f]];
    [shadow setShadowOffset:CGSizeMake(0, 0.7)];
    [self.navigationController.navigationBar setTitleTextAttributes:@{
                                                                      NSForegroundColorAttributeName:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0],
                                                                      NSFontAttributeName:[UIFont systemFontOfSize:20],
                                                                      NSShadowAttributeName:shadow}];
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
