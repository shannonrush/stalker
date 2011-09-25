//
//  ViewController.h
//  stalker
//
//  Created by Shannon Rush on 9/17/11.
//  Copyright (c) 2011 Rush Devo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BaseController.h"

@class PendingTrack;
@class Reachability;


@interface ViewController : BaseController <CLLocationManagerDelegate> {
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


@end
