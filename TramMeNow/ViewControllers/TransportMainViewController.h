//
//  ViewController.h
//  TramMeNow
//
//  Created by Laurence Saleh on 26/09/2015.
//  Copyright © 2015 Laurence Saleh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface TransportMainViewController : UIViewController <CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic,weak) IBOutlet MKMapView *mapview;
@property (nonatomic,weak) IBOutlet UITableView *connectionsTableView;

@property (nonatomic,strong) UIButton * tramMeButton;
@property (nonatomic,strong) UIBarButtonItem * refreshButton;

@property (nonatomic,strong) UIRefreshControl * connectionsPullToRefreshControl;
@end

