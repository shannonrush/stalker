//
//  ViewController.m
//  stalker
//
//  Created by Shannon Rush on 9/17/11.
//  Copyright (c) 2011 Rush Devo. All rights reserved.
//

#import "ViewController.h"
#import "NSString+escape.h"
#import "Reachability.h"
#import "AppDelegate.h"

@implementation ViewController

@synthesize internetActive, hostActive;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initLocation];
    [self initReachability];
}

#pragma mark CLLocationManagerDelegate

-(void)initLocation {
    if (!locationManager) 
        locationManager = [[CLLocationManager alloc] init];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager setDelegate:self];
    [locationManager startUpdatingLocation];
    lastLocationDate = [[NSDate alloc]initWithTimeIntervalSinceNow:-300];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSTimeInterval age = [newLocation.timestamp timeIntervalSinceNow];
    // make sure location is fresh and get new data only once every minute
    if (abs(age) < 60.0 && [lastLocationDate timeIntervalSinceNow] < -300)  {
        if (internetActive && hostActive) {

        } else {
            [self savePendingTrackWithLatitude:newLocation.coordinate.latitude WithLongitude:newLocation.coordinate.longitude];
        }
        lastLocationDate = [NSDate date];
    }
}

-(void)getDestinationInfoWithLatitude:(double)latitude WithLongitude:(double)longitude {
    NSString *urlString = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?ll=%g,%g&intent=checkin&limit=3&oauth_token=CF3ULZN4PBS3NFQVGICT1ABUNLALPKQH5TTHEEYY3U0CBMEI&v=20110918",
                           latitude,
                           longitude];
    [self asynchRequest:urlString withMethod:@"GET" withContentType:@"application/x-www-form-urlencoded" withData:nil];
}

-(void)savePendingTrackWithLatitude:(double)latitude WithLongitude:(double)longitude {
    AppDelegate *appDelegate=[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext*context=[appDelegate managedObjectContext];
    NSManagedObject *track=[NSEntityDescription
                            insertNewObjectForEntityForName:@"PendingTrack"
                            inManagedObjectContext:context];    
    [track setValue:[NSNumber numberWithDouble:latitude] forKey:@"lat"];
    [track setValue:[NSNumber numberWithDouble:longitude] forKey:@"lng"];
    [track setValue:[NSDate date] forKey:@"timestamp"];
    NSError *error;
    [context save:&error];
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
}

#pragma mark HTTP

-(void) handleAsynchResponse:(id)data {
    if ([[data allKeys]containsObject:@"response"]) {
        NSMutableString *dataString = [NSMutableString stringWithFormat:@"[stalker_track]stalker_user_id=1&[stalker_track]lat=%g&[stalker_track]lng=%g",
                                    locationManager.location.coordinate.latitude,
                                    locationManager.location.coordinate.longitude];
        NSArray *destinations = [[data objectForKey:@"response"]objectForKey:@"venues"];
        for (NSDictionary *destination in destinations) {
            NSArray *categories = [destination objectForKey:@"categories"];
            NSString *category = [categories count]>0 ? [[categories objectAtIndex:0]objectForKey:@"name"] : @"";
            NSString *name = [destination objectForKey:@"name"];
            [dataString appendFormat:@"&[stalker_track]stalker_destinations_attributes[][category]=%@&[stalker_track]stalker_destinations_attributes[][name]=%@",[category escapeString],[name escapeString]];
        }
        NSString *urlString = @"http://rushdevo.com/stalker_tracks.json";
        [self asynchRequest:urlString withMethod:@"POST" withContentType:@"application/x-www-form-urlencoded" withData:dataString];
    }
}

@end
