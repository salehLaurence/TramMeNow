//
//  RestKitManager.m
//  TramMeNow
//
//  Created by Laurence Saleh on 29/09/15.
//  Copyright (c) 2015 Laurence Saleh. All rights reserved.
//

#import "RestKitManager.h"
#import <RestKit/RestKit.h>
#import "Location.h"
#import "Transport.h"
#import "Constants.h"
#import "JourneyLocation.h"

@implementation RestKitManager

// -- Creates a singleton and returns it via an abstract method
+ (RestKitManager *)sharedInstance
{
    static RestKitManager *instance = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        instance = [[RestKitManager alloc] init];
    });
    
    return instance;
}

// -- Setup our restkit configuration
-(void)configureRestKit
{

    NSURL *baseURL = [NSURL URLWithString:TRAM_API_URL];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    
    // -- Setup object mappings
    RKObjectMapping *locationMapping = [RKObjectMapping mappingForClass:[Location class]];
    [locationMapping addAttributeMappingsFromDictionary:@{@"name" : @"name",
                                                       @"id" : @"locationID",
                                                       @"coordinate" : @"coordinates",
                                                       @"score" : @"score",
                                                       @"distance" : @"distance",
                                                       }];
    
    RKObjectMapping *transportMapping = [RKObjectMapping mappingForClass:[Transport class]];
    [transportMapping addAttributeMappingsFromDictionary:@{@"name" : @"name",
                                                           @"category" : @"category",
                                                           @"number" : @"number",
                                                           @"operator" : @"operatedBy",
                                                           @"to" : @"to",
                                                           @"stop.departureTimestamp" : @"departureTimestamp",
                                                           @"stop.departure" : @"departure",
                                                           }];

    RKObjectMapping *journeyLocationMapping = [RKObjectMapping mappingForClass:[JourneyLocation class]];
    [journeyLocationMapping addAttributeMappingsFromDictionary:@{@"arrival" : @"arrival",
                                                                 @"station.name" : @"name",
                                                                }];
    
    RKRelationshipMapping *transportJourneyMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"passList" toKeyPath:@"stations" withMapping:journeyLocationMapping];
    [transportMapping addPropertyMapping:transportJourneyMapping];
    
    // -- Setup our response descriptors
    RKResponseDescriptor * stationResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:locationMapping
                                                 method:RKRequestMethodGET
                                            pathPattern:TRAM_LOCATIONS_PATH
                                                keyPath:@"stations"
                                            statusCodes:[NSIndexSet indexSetWithIndex:200]];
    
    RKResponseDescriptor * transportResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:transportMapping
                                                 method:RKRequestMethodGET
                                            pathPattern:TRAM_TRANSPORT_PATH
                                                keyPath:@"stationboard"
                                            statusCodes:[NSIndexSet indexSetWithIndex:200]];
    
    [objectManager addResponseDescriptor:stationResponseDescriptor];
    [objectManager addResponseDescriptor:transportResponseDescriptor];
}

@end
