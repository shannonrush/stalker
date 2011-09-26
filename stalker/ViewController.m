//
//  ViewController.m
//  stalker
//
//  Created by Shannon Rush on 9/17/11.
//  Copyright (c) 2011 Rush Devo. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

#pragma mark HTTP

-(IBAction)predictLocation {
    // send date to Ruby app for location and category prediction
    NSDate *date = [datePicker date];
    
    NSString *urlString = [NSString stringWithFormat:@"http://10.0.1.17:3000/stalker_predictions.json?date=%@",date]; 
    [self asynchRequest:urlString withMethod:@"GET" withContentType:@"application/x-www-form-urlencoded" withData:nil];
}

-(void)handleAsynchResponse:(id)data {
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
        NSString *urlString = [NSString stringWithFormat:@"%@/stalker_tracks.json",DOMAIN]; 
        [self asynchRequest:urlString withMethod:@"POST" withContentType:@"application/x-www-form-urlencoded" withData:dataString];
    }
}

@end
