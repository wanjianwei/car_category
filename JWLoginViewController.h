//
//  JWLoginViewController.h
//  JWParkingLease
//
//  Created by jway on 16/1/5.
//  Copyright © 2016年 jway. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol loginSuccessDelegate <NSObject>

-(void)requestInfoAgain;

@end

@interface JWLoginViewController : UIViewController

//定义一个程序委托代理
@property(nonatomic,weak) id<loginSuccessDelegate>delegate;

@end
