//
//  JWSearchCarViewController.m
//  camera_example
//
//  Created by jway on 2017/1/3.
//
//

#import "JWSearchCarViewController.h"
#import "CameraExampleAppDelegate.h"

@interface JWSearchCarViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchResultsUpdating>

//输入搜索视图
@property (nonatomic,strong) UISearchController * searchView;
//存储搜索结果
@property (nonatomic,strong) NSArray * searchResultArray;
//结果展示视图
@property (nonatomic,strong) UITableView * resultList;

//appDelegate引用
@property (nonatomic,strong) CameraExampleAppDelegate * app;

@end

@implementation JWSearchCarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 初始化
     _searchView = [[UISearchController alloc] initWithSearchResultsController:nil];
     _searchView.searchResultsUpdater = self;
     _searchView.hidesNavigationBarDuringPresentation = NO;
     _searchView.dimsBackgroundDuringPresentation = false;
     _searchView.searchBar.placeholder = @"请输入查找车型";
     self.navigationItem.titleView = _searchView.searchBar;
    
    _searchView.active = YES;

    
    _resultList = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    _resultList.dataSource = self;
    _resultList.delegate = self;
    _resultList.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.view addSubview:_resultList];
    
    _app = (CameraExampleAppDelegate *)[UIApplication sharedApplication].delegate;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (_searchView.active) {
        _searchView.active = NO;
        [_searchView.searchBar removeFromSuperview];
    }
}

#pragma UISearchResultsUpdating
-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    //更新搜索结果
    [_app.manager POST:@"" parameters:@{@"keyword":searchController.searchBar.text} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //
    }];
    
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
    if ([_searchView.searchBar.text isEqualToString:@""])
        return 2;
    else
        return _searchResultArray.count+2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    if ([_searchView.searchBar.text isEqualToString:@""]) {
        cell.imageView.image = [UIImage imageNamed:@"dazhong.png"];
        if (indexPath.row == 0)
            cell.textLabel.text = @"上海大众_途观_2016";
        else
            cell.textLabel.text = @"上海大众_朗逸_2016";
    }else{
        //分类图标展示
        cell.textLabel.text = [[_searchResultArray objectAtIndex:indexPath.row] objectForKey:@"carName"];
        
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 25;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 40)];
    label.textAlignment = NSTextAlignmentLeft;
    label.textColor = [UIColor grayColor];
    label.backgroundColor = [UIColor groupTableViewBackgroundColor];
    label.font = [UIFont boldSystemFontOfSize:15];
    if ([_searchView.searchBar.text isEqualToString:@""]) {
        label.text = @"---热门搜索";
    }else
        label.text = @"---搜索结果";
    return label;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //跳转到选定车型信息展示界面
}

@end
