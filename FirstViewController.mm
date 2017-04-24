//
//  FirstViewController.m
//  camera_example
//
//  Created by jway on 2017/1/2.
//
//

#import "FirstViewController.h"
#import "AFNetworking.h"
//#import "SDRefresh.h"
#import "UIImageView+AFNetworking.h"
#import "CameraExampleAppDelegate.h"
#import "MBProgressHUD.h"
//#import "JWSearchCarViewController.h"
#import "JWBrandChooseViewController.h"
//#import "JWMyInfoViewController.h"
#import "SecondViewController.h"
#import "CameraExampleViewController.h"
#import "JWUploadCarImageViewController.h"
#import "UIImageView+AFNetworking.h"
#import "JWCarDetailInfoViewController.h"

@interface FirstViewController ()<UITableViewDelegate,UITableViewDataSource,chooseBrandProtocol>{
    UIButton * refreshBtn;
}

//汽车信息展示列表
@property(nonatomic,strong) UITableView * carInfoList;
//可变数组，用来存储汽车信息数据
@property (nonatomic,strong) NSArray * carInfo_array;
//appDelegate引用
@property (nonatomic,strong) CameraExampleAppDelegate * app;

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化设置
    [self createView];
    _app = (CameraExampleAppDelegate *)[[UIApplication sharedApplication] delegate];
    [self requestCarInfosWithManufacturer:@"上汽大众"];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//初次加载初始化视图
-(void) createView{
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    _carInfoList = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStylePlain];
    [self.view addSubview:_carInfoList];
    _carInfoList.dataSource = self;
    _carInfoList.delegate = self;
    _carInfoList.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    UIBarButtonItem * barbutton1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(clickCamareIcon)];
    
    UIBarButtonItem * barButton2 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"checkAll.png"] style:UIBarButtonItemStyleDone target:self action:@selector(checkAllFounctions)];
    
    self.navigationItem.rightBarButtonItem = barbutton1;
    self.navigationItem.leftBarButtonItem = barButton2;
   
    
    UIButton * titleBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 300, 40)];
    [titleBtn addTarget:self action:@selector(changeBrand) forControlEvents:UIControlEventTouchUpInside];
    [titleBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [titleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateFocused];
    [titleBtn setTitle:@"上汽大众" forState:UIControlStateNormal];
    titleBtn.titleLabel.font = [UIFont boldSystemFontOfSize:19.0];
    titleBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleBtn;
    
}

//请求服务器
-(void)requestCarInfosWithManufacturer:(NSString *)name{
    //活动指示器展示
    MBProgressHUD * activity_hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    activity_hud.mode = MBProgressHUDModeIndeterminate;
    activity_hud.removeFromSuperViewOnHide = YES;
    activity_hud.label.text = @"加载中";
    //每次请求不同厂商的车型信息前，都先把存储车型信息的数组清空
    _carInfo_array = nil;
    //请求服务器
    [_app.manager POST:[NSString stringWithFormat:@"%@/getCarInfo.php",url_base] parameters:@{@"car_manufacturer":name} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        activity_hud.hidden = YES;
        if ([[responseObject objectForKey:@"state"] intValue] == 1) {
           _carInfo_array = [responseObject objectForKey:@"returnInfo"];
            [_carInfoList reloadData];
            
            //去除refreshBtn
            if (refreshBtn != nil) {
                [refreshBtn removeFromSuperview];
                refreshBtn = nil;
            }
            
        }else{
            [self showHUDWithNSString:[responseObject objectForKey:@"message"]];
            [_carInfoList reloadData];
            if (refreshBtn == nil)
                [self refresh];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        activity_hud.hidden = YES;
        //如果错误，就弹出提示
        [self showHUDWithNSString:[error.userInfo objectForKey:@"NSLocalizedDescription"]];
        [_carInfoList reloadData];
        //添加刷新按钮
        if (refreshBtn == nil)
            [self refresh];
    }];

}

