//
//  BaseController.h
//  stalker
//
//  Created by Shannon Rush on 9/17/11.
//  Copyright (c) 2011 Rush Devo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "NSString+escape.h"

extern NSString * const DOMAIN;
extern NSTimeInterval INTERVAL;

@class PendingTrack;
@class Reachability;

@interface BaseController : UIViewController <CLLocationManagerDelegate> {
    NSMutableData *responseData;
    CLLocationManager *locationManager;
    NSDate *lastLocationDate;
    PendingTrack *pending;
    Reachability* internetReachable;
    Reachability* hostReachable;
    BOOL internetActive;
    BOOL hostActive;
}

@property BOOL internetActive;
@property BOOL hostActive;

-(void)initLocation;
-(void)initReachability;
-(void)checkNetworkStatus:(NSNotification *)notice;

-(void) noConnectionAlert;
-(void) asynchRequest:(NSString *)urlString withMethod:(NSString *)method withContentType:(NSString *)contentType withData:(NSString *)data;
-(void) handleAsynchResponse:(id)data;

-(void)getDestinationInfoWithLatitude:(double)latitude WithLongitude:(double)longitude;


@end
