//
//  UIViewController+BackButtonHandler.h
//  fileTransfer
//
//  Created by jway on 15/11/10.
//  Copyright © 2015年 jway. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BackButtonHandlerProtocol <NSObject>
@optional
// Override this method in UIViewController derived class to handle 'Back' button click
-(BOOL)navigationShouldPopOnBackButton;
@end

@interface UIViewController (BackButtonHandler)<BackButtonHandlerProtocol>

@end
