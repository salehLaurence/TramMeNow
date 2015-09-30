//
//  Transport.h
//  TramMeNow
//
//  Created by Laurence Saleh on 28/09/15.
//  Copyright (c) 2015 Laurence Saleh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Transport : NSObject

@property(nonatomic,strong) NSString * name;
@property(nonatomic,strong) NSString * category;
@property(nonatomic,strong) NSString * number;
@property(nonatomic,strong) NSString * operatedBy;
@property(nonatomic,strong) NSString * to;
@property(nonatomic,strong) NSDate * departureTimestamp;
@property(nonatomic,strong) NSDate *departure;
@property(nonatomic,strong) NSArray * stations;

@end
