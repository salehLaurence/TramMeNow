//
//  TransportJourneyTableViewCell.h
//  TramMeNow
//
//  Created by Laurence Saleh on 29/09/15.
//  Copyright (c) 2015 Laurence Saleh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TransportJourneyTableViewCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UILabel * journeyArrivalTimeLabel;
@property (nonatomic,weak) IBOutlet UILabel * journeyStationNameLabel;
@end
