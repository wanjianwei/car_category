//
//  JWCarDetailInfoViewController.m
//  camera_example
//
//  Created by jway on 2017/2/22.
//  Copyright © 2017年 jway. All rights reserved.
//

#import "JWCarDetailInfoViewController.h"
#import "MBProgressHUD.h"
#import "CameraExampleAppDelegate.h"
#import "JWScrollImagesView.h"
#import "JWCarParameterOrDealersInfoViewController.h"
#import "JWCommentViewController.h"

@interface JWCarDetailInfoViewController ()

@property (nonatomic,strong) CameraExampleAppDelegate * app;

//用来存储服务器返回的数据
@property (nonatomic,strong) NSDictionary * carDetailInfo;

@end

@implementation JWCarDetailInfoViewController

//定义两个参数，用来存储优点文本和缺点文本的行高
CGFloat advantage_rowHeight;
CGFloat drawback_rowHeight;

- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化界面
    self.title = _car_brand;
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    _app = (CameraExampleAppDelegate *)[UIApplication sharedApplication].delegate;
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [self setHeaderViewWithImagesArray:nil];
    
    //请求数据
    [self requestInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//响应手势，查阅车型图片
-(void)handTap{
    
}

//设置表头
-(void)setHeaderViewWithImagesArray:(NSArray *)array{
    //构造tableHeaderView
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, ([UIScreen mainScreen].bounds.size.height-80)/3.0+60)];
    headerView.backgroundColor = [UIColor whiteColor];
    //定义滚动视图
    JWScrollImagesView * scrollView = [[JWScrollImagesView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, ([UIScreen mainScreen].bounds.size.height-80)/3.0) WithImageArray:array];
    //添加点击事件
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handTap)];
    tap.numberOfTouchesRequired = 1;
    //添加手势处理器
    [scrollView addGestureRecognizer:tap];
    
    [headerView addSubview:scrollView];
    
    //添加结构
    UILabel * car_architecture = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(scrollView.frame)+5, [UIScreen mainScreen].bounds.size.width/3.0, 20)];
    car_architecture.textAlignment = NSTextAlignmentCenter;
    car_architecture.font = [UIFont boldSystemFontOfSize:18];
    car_architecture.text = @"结构";
    [headerView addSubview:car_architecture];
    
    UILabel * car_architecture_value = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(car_architecture.frame)+10, [UIScreen mainScreen].bounds.size.width/3.0, 20)];
    car_architecture_value.textAlignment = NSTextAlignmentCenter;
    car_architecture_value.font = [UIFont systemFontOfSize:16];
    car_architecture_value.textColor = [UIColor grayColor];
    car_architecture_value.text = [_carDetailInfo objectForKey:@"car_architecture"];
    [headerView addSubview:car_architecture_value];
    
    //添加级别
    UILabel * car_level = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(car_architecture.frame), CGRectGetMaxY(scrollView.frame)+5, [UIScreen mainScreen].bounds.size.width/3.0, 20)];
    car_level.textAlignment = NSTextAlignmentCenter;
    car_level.font = [UIFont boldSystemFontOfSize:18];
    car_level.text = @"级别";
    [headerView addSubview:car_level];
    
    UILabel * car_level_value = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(car_architecture.frame), CGRectGetMaxY(car_level.frame)+10, [UIScreen mainScreen].bounds.size.width/3.0, 20)];
    car_level_value.textAlignment = NSTextAlignmentCenter;
    car_level_value.font = [UIFont systemFontOfSize:16];
    car_level_value.textColor = [UIColor grayColor];
    car_level_value.text = [_carDetailInfo objectForKey:@"car_level"];
    [headerView addSubview:car_level_value];
    
    //添加售价
    UILabel * car_price = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(car_level.frame), CGRectGetMaxY(scrollView.frame)+5, [UIScreen mainScreen].bounds.size.width/3.0, 20)];
    car_price.textAlignment = NSTextAlignmentCenter;
    car_price.font = [UIFont boldSystemFontOfSize:18];
    car_price.text = @"售价";
    [headerView addSubview:car_price];
    
    UILabel * car_price_value = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(car_level.frame), CGRectGetMaxY(car_price.frame)+10, [UIScreen mainScreen].bounds.size.width/3.0, 20)];
    car_price_value.textAlignment = NSTextAlignmentCenter;
    car_price_value.font = [UIFont systemFontOfSize:16];
    car_price_value.textColor = [UIColor grayColor];
    car_price_value.text = [_carDetailInfo objectForKey:@"car_price"];
    [headerView addSubview:car_price_value];
    
    [self.tableView setTableHeaderView:headerView];
}

