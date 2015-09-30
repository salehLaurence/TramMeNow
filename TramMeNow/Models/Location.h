//
//  Location.h
//  TramMeNow
//
//  Created by Laurence Saleh on 26/09/2015.
//  Copyright © 2015 Laurence Saleh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Location : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *locationID;
@property (nonatomic, strong) NSString *score;
@property (nonatomic, strong) NSDictionary *coordinates;
@property (nonatomic, strong) NSString *distance;

@end