//刷新重新获取数据
-(void)refresh{
    if(refreshBtn == nil){
        refreshBtn = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2.0-25, [UIScreen mainScreen].bounds.size.height/2.0-25, 50, 50)];
        [refreshBtn setBackgroundImage:[UIImage imageNamed:@"refresh.png"] forState:UIControlStateNormal];
        [refreshBtn addTarget:self action:@selector(requestAgain) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:refreshBtn];
    }
    
}

-(void)requestAgain{
    [refreshBtn removeFromSuperview];
    refreshBtn = nil;
    [self requestCarInfosWithManufacturer:((UIButton *)self.navigationItem.titleView).titleLabel.text];
}

//更换汽车品牌
-(void)changeBrand{
    JWBrandChooseViewController * brandChooseView = [[JWBrandChooseViewController alloc] init];
    brandChooseView.flag = 0;
    brandChooseView.delegate = self;
    [self.navigationController pushViewController:brandChooseView animated:YES];
}


//点击camera图标，弹出UIAlertcontroller
-(void)clickCamareIcon{
    UIAlertController * alertVontroller = [UIAlertController alertControllerWithTitle:@"操作列表" message:@"请选择您要进行的操作" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction * action1 = [UIAlertAction actionWithTitle:@"车型识别" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //跳转到车型识别界面
        CameraExampleViewController * photoView = [[CameraExampleViewController alloc] init];
        //photoView.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:photoView animated:YES];
    }];
    UIAlertAction * action2 = [UIAlertAction actionWithTitle:@"上传车图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //跳转到车型图片上传界面
        JWUploadCarImageViewController * uploadImageView = [[JWUploadCarImageViewController alloc] init];
        [self.navigationController pushViewController:uploadImageView animated:YES];
    }];
    UIAlertAction * action3 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [alertVontroller addAction:action1];
    [alertVontroller addAction:action2];
    [alertVontroller addAction:action3];
    [self presentViewController:alertVontroller animated:YES completion:nil];
}

//跳转到功能界面
-(void)checkAllFounctions{
    SecondViewController * secondView = [[SecondViewController alloc] init];
    [self.navigationController pushViewController:secondView animated:YES];
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



#pragma mark -UITableViewDelegate,UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (tableView.dataSource>0) {
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        [self hideOtherSeparatorLine:tableView];
    }else
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    return 1;
}

