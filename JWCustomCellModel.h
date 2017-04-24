//
//  JWCustomCellModel.h
//  camera_example
//
//  Created by jway on 2017/2/27.
//  Copyright © 2017年 jway. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JWCustomCellModel : NSObject

//定义一个初始化方法
-(id) initWithDictionary:(NSDictionary *)dic;

//评论Id
@property (nonatomic,strong) NSString * commentId;

//评论者头像
@property (nonatomic,strong) NSString * portrait;

//用户昵称
@property (nonatomic,strong) NSString * username;

//用户签名
@property (nonatomic,strong) NSString * sign;

//评论内容
@property (nonatomic,strong) NSString * content;

//评论时间:将其转化为string形式存储
@property (nonatomic,strong) NSString * comment_time;

//评论附图-将其转化为数组形式存储
@property (nonatomic,strong) NSArray * imageArray;;

//点赞数:点赞存储形式为23#21#22#46
@property (nonatomic,strong) NSString * praiseNumbers;

//该条评论用户是否点赞过
@property (nonatomic,assign) BOOL isPraiesd;

@end
