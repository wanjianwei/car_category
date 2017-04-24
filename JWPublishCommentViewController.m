//
//  JWPublishCommentViewController.m
//  camera_example
//
//  Created by jway on 2017/2/28.
//  Copyright © 2017年 jway. All rights reserved.
//

#import "JWPublishCommentViewController.h"
#import "CameraExampleAppDelegate.h"
#import "MBProgressHUD.h"
#import "JWLoginViewController.h"

#define IMAGEWIDTH ([UIScreen mainScreen].bounds.size.width-64)/3.0

@interface JWPublishCommentViewController ()<UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextViewDelegate,loginSuccessDelegate>{
    //输入评论内容
    UITextView * content;
    //存储车型图片
    NSMutableArray * comment_images;
    
    //定义网络任务
    NSURLSessionDataTask * task;
}

@property (nonatomic,strong) CameraExampleAppDelegate * app;
@property (nonatomic,strong) UITableView * commentView;
//imagePicker
@property (nonatomic,strong) UIImagePickerController * imagePicker;
@end

@implementation JWPublishCommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 初始化
    self.title = @"发布评论";
    self.view.backgroundColor = [UIColor whiteColor];
    _app = (CameraExampleAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //tableview
    _commentView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _commentView.delegate = self;
    _commentView.dataSource = self;
    _commentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.view addSubview:_commentView];
    
    //内容输入框初始化
    content = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 40*3)];
    content.textColor = [UIColor blackColor];
    content.font = [UIFont systemFontOfSize:17];
    content.textAlignment = NSTextAlignmentLeft;
    [content becomeFirstResponder];
    content.returnKeyType = UIReturnKeyDone;
    content.delegate = self;
    
    //comment_images初始化
    UIImageView * addImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"addImage.jpg"]];
    addImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addCarImage)];
    tap.numberOfTapsRequired = 1;
    [addImageView addGestureRecognizer:tap];
    comment_images = [NSMutableArray arrayWithObjects:addImageView, nil];
    
    //设置长传按钮
    UIBarButtonItem * rightBtn = [[UIBarButtonItem alloc] initWithTitle:@"发布" style:UIBarButtonItemStyleDone target:self action:@selector(uploadComment)];
    self.navigationItem.rightBarButtonItem = rightBtn;
    
    //imagePicker初始化
    _imagePicker = [[UIImagePickerController alloc] init];
    _imagePicker.delegate = self;
    
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




//上传评论
-(void)uploadComment{
    if ([self.navigationItem.rightBarButtonItem.title isEqualToString:@"发布"]) {
        //先判断
        if ([content.text isEqualToString:@""]) {
            [self showHUDWithNSString:@"请先填写评论内容"];
        }else if (comment_images.count == 1){
            [self showHUDWithNSString:@"请添加评论图片"];
        }
        else{
            //展示HUD
            MBProgressHUD * progressHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            progressHud.mode =  MBProgressHUDModeIndeterminate;
            progressHud.label.text = @"上传中";
            progressHud.removeFromSuperViewOnHide = YES;
            //隐藏view的交互性能
            self.view.userInteractionEnabled = YES;
            self.navigationItem.rightBarButtonItem.title = @"取消";
            //定义网络任务
            task = [_app.manager POST:[NSString stringWithFormat:@"%@/publishComment.php",url_base] parameters:@{@"car_brand":_car_brand,@"userId":[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"],@"content":content.text} constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                if (comment_images.count > 1) {
                    for (int i=0; i<comment_images.count-1; i++) {
                        
                        /**
                         * 注意，AFNetWorking在进行多张图片或多文件上传时候，name（也就是表单名）的命名格式如下所示
                         */
                        
                        [formData appendPartWithFileData:UIImageJPEGRepresentation(((UIImageView *)[comment_images objectAtIndex:i]).image, 0.2) name:@"commentImages[]" fileName:[NSString stringWithFormat:@"%i.jpg",i] mimeType:@"image/jpeg"];
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
                self.navigationItem.rightBarButtonItem.title = @"发布";
                
                if ([[responseObject objectForKey:@"state"] intValue] == 1) {
                    //上传成功,清空内容和图片，并重载表视图
                    content.text = nil;
                    [comment_images removeObjectsInRange:NSMakeRange(0, comment_images.count-1)];
                    
                    [_commentView reloadData];
                    //提示评论上传成功
                    [self showHUDWithNSString:@"评论发布成功"];
                }else{
                    if ([[responseObject objectForKey:@"message"] isEqualToString:@"请先登录"]) {
                        //跳转到登录界面
                        JWLoginViewController * loginView = [[JWLoginViewController alloc] init];
                        loginView.delegate = self;
                        [self.navigationController pushViewController:loginView animated:YES];
                    }else
                        [self showHUDWithNSString:[responseObject objectForKey:@"message"]];
                }
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                progressHud.hidden = YES;
                self.view.userInteractionEnabled = YES;
                self.navigationItem.rightBarButtonItem.title = @"发布";
                [self showHUDWithNSString:[error.userInfo objectForKey:@"NSLocalizedDescription"]];
            }];
        }
    
    }else{
        //取消正在进行的发布任务
        [task cancel];
        self.navigationItem.rightBarButtonItem.title = @"发布";
    }
}

//添加车图
-(void)addCarImage{
    //从相册还是直接拍照
    UIAlertController * actionSheet = [UIAlertController alertControllerWithTitle:@"上传图片" message:@"请选择图像来源" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction * action1 = [UIAlertAction actionWithTitle:@"从相册中选取" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        _imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        [self presentViewController:_imagePicker animated:YES completion:nil];
    }];
    
    UIAlertAction * action2 = [UIAlertAction actionWithTitle:@"从相机中选取" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        _imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:_imagePicker animated:YES completion:nil];
    }];
    UIAlertAction * action3 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [actionSheet addAction:action1];
    [actionSheet addAction:action2];
    [actionSheet addAction:action3];
    [self presentViewController:actionSheet animated:YES completion:nil];
}

