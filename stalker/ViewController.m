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
    
    NSString *dataString = [NSString stringWithFormat:@"date=%@",date];
    NSString *urlString = [NSString stringWithFormat:@"%@/stalker_predictions.json",DOMAIN]; 
    [self asynchRequest:urlString withMethod:@"POST" withContentType:@"application/x-www-form-urlencoded" withData:dataString];
}

-(void)handleAsynchResponse:(id)data {
    
}

@end
