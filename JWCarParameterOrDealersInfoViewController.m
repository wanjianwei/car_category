//
//  JWCarParameterOrDealersInfoViewController.m
//  camera_example
//
//  Created by jway on 2017/2/23.
//  Copyright © 2017年 jway. All rights reserved.
//

#import "JWCarParameterOrDealersInfoViewController.h"
#import <WebKit/WebKit.h>

@interface JWCarParameterOrDealersInfoViewController ()<WKUIDelegate,WKNavigationDelegate>

@property (strong, nonatomic) WKWebView *webView;
@property (strong, nonatomic) UIProgressView *progressView;

@end

@implementation JWCarParameterOrDealersInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"车型参数详情";
   
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    //要添加一个webView
    _webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    _webView.UIDelegate = self;
    _webView.navigationDelegate = self;
    [self.view addSubview:_webView];
    
    //定义进度条
    _progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(0, 65, CGRectGetWidth(self.view.frame),2)];
    _progressView.trackTintColor = [UIColor orangeColor];
    
    //KVO观察进度
    [_webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew| NSKeyValueObservingOptionOld context:nil];
    
    //右侧导航栏添加一个刷新按钮
    UIBarButtonItem * refreshBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshLoading)];
    self.navigationItem.rightBarButtonItem = refreshBtn;
    
    //加载URL
    [self loadURL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//加载URL
-(void)loadURL{
    [self.view addSubview:_progressView];
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_url]]];
}

//重新加载
-(void)refreshLoading{
    [self loadURL];
}

-(void)dealloc{
    [_webView removeObserver:self forKeyPath:@"estimatedProgress"];
}

#pragma mark KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void*)context{
    
    if ([keyPath isEqualToString: @"estimatedProgress"] && object == _webView) {
        [self.progressView setAlpha:1.0f];
        [self.progressView setProgress:_webView.estimatedProgress animated:YES];
        if(_webView.estimatedProgress >= 1.0f)
        {
            [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [_progressView removeFromSuperview];
            } completion:^(BOOL finished) {
                [self.progressView setProgress:0.0f animated:NO];
            }];
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