#pragma mark -loginSuccessDelegate
-(void)requestInfoAgain{
    [self uploadComment];
}

#pragma mark - UIImagePickerControllerDelegate
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    UIImage * originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    //添加车型图片
    UIImageView * imageView = [[UIImageView alloc] initWithImage:originalImage];
    [comment_images insertObject:imageView atIndex:0];
    
    [picker dismissViewControllerAnimated:YES completion:^{
        //重新更新tableview
        [_commentView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:2], nil] withRowAnimation:UITableViewRowAnimationFade];
    }];
}


#pragma mark -UITableViewDelegate/DataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (tableView.dataSource>0) {
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        [self hideOtherSeparatorLine:(UITableView *)tableView];
    }else
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    return 3;
}

//隐藏多余的分割线
-(void)hideOtherSeparatorLine:(UITableView *)tableview{
    UIView * view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    [tableview setTableFooterView:view];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
    }else{
        for (UIView * view in [cell.contentView subviews]) {
            [view removeFromSuperview];
        }
    }
    
    if (indexPath.section == 0) {
        cell.textLabel.text = @"汽车品牌";
        cell.detailTextLabel.text = _car_brand;
    }else if (indexPath.section == 1){
        //添加一个UITextView
        [cell.contentView addSubview:content];
        cell.textLabel.text = nil;
        cell.detailTextLabel.text = nil;
    }
    else{
        cell.textLabel.text = nil;
        cell.detailTextLabel.text = nil;
        cell.userInteractionEnabled = YES;
        for (int i =0; i<comment_images.count; i++) {
            UIImageView * imageView = [comment_images objectAtIndex:i];
            if (i<3) {
                [imageView setFrame:CGRectMake(16+i*(16+IMAGEWIDTH), 16, IMAGEWIDTH, IMAGEWIDTH*4/3.0)];
                [cell.contentView addSubview:imageView];
            }else if (i>=3 && i<6){
                [imageView setFrame:CGRectMake(16+(i-3)*(16+IMAGEWIDTH), 32+IMAGEWIDTH*4/3.0, IMAGEWIDTH, IMAGEWIDTH*4/3.0)];
                [cell.contentView addSubview:imageView];
            }
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 44;
    }else if (indexPath.section == 1)
        return 120;
    else{
        if (comment_images.count <= 3)
            return IMAGEWIDTH*4/3.0+32;
        else
            return 2*IMAGEWIDTH*4/3.0+48;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 44;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
    headerView.backgroundColor = [UIColor clearColor];
    
    UILabel * lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 14, [UIScreen mainScreen].bounds.size.width, 30)];
    lab.textColor = [UIColor grayColor];
    lab.textAlignment = NSTextAlignmentLeft;
    lab.font = [UIFont systemFontOfSize:16];
    lab.backgroundColor = [UIColor clearColor];
    if (section == 0) {
        lab.text = @"* 待评价车型";
    }else if (section == 1)
        lab.text = @"* 请输入评论内容";
    else
        lab.text = @"* 图片上传(最多可上传6张图片)";

    [headerView addSubview:lab];
    return headerView;
}


#pragma mark -UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [content resignFirstResponder];
    }
    return YES;
}
@end
