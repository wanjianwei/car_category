//
//  JWRegisterViewController.m
//  camera_example
//
//  Created by jway on 2017/3/3.
//  Copyright © 2017年 jway. All rights reserved.
//

#import "JWRegisterViewController.h"
#import "CameraExampleAppDelegate.h"
#import "MBProgressHUD.h"
#import <CommonCrypto/CommonDigest.h>

@interface JWRegisterViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>{
    UITextField * telphone;
    UITextField * randomNum;
    UITextField * password;
    UITextField * password_again;
    UIButton * getRandomBtn;
    //定义一个计时器
    NSTimer * timer;
    int sum;
}

@property (nonatomic,strong) CameraExampleAppDelegate * app;

@end

@implementation JWRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化界面
    self.title = @"手机注册";
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    UITableView * bgView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, 44*4) style:UITableViewStylePlain];
    bgView.scrollEnabled = NO;
    bgView.delegate = self;
    bgView.dataSource = self;
    [self.view addSubview:bgView];
    
    //初始化输入框
    telphone = [[UITextField alloc] initWithFrame:CGRectMake(10, 7, [UIScreen mainScreen].bounds.size.width-32, 30)];
    telphone.returnKeyType = UIReturnKeyDone;
    telphone.keyboardType = UIKeyboardTypeNumberPad;
    telphone.clearButtonMode = UITextFieldViewModeWhileEditing;
    telphone.placeholder = @"请输入您的手机号码";
    telphone.font = [UIFont systemFontOfSize:15];
    telphone.delegate = self;
    
    randomNum = [[UITextField alloc] initWithFrame:CGRectMake(16, 7, ([UIScreen mainScreen].bounds.size.width-32)/2.0, 30)];
    randomNum.returnKeyType = UIReturnKeyDone;
    randomNum.keyboardType = UIKeyboardTypeNumberPad;
    randomNum.clearButtonMode = UITextFieldViewModeWhileEditing;
    randomNum.placeholder = @"短信验证码";
    randomNum.font = [UIFont systemFontOfSize:15];
    randomNum.delegate = self;
    
    getRandomBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(randomNum.frame), 7, ([UIScreen mainScreen].bounds.size.width-32)/2.0, 30)];
    [getRandomBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    getRandomBtn.backgroundColor = [UIColor greenColor];
    getRandomBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    getRandomBtn.layer.cornerRadius = 3.0;
    [getRandomBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    //添加事件响应
    [getRandomBtn addTarget:self action:@selector(getRandomNum:) forControlEvents:UIControlEventTouchUpInside];
    [getRandomBtn addTarget:self action:@selector(changeBackgroundColor:) forControlEvents:UIControlEventTouchDown];
    
    password = [[UITextField alloc] initWithFrame:CGRectMake(16, 7, [UIScreen mainScreen].bounds.size.width-32, 30)];
    password.returnKeyType = UIReturnKeyDone;
    password.keyboardType = UIKeyboardTypeDefault;
    password.clearButtonMode = UITextFieldViewModeWhileEditing;
    password.placeholder = @"请输入密码(6~24位)";
    password.font = [UIFont systemFontOfSize:15];
    password.secureTextEntry = YES;
    password.delegate = self;
    
    password_again = [[UITextField alloc] initWithFrame:CGRectMake(16, 7, [UIScreen mainScreen].bounds.size.width-32, 30)];
    password_again.returnKeyType = UIReturnKeyDone;
    password_again.keyboardType = UIKeyboardTypeDefault;
    password_again.secureTextEntry = YES;
    password_again.clearButtonMode = UITextFieldViewModeWhileEditing;
    password_again.placeholder = @"请再次输入密码";
    password_again.font = [UIFont systemFontOfSize:15];
    password_again.delegate = self;
    
    //添加注册按钮
    UIButton * registerBtn = [[UIButton alloc] initWithFrame:CGRectMake(16, CGRectGetMaxY(bgView.frame)+55, [UIScreen mainScreen].bounds.size.width-32, 44)];
    [registerBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [registerBtn setTitle:@"注册" forState:UIControlStateNormal];
    registerBtn.layer.cornerRadius = 3.0f;
    registerBtn.backgroundColor = [UIColor greenColor];
    //添加事件响应
    [registerBtn addTarget:self action:@selector(registerNow:) forControlEvents:UIControlEventTouchUpInside];
    [registerBtn addTarget:self action:@selector(changeBackgroundColor:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:registerBtn];
    
    //定义 一个手势处理器，用于关闭键盘
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handTap)];
    tap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tap];
    
    //初始化属性变量app
    _app = (CameraExampleAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [timer invalidate];
    timer = nil;
}

//展示显示错误提示hud
-(void)showHUDWithNSString:(NSString * )str{
    MBProgressHUD * HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.mode = MBProgressHUDModeText;
    HUD.label.text = str;
    HUD.margin = 10;
    [HUD setOffset:CGPointMake(0, [UIScreen mainScreen].bounds.size.height/2.0-60)];
    HUD.removeFromSuperViewOnHide = YES;
    [HUD hideAnimated:YES afterDelay:1];
}

//手势处理器，关闭键盘
-(void)handTap{
    [telphone resignFirstResponder];
    [password_again resignFirstResponder];
    [password resignFirstResponder];
    [randomNum resignFirstResponder];
}

//获取验证码
-(void)getRandomNum:(id)sender{
    //按钮颜色先恢复
    ((UIButton *)sender).backgroundColor = [UIColor greenColor];
    [self handTap]; //关闭键盘
    //判断电话号码输入是否合法
    if (![[NSPredicate predicateWithFormat:@"SELF MATCHES %@",[NSString stringWithFormat:@"^((13[0-9])|(147)|(15[^4,\\D])|(18[0,1，5-9]))\\d{8}$"]] evaluateWithObject:telphone.text]) {
        [self showHUDWithNSString:@"电话号码输入不合法"];
    }else{
        //向服务器请求验证码
        [_app.manager POST:[NSString stringWithFormat:@"%@/getRandomNumber.php",url_base] parameters:@{@"telphone":telphone.text} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            //
            if ([[responseObject objectForKey:@"state"] intValue] == 1) {
                [self showHUDWithNSString:@"验证码发送成功"];
                //倒计时
                [self count_wait];
            }else{
                [self showHUDWithNSString:[responseObject objectForKey:@"message"]];
                [getRandomBtn setTitle:@"重新获取" forState:UIControlStateNormal];
                getRandomBtn.backgroundColor = [UIColor greenColor];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            //网络出现问题
            [self showHUDWithNSString:error.localizedDescription];
            [getRandomBtn setTitle:@"重新获取" forState:UIControlStateNormal];
            getRandomBtn.backgroundColor = [UIColor greenColor];
        }];
    }
}

-(void)count_wait{
    //开始倒计时
    sum = 60;
    getRandomBtn.userInteractionEnabled = NO;
    getRandomBtn.backgroundColor = [UIColor grayColor];
    timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(count1) userInfo:nil repeats:YES];
}

