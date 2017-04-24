//
//  JWCustomTableViewCell.m
//  camera_example
//
//  Created by jway on 2017/2/27.
//  Copyright © 2017年 jway. All rights reserved.
//

#import "JWCustomTableViewCell.h"
#import "UIImageView+AFNetworking.h"

#define WIDTH ([UIScreen mainScreen].bounds.size.width-64)/3.0
#define url_base @"http://120.25.162.238/searchCar"

@implementation JWCustomTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

//复写该方法
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //自定义头像
        _portrait = [[UIImageView alloc] init];
        [self.contentView addSubview:_portrait];
        
        //自定义用户昵称
        _username = [[UILabel alloc] init];
        _username.textColor = [UIColor redColor];
        _username.textAlignment = NSTextAlignmentLeft;
        _username.font = [UIFont boldSystemFontOfSize:17];
        [self.contentView addSubview:_username];
        
        //自定义用户签名
        _sign = [[UILabel alloc] init];
        _sign.textAlignment = NSTextAlignmentLeft;
        _sign.font = [UIFont systemFontOfSize:14];
        _sign.textColor = [UIColor grayColor];
        [self.contentView addSubview:_sign];
        
        //评论内容
        _content = [[UILabel alloc] init];
        _content.numberOfLines = 0;
        _content.textAlignment = NSTextAlignmentLeft;
        _content.font = [UIFont systemFontOfSize:16];
        [self.contentView addSubview:_content];
        
        //评论附图
        _comment_image = [[UIView alloc] init];
        _comment_image.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:_comment_image];
        
        //评论时间
        _comment_time = [[UILabel alloc] init];
        _comment_time.textAlignment = NSTextAlignmentLeft;
        _comment_time.font = [UIFont systemFontOfSize:14];
        _comment_time.textColor = [UIColor grayColor];
        [self.contentView addSubview:_comment_time];
        
        //点赞btn
        _praiseBtn = [[UIButton alloc] init];
        [self.contentView addSubview:_praiseBtn];
        
        //点赞数
        _praiseNumbers = [[UILabel alloc] init];
        _praiseNumbers.textAlignment = NSTextAlignmentLeft;
        _praiseNumbers.textColor = [UIColor grayColor];
        _praiseNumbers.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:_praiseNumbers];
    }
    return self;
}

-(void)setContentFrame:(JWCustomCellFrame *)frame{
    _contentFrame = frame;
    //头像赋值，并且赋予每个控件frame
    [_portrait setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/portrait/%@",url_base,frame.model.portrait]] placeholderImage:[UIImage imageNamed:@"test.png"]];
    [_portrait setFrame:frame.portrait_frame];
    
    //用户昵称赋值
    _username.text = frame.model.username;
    [_username setFrame:frame.username_frame];
    
    //用户签名
    _sign.text = frame.model.sign;
    [_sign setFrame:frame.sign_frame];
    
    //评论内容
    _content.text = frame.model.content;
    [_content setFrame:frame.content_frame];
    
    //首先将_comment_images上的所有子视图移除，然后添加新的imageview，防止cell的重用
    for (UIView * view in [_comment_image subviews])
        [view removeFromSuperview];
    //重新设置frame
    [_comment_image setFrame:frame.comment_images_frame];
    //评论附图，需要重新计算下有几张图片
    for (int i = 0; i<frame.model.imageArray.count; i++) {
        //循环构建UIImageView
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake((16+WIDTH)*(i%3), (16+WIDTH*4/3.0)*(i/3), WIDTH, WIDTH*4/3.0)];
        [imageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat: @"%@/car_comment_images/%@",url_base,[frame.model.imageArray objectAtIndex:i]]] placeholderImage:[UIImage imageNamed:@"test.png"]];
        [_comment_image addSubview:imageView];
    }
    
    //添加评论时间
    _comment_time.text = frame.model.comment_time;
    [_comment_time setFrame:frame.comment_time_frame];
    
    //点赞按钮
    [_praiseBtn setFrame:frame.praiseBtn_frame];
    //如果praiseBtn已经绑定了target，要先去除
    if ([[_praiseBtn allTargets] containsObject:self]) {
        [_praiseBtn removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
    }
    //
    if (frame.model.isPraiesd)
        [_praiseBtn setImage:[UIImage imageNamed:@"praise-2.png"] forState:UIControlStateNormal];
    else{
        [_praiseBtn setImage:[UIImage imageNamed:@"praise-1.png"] forState:
         UIControlStateNormal];
        [_praiseBtn addTarget:self action:@selector(praiseForComment:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    //点赞数
    _praiseNumbers.text = frame.model.praiseNumbers;
    [_praiseNumbers setFrame:frame.praiseNumbers_frame];
}

//点赞
-(void)praiseForComment:(id)sender{
    UIButton * btn = (UIButton *)sender;
    //采用代理形式
    [self.delegate praiseWithCommentId:_contentFrame.model.commentId AndTag:btn.tag];
}

@end
