//
//  JWCommentViewController.m
//  camera_example
//
//  Created by jway on 2017/2/27.
//  Copyright © 2017年 jway. All rights reserved.
//

#import "JWCommentViewController.h"
#import "CameraExampleAppDelegate.h"
#import "JWCustomTableViewCell.h"
#import "SDRefresh.h"
#import "JWPublishCommentViewController.h"
#import "MBProgressHUD.h"
#import "JWLoginViewController.h"

@interface JWCommentViewController ()<UITableViewDelegate,UITableViewDataSource,JWCustomCellDelegate,loginSuccessDelegate>
@property (nonatomic,strong) UITableView * commentList;

//可变数组，用来存储评论
@property (nonatomic,strong) NSMutableArray * commentArray;

//可变数组，用来存储评论的原始数据
@property (nonatomic,strong) NSMutableArray * rawArray;

@property (nonatomic,strong) CameraExampleAppDelegate * app;

//上拉加载
@property (nonatomic, weak) SDRefreshFooterView *refreshFooter;
@property (nonatomic,weak) SDRefreshHeaderView *weakRefreshHeader;

@end

@implementation JWCommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 初始化
    self.title = @"评论详情";
    UIBarButtonItem * rightBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(publishComment)];
    self.navigationItem.rightBarButtonItem = rightBtn;
    
    //初始化tableview
    _commentList = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _commentList.backgroundColor = [UIColor groupTableViewBackgroundColor];
    _commentList.delegate = self;
    _commentList.dataSource = self;
    [self.view addSubview:_commentList];
    _app = (CameraExampleAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    _commentArray = [[NSMutableArray alloc] init];
    _rawArray = [[NSMutableArray alloc] init];
    
    [self setupHeader];
    [self setupFooter];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

//发表评论
-(void)publishComment{
    JWPublishCommentViewController * publishCommentView = [[JWPublishCommentViewController alloc] init];
    publishCommentView.car_brand = _car_brand;
    [self.navigationController pushViewController:publishCommentView animated:YES];
}


//下拉刷新
- (void)setupHeader{
    SDRefreshHeaderView *refreshHeader = [SDRefreshHeaderView refreshView];
    // 默认是在navigationController环境下，如果不是在此环境下，请设置 refreshHeader.isEffectedByNavigationController = NO;
    [refreshHeader addToScrollView:_commentList];
    _weakRefreshHeader = refreshHeader;
    refreshHeader.beginRefreshingOperation = ^{
        [self requestInfo];
     };
    // 进入页面自动加载一次数据
    [refreshHeader beginRefreshing];
}

//向服务器请求评论数据
-(void)requestInfo{
    //界面失去响应
    self.view.userInteractionEnabled = NO;
    //请求服务器
    /**
     *传入的参数有car_brand,flag,和commentTime
     *其中flag = 0表示刷新最新的评论，最新的评论时间必须都大于commentTime，且每次取出所有最新评论，flag = 1表示再多加载最多5条评论，加载的评论，其评论时间都要小于commentTime，flag = 2表示初次请求用户评论，只取最新的评论，且不超过5条；
     */
    [_app.manager POST:[NSString stringWithFormat:@"%@/checkUserComment.php",url_base] parameters:@{@"car_brand":_car_brand,@"flag":(_rawArray.count == 0)?@0:@1,@"commentTime":(_rawArray.count == 0)?@0:[[_rawArray objectAtIndex:0] objectForKey:@"comment_time"]} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //先停止刷新并恢复界面响应
        [_weakRefreshHeader endRefreshing];
        self.view.userInteractionEnabled = YES;
        //获取服务器返回数据
        if ([[responseObject objectForKey:@"state"] intValue] == 1) {
            NSArray * array_temp = [responseObject objectForKey:@"returnInfo"];
            for (int i = 0;i<array_temp.count;i++) {
                //评论原始数据先缓存到rawArray数组中
                [_rawArray insertObject:[array_temp objectAtIndex:i] atIndex:i];
                
                //在插入到commentArray中
                JWCustomCellModel * model = [[JWCustomCellModel alloc] initWithDictionary:[array_temp objectAtIndex:i]];
                JWCustomCellFrame * frame = [[JWCustomCellFrame alloc] initWithCellModel:model];
                [_commentArray insertObject:frame atIndex:i];
            }
            
            //更新表示图
            [_commentList reloadData];
            //提示用户
            [self showHUDWithNSString:@"获取评论成功"];
        }else{
            if ([[responseObject objectForKey:@"message"] isEqualToString:@"请先登录"]) {
                //跳转到登录界面
                [self gotoLoginView];
            }else
                [self showHUDWithNSString:[responseObject objectForKey:@"message"]];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //恢复初始状态
        self.view.userInteractionEnabled = YES;
        [_weakRefreshHeader endRefreshing];
        [self showHUDWithNSString:[error.userInfo objectForKey:@"NSLocalizedDescription"]];
    }];
}

//跳转到登录界面
-(void)gotoLoginView{
    JWLoginViewController * loginView = [[JWLoginViewController alloc] init];
    loginView.delegate = self;
    [self.navigationController pushViewController:loginView animated:YES];
}

//上拉加载
- (void)setupFooter{
    SDRefreshFooterView *refreshFooter = [SDRefreshFooterView refreshView];
    [refreshFooter addToScrollView:_commentList];
    [refreshFooter addTarget:self refreshAction:@selector(footerRefresh)];
    _refreshFooter = refreshFooter;
}

//再次向服务器请求数据，并重新加载
-(void)footerRefresh{
    self.view.userInteractionEnabled = NO;
    //请求服务器
    [_app.manager POST:[NSString stringWithFormat:@"%@/checkUserComment.php",url_base] parameters:@{@"car_brand":_car_brand,@"flag":@2,@"commentTime":[[_rawArray lastObject] objectForKey:@"comment_time"]} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //恢复状态
        self.view.userInteractionEnabled = YES;
        [_refreshFooter endRefreshing];
        
        if ([[responseObject objectForKey:@"state"] intValue] == 1) {
            NSArray * array_temp = [responseObject objectForKey:@"returnInfo"];
            for (int i=0; i<array_temp.count; i++) {
                [_rawArray addObject:[array_temp objectAtIndex:i]];
                JWCustomCellModel * model = [[JWCustomCellModel alloc] initWithDictionary:[array_temp objectAtIndex:i]];
                JWCustomCellFrame * frame = [[JWCustomCellFrame alloc] initWithCellModel:model];
                [_commentArray addObject:frame];
            }
            
            [_commentList reloadData];
            //提示用户
            [self showHUDWithNSString:@"加载评论成功"];
        }else
            [self showHUDWithNSString:[responseObject objectForKey:@"message"]];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //恢复状态
        self.view.userInteractionEnabled = YES;
        [_refreshFooter endRefreshing];
        [self showHUDWithNSString:error.localizedDescription];
    }];
}

