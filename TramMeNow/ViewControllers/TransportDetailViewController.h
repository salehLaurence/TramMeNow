//
//  TransportDetailViewController.h
//  TramMeNow
//
//  Created by Laurence Saleh on 29/09/15.
//  Copyright (c) 2015 Laurence Saleh. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "Transport.h"

@interface TransportDetailViewController : UIViewController <UITableViewDataSource , UITableViewDelegate>
{
}


@property (nonatomic,weak) Transport * transport;

@end
