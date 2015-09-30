//
//  TransportDetailViewController.m
//  TramMeNow
//
//  Created by Laurence Saleh on 29/09/15.
//  Copyright (c) 2015 Laurence Saleh. All rights reserved.
//

#import "TransportDetailViewController.h"
#import "TransportJourneyTableViewCell.h"
#import "UIViewController+ViewController.h"
#import "JourneyLocation.h"

@interface TransportDetailViewController ()
{
    NSDateFormatter *dateFormatter;
}
@end

@implementation TransportDetailViewController


-(void)viewDidLoad
{
    [self setupNavigationBarWithTitle:self.transport.name];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
}

#pragma mark -
#pragma mark TableView delegate methods

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.transport.stations.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"TransportJourneyCellIdentifier";
    
    TransportJourneyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[TransportJourneyTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (!dateFormatter)
    {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setLocale:[NSLocale currentLocale]];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    }
    
    if([[self.transport.stations objectAtIndex:indexPath.row] isKindOfClass:[JourneyLocation class]])
    {
        JourneyLocation * journeyLocation = [self.transport.stations objectAtIndex:indexPath.row];

        cell.journeyArrivalTimeLabel.text = [dateFormatter stringFromDate:journeyLocation.arrival];
        cell.journeyStationNameLabel.text = journeyLocation.name;
    }
    
    return cell;
}

@end
