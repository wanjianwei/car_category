//
//  JWUploadCarImageViewController.m
//  camera_example
//
//  Created by jway on 2017/2/21.
//  Copyright © 2017年 jway. All rights reserved.
//

#import "JWUploadCarImageViewController.h"
#import "CameraExampleAppDelegate.h"
#import "JWBrandChooseViewController.h"
#import "MBProgressHUD.h"

@interface JWUploadCarImageViewController ()<UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate,chooseBrandProtocol>

@property(nonatomic,strong) UITableView * bgTable;
//appDelegate引用
@property (nonatomic,strong) CameraExampleAppDelegate * app;
//imagePicker
@property (nonatomic,strong) UIImagePickerController * imagePicker;
@end

@implementation JWUploadCarImageViewController

//用来存储用户选择的车型厂家、品牌、年份
NSMutableDictionary * carInfoDic;

//存储车型图片
NSMutableArray * carImages;

//定义一个网络任务
NSURLSessionDataTask * task;


- (void)viewDidLoad {
    [super viewDidLoad];
    // 初始化界面
    self.title = @"上传车图";
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    _bgTable = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _bgTable.delegate = self;
    _bgTable.dataSource = self;
    _bgTable.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.view addSubview:_bgTable];
    
    /*
    //上传按钮
    UIButton * uploadBtn = [[UIButton alloc] initWithFrame:CGRectMake(16, CGRectGetMaxY(_bgTable.frame)+18, [UIScreen mainScreen].bounds.size.width-32, 44)];
    [uploadBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [uploadBtn setTitle:@"上传" forState:UIControlStateNormal];
    [uploadBtn setBackgroundColor:[UIColor orangeColor]];
    uploadBtn.layer.cornerRadius = 5;
    [uploadBtn addTarget:self action:@selector(uploadCarImages) forControlEvents:UIControlEventTouchUpInside];
    [uploadBtn addTarget:self action:@selector(changeBtnBackgroundColor:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:uploadBtn];
     */
    
    //导航栏的上传按钮
    UIBarButtonItem * rightBtn = [[UIBarButtonItem alloc] initWithTitle:@"上传" style:UIBarButtonItemStyleDone target:self action:@selector(uploadCarImages)];
    self.navigationItem.rightBarButtonItem = rightBtn;
    
    //imagePicker初始化
    _imagePicker = [[UIImagePickerController alloc] init];
    _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary | UIImagePickerControllerSourceTypeCamera;
    _imagePicker.delegate = self;
    _imagePicker.allowsEditing = YES;
    
    /*
    _imagePicker.showsCameraControls = NO;
    //自定义UIImagepickerController界面
    // 拍照界面容器
    UIView * customCameraView = [[UIView alloc] initWithFrame:[UIScreen  mainScreen].bounds];
    
    // 停止摄像按钮（如果是拍照，则不需要此按钮）
    UIButton * stop = [UIButton buttonWithType:UIButtonTypeCustom];
    stop.frame = CGRectMake(20, [UIScreen mainScreen].bounds.size.height-50, 60, 40);
    stop.backgroundColor = [UIColor greenColor];
    [stop setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [stop setTitle:@"停止" forState:UIControlStateNormal];
    [stop addTarget:self action:@selector(stop) forControlEvents:UIControlEventTouchUpInside];
    [customCameraView addSubview:stop];
    
    // 拍照按钮（如果是摄像，则不需要此按钮）
    UIButton * takePicture = [UIButton buttonWithType:UIButtonTypeCustom];
    takePicture.frame = CGRectMake([UIScreen mainScreen].bounds.size.width/2.0-30, [UIScreen mainScreen].bounds.size.height-60, 60, 60);
    takePicture.backgroundColor = [UIColor redColor];
    [takePicture setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [takePicture setTitle:@"拍照" forState:UIControlStateNormal];
    [takePicture addTarget:self action:@selector(takePicture) forControlEvents:UIControlEventTouchUpInside];
    [customCameraView addSubview:takePicture];
    
    //添加bounding box类似的方框
    UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(20, 30, [UIScreen mainScreen].bounds.size.width-40, [UIScreen mainScreen].bounds.size.width-40) cornerRadius:0];
    CAShapeLayer * box_layer = [CAShapeLayer layer];
    box_layer.path = path.CGPath;
    box_layer.fillColor = [UIColor clearColor].CGColor;
    box_layer.strokeColor = [UIColor greenColor].CGColor;
    box_layer.lineWidth = 2.0f;
    [[customCameraView layer] addSublayer:box_layer];
    
    // 将自定义的相机界面赋值给cameraOverlayView属性即可显示自定义界面
    _imagePicker.cameraOverlayView = customCameraView;
    
   */
    
    //初始化
     _app = (CameraExampleAppDelegate *)[[UIApplication sharedApplication] delegate];
    carInfoDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"请选择",@"car_manufacturer",@"请选择",@"car_brand",@"请选择",@"car_year", nil];
    
    UIImageView * addImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"addImage.jpg"]];
    addImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addCarImage)];
    tap.numberOfTapsRequired = 1;
    [addImageView addGestureRecognizer:tap];
    
    carImages = [NSMutableArray arrayWithObjects:addImageView, nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
//拍照
-(void)takePicture{
    // 拍照
    [_imagePicker takePicture];
}

//停止拍照
-(void)stop{
    [_imagePicker stopVideoCapture];
}
*/
//上传车图
-(void)uploadCarImages{
    if ([self.navigationItem.rightBarButtonItem.title isEqualToString:@"上传"]) {
        //展示HUD
        MBProgressHUD * progressHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        progressHud.mode =  MBProgressHUDModeIndeterminate;
        progressHud.label.text = @"上传中";
        progressHud.removeFromSuperViewOnHide = YES;
        //隐藏view的交互性能
        self.view.userInteractionEnabled = YES;
        self.navigationItem.rightBarButtonItem.title = @"取消";
        
        //定义网络任务
        task = [_app.manager POST:[NSString stringWithFormat:@"%@/uploadCarImages.php",url_base] parameters:@{@"car_manufacturer":[carInfoDic objectForKey:@"car_manufacturer"],@"car_brand":[carInfoDic objectForKey:@"car_brand"],@"car_year":[carInfoDic objectForKey:@"car_year"]} constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            if (carImages.count > 1) {
                for (int i=0; i<carImages.count-1; i++) {
                    /**
                     * 注意，AFNetWorking在进行多张图片或多文件上传时候，name（也就是表单名）的命名格式如下所示
                     */
                    
                    [formData appendPartWithFileData:UIImageJPEGRepresentation(((UIImageView *)[carImages objectAtIndex:i]).image, 0.2) name:@"carImages[]" fileName:[NSString stringWithFormat:@"%i.jpg",i] mimeType:@"image/jpeg"];
                }
            }
        } progress:^(NSProgress * _Nonnull uploadProgress) {
            //计算已上传多少
            progressHud.progress = (CGFloat)uploadProgress.completedUnitCount/(CGFloat)uploadProgress.totalUnitCount;
            progressHud.label.text = [NSString stringWithFormat:@"已上传%3.1f%%",progressHud.progress*100];
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            //服务器正确返回数据
            progressHud.hidden = YES;
            self.view.userInteractionEnabled = YES;
            self.navigationItem.rightBarButtonItem.title = @"上传";
            
            if ([[responseObject objectForKey:@"state"] intValue] == 1) {
                //上传成功,清空内容和图片，并重载表视图
                [carInfoDic setObject:@"请选择" forKey:@"car_manufacturer"];
                [carInfoDic setObject:@"请选择" forKey:@"car_brand"];
                [carInfoDic setObject:@"请选择" forKey:@"car_year"];
                
                [carImages removeObjectsInRange:NSMakeRange(0, carImages.count-1)];
                
                [_bgTable reloadData];
                //提示评论上传成功
                [self showHUDWithNSString:@"图像上传成功"];
            }else
                [self showHUDWithNSString:[responseObject objectForKey:@"message"]];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            progressHud.hidden = YES;
            self.view.userInteractionEnabled = YES;
            self.navigationItem.rightBarButtonItem.title = @"上传";
            [self showHUDWithNSString:[error.userInfo objectForKey:@"NSLocalizedDescription"]];
        }];
    }else{
        //取消正在进行的发布任务
        [task cancel];
        self.navigationItem.rightBarButtonItem.title = @"上传";
    }

}

