//
//  ViewController.m
//  TramMeNow
//
//  Created by Laurence Saleh on 26/09/2015.
//  Copyright © 2015 Laurence Saleh. All rights reserved.
//

#import "TransportMainViewController.h"
#import "Location.h"
#import "Transport.h"
#import "MBProgressHUD.h"
#import "UIViewController+ViewController.h"
#import "Constants.h"
#import "TransportTableViewCell.h"
#import "TransportDetailViewController.h"
#import "RestKitManager.h"
#import <RestKit/RestKit.h>
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>

#define IS_SIMULATOR 1

@interface TransportMainViewController ()
{
    // -- Private ivars
    NSDateFormatter *dateFormatter;
    
    NSArray * locations;
    NSArray * connections;

    CLLocationManager *locationManager;
}

@end

@implementation TransportMainViewController

#pragma mark -
#pragma mark View Controller delegate methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // -- Restkit singleton to setup the mappings and response descriptors
    [[RestKitManager sharedInstance] configureRestKit];
    
    [self setupUI];
    [self setupNavigationBarWithTitle:@"Tram Me Now!"];
    [self setupPullToRefresh];
    [self setupLocationManager];
    [self hideConnectionsTableView];
    [self displayTramMeButton];
    
    [self.mapview setRegion:[self getCurrentPosition] animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.destinationViewController isKindOfClass:[TransportDetailViewController class]])
    {
        NSIndexPath *indexPath = [self.connectionsTableView indexPathForSelectedRow];
        Transport * selectedTransport = [connections objectAtIndex:indexPath.row];
        
        // -- Set the current selected transport object to the detail view so we can get the list of stations along its journey.
        TransportDetailViewController * transportDetailViewController = (TransportDetailViewController *)segue.destinationViewController;
        transportDetailViewController.transport = selectedTransport;
    }
}

