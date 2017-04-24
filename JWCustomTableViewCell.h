//
//  JWCustomTableViewCell.h
//  camera_example
//
//  Created by jway on 2017/2/27.
//  Copyright © 2017年 jway. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JWCustomCellFrame.h"

@protocol JWCustomCellDelegate <NSObject>

-(void)praiseWithCommentId:(NSString *)commentId AndTag:(int)tag;


@end

@interface JWCustomTableViewCell : UITableViewCell

@property (nonatomic,strong) JWCustomCellFrame * contentFrame;

//用户头像
@property (nonatomic,strong) UIImageView * portrait;

//用户昵称
@property (nonatomic,strong) UILabel * username;

//用户签名
@property (nonatomic,strong) UILabel * sign;

//评论内容
@property (nonatomic,strong) UILabel * content;

//评论附图（容器view）
@property (nonatomic,strong) UIView * comment_image;

//评论时间
@property (nonatomic,strong) UILabel * comment_time;

//点赞按钮
@property (nonatomic,strong) UIButton * praiseBtn;

//点赞数
@property (nonatomic,strong) UILabel * praiseNumbers;

//定义委托代理
@property (nonatomic,weak) id<JWCustomCellDelegate> delegate;

@end
