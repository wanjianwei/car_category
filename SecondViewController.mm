//
//  SecondViewController.m
//  camera_example
//
//  Created by jway on 2017/1/3.
//
//

#import "SecondViewController.h"
#import "CameraExampleViewController.h"
#import "JWMyInfoViewController.h"
#import "JWUploadCarImageViewController.h"
#import "CameraExampleViewController.h"
#import "IllustrateViewController.h"
#import "JWTutorViewController.h"
#import "JWLoginViewController.h"

@interface SecondViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong) UITableView * tableView;

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //视图初始化
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    _tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.view addSubview:_tableView];
    
    self.title = @"功能界面";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//识别车型
-(void)recognizeCarType{
    
    CameraExampleViewController * photoView = [[CameraExampleViewController alloc] init];
    photoView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:photoView animated:YES];
    
}

#pragma mark -UITableViewDelegate/dataDource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0)
        return 1;
    else if (section == 1)
        return 2;
    else if (section == 2)
        return 1;
    else
        return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    switch (indexPath.section) {
        case 0:
            cell.imageView.image = [UIImage imageNamed:@"myInfo.png"];
            cell.textLabel.text = @"我的信息";
            break;
        case 1:
            if (indexPath.row == 0) {
                cell.imageView.image = [UIImage imageNamed:@"lookOut.png"];
                cell.textLabel.text = @"车型识别";
            }else{
                cell.imageView.image = [UIImage imageNamed:@"img_upload.png"];
                cell.textLabel.text = @"上传车图";
            }
            break;
        case 2:
            cell.imageView.image = [UIImage imageNamed:@"4s_location.png"];
            cell.textLabel.text = @"附近车行";
            break;
        case 3:
            if (indexPath.row == 0) {
                cell.imageView.image = [UIImage imageNamed:@"tutor.png"];
                cell.textLabel.text = @"用户指南";
            }else{
                cell.imageView.image = [UIImage imageNamed:@"describe.png"];
                cell.textLabel.text = @"软件介绍";
            }
            break;
        default:
            break;
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        //跳转到“我的信息”界面
        JWMyInfoViewController * myInfoView = [[JWMyInfoViewController alloc] init];
        [self.navigationController pushViewController:myInfoView animated:YES];
    }else if (indexPath.section == 1){
        if (indexPath.row == 0) {
            //跳转到车型识别界面
            CameraExampleViewController * carRecognizeView = [[CameraExampleViewController alloc] init];
            [self.navigationController pushViewController:carRecognizeView animated:YES];
        }else{
            //跳转到上传车图界面
            JWUploadCarImageViewController * uploadCarImageView = [[JWUploadCarImageViewController alloc] init];
            [self.navigationController pushViewController:uploadCarImageView animated:YES];
        }
    }else if (indexPath.section == 2){
        //跳转到附近车行界面
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://dealer.auto.sohu.com/map"]];
        
    }else{
        if (indexPath.row == 0) {
            //跳转到用户指南界面
            JWTutorViewController * tutorView = [[JWTutorViewController alloc] init];
            [self.navigationController pushViewController:tutorView animated:YES];
        }else{
            //跳转到关于我们界面
            IllustrateViewController * illustrateView = [[IllustrateViewController alloc] init];
            illustrateView.flag = 1;
            [self.navigationController pushViewController:illustrateView animated:YES];
        }
    }
    
    [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
}

@end
