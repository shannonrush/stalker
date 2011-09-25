//
//  ViewController.m
//  stalker
//
//  Created by Shannon Rush on 9/17/11.
//  Copyright (c) 2011 Rush Devo. All rights reserved.
//

#import "ViewController.h"
#import "Reachability.h"
#import "AppDelegate.h"
#import "PendingTrack.h"


@implementation ViewController

@synthesize internetActive, hostActive;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initLocation];
    [self initReachability];
    pending = [[PendingTrack alloc]init];
}

#pragma mark CLLocationManagerDelegate

-(void)initLocation {
    if (!locationManager) 
        locationManager = [[CLLocationManager alloc] init];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager setDelegate:self];
    [locationManager startUpdatingLocation];
    lastLocationDate = [[NSDate alloc]initWithTimeIntervalSinceNow:INTERVAL];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSTimeInterval age = [newLocation.timestamp timeIntervalSinceNow];
    // make sure location is fresh and get new data only once every minute
    if (abs(age) < 60.0 && [lastLocationDate timeIntervalSinceNow] < INTERVAL)  {
        if (internetActive && hostActive) {
            [self getDestinationInfoWithLatitude:newLocation.coordinate.latitude WithLongitude:newLocation.coordinate.longitude];
        } else {
            [pending savePendingTrackWithLatitude:newLocation.coordinate.latitude WithLongitude:newLocation.coordinate.longitude];
        }
        lastLocationDate = [NSDate date];
    }
}

#pragma mark Reachability

-(void)initReachability {
    // check for internet connection
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    
    internetReachable = [Reachability reachabilityForInternetConnection];
    [internetReachable startNotifier];
    
    // check if a pathway to a random host exists
    hostReachable = [Reachability reachabilityWithHostName:@"www.rushdevo.com"];
    [hostReachable startNotifier];
    
    // now patiently wait for the notification
}

- (void) checkNetworkStatus:(NSNotification *)notice {
    // called after network status changes
    
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    switch (internetStatus) {
        case NotReachable: {
            NSLog(@"The internet is down.");
            self.internetActive = NO;
            break;
        }
        case ReachableViaWiFi: {
            NSLog(@"The internet is working via WIFI.");
            self.internetActive = YES;
            break;
        }
        case ReachableViaWWAN:{
            NSLog(@"The internet is working via WWAN.");
            self.internetActive = YES;
            break;
        }
    }
    
    NetworkStatus hostStatus = [hostReachable currentReachabilityStatus];
    switch (hostStatus) {
        case NotReachable: {
            NSLog(@"A gateway to the host server is down.");
            self.hostActive = NO;
            break;
        }
        case ReachableViaWiFi: {
            NSLog(@"A gateway to the host server is working via WIFI.");
            self.hostActive = YES;
            break;
        }
        case ReachableViaWWAN: {
            NSLog(@"A gateway to the host server is working via WWAN.");
            self.hostActive = YES;
            break;
        }
    }
    if (self.internetActive && self.hostActive)
        [pending processTracks];
}


#pragma mark HTTP

-(void) handleAsynchResponse:(id)data {
    if ([[data allKeys]containsObject:@"response"]) {
        NSMutableString *dataString = [NSMutableString stringWithFormat:@"[stalker_track]stalker_user_id=1&[stalker_track]lat=%g&[stalker_track]lng=%g&[stalker_track]track_at=%@",
                                    locationManager.location.coordinate.latitude,
                                    locationManager.location.coordinate.longitude,
                                       [NSDate date]];
        [self sendTrackWithData:data WithDataString:dataString];
    }
}

@end