//点赞数加1
-(void)addPraiseNumbers{
    UILabel * lab = [[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2.0-20, self.view.bounds.size.height/2.0+30, 40, 44)];
    lab.layer.backgroundColor = [UIColor clearColor].CGColor;
    lab.textColor = [UIColor whiteColor];
    lab.layer.cornerRadius = 5;
    lab.textAlignment = NSTextAlignmentCenter;
    lab.text = @"+ 1";
    lab.font = [UIFont boldSystemFontOfSize:15];
    [self.view addSubview:lab];
    //动画效果
    [UIView animateWithDuration:1.0 animations:^{
        [lab setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2.0-30, self.view.bounds.size.height/2.0-30-44, 60, 44)];
        lab.layer.backgroundColor = [UIColor redColor].CGColor;
    } completion:^(BOOL finished) {
        if(finished)
            //动画结束后，移除label
            [lab removeFromSuperview];
    }];
}

#pragma mark -loginSuccessDelegate
-(void)requestInfoAgain{
    [_weakRefreshHeader beginRefreshing];
}

#pragma mark -JWCustomCellDelegate
-(void)praiseWithCommentId:(NSString *)commentId AndTag:(int)tag{
    //点赞操作
    [_app.manager POST:[NSString stringWithFormat:@"%@/praiseForComment.php",url_base] parameters:@{@"commentId":commentId,@"userId":[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //成功
        if ([[responseObject objectForKey:@"state"] intValue] == 1) {
            //动画显示，点赞数加1
            [self addPraiseNumbers];
            JWCustomCellFrame * frame1 = [_commentArray objectAtIndex:tag];
            frame1.model.isPraiesd = YES;
            frame1.model.praiseNumbers = [NSString stringWithFormat:@"%d",[frame1.model.praiseNumbers intValue]+1];
            //重载表视图
            [_commentList reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:tag inSection:0], nil] withRowAnimation:UITableViewRowAnimationNone];
        }else
            [self showHUDWithNSString:[responseObject objectForKey:@"message"]];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self showHUDWithNSString:error.localizedDescription];
    }];
    
}

#pragma mark -UITableViewDelegate/DataSource
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
    return _commentArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    JWCustomTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[JWCustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    cell.delegate = self;
    cell.praiseBtn.tag = indexPath.row;//标记点击的是哪个单元格
    cell.contentFrame = [_commentArray objectAtIndex:indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    JWCustomCellFrame * frame1 = [_commentArray objectAtIndex:indexPath.row];
    return frame1.rowHeight;
}



@end
