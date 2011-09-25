//
//  ViewController.h
//  stalker
//
//  Created by Shannon Rush on 9/17/11.
//  Copyright (c) 2011 Rush Devo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BaseController.h"

@interface ViewController : BaseController {
    
    IBOutlet UILabel *locationLabel;
    IBOutlet UILabel *categoryLabel;
    IBOutlet UIDatePicker *datePicker;
}

-(IBAction)predictLocation;

@end
