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
    NSMutableArray *pendingTracks;
    PendingTrack *pending;
    Reachability* internetReachable;
    Reachability* hostReachable;
}



-(void)initLocation;
-(void)initReachability;
-(void)checkNetworkStatus:(NSNotification *)notice;


@end
