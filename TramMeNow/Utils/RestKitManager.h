//
//  RestKitManager.h
//  TramMeNow
//
//  Created by Laurence Saleh on 29/09/15.
//  Copyright (c) 2015 Laurence Saleh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RestKitManager : NSObject


+(RestKitManager *)sharedInstance;
-(void)configureRestKit;
@end