//添加车图
-(void)addCarImage{
    //先判断用户是否已经选择了“面市时间”
    if ([[carInfoDic objectForKey:@"car_year"] isEqualToString:@"请选择"])
        [self showHUDWithNSString:@"请选择车型面市时间"];
    else
        [self presentViewController:_imagePicker animated:YES completion:nil];
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

#pragma mark - UIImagePickerControllerDelegate
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    UIImage * originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    //添加车型图片
    UIImageView * imageView = [[UIImageView alloc] initWithImage:originalImage];
    [carImages insertObject:imageView atIndex:0];
    
    [picker dismissViewControllerAnimated:YES completion:^{
        //重新更新tableview
        [_bgTable reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:1], nil] withRowAnimation:UITableViewRowAnimationFade];
    }];
}

#pragma mark - Navigation

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (tableView.dataSource>0) {
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        [self hideOtherSeparatorLine:(UITableView *)tableView];
    }else
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    return 2;
}

//隐藏多余的分割线
-(void)hideOtherSeparatorLine:(UITableView *)tableview{
    UIView * view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    [tableview setTableFooterView:view];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 3;
    }else
        return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
    }else{
        for(UIView * view in [cell.contentView subviews])
            [view removeFromSuperview];
    }
    
    if (indexPath.section == 0) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        if (indexPath.row == 0) {
            cell.textLabel.text = @"汽车厂家";
            cell.detailTextLabel.text = [carInfoDic objectForKey:@"car_manufacturer"];
        }else if (indexPath.row == 1){
            cell.textLabel.text = @"汽车品牌";
            cell.detailTextLabel.text = [carInfoDic objectForKey:@"car_brand"];
        }else{
            cell.textLabel.text = @"面市时间";
            cell.detailTextLabel.text = [carInfoDic objectForKey:@"car_year"];
        }
    }else{
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = nil;
        cell.detailTextLabel.text = nil;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.userInteractionEnabled = YES;
        CGFloat imageWidth = ([UIScreen mainScreen].bounds.size.width-64)/3.0;
        for (int i =0; i<carImages.count; i++) {
            UIImageView * imageView = [carImages objectAtIndex:i];
            if (i<3) {
                [imageView setFrame:CGRectMake(16+i*(16+imageWidth), 16, imageWidth, imageWidth)];
                [cell.contentView addSubview:imageView];
            }else if (i>=3 && i<6){
                [imageView setFrame:CGRectMake(16+(i-3)*(16+imageWidth), 32+imageWidth, imageWidth, imageWidth)];
                [cell.contentView addSubview:imageView];
            }
        }
    }
    return cell;
}

