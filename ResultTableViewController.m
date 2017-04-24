//
//  ResultTableViewController.m
//  camera_example
//
//  Created by jway on 2017/1/6.
//  Copyright © 2017年 jway. All rights reserved.
//

#import "ResultTableViewController.h"
#import "JWCarDetailInfoViewController.h"
@interface ResultTableViewController ()

@property (nonatomic,strong) NSArray * keyArray;

//定义两个匹配字典
@property (nonatomic,strong) NSDictionary * brandDic;
@property (nonatomic,strong) NSDictionary * levelDic;

@end

@implementation ResultTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //界面初始化
    self.title = @"识别结果";
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    //快速枚举dictionary，并按照概率值从大到小排序
    _keyArray = [self.resultDic keysSortedByValueUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        if ([obj1 floatValue] > [obj2 floatValue]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        if ([obj1 floatValue] < [obj2 floatValue]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    
   // NSLog(@"keyarray = %@",_keyArray);
    
    //初始化匹配字典
    _brandDic = @{@"crosspolo":@"crossPolo",@"lamando":@"凌度",@"polo":@"Polo",@"tiguan":@"途观",@"touran":@"途安",@"touranl":@"途安L",@"phideon":@"辉昂",@"lavidalx":@"朗行",@"polojinqu":@"劲取",@"lavidaly":@"朗逸",@"polojinqing":@"劲情",@"lavidalj":@"朗境",@"passat":@"帕萨特",@"passatly":@"领驭",@"santanazj":@"志俊",@"santanahn":@"浩纳",@"santanasn":@"尚纳",@"pologti":@"poloGTI"};
    _levelDic = @{@"a0":@"小型车",@"a":@"紧凑型车",@"b":@"中型车",@"suv":@"SUV",@"mpv":@"MPV",@"c":@"中大型车"};
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView.dataSource>0) {
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        [self hideOtherSeparatorLine:tableView];
    }else
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    return 2;
}

//隐藏多余的单元格分割线
-(void)hideOtherSeparatorLine:(UITableView *)tableView{
    UIView * view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return 1;
    else
        return _keyArray.count-1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
        //配置单元格
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        //自定义单元格
        //车型样图
        UIImageView * carImage = [[UIImageView alloc] initWithFrame:CGRectMake(16, 0, 70, 70*2/3.0)];
        carImage.tag = 5;
        [cell.contentView addSubview:carImage];
        
        //识别精确度
        UILabel * accurate = [[UILabel alloc] initWithFrame:CGRectMake(16, 70*2/3.0, 70, 70/3.0)];
        accurate.textAlignment = NSTextAlignmentCenter;
        accurate.font = [UIFont boldSystemFontOfSize:15];
        accurate.textColor = [UIColor whiteColor];
        accurate.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.45];
        accurate.tag = 6;
        [cell.contentView addSubview:accurate];
        
        //车型品牌,eg：上汽大众_crosspolo
        UILabel * car_brand = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(carImage.frame)+10, 5, [UIScreen mainScreen].bounds.size.width-112, 23)];
        car_brand.textAlignment = NSTextAlignmentLeft;
        car_brand.font = [UIFont systemFontOfSize:16];
        [cell.contentView addSubview:car_brand];
        car_brand.tag = 2;
        
        //车型级别
        UILabel * car_level = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(carImage.frame)+10, CGRectGetMaxY(car_brand.frame), [UIScreen mainScreen].bounds.size.width-112, 23)];
        car_level.textAlignment = NSTextAlignmentLeft;
        [cell.contentView addSubview:car_level];
        car_level.tag = 3;
        
        //车型年份
        UILabel * car_year = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(carImage.frame)+10, CGRectGetMaxY(car_level.frame), [UIScreen mainScreen].bounds.size.width-112, 23)];
        car_year.textAlignment = NSTextAlignmentLeft;
        [cell.contentView addSubview:car_year];
        car_year.tag = 4;
        
    }
    
    NSString * str = [_keyArray objectAtIndex:indexPath.row+indexPath.section];
    
   // NSLog(@"str = %@",str);
    
    //分割字符串
    NSArray * strArray = [str componentsSeparatedByString:@" "];
    
    
   // NSLog(@"strArray = %@",strArray);
    //车型图片
    __weak UIImageView * carImage = (UIImageView *)[cell.contentView viewWithTag:5];
    carImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.jpg",[strArray objectAtIndex:1]]];
        //显示预测精度
    __weak UILabel * accurate = (UILabel *)[cell.contentView viewWithTag:6];
    NSNumber * accurate_num = [_resultDic objectForKey:[_keyArray objectAtIndex:indexPath.row+indexPath.section]];
    accurate.text = [NSString stringWithFormat:@"%5.4f",[accurate_num floatValue]];
    
    //显示预测的车型
    __weak UILabel * carBrand = (UILabel *)[cell.contentView viewWithTag:2];
    carBrand.text = [NSString stringWithFormat:@"上汽大众_%@",[_brandDic objectForKey:[strArray objectAtIndex:1]]];
    //显示车型级别
    __weak UILabel * carLevel = (UILabel *)[cell.contentView viewWithTag:3];
    NSString * carLevel_str = [NSString stringWithFormat:@"级别:%@",[_levelDic objectForKey:[strArray lastObject]]];
    NSMutableAttributedString * carLevel_text = [[NSMutableAttributedString alloc] initWithString:carLevel_str attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}];
    [carLevel_text addAttributes:@{NSForegroundColorAttributeName:[UIColor grayColor]} range:[carLevel_str rangeOfString:@"级别:"]];
    [carLevel_text addAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]} range:[carLevel_str rangeOfString:[_levelDic objectForKey:[strArray lastObject]]]];
    carLevel.attributedText = carLevel_text;
    //显示车型年份
    __weak UILabel * carYear = (UILabel *)[cell.contentView viewWithTag:4];
    NSArray * yearArray = [strArray subarrayWithRange:NSMakeRange(2, strArray.count-3)];
    NSString * carYear_str = [NSString stringWithFormat:@"年份:%@",[yearArray componentsJoinedByString:@"#"]];
    NSMutableAttributedString * carYear_text = [[NSMutableAttributedString alloc] initWithString:carYear_str attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}];
    [carYear_text addAttributes:@{NSForegroundColorAttributeName:[UIColor grayColor]} range:[carYear_str rangeOfString:@"年份:"]];
    [carYear_text addAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]} range:[carYear_str rangeOfString:[yearArray componentsJoinedByString:@"#"]]];
    carYear.attributedText = carYear_text;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 35;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return @"目标物体";
    }else
        return @"可能相似";
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString * str = [_keyArray objectAtIndex:indexPath.row+indexPath.section];
    NSArray * strArray = [str componentsSeparatedByString:@" "];
    JWCarDetailInfoViewController * detailView = [[JWCarDetailInfoViewController alloc] init];
    detailView.car_brand = [_brandDic objectForKey:[strArray objectAtIndex:1]];
    [self.navigationController pushViewController:detailView animated:YES];
    
}



@end
