//
//  JWCustomCellFrame.h
//  camera_example
//
//  Created by jway on 2017/2/27.
//  Copyright © 2017年 jway. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "JWCustomCellModel.h"

@interface JWCustomCellFrame : NSObject

//定义初始化方法
-(id)initWithCellModel:(JWCustomCellModel *)model;

@property (nonatomic,strong) JWCustomCellModel * model;

@property (nonatomic,assign) CGRect portrait_frame;

@property (nonatomic,assign) CGRect username_frame;

@property (nonatomic,assign) CGRect sign_frame;

@property (nonatomic,assign) CGRect content_frame;

@property (nonatomic,assign) CGRect comment_images_frame;

@property (nonatomic,assign) CGRect comment_time_frame;

//增加一个点赞按钮
@property (nonatomic,assign) CGRect praiseBtn_frame;

@property (nonatomic,assign) CGRect praiseNumbers_frame;

//总体的行高
@property (nonatomic,assign) CGFloat rowHeight;

@end
