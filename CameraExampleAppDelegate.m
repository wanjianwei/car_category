// Copyright 2015 Google Inc. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "CameraExampleAppDelegate.h"
#import "FirstViewController.h"
#import "SecondViewController.h"
#import "AFNetworkActivityIndicatorManager.h"

@implementation CameraExampleAppDelegate

//@synthesize window = _window;

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    //初始化并设置网络请求管理器
    self.manager=[AFHTTPSessionManager manager];
    self.manager.responseSerializer=[AFJSONResponseSerializer serializer];
    //manager加上这个就会在success中回调
    self.manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/json"];
    //设置请求时间
    self.manager.requestSerializer.timeoutInterval = 60.0;
    
    
    UINavigationController * firstNav = [[UINavigationController alloc] initWithRootViewController:[[FirstViewController alloc] init]];
    //指定新的根视图
    self.window.rootViewController = firstNav;
    [self.window makeKeyAndVisible];

    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
  [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

@end
