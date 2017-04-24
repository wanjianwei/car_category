//
//  JWBrandChooseViewController.h
//  camera_example
//
//  Created by jway on 2017/1/3.
//
//

#import <UIKit/UIKit.h>

@protocol chooseBrandProtocol <NSObject>

-(void)finishChooseWithBrand:(NSString *)brand AndFlag:(int)flag;

@end

@interface JWBrandChooseViewController : UIViewController

//定义一个委托代理,这里其实也用到了范型
@property (nonatomic,weak) id<chooseBrandProtocol>delegate;

/*
 定义是选择厂家还是品牌,flag = 0表示选择厂家，flag = 1表示选择品牌
 */
@property (nonatomic,assign) int flag;

//如果选择车型品牌，则需要提供车型制造商的名称
@property (strong,nonatomic) NSString * car_manufacturer;

@end
