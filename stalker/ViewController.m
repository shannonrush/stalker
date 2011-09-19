//
//  ViewController.m
//  stalker
//
//  Created by Shannon Rush on 9/17/11.
//  Copyright (c) 2011 Rush Devo. All rights reserved.
//

#import "ViewController.h"
#import "NSString+escape.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!locationManager) 
        locationManager = [[CLLocationManager alloc] init];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager setDelegate:self];
    [locationManager startUpdatingLocation];
    lastLocationDate = [[NSDate alloc]initWithTimeIntervalSinceNow:-60];
}

#pragma mark CLLocationManagerDelegate



- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSTimeInterval age = [newLocation.timestamp timeIntervalSinceNow];
    // make sure location is fresh and get new data only once every minute
    if (abs(age) < 60.0 && [lastLocationDate timeIntervalSinceNow] < -60)  {
        NSLog(@"calling foursquare");
        NSString *urlString = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?ll=%g,%g&intent=checkin&limit=3&oauth_token=CF3ULZN4PBS3NFQVGICT1ABUNLALPKQH5TTHEEYY3U0CBMEI&v=20110918",
                               newLocation.coordinate.latitude,
                               newLocation.coordinate.longitude];
        [self asynchRequest:urlString withMethod:@"GET" withContentType:@"application/x-www-form-urlencoded" withData:nil];
        lastLocationDate = [NSDate date];
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
