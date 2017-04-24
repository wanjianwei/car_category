//
//  JWTutorViewController.m
//  camera_example
//
//  Created by jway on 2017/2/24.
//  Copyright © 2017年 jway. All rights reserved.
//

#import "JWTutorViewController.h"

@interface JWTutorViewController ()

@end

@implementation JWTutorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 初始化
    self.title = @"用户指南";
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    UIScrollView * bgView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    bgView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    bgView.showsHorizontalScrollIndicator = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //添加教程1
    CGRect rect1 = [@"1、打开App，进入首页，首页主要用于展示各个厂家的汽车品牌信息，主要功能及操作如下图所示:" boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width-32, 500) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil];
    UILabel * lab1 = [[UILabel alloc] initWithFrame:CGRectMake(16, 90, [UIScreen mainScreen].bounds.size.width-32, rect1.size.height)];
    lab1.font = [UIFont systemFontOfSize:15];
    lab1.textAlignment = NSTextAlignmentLeft;
    lab1.numberOfLines = 0;
    lab1.backgroundColor = [UIColor clearColor];
    lab1.text = @"1、打开App，进入首页，首页主要用于展示各个厂家的汽车品牌信息，主要功能及操作如下图所示:";
    [bgView addSubview:lab1];
    
    //教程1展示图
    UIImageView * image1 = [[UIImageView alloc] initWithFrame:CGRectMake(16, CGRectGetMaxY(lab1.frame)+20, [UIScreen mainScreen].bounds.size.width-32, [UIScreen mainScreen].bounds.size.width*3/4.0)];
    image1.image = [UIImage imageNamed:@"用户指南1.png"];
    [bgView addSubview:image1];
    
    //添加教程2
    CGRect rect2 = [@"2、本软件其余主要功能如下图所示,点击上图中的\"展开其余功能\"既可进入." boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width-32, 500) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil];
    UILabel * lab2 = [[UILabel alloc] initWithFrame:CGRectMake(16, CGRectGetMaxY(image1.frame)+40, [UIScreen mainScreen].bounds.size.width-32, rect2.size.height)];
    lab2.font = [UIFont systemFontOfSize:15];
    lab2.textAlignment = NSTextAlignmentLeft;
    lab2.numberOfLines = 0;
    lab2.backgroundColor = [UIColor clearColor];
    lab2.text = @"2、本软件其余主要功能如下图所示,点击上图中的\"展开其余功能\"既可进入.";
    [bgView addSubview:lab2];
    
    //教程图2展示
    UIImageView * image2 = [[UIImageView alloc] initWithFrame:CGRectMake(16, CGRectGetMaxY(lab2.frame)+20, [UIScreen mainScreen].bounds.size.width-32, [UIScreen mainScreen].bounds.size.height*2/3.0)];
    image2.image = [UIImage imageNamed:@"用户指南2.jpg"];
    [bgView addSubview:image2];
    
    //教程3
    CGRect rect3 = [@"3、本软件的主要功能是车型识别,点击上图中的\"车型识别\"即可进入下图中的车型拍照界面,该界面的主要提示如下图所示:" boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width-32, 500) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil];
    UILabel * lab3 = [[UILabel alloc] initWithFrame:CGRectMake(16, CGRectGetMaxY(image2.frame)+40, [UIScreen mainScreen].bounds.size.width-32, rect3.size.height)];
    lab3.font = [UIFont systemFontOfSize:15];
    lab3.textAlignment = NSTextAlignmentLeft;
    lab3.numberOfLines = 0;
    lab3.backgroundColor = [UIColor clearColor];
    lab3.text = @"3、本软件的主要功能是车型识别,点击上图中的\"车型识别\"即可进入下图中的车型拍照界面,该界面的主要提示如下图所示:";
    [bgView addSubview:lab3];
    
    //添加教程图3
    UIImageView * image3 = [[UIImageView alloc] initWithFrame:CGRectMake(16, CGRectGetMaxY(lab3.frame)+20, [UIScreen mainScreen].bounds.size.width-32, [UIScreen mainScreen].bounds.size.width*3/4.0)];
    image3.image = [UIImage imageNamed:@"用户指南3.png"];
    [bgView addSubview:image3];
    
    //设置UIScrollView的content尺寸，并添加到view中
    
    [bgView setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, 90+rect1.size.height+20+image1.bounds.size.height+40+rect2.size.height+20+image2.bounds.size.height+40+rect3.size.height+20+image3.bounds.size.height+40)];
    
    [self.view addSubview:bgView];
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
