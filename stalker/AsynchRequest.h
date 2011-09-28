//
//  AsynchRequest.h
//  stalker
//
//  Created by Shannon Rush on 9/27/11.
//  Copyright (c) 2011 Rush Devo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseController.h"

@interface AsynchRequest : NSObject {
    NSMutableData *responseData;
    NSManagedObjectID *managedObjectID;
    UIViewController *controller;
}

@property (strong) NSManagedObjectID *managedObjectID;
@property (strong) UIViewController *controller;

-(void) noConnectionAlert;
-(void) asynchRequest:(NSString *)urlString withMethod:(NSString *)method withContentType:(NSString *)contentType withData:(NSString *)data;
-(void) handleAsynchResponse:(id)data;

@end
