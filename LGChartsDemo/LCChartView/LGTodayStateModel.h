//
//  LGTodayStateModel.h
//  aofengDJ
//
//  Created by hzx on 2018/8/1.
//  Copyright © 2018年 hzx. All rights reserved.
//

#import <Foundation/Foundation.h>
//"create_time" = 1533032646000;
//date = "2018-07-16";
//"device_id" = ChronoBlade11812D;
//id = 81;
//"sit_time" = 25;
//"start_time" = "06:28";
@interface LGTodayStateModel : NSObject
@property (nonatomic,strong)NSString *create_time;
@property (nonatomic,strong)NSString *date;
@property (nonatomic,strong)NSString *device_id;
@property (nonatomic,strong)NSString *idStr;
@property (nonatomic,strong)NSString *sit_time;
@property (nonatomic,strong)NSString *start_time;
@end
