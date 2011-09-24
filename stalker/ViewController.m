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
    pendingTracks = [[NSMutableArray alloc]init];

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
    if (self.internetActive && self.hostActive && [self hasPendingTracks]) {
        [pending performSelectorInBackground:@selector(sendTracks) withObject:pendingTracks];
    }
}

-(BOOL)hasPendingTracks {
    AppDelegate *appDelegate=[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context=[appDelegate managedObjectContext];
    NSEntityDescription *entityDesc=[NSEntityDescription entityForName:@"PendingTrack" inManagedObjectContext:context];
    NSFetchRequest *request=[[NSFetchRequest alloc]init];
    [request setEntity:entityDesc];
    NSError *error;
    NSArray *tracks=[context executeFetchRequest:request error:&error];
    if ([tracks count]>0) {
        [pendingTracks setArray:tracks];
        return YES;
    } else {
        return NO;
    }
}

#pragma mark HTTP

-(void) handleAsynchResponse:(id)data {
    if ([[data allKeys]containsObject:@"response"]) {
        NSMutableString *dataString = [NSMutableString stringWithFormat:@"[stalker_track]stalker_user_id=1&[stalker_track]lat=%g&[stalker_track]lng=%g&[stalker_track]track_at=%@",
                                    locationManager.location.coordinate.latitude,
                                    locationManager.location.coordinate.longitude,
                                       [NSDate date]];
        NSArray *destinations = [[data objectForKey:@"response"]objectForKey:@"venues"];
        for (NSDictionary *destination in destinations) {
            NSArray *categories = [destination objectForKey:@"categories"];
            NSString *category = [categories count]>0 ? [[categories objectAtIndex:0]objectForKey:@"name"] : @"";
            NSString *name = [destination objectForKey:@"name"];
            [dataString appendFormat:@"&[stalker_track]stalker_destinations_attributes[][category]=%@&[stalker_track]stalker_destinations_attributes[][name]=%@",[category escapeString],[name escapeString]];
        }
        NSString *urlString = @"http://10.0.1.17:3000/stalker_tracks.json";
        [self asynchRequest:urlString withMethod:@"POST" withContentType:@"application/x-www-form-urlencoded" withData:dataString];
    }
}

@end
