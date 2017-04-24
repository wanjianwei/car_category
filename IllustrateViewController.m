//
//  IllustrateViewController.m
//  camera_example
//
//  Created by jway on 2017/2/21.
//  Copyright © 2017年 jway. All rights reserved.
//

#import "IllustrateViewController.h"

@interface IllustrateViewController ()

@end

@implementation IllustrateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化界面
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self initViewWithFlag:_flag];
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initViewWithFlag:(int)flag{
    //初始化
    if (_flag == 1) {
        self.title = @"软件介绍";
        
        
        //添加UIImageView
        UIImageView * img = [[UIImageView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/3.0, 100, [UIScreen mainScreen].bounds.size.width/3.0, [UIScreen mainScreen].bounds.size.width/3.0)];
        img.image = [UIImage imageNamed:@"test.png"];
        img.layer.cornerRadius = 5;
        img.layer.masksToBounds = YES;
        [self.view addSubview:img];
        
        //设置属性字符串
        NSString * illustrateText = @"      该软件由华中科技大学万建伟同学(Github:https://github.com/wanjianwei)独自开发,是其研究生毕业论文工作中的工程部分.该软件利用tensorflow开放的接口,成功将深度学习模型迁移到移动端.并基于此，设计开发了一个车型细粒度识别系统,以探索人工智能的移动化应用.";
        NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:illustrateText attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17],NSForegroundColorAttributeName:[UIColor blackColor]}];
        [str addAttribute:NSLinkAttributeName value:@"http://foreverwan.vicp.net/about/" range:[illustrateText rangeOfString:@"万建伟"]];
        [str addAttribute:NSLinkAttributeName value:@"https://github.com/wanjianwei" range:[illustrateText rangeOfString:@"https://github.com/wanjianwei"]];
        
        //获取字符串的行高
        CGRect rect = [illustrateText boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width-32, [UIScreen mainScreen].bounds.size.height/2.0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]} context:nil];
        //构建label
        UITextView * illustrateLab = [[UITextView alloc] initWithFrame:CGRectMake(16, CGRectGetMaxY(img.frame)+30, [UIScreen mainScreen].bounds.size.width-32, rect.size.height+30)];
        illustrateLab.font = [UIFont systemFontOfSize:17];
        illustrateLab.textColor = [UIColor grayColor];
        illustrateLab.attributedText = str;
        illustrateLab.editable = NO;
        illustrateLab.scrollEnabled = NO;
        illustrateLab.backgroundColor = [UIColor clearColor];
        [self.view addSubview:illustrateLab];
        
        //添加版权说明
        UILabel * lab_right = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.view.frame)-30, [UIScreen mainScreen].bounds.size.width, 25)];
        lab_right.textColor = [UIColor grayColor];
        lab_right.textAlignment = NSTextAlignmentCenter;
        lab_right.font = [UIFont systemFontOfSize:14];
        lab_right.text = @"Copyright@2017 jway All Rights Reserved";
        [self.view addSubview:lab_right];
        
       
        
        
        
    }else
        self.title = @"用户指南";
}

@end