#pragma mark -
#pragma mark TableView delegate methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"ConnectionDetailSegue" sender:self];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return connections.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"TransportCellIdentifier";
    
    TransportTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if([[connections objectAtIndex:indexPath.row] isKindOfClass:[Transport class]])
    {
        Transport * connection = [connections objectAtIndex:indexPath.row];
        
        if (cell == nil) {
            cell = [[TransportTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        if (!dateFormatter)
        {
            dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setLocale:[NSLocale currentLocale]];
            [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        }
        
        cell.transportDepartureTimeLabel.text = [dateFormatter stringFromDate:connection.departure];
        cell.transportNumberLabel.text = connection.number;
        cell.transportDirectionLabel.text = connection.to;
        
        [self setLabelShadowProperties:cell.transportDepartureTimeLabel];
        [self setLabelShadowProperties:cell.transportNumberLabel];
        [self setLabelShadowProperties:cell.transportDirectionLabel];
        
        UIImageView * backgroundImageView = [UIImageView new];
        UIImage * cellBackgroundImageColour = [self tramColourFromTramNumber:[connection.number intValue]];
        
        if(cellBackgroundImageColour == nil)
            cellBackgroundImageColour = [UIImage imageNamed:@"default.png"];
        
        backgroundImageView.image = cellBackgroundImageColour;
        cell.backgroundView = backgroundImageView;
    }
    
    return cell;
}

#pragma mark -
#pragma mark Helper methods

-(void)setLabelShadowProperties:(UILabel *)label
{
    label.layer.shadowColor = [UIColor blackColor].CGColor;
    label.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    label.layer.shadowRadius = 3.0;
    label.layer.shadowOpacity = 0.8;
    label.layer.masksToBounds = NO;
    label.layer.shouldRasterize = YES;
}

-(UIImage *)tramColourFromTramNumber:(NSInteger)tramNumber
{
    if(tramNumber)
    {
        NSString * imageName = [NSString stringWithFormat:@"tram_%li.png",(long)tramNumber];
        return [UIImage imageNamed:imageName];
    }
    
    return nil;
}

-(void)setupLocationManager
{
    locationManager = nil;
    locationManager = [[CLLocationManager alloc] init];
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    [locationManager startUpdatingLocation];
}

-(void)setupPullToRefresh
{
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    
    [refreshControl addTarget:self action:@selector(getTransitStationAndTransportData) forControlEvents:UIControlEventValueChanged];
    
    self.connectionsPullToRefreshControl = refreshControl;
    [self.connectionsTableView addSubview:self.connectionsPullToRefreshControl];
}


-(MKCoordinateRegion)getCurrentPosition
{
    if(locationManager == nil)
        [self setupLocationManager];
    
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = locationManager.location.coordinate.latitude;
    zoomLocation.longitude = locationManager.location.coordinate.longitude;
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 50,50);
    
    return viewRegion;
}


-(void)getTransitStationAndTransportData
{
    
    [self hideTramMeButton];
    [self showLoadingHud];
    
    // -- Make the REST call to get a array of transit stations close to our current location
    [self getClosestTransitStationWithRetry:YES withCompletetion:^{
        if(locations.count > 0)
        {
            // -- The closest transit station is always returned at index 0
            Location * closestTransitStation = [locations objectAtIndex:0];
            
            NSDictionary * coords = closestTransitStation.coordinates;
            double latitude = [[coords objectForKey:@"x"] doubleValue];
            double longtitude = [[coords objectForKey:@"y"] doubleValue];
            
            [self createTransitStationPointerWithName:closestTransitStation.name x:latitude y:longtitude];
            [self displayMapRegionWithCoordinates:latitude y:longtitude];
            
            // -- Make the REST call to get an array of trams and busses travelling from the closest transit station to you
            [self getTramTimesForStation:closestTransitStation.name shouldRetry:YES withCompletetion:^{
                
                [self performSelectorOnMainThread:@selector(hideLoadingHud) withObject:nil waitUntilDone:NO];
                [self performSelectorOnMainThread:@selector(showConnectionsTableView) withObject:nil waitUntilDone:NO];
                
            }];
        }
    }];
}

-(void)createTransitStationPointerWithName:(NSString *)name x:(double)latitude y:(double)longtitude
{
    
    // -- Add a pin to the location of the closest tram/bus stop and select it so we can see the name on the mapview
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = latitude;
    zoomLocation.longitude = longtitude;
    
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = zoomLocation;
    point.title = name;
    
    [self.mapview addAnnotation:point];
    [self.mapview selectAnnotation:point animated:YES];
}

-(void)displayMapRegionWithCoordinates:(double)latitude y:(double)longtitude
{
    
    // -- Zoom into a position on the map
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = latitude;
    zoomLocation.longitude = longtitude;
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 50,50);
    [self.mapview setRegion:viewRegion animated:YES];
}

-(void)cancelRequest
{
    
    // -- Something has gone wrong, end all loaders, reset the UI and remove data from the tableview
    [self.connectionsPullToRefreshControl endRefreshing];
    [self hideConnectionsTableView];
    [self performSelectorOnMainThread:@selector(hideLoadingHud) withObject:nil waitUntilDone:NO];
    [self performSelectorOnMainThread:@selector(showTramMeButton) withObject:nil waitUntilDone:NO];
}

#pragma mark -
#pragma mark UI Helper Methods