//隐藏多余的单元格分割线
-(void)hideOtherSeparatorLine:(UITableView *)tableView{
    UIView * view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _carInfo_array.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        //自定义单元格
        //车型样图
        UIImageView * carImage = [[UIImageView alloc] initWithFrame:CGRectMake(16, 0, 70, 70*2/3.0)];
        carImage.tag = 5;
        [cell.contentView addSubview:carImage];
        
        //车型品牌
        UILabel * car_brand = [[UILabel alloc] initWithFrame:CGRectMake(16, 70*2/3.0, 70, 70/3.0)];
        car_brand.textAlignment = NSTextAlignmentCenter;
        car_brand.font = [UIFont boldSystemFontOfSize:15];
        car_brand.textColor = [UIColor whiteColor];
        car_brand.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.45];
        car_brand.tag = 6;
        [cell.contentView addSubview:car_brand];
        
        //车型售价
        UILabel * car_price = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(carImage.frame)+10, 5, [UIScreen mainScreen].bounds.size.width-112, 23)];
        car_price.textAlignment = NSTextAlignmentLeft;
       
        [cell.contentView addSubview:car_price];
        car_price.tag = 2;
        
        //车型油耗
        UILabel * car_MPG = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(carImage.frame)+10, CGRectGetMaxY(car_price.frame), [UIScreen mainScreen].bounds.size.width-112, 23)];
        car_MPG.textAlignment = NSTextAlignmentLeft;
        [cell.contentView addSubview:car_MPG];
        car_MPG.tag = 3;
        
        //车型等级
        UILabel * car_level = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(carImage.frame)+10, CGRectGetMaxY(car_MPG.frame), [UIScreen mainScreen].bounds.size.width-112, 23)];
        car_level.textAlignment = NSTextAlignmentLeft;
        [cell.contentView addSubview:car_level];
        car_level.tag = 4;
    }
    //显示车型样图
    __weak UIImageView * carImage = (UIImageView *)[cell.contentView viewWithTag:5];
    
    [carImage setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/car_brand_demoImg/%@.jpg",url_base,[[_carInfo_array objectAtIndex:indexPath.row] objectForKey:@"car_demoImg"]]] placeholderImage:[UIImage imageNamed:@"test.png"]];

    //显示车型品牌
    __weak UILabel * carBrand = (UILabel *)[cell.contentView viewWithTag:6];
    carBrand.text = [[_carInfo_array objectAtIndex:indexPath.row] objectForKey:@"car_brand"];
    
    //显示车型售价
    __weak UILabel * carPrice = (UILabel *)[cell.contentView viewWithTag:2];
    NSString * carPrice_str = [NSString stringWithFormat:@"售价:%@",[[_carInfo_array objectAtIndex:indexPath.row] objectForKey:@"car_price"]];
    
    NSMutableAttributedString * carPrice_text = [[NSMutableAttributedString alloc] initWithString:carPrice_str attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}];
    [carPrice_text addAttributes:@{NSForegroundColorAttributeName:[UIColor grayColor]} range:[carPrice_str rangeOfString:@"售价:"]];
    [carPrice_text addAttributes:@{NSForegroundColorAttributeName:[UIColor redColor]} range:[carPrice_str rangeOfString:[[_carInfo_array objectAtIndex:indexPath.row] objectForKey:@"car_price"]]];
    carPrice.attributedText = carPrice_text;
    
    //显示车型油耗
    __weak UILabel * carMPG = (UILabel *)[cell.contentView viewWithTag:3];
    NSString * carMPG_str = [NSString stringWithFormat:@"油耗:%@",[[_carInfo_array objectAtIndex:indexPath.row] objectForKey:@"car_MPG"]];
    NSMutableAttributedString * carMPG_text = [[NSMutableAttributedString alloc] initWithString:carMPG_str attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}];
    [carMPG_text addAttributes:@{NSForegroundColorAttributeName:[UIColor grayColor]} range:[carMPG_str rangeOfString:@"油耗:"]];
    [carMPG_text addAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]} range:[carMPG_str rangeOfString:[[_carInfo_array objectAtIndex:indexPath.row] objectForKey:@"car_MPG"]]];
    carMPG.attributedText = carMPG_text;
    
    //显示车型级别
    __weak UILabel * carLevel = (UILabel *)[cell.contentView viewWithTag:4];
    NSString * carLevel_str = [NSString stringWithFormat:@"级别:%@",[[_carInfo_array objectAtIndex:indexPath.row] objectForKey:@"car_level"]];
    NSMutableAttributedString * carLevel_text = [[NSMutableAttributedString alloc] initWithString:carLevel_str attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}];
    [carLevel_text addAttributes:@{NSForegroundColorAttributeName:[UIColor grayColor]} range:[carLevel_str rangeOfString:@"级别:"]];
    [carLevel_text addAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]} range:[carLevel_str rangeOfString:[[_carInfo_array objectAtIndex:indexPath.row] objectForKey:@"car_level"]]];
    carLevel.attributedText = carLevel_text;
    
    return cell;
}
//该回调方法先于cellforRowsInSection执行
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

//点击单元格，查看详细信息
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //点击单元格
    JWCarDetailInfoViewController * detailView = [[JWCarDetailInfoViewController alloc] init];
    detailView.car_brand = [[_carInfo_array objectAtIndex:indexPath.row] objectForKey:@"car_brand"];
    [self.navigationController pushViewController:detailView animated:YES];
    [_carInfoList reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
    
}


#pragma mark --chooseBrandProtocol
-(void)finishChooseWithBrand:(NSString *)brand AndFlag:(int)flag{
    if (flag == 0) {
        //重新开始搜索
        UIButton * btn = (UIButton *)self.navigationItem.titleView;
        //如果厂商并未更改，则不需要再请求服务器
        if (![brand isEqualToString:btn.titleLabel.text]) {
            [btn setTitle:brand forState:UIControlStateNormal];
            //请求服务器
            [self requestCarInfosWithManufacturer:brand];
        }
    }
}

@end
