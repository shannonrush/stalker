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


@interface BaseController : UIViewController {
    NSMutableData *responseData;
    BOOL internetActive;
    BOOL hostActive;
}

@property BOOL internetActive;
@property BOOL hostActive;

-(void) noConnectionAlert;
//-(NSURL *) constructURL:(NSString *)path;
-(void) asynchRequest:(NSString *)urlString withMethod:(NSString *)method withContentType:(NSString *)contentType withData:(NSString *)data;
-(void) handleAsynchResponse:(id)data;

-(void)getDestinationInfoWithLatitude:(double)latitude WithLongitude:(double)longitude;
-(void)sendTrackWithData:(id)data WithDataString:(NSMutableString *)dataString;


@end
