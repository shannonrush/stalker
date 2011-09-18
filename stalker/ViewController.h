//
//  ViewController.h
//  stalker
//
//  Created by Shannon Rush on 9/17/11.
//  Copyright (c) 2011 Rush Devo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "BaseController.h"

@interface ViewController : BaseController <CLLocationManagerDelegate> {
    CLLocationManager *locationManager;
}


@end
