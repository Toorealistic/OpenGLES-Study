//
//  ShaderView.h
//  OpenGLES-Study
//
//  Created by huang on 2017/5/3.
//  Copyright © 2017年 huang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShaderView : UIView

- (instancetype)initWithFrame:(CGRect)frame bundleName:(NSString *)bundleName;

- (void)render;

- (void)render3D;

@property (nonatomic, assign) GLfloat angle;

@end
