//
//  JWMyInfoViewController.m
//  camera_example
//
//  Created by jway on 2017/1/4.
//
//

#import "JWMyInfoViewController.h"
#import "JWLoginViewController.h"
#import "CameraExampleAppDelegate.h"
#import "MBProgressHUD.h"
#import "UIImageView+AFNetworking.h"


@interface JWMyInfoViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITableViewDelegate,UITableViewDataSource,loginSuccessDelegate>

//UIImagePicker
@property(nonatomic,strong) UIImagePickerController * imagePicker;
//appDelegate引用
@property (nonatomic,strong) CameraExampleAppDelegate * app;
//个人信息列表
@property (nonatomic,strong) UITableView * tableView;
//存储用户信息
@property(nonatomic,strong) NSMutableDictionary * userInfo;

@end

@implementation JWMyInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我的信息";
    //初始化可变字典
    _userInfo = [NSMutableDictionary dictionaryWithDictionary:@{@"portrait":@"test.png",@"username":@"未知",@"telphone":@"未知",@"password":@"未知",@"registerTime":@"未知",@"sign":@"未知",@"gender":@"保密"}];
    
    //tableview初始化
    self.tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    //初始化程序委托代理
    _app = (CameraExampleAppDelegate *)[[UIApplication sharedApplication] delegate];
    //请求服务器
    [self requestMyInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//请求服务器
-(void)requestMyInfo{
    MBProgressHUD * loginState = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    loginState.mode = MBProgressHUDModeIndeterminate;
    loginState.label.text = @"加载中";
    loginState.removeFromSuperViewOnHide = YES;
    //网络请求
    [_app.manager POST:[NSString stringWithFormat:@"%@/checkMyInfo.php",url_base] parameters:@{@"userId":([[NSUserDefaults standardUserDefaults] objectForKey:@"userId"] == nil)?@0:[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        loginState.hidden = YES;
        if ([[responseObject objectForKey:@"state"] intValue] == 1) {
            self.navigationItem.rightBarButtonItem = nil;
            _userInfo = [NSMutableDictionary dictionaryWithDictionary:[responseObject objectForKey:@"returnInfo"]];
            [self.tableView reloadData];
        }else{
            if ([[responseObject objectForKey:@"message"] isEqualToString:@"请先登录"]) {
                //跳出登录界面
                JWLoginViewController * loginView = [[JWLoginViewController alloc] init];
                loginView.delegate = self;
                [self.navigationController pushViewController:loginView animated:YES];
            }else{
                [self showHUDWithNSString:[responseObject objectForKey:@"message"]];
                UIBarButtonItem * rightBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(requestAgain)];
                self.navigationItem.rightBarButtonItem = rightBtn;
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //网络出现问题
        loginState.hidden = YES;
        [self showHUDWithNSString:[error.userInfo objectForKey:@"NSLocalizedDescription"]];
        UIBarButtonItem * rightBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(requestAgain)];
        self.navigationItem.rightBarButtonItem = rightBtn;
    }];
}

//重新获取个人信息
-(void)requestAgain{
    [self requestMyInfo];
}

//判断退出或登录
-(void)LoginOut{
    [_app.manager POST:[NSString stringWithFormat:@"%@/logout.php",url_base] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

-(void)changeBtnBackgroundColor:(id)sender{
    UIButton * btn = (UIButton *)sender;
    btn.backgroundColor = [UIColor grayColor];
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

//更改或填写性别
-(void)changeGenderWithOption:(NSString *)gender{
    [_app.manager POST:[NSString stringWithFormat:@"%@/changeMyInfo.php",url_base] parameters:@{@"gender":gender,@"userId":[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([[responseObject objectForKey:@"state"] intValue] == 1) {
            [_userInfo setObject:gender forKey:@"gender"];
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:1], nil] withRowAnimation:UITableViewRowAnimationFade];
            //提示成功
            [self showHUDWithNSString:@"性别设置成功"];
        }else{
            //错误提示
            [self showHUDWithNSString:[responseObject objectForKey:@"message"]];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //错误提示
        [self showHUDWithNSString:error.description];
    }];
}

#pragma mark -loginSuccessDelegate
-(void)requestInfoAgain{
    [self requestMyInfo];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 4;
    }else if(section == 1){
        return 3;
    }else
        return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"infoCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"infoCell"];
        cell.textLabel.textColor = [UIColor blackColor];
        cell.detailTextLabel.textColor = [UIColor grayColor];
        cell.textLabel.font = [UIFont systemFontOfSize:17];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
        cell.backgroundColor = [UIColor whiteColor];
    }else{
        cell.accessoryView = nil;
    }
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"头像";
            UIImageView * portraitView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
            [portraitView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/portrait/%@",url_base,[_userInfo objectForKey:@"portrait"]]] placeholderImage:[UIImage imageNamed:@"test.png"]];
            portraitView.layer.cornerRadius = 4;
            portraitView.layer.masksToBounds = YES;
            cell.detailTextLabel.text = @"";
            cell.accessoryView = portraitView;
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }else if (indexPath.row == 1){
            cell.textLabel.text = @"用户昵称";
            cell.detailTextLabel.text = ([_userInfo objectForKey:@"username"] == [NSNull null])?@"未知":[_userInfo objectForKey:@"username"];
             cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }else if (indexPath.row == 2){
            cell.textLabel.text = @"注册手机";
            cell.detailTextLabel.text = ([_userInfo objectForKey:@"telphone"] == [NSNull null])?@"未知":[_userInfo objectForKey:@"telphone"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }else {
            cell.textLabel.text = @"登录密码";
            //cell.detailTextLabel.text = ([_userInfo objectForKey:@"password"] == [NSNull null])?@"未知":[_userInfo objectForKey:@"password"];
            cell.detailTextLabel.text = nil;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
    }else if(indexPath.section == 1){
        if (indexPath.row == 0) {
            cell.textLabel.text = @"性别";
            cell.detailTextLabel.text = ([_userInfo objectForKey:@"gender"] == [NSNull null])?@"未填":[_userInfo objectForKey:@"gender"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }else if (indexPath.row == 1) {
            cell.textLabel.text = @"注册时间";
            //添加申请日期-先转换日期格式
            NSDate * date = [NSDate dateWithTimeIntervalSince1970:[[_userInfo objectForKey:@"registerTime"] intValue]];
            NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
            NSString * timeStr = [formatter stringFromDate:date];
            cell.detailTextLabel.text = timeStr;
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }else{
            cell.textLabel.text = @"个性签名";
            cell.detailTextLabel.text = ([_userInfo objectForKey:@"sign"] == [NSNull null])?@"未填":[_userInfo objectForKey:@"sign"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
    }else{
        //退出按钮
        UIButton * loginBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
        [loginBtn addTarget:self action:@selector(LoginOut) forControlEvents:UIControlEventTouchUpInside];
        [loginBtn addTarget:self action:@selector(changeBtnBackgroundColor:) forControlEvents:UIControlEventTouchDown];
        loginBtn.backgroundColor = [UIColor redColor];
        [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [loginBtn setTitle:@"退出当前账号" forState:UIControlStateNormal];
        [cell.contentView addSubview:loginBtn];
    }
   
    return cell;
}




-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 80;
    }else{
        return 44;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 15;
}

//点击单元格
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"头像上传" message:@"请选择图片来源" preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction * action1 = [UIAlertAction actionWithTitle:@"打开相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                //
                _imagePicker = [[UIImagePickerController alloc] init];
                _imagePicker.delegate = self;
                _imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                _imagePicker.allowsEditing = YES;
                [self presentViewController:_imagePicker animated:YES completion:nil];
            }];
            UIAlertAction * action2 = [UIAlertAction actionWithTitle:@"打开相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                //
                _imagePicker = [[UIImagePickerController alloc] init];
                _imagePicker.delegate = self;
                _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                _imagePicker.allowsEditing = YES;
                [self presentViewController:_imagePicker animated:YES completion:nil];
                
            }];
            UIAlertAction * action3 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:action1];
            [alert addAction:action2];
            [alert addAction:action3];
            [self presentViewController:alert animated:YES completion:nil];
        }else if (indexPath.row == 1){
            //修改昵称
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"修改昵称" message:@"请按要求填写新昵称" preferredStyle:UIAlertControllerStyleAlert];
            
            [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = @"6~24位数字、字母、下划线组成";
                textField.returnKeyType = UIReturnKeyDone;
            }];
            UIAlertAction * action1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                //发送给服务器
                if (![[NSPredicate predicateWithFormat:@"SELF MATCHES %@",[NSString stringWithFormat:@"^[A-Z0-9a-z_]{6,24}+$"]] evaluateWithObject:[[alert.textFields objectAtIndex:0] text]]) {
                    //提示两次密码输入不一致
                    [self showHUDWithNSString:@"昵称输入格式错误"];
                }else{
                    [_app.manager POST:[NSString stringWithFormat:@"%@/changeMyInfo.php",url_base] parameters:@{@"userId":[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"],@"username":[[alert.textFields objectAtIndex:0] text]} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                        if ([[responseObject objectForKey:@"state"] intValue] == 1) {
                            //更新值，并重载表视图
                            [_userInfo setObject:[[alert.textFields objectAtIndex:0] text] forKey:@"username"];
                            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:1 inSection:0], nil] withRowAnimation:UITableViewRowAnimationFade];
                            //提示更新成功
                            [self showHUDWithNSString:@"昵称重置成功"];
                        }else{
                            //弹出错误提示
                            [self showHUDWithNSString:[responseObject objectForKey:@"message"]];
                        }
                        
                    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                        //弹出错误提示
                        [self showHUDWithNSString:error.debugDescription];
                    }];
                    
                }
            }];
            UIAlertAction * action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:action1];
            [alert addAction:action2];
            [self presentViewController:alert animated:YES completion:nil];
        }else if (indexPath.row == 3){
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"修改登录密码" message:@"请按要求填写新密码" preferredStyle:UIAlertControllerStyleAlert];
            [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = @"6~24位数字、字母、下划线组成";
                textField.returnKeyType = UIReturnKeyDone;
            }];
            
            [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = @"请再次输入新密码";
                textField.returnKeyType = UIReturnKeyDone;
            }];
            
            UIAlertAction * action1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                //发送给服务器
                if (![[NSPredicate predicateWithFormat:@"SELF MATCHES %@",[NSString stringWithFormat:@"^[A-Z0-9a-z_]{6,24}+$"]] evaluateWithObject:[[alert.textFields objectAtIndex:0] text]]) {
                    //提示两次密码输入不一致
                    [self showHUDWithNSString:@"密码输入格式错误"];
                }else if(![[[alert.textFields objectAtIndex:0] text] isEqualToString:[[alert.textFields objectAtIndex:1] text]]){
                    //提示两次密码输入不一致
                    [self showHUDWithNSString:@"两次密码输入不一致"];
                }else{
                    [_app.manager POST:[NSString stringWithFormat:@"%@/changeMyInfo.php",url_base] parameters:@{@"userId":[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"],@"password":[[alert.textFields objectAtIndex:1] text]} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                        if ([[responseObject objectForKey:@"state"] intValue] == 1) {
                            //更新值，并重载表视图
                            [_userInfo setObject:[[alert.textFields objectAtIndex:0] text] forKey:@"password"];
                            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:3 inSection:0], nil] withRowAnimation:UITableViewRowAnimationFade];
                            //提示更新成功
                            [self showHUDWithNSString:@"密码重置成功"];
                        }else{
                            //弹出错误提示
                            [self showHUDWithNSString:[responseObject objectForKey:@"message"]];
                        }
                        
                    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                        //弹出错误提示
                        [self showHUDWithNSString:error.debugDescription];
                    }];
                    
                }
            }];
            
            UIAlertAction * action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:action1];
            [alert addAction:action2];
            
            [self presentViewController:alert animated:YES completion:nil];
            
        }
    }else if(indexPath.section == 1){
        //我的基本信息修改或填写
        if (indexPath.row == 0) {
            //性别修改
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"性别选择" message:@"请选择您的性别" preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction * action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            //修改/添加性别
            UIAlertAction * action2 = [UIAlertAction  actionWithTitle:@"男" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self changeGenderWithOption:@"男"];
            }];
            UIAlertAction * action3 = [UIAlertAction actionWithTitle:@"女" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self changeGenderWithOption:@"女"];
            }];
            UIAlertAction * action4 = [UIAlertAction actionWithTitle:@"保密" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self changeGenderWithOption:@"保密"];
            }];
            [alert addAction:action1];
            [alert addAction:action2];
            [alert addAction:action3];
            [alert addAction:action4];
            [self presentViewController:alert animated:YES completion:nil];
        }else if (indexPath.row == 1){
            
        }else{
            //个性签名
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"签名修改" message:@"请重新输入您的个性签名" preferredStyle:UIAlertControllerStyleAlert];
            
            [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = @"限定21字以内";
                textField.returnKeyType = UIReturnKeyDone;
            }];
            
            UIAlertAction * action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction * action2 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                //上传服务器，成功后更新
                [_app.manager POST:[NSString stringWithFormat:@"%@/changeMyInfo.php",url_base] parameters:@{@"sign":[[alert.textFields objectAtIndex:0] text],@"userId":[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    
                    if ([[responseObject objectForKey:@"state"] intValue] == 1) {
                        [_userInfo setObject:[[alert.textFields objectAtIndex:0] text] forKey:@"sign"];
                        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:2 inSection:1], nil] withRowAnimation:UITableViewRowAnimationFade];
                        //提示成功
                        [self showHUDWithNSString:@"个性签名修改成功"];
                    }else{
                        //错误提示
                        [self showHUDWithNSString:[responseObject objectForKey:@"message"]];
                    }
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    //错误提示
                    [self showHUDWithNSString:error.description];
                }];
            }];
            [alert addAction:action1];
            [alert addAction: action2];
            [self presentViewController:alert animated:YES completion:nil];
            
        }
    }
}