//限定行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 44;
    }else{
        if (carImages.count <= 3)
            return ([UIScreen mainScreen].bounds.size.width-64)/3.0+32;
        else
            return 2*([UIScreen mainScreen].bounds.size.width-64)/3.0+48;
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 60;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 60)];
    headerView.backgroundColor = [UIColor clearColor];
    
    UILabel * lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, [UIScreen mainScreen].bounds.size.width-32, 30)];
    lab.textAlignment = NSTextAlignmentLeft;
    lab.textColor = [UIColor grayColor];
    lab.font = [UIFont systemFontOfSize:16];
    lab.backgroundColor = [UIColor clearColor];
    if (section == 0) {
        lab.text = @"* 车辆基本信息";
    }else
        lab.text = @"* 车辆图片（最多同时上传6张）";
    [headerView addSubview:lab];
    return headerView;
}

//点击单元格
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            //选择汽车厂家
            JWBrandChooseViewController * chooseView = [[JWBrandChooseViewController alloc] init];
            chooseView.delegate = self;
            chooseView.flag = 0;
            [self.navigationController pushViewController:chooseView animated:YES];
        }else if (indexPath.row == 1){
            //选择汽车品牌---这里要做判断，如果没有先选择“汽车厂家”则提示用户
            if ([[carInfoDic objectForKey:@"car_manufacturer"] isEqualToString:@"请选择"]) {
                //提示用户先选择汽车厂家
                [self showHUDWithNSString:@"请先选择汽车厂家"];
            }else{
                JWBrandChooseViewController * chooseView = [[JWBrandChooseViewController alloc] init];
                chooseView.delegate = self;
                chooseView.flag = 1;
                chooseView.car_manufacturer = [carInfoDic objectForKey:@"car_manufacturer"];
                [self.navigationController pushViewController:chooseView animated:YES];
            }
            
        }else{
            //先选择了汽车品牌才能在选择面市时间
            if ([[carInfoDic objectForKey:@"car_brand"] isEqualToString:@"请选择"]) {
                [self showHUDWithNSString:@"请先选择汽车品牌"];
            }else{
                //选择年份
                UIAlertController * actionSheet = [UIAlertController alertControllerWithTitle:@"生产年份" message:@"目前只支持2010年及之后面市的车型款式" preferredStyle:UIAlertControllerStyleActionSheet];
                //循环添加支持的车型年份
                for (int i = 0; i<=7; i++) {
                    UIAlertAction * action = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"%@",@(2010+i)] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        //更新年份
                        [carInfoDic setObject:[NSString stringWithFormat:@"%@",@(2010+i)] forKey:@"car_year"];
                        [_bgTable reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:2 inSection:0], nil] withRowAnimation:UITableViewRowAnimationFade];
                    }];
                    [actionSheet addAction:action];
                }
                //添加取消按钮
                UIAlertAction * action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                [actionSheet addAction:action1];
                [self presentViewController:actionSheet animated:YES completion:nil];
            }
        }
    }
}

#pragma mark chooseBrandProtocol
-(void)finishChooseWithBrand:(NSString *)brand AndFlag:(int)flag{
    if (flag == 0) {
        if (![brand isEqualToString:[carInfoDic objectForKey:@"car_manufacturer"]]) {
            //更新的是汽车厂家
            [carInfoDic setValue:brand forKey:@"car_manufacturer"];
            [carInfoDic setValue:@"请选择" forKey:@"car_brand"];
            [carInfoDic setValue:@"请选择" forKey:@"car_year"];
            [_bgTable reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:0],[NSIndexPath indexPathForRow:1 inSection:0],[NSIndexPath indexPathForRow:2 inSection:0], nil] withRowAnimation:UITableViewRowAnimationFade];
        }
        
    }else{
        //更新汽车品牌
        if (![brand isEqualToString:[carInfoDic objectForKey:@"car_brand"]]) {
            [carInfoDic setValue:brand forKey:@"car_brand"];
            [carInfoDic setValue:@"请选择" forKey:@"car_year"];
            [_bgTable reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:1 inSection:0],[NSIndexPath indexPathForRow:2 inSection:0], nil] withRowAnimation:UITableViewRowAnimationFade];
        }
        
    }
    
    
}

@end