-(void)setupUI
{
    
    // -- Make sure that the frames of the tableview and mapview have been set properly for all screen sizes
    self.connectionsTableView.frame = CGRectMake(0,0,self.view.frame.size.width,(self.view.frame.size.height / 3) * 2);
    self.mapview.frame = CGRectMake(0,self.connectionsTableView.bounds.size.height,self.view.frame.size.width,self.view.frame.size.height / 3);
}
-(void)showConnectionsTableView
{
    // -- Show the tableview with a nice fade in animation
    [self.connectionsTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    
    [UIView animateWithDuration:1.00 animations:^{
        self.connectionsTableView.alpha = 1.0;
    }];
}

-(void)hideConnectionsTableView
{
    // -- Hide the tableview with a nice fade out animation
    connections = nil;
    [self.connectionsTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    
    [UIView animateWithDuration:1.00 animations:^{
        self.connectionsTableView.alpha = 0.0;
    }];
}

-(void)displayTramMeButton
{
    
    // -- Show and create the main tram me button
    if(!self.tramMeButton) {
        
        UIImage * tramMeUpButtonImage = [UIImage imageNamed:@"tram_me_button_up.png"];
        UIImage * tramMeDownButtonImage = [UIImage imageNamed:@"tram_me_button_down.png"];

        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self action:@selector(getTransitStationAndTransportData) forControlEvents:UIControlEventTouchUpInside];
        button.frame = CGRectMake(self.view.frame.size.width / 2 - 110, self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height, 220,240);
        [button setImage:tramMeUpButtonImage forState:UIControlStateNormal];
        [button setImage:tramMeDownButtonImage forState:UIControlStateHighlighted];
        
        self.tramMeButton = button;
        [self.view addSubview:self.tramMeButton];
    }
    else
    {
        [self showTramMeButton];
    }
}

-(void)hideTramMeButton
{
    [UIView animateWithDuration:1.00 animations:^{
        self.tramMeButton.alpha = 0.0;
    }];
}

-(void)showTramMeButton
{
    [UIView animateWithDuration:1.00 animations:^{
        self.tramMeButton.alpha = 1.0;
    }];
}

-(void)showLoadingHud
{
    // -- We dont want too loading animations to be on the screen at once so check if one is already running first
    if(![self.connectionsPullToRefreshControl isRefreshing])
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

-(void)hideLoadingHud
{
    [self.connectionsPullToRefreshControl endRefreshing];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

#pragma mark -
#pragma mark RESTKit caller methods

- (void)getClosestTransitStationWithRetry:(BOOL)retry withCompletetion:(void (^)(void))completion
{
    
    if(locationManager == nil)
        [self setupLocationManager];
    
    // -- Get the current coordinates for your location
    NSString *  latitude = [NSString stringWithFormat:@"%f",locationManager.location.coordinate.latitude];
    NSString *  longitude = [NSString stringWithFormat:@"%f",locationManager.location.coordinate.longitude];
    
    
    // -- If the simulator is running we can give it some pre defined values so the app still runs
    if(IS_SIMULATOR)
    {
        latitude = @"47.377944";
        longitude = @"8.540198";
    }

    // -- If location services have not been enabled we need to stop the request and tell the user
    if([latitude intValue] == 0 || [longitude intValue] == 0)
    {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"No Location"
                                                        message:@"There is a problem finding your location, please make sure you have enabled location services for this app"
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil,nil];
        [alert show];
        
        [self cancelRequest];
        return;
    }

    // -- Setup the extra parameters for the REST call
    NSDictionary *queryParameters = @{@"type" : @"station",
                                  @"x" : latitude,
                                  @"y" : longitude};
    
    __block BOOL shouldRetry = retry;

    [[RKObjectManager sharedManager] getObjectsAtPath:TRAM_LOCATIONS_PATH
                                           parameters:queryParameters
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  locations = mappingResult.array;
                                                  completion();
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  RKLogDebug(@"Error %@",error.description);
                                                  // -- The API I am using here only allows a certain amount of requests per minute.  Sometimes a retry is needed.
                                                  if(shouldRetry == YES){
                                                      // -- To prevent a infinite loop, we only do this once with the help of the shouldRetry flag
                                                      shouldRetry = NO;
                                                      [self getClosestTransitStationWithRetry:shouldRetry withCompletetion:completion];
                                                  }
                                                  else
                                                      [self cancelRequest];
                                              }];
}

-(void)getTramTimesForStation:(NSString *)stationName shouldRetry:(BOOL)retry withCompletetion:(void (^)(void))completion
{
    
    // -- Setup the extra parameters for the REST call
    NSDictionary *queryParameters = @{@"station" : stationName,
                                  @"limit" : @"8",
                                  @"transportations" : @[@"tramway_underground",@"bus"]};
    
    __block BOOL shouldRetry = retry;
    
    [[RKObjectManager sharedManager] getObjectsAtPath:TRAM_TRANSPORT_PATH
                                           parameters:queryParameters
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  connections = mappingResult.array;
                                                  completion();
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  RKLogDebug(@"Error %@",error.description);
                                                  // -- The API I am using here only allows a certain amount of requests per minute.  Sometimes a retry is needed.
                                                  if(shouldRetry == YES){
                                                      // -- To prevent a infinite loop, we only do this once with the help of the shouldRetry flag
                                                      shouldRetry = NO;
                                                      [self getTramTimesForStation:stationName shouldRetry:shouldRetry withCompletetion:completion];
                                                  }
                                                  else
                                                      [self cancelRequest];
                                              }];
}

@end
