//
//  JWCustomCellFrame.m
//  camera_example
//
//  Created by jway on 2017/2/27.
//  Copyright © 2017年 jway. All rights reserved.
//

#import "JWCustomCellFrame.h"

#define WIDTH [UIScreen mainScreen].bounds.size.width

@implementation JWCustomCellFrame

//复写set方法
-(void)setModel:(JWCustomCellModel *)model{
    _model = model;
    [self makeFrame];
}

//初始化方法
-(id)initWithCellModel:(JWCustomCellModel *)model{
    self = [super init];
    if (self) {
        _model = model;
        //构造frame
        [self makeFrame];
    }
    
    return self;
}

//构造frame
-(void)makeFrame{
    _portrait_frame = CGRectMake(16, 20, 60, 60);
    _username_frame = CGRectMake(CGRectGetMaxX(_portrait_frame)+16, 20, WIDTH-32-60-16, 30);
    
    _sign_frame = CGRectMake(CGRectGetMaxX(_portrait_frame)+16, CGRectGetMaxY(_username_frame)+10, WIDTH-92-16, 20);
    //构造content的大小
    CGRect rect = [_model.content boundingRectWithSize:CGSizeMake(WIDTH-32, 600) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]} context:nil];
    _content_frame = CGRectMake(16, CGRectGetMaxY(_portrait_frame)+16, WIDTH-32, rect.size.height);
    
    //构造评论附图的尺寸(主要看有多少个图片)
    if (_model.imageArray.count == 0) {
        _comment_images_frame = CGRectMake(16, CGRectGetMaxY(_content_frame)+16, WIDTH-32, 0);
    }else if (_model.imageArray.count != 0 && _model.imageArray.count<=3){
        _comment_images_frame = CGRectMake(16, CGRectGetMaxY(_content_frame)+16, WIDTH-32, (WIDTH-64)*4/9.0);
    }else{
        //最多只有6张图片
        _comment_images_frame = CGRectMake(16, CGRectGetMaxY(_content_frame)+16, WIDTH-32, (WIDTH-64)*8/9.0+16);
    }
    
    //评论时间
    _comment_time_frame = CGRectMake(16, CGRectGetMaxY(_comment_images_frame)+16, (WIDTH-32)*2/3.0, 30);
    
    //点赞按钮
    _praiseBtn_frame = CGRectMake(CGRectGetMaxX(_comment_time_frame)+16, CGRectGetMaxY(_comment_images_frame)+16+5, 20, 20);
    
    _praiseNumbers_frame = CGRectMake(CGRectGetMaxX(_praiseBtn_frame)+4, CGRectGetMaxY(_comment_images_frame)+16+5, (WIDTH-32)/3.0-50, 20);
    
    //计算rowHeight
    _rowHeight = 20+60+16+rect.size.height+16+_comment_images_frame.size.height+16+30+20;
    
}

@end
