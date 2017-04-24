//
//  UINavigationController+ShouldPopOnBackButton.m
//  fileTransfer
//
//  Created by jway on 15/11/10.
//  Copyright © 2015年 jway. All rights reserved.
//

#import "UINavigationController+ShouldPopOnBackButton.h"
#import "UIViewController+BackButtonHandler.h"
@implementation UINavigationController (ShouldPopOnBackButton)

//通过分类重写了该方法，该方法会在用户点击返回按钮时调用
- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem*)item {
    
    if([self.viewControllers count] < [navigationBar.items count]) {
        return YES;
    }
    
    BOOL shouldPop = YES;
    UIViewController* vc = [self topViewController];
    if([vc respondsToSelector:@selector(navigationShouldPopOnBackButton)]) {
        shouldPop = [vc navigationShouldPopOnBackButton];
    }
    
    if(shouldPop) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self popViewControllerAnimated:YES];
        });
    } else {
        // Workaround for iOS7.1. Thanks to @boliva - http://stackoverflow.com/posts/comments /34452906
        for(UIView *subview in [navigationBar subviews]) {
            if(subview.alpha < 1.) {
                [UIView animateWithDuration:.25 animations:^{
                    subview.alpha = 1.;
                }];
            }
        }
    }
    
    return NO;
}

@end