//向服务器请求数据
-(void)requestInfo{
    
    NSLog(@"123");
    
    //先显示活动指示器
    MBProgressHUD * hud1 = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud1.mode = MBProgressHUDModeIndeterminate;
    hud1.removeFromSuperViewOnHide = YES;
    hud1.label.text = @"加载中";
    //请求数据
    [_app.manager POST:[NSString stringWithFormat:@"%@/getCarDetailInfo.php",url_base] parameters:@{@"car_brand":_car_brand} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //请求结果
        hud1.hidden = YES;
        if ([[responseObject objectForKey:@"state"] intValue] == 1) {
            _carDetailInfo = [responseObject objectForKey:@"returnInfo"];
            //请求成功，去掉刷新barButton
            self.navigationItem.rightBarButtonItem = nil;
            //计算优点行高
            NSString * advantage = [_carDetailInfo objectForKey:@"car_advantage"];
            CGRect rect_advantage = [advantage boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width-80-16, 500) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil];
            advantage_rowHeight = rect_advantage.size.height;
            
            //计算缺点行高
            NSString * drawback = [_carDetailInfo objectForKey:@"car_drawback"];
            CGRect rect_drawback = [drawback boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width-80-16, 500) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil];
            drawback_rowHeight = rect_drawback.size.height;
            
            //将车型图片解析为URL数组
            NSArray * array = [[_carDetailInfo objectForKey:@"car_images"] componentsSeparatedByString:@"#"];
            //定义可变数组
            NSMutableArray * mutableArray = [[NSMutableArray alloc] init];
            for (NSString * str in array) {
                NSString * imageUrl = [NSString stringWithFormat:@"%@/car_brand_images/%@/%@",url_base,[_carDetailInfo objectForKey:@"car_demoImg"],str];
                [mutableArray addObject:imageUrl];
            }
            [self setHeaderViewWithImagesArray:[mutableArray copy]];
            
            [self.tableView reloadData];
        }else{
            [self showHUDWithNSString:[responseObject objectForKey:@"message"]];
            //添加刷新barButton
            UIBarButtonItem * refreshBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(requestAgain)];
            self.navigationItem.rightBarButtonItem = refreshBtn;
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        hud1.hidden = YES;
        //网络请求错误
        [self showHUDWithNSString:[error.userInfo objectForKey:@"NSLocalizedDescription"]];
        //添加刷新barButton
        UIBarButtonItem * refreshBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(requestAgain)];
        self.navigationItem.rightBarButtonItem = refreshBtn;
    }];
}

//刷新，再次请求服务器
-(void)requestAgain{
    [self requestInfo];
}

//展示显示错误提示hud
-(void)showHUDWithNSString:(NSString * )str{
    MBProgressHUD * HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.mode = MBProgressHUDModeText;
    HUD.label.text = str;
    HUD.margin = 10;
    HUD.offset =CGPointMake(0, [UIScreen mainScreen].bounds.size.height/2.0-60);
    HUD.removeFromSuperViewOnHide = YES;
    [HUD hideAnimated:YES afterDelay:1.5];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (section == 0)
        return 4;
    else if (section == 1)
        return 3;
    else
        return 2;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
    }else{
        //删除添加的subview
        for(UIView * view in [cell.contentView subviews])
            [view removeFromSuperview];
    }
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"排量";
            cell.detailTextLabel.text = [_carDetailInfo objectForKey:@"car_displacement"];
        }else if (indexPath.row == 1){
            cell.textLabel.text = @"保修";
            cell.detailTextLabel.text = [_carDetailInfo objectForKey:@"car_warranty"];
        }else if (indexPath.row == 2){
            cell.textLabel.text = @"油耗";
            cell.detailTextLabel.text = [_carDetailInfo objectForKey:@"car_MPG"];
        }else{
            cell.textLabel.text = @"二手车";
            cell.detailTextLabel.text = [_carDetailInfo objectForKey:@"car_secondHand"];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }else if (indexPath.section == 1){
        if (indexPath.row == 0) {
            cell.textLabel.text = @"查看参数详情";
            cell.detailTextLabel.text = nil;
        }else if(indexPath.row == 1){
            cell.textLabel.text = @"查看经销商";
            cell.detailTextLabel.text = nil;
        }else{
            cell.textLabel.text = @"查看用户评价";
            cell.detailTextLabel.text = nil;
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }else{
        //显示优点和缺点
        if (indexPath.row == 0) {
            cell.textLabel.text = @"优点";
            UILabel * lab = [[UILabel alloc] initWithFrame:CGRectMake(80, 10, [UIScreen mainScreen].bounds.size.width-80-16, advantage_rowHeight)];
            lab.textColor = [UIColor redColor];
            lab.numberOfLines = 0;
            lab.textAlignment = NSTextAlignmentLeft;
            lab.font = [UIFont systemFontOfSize:15];
            lab.text = [_carDetailInfo objectForKey:@"car_advantage"];
            [cell.contentView addSubview:lab];
            
           
        }else{
            cell.textLabel.text = @"缺点";
            UILabel * lab = [[UILabel alloc] initWithFrame:CGRectMake(80, 10, [UIScreen mainScreen].bounds.size.width-80-16, drawback_rowHeight)];
            lab.textColor = [UIColor grayColor];
            lab.numberOfLines = 0;
            lab.textAlignment = NSTextAlignmentLeft;
            lab.font = [UIFont systemFontOfSize:15];
            lab.text = [_carDetailInfo objectForKey:@"car_drawback"];
            [cell.contentView addSubview:lab];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 2) {
        if (indexPath.row == 0)
            return advantage_rowHeight+20;
        else
            return drawback_rowHeight+20;
            
    }else
        return 44;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return nil;
    }else if (section == 1)
        return @"---车型详细信息";
    else
        return @"---网友评价总结";
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0)
        return 0;
    else
        return 25;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            JWCarParameterOrDealersInfoViewController * detailView = [[JWCarParameterOrDealersInfoViewController alloc] init];
            detailView.url = [_carDetailInfo objectForKey:@"car_parameters"];
            [self.navigationController pushViewController:detailView animated:YES];
            
        }else if(indexPath.row == 1){
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[_carDetailInfo objectForKey:@"car_dealership"]]];
        }else{
            JWCommentViewController * commentView = [[JWCommentViewController alloc] init];
            //将车型品牌名传递过去
            commentView.car_brand = _car_brand;
            [self.navigationController pushViewController:commentView animated:YES];
        }
        
        
    }
}


@end