#pragma UIImagePiclerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    //获取选择的图片
    UIImage * originImage = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
    [self dismissViewControllerAnimated:YES completion:^{
        [self uploadPortraitWithImage:originImage];
    }];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//上传头像
-(void)uploadPortraitWithImage:(UIImage *)image{
    //要显示上传进度了
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeDeterminate;
    hud.removeFromSuperViewOnHide = YES;
    self.view.userInteractionEnabled = NO;//让界面失去响应
    //上传服务器,本身就是异步的
    [_app.manager POST:[NSString stringWithFormat:@"%@/uploadPortrait.php",url_base] parameters:@{@"userId":[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"],@"portrait":[_userInfo objectForKey:@"portrait"]} constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        //上传图片
        [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 0.2) name:@"myPortrait" fileName:[NSString stringWithFormat:@"%@.jpg",[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]] mimeType:@"image/jpeg"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        //显示进度
        hud.progress = uploadProgress.completedUnitCount/uploadProgress.totalUnitCount;
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        hud.hidden = YES;
        self.view.userInteractionEnabled = YES;
        
        if ([[responseObject objectForKey:@"state"] intValue] == 1) {
            //接收返回参数
            [_userInfo setObject:[responseObject objectForKey:@"portrait"] forKey:@"portrait"];
            //重载表示图
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:0],nil] withRowAnimation:UITableViewRowAnimationFade];
            [self showHUDWithNSString:@"头像上传成功"];
        }else
            [self showHUDWithNSString:[responseObject objectForKey:@"message"]];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        hud.hidden = YES;
        self.view.userInteractionEnabled = YES;
        [self showHUDWithNSString:error.description];
    }];
    
    

}

@end