//验证码等待计数
-(void)count1{
    while (sum > 0) {
        sum = sum-1;
        //getRandomBtn.titleLabel.text = [NSString stringWithFormat:@"剩余(%is)",sum];
        [getRandomBtn setTitle:[NSString stringWithFormat:@"剩余(%is)",sum] forState:UIControlStateNormal];
    }
    getRandomBtn.backgroundColor = [UIColor greenColor];
    [getRandomBtn setTitle:@"重新获取" forState:UIControlStateNormal];
    getRandomBtn.userInteractionEnabled = YES;
    //取消定时器
    [timer invalidate];
    timer = nil;
   
}
//登录
-(void)registerNow:(id)sender{
    UIButton * btn = (UIButton *)sender;
    btn.backgroundColor = [UIColor greenColor];
    [self handTap]; //关闭键盘
    //如果计时器没有计时完，先结束
    if (timer != nil) {
        [timer invalidate];
        getRandomBtn.backgroundColor = [UIColor greenColor];
        [getRandomBtn setTitle:@"重新获取" forState:UIControlStateNormal];
        getRandomBtn.userInteractionEnabled = YES;
    }
    //请求服务器
    if (![[NSPredicate predicateWithFormat:@"SELF MATCHES %@",[NSString stringWithFormat:@"^[A-Z0-9a-z_]{6,24}+$"]] evaluateWithObject:password.text]) {
        [self showHUDWithNSString:@"密码输入不符合要求"];
    }else if (![password_again.text isEqualToString:password.text])
        [self showHUDWithNSString:@"两次密码输入不一致"];
    else{
        [_app.manager POST:[NSString stringWithFormat:@"%@/register.php",url_base] parameters:@{@"password":[self md5HexDigest:password.text],@"randomNum":randomNum.text} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if ([[responseObject objectForKey:@"state"] intValue] == 1) {
                //注册成功，可直接返回登录
                UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"恭喜" message:@"您已注册成功,可直接返回登录" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self.navigationController popViewControllerAnimated:YES];
                }];
                [alert addAction:action];
                [self presentViewController:alert animated:YES completion:nil];
            }else
                [self showHUDWithNSString:[responseObject objectForKey:@"message"]];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [self showHUDWithNSString:[error.userInfo objectForKey:@"NSLocalizedDescription"]];
        }];
    }
    
}

//MD5算法加密--32位的大写MD5加密
-(NSString *)md5HexDigest:(NSString*)input{
    const char* str = [input UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (int)strlen(str), result);
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
    
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++){
        [ret appendFormat:@"%02X",result[i]];
    }
    return ret;
}

//改变注册按钮背景颜色
-(void)changeBackgroundColor:(id)sender{
    UIButton * btn = (UIButton *)sender;
    btn.backgroundColor = [UIColor grayColor];
}

#pragma mark -UITableViewDelegate/DataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    if (indexPath.row == 0) {
        [cell.contentView addSubview:telphone];
    }else if (indexPath.row ==1){
        [cell.contentView addSubview:randomNum];
        [cell.contentView addSubview:getRandomBtn];
    }else if (indexPath.row == 2)
        [cell.contentView addSubview:password];
    else
        [cell.contentView addSubview:password_again];
    return cell;
}

#pragma mark -UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

@end
