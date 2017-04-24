//
//  JWCustomCellModel.m
//  camera_example
//
//  Created by jway on 2017/2/27.
//  Copyright © 2017年 jway. All rights reserved.
//

#import "JWCustomCellModel.h"

@implementation JWCustomCellModel

-(id)initWithDictionary:(NSDictionary *)dic{
    self = [super init];
    if (self) {
        _commentId = [NSString stringWithFormat:@"%@",[dic objectForKey:@"commentId"]];
        _portrait = [dic objectForKey:@"portrait"];
        _username = [dic objectForKey:@"username"];
        _sign = [dic objectForKey:@"sign"];
        _content = [dic objectForKey:@"content"];
        
        //点赞数计算
        if ([dic objectForKey:@"praiseNumbers"] == [NSNull null]) {
            //
            _isPraiesd = NO;
            _praiseNumbers = @"0";
        }else{
            NSArray * idArray = [[dic objectForKey:@"praiseNumbers"] componentsSeparatedByString:@"#"];
            if ([idArray containsObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]])
                _isPraiesd = YES;
            else
                _isPraiesd = NO;
            _praiseNumbers = [NSString stringWithFormat:@"%lu",(unsigned long)idArray.count];
        }
        
        
        //时间格式转化
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYY/MM/dd hh:mm"];
        _comment_time = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[[dic objectForKey:@"comment_time"] integerValue]]];
        
        //评论附图计算
        _imageArray = [[dic objectForKey:@"comment_images"] componentsSeparatedByString:@"#"];
    }
    return self;
}

@end
