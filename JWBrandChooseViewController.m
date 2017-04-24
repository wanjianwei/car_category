//
//  JWBrandChooseViewController.m
//  camera_example
//
//  Created by jway on 2017/1/3.
//
//

#import "JWBrandChooseViewController.h"
#import "CameraExampleAppDelegate.h"
//下拉刷新
#import "SDRefresh.h"
#import "MBProgressHUD.h"
#import "UIImageView+AFNetworking.h"

@interface JWBrandChooseViewController ()<UITableViewDelegate,UITableViewDataSource>

//存储用户信息
@property(nonatomic,strong) NSArray *carBrandArray;
@property(nonatomic,strong) UITableView * tableView;

@property(nonatomic,strong) CameraExampleAppDelegate * app;

@end

@implementation JWBrandChooseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 初始化
    if (_flag == 0)
        self.title = @"汽车厂家";
    else
        self.title = @"汽车品牌";
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    _tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.view addSubview:_tableView];
    
    _app = (CameraExampleAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //设置下拉刷新
    [self setupHeader];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//下拉刷新
- (void)setupHeader{
    SDRefreshHeaderView *refreshHeader = [SDRefreshHeaderView refreshView];
    // 默认是在navigationController环境下，如果不是在此环境下，请设置 refreshHeader.isEffectedByNavigationController = NO;
    [refreshHeader addToScrollView:self.tableView];
    __weak SDRefreshHeaderView *weakRefreshHeader = refreshHeader;
    refreshHeader.beginRefreshingOperation = ^{
        //界面失去响应
        self.view.userInteractionEnabled = NO;
        [_app.manager POST:[NSString stringWithFormat:@"%@/chooseManufacturerOrBrand.php",url_base] parameters:(_flag == 1)?@{@"flag":@(_flag),@"car_manufacturer":_car_manufacturer}:@{@"flag":@(_flag)} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [weakRefreshHeader endRefreshing];
            //处理返回结果
            if ([[responseObject objectForKey:@"state"] intValue] == 1) {
                //更新UI
                _carBrandArray = [responseObject objectForKey:@"returnInfo"];
                [self.tableView reloadData];
                
            }else{
                //错误提示
                [self showHUDWithNSString:[responseObject objectForKey:@"message"]];
            }
            //恢复交互状态
            self.view.userInteractionEnabled = YES;
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            [weakRefreshHeader endRefreshing];
            //弹出错误提示
            [self showHUDWithNSString:[error.userInfo objectForKey:@"NSLocalizedDescription"]];
            //停止下拉刷新
            self.view.userInteractionEnabled = YES;
            
        }];
    };
    // 进入页面自动加载一次数据
    [refreshHeader beginRefreshing];
    
    /*
    if (_flag == 0)
        _carBrandArray = [NSArray arrayWithObjects:@{@"car_logo":@"123",@"car_factory":@"上海大众"},@{@"car_logo":@"123",@"car_factory":@"一汽奥迪"},@{@"car_logo":@"123",@"car_factory":@"一汽大众"},@{@"car_logo":@"123",@"car_factory":@"东风本田"},@{@"car_logo":@"123",@"car_factory":@"广汽本田"},@{@"car_logo":@"123",@"car_factory":@"奔驰"},@{@"car_logo":@"123",@"car_factory":@"上汽通用别克"}, nil];
    else
        _carBrandArray = [NSArray arrayWithObjects:@{@"carBrand":@"朗逸",@"demoImg":@"123"},@{@"carBrand":@"途观",@"demoImg":@"123"},@{@"carBrand":@"途安",@"demoImg":@"123"},@{@"carBrand":@"CrossPolo",@"demoImg":@"123"},nil];
     */
    
    
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _carBrandArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        
    }
    
    if (_flag == 1) {
        //选择车型品牌
      //  NSString * urlStr = [NSString stringWithFormat:@"%@/car_brand_demoImg/%@",url_base,[[_carBrandArray objectAtIndex:indexPath.row] objectForKey:@"car_demoImg"]];
      //  [cell.imageView setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"dazhong.png"]];
        cell.textLabel.text = [[_carBrandArray objectAtIndex:indexPath.row] objectForKey:@"car_brand"];
    }else{
        //选择车型制造商--有图标
        NSString * urlStr = [NSString stringWithFormat:@"%@/car_logo/%@",url_base,[[_carBrandArray objectAtIndex:indexPath.row] objectForKey:@"car_logo"]];
        
        [cell.imageView setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"dazhong.png"]];
        
        cell.textLabel.text = [[_carBrandArray objectAtIndex:indexPath.row] objectForKey:@"car_manufacturer"];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    [self.delegate finishChooseWithBrand:cell.textLabel.text AndFlag:_flag];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
