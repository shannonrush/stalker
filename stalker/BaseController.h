//
//  BaseController.h
//  stalker
//
//  Created by Shannon Rush on 9/17/11.
//  Copyright (c) 2011 Rush Devo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseController : UIViewController {
    NSMutableData *responseData;
}

-(void) noConnectionAlert;
//-(NSURL *) constructURL:(NSString *)path;
-(void) asynchRequest:(NSString *)urlString withMethod:(NSString *)method withContentType:(NSString *)contentType withData:(NSString *)data;
-(void) handleAsynchResponse:(id)data;


@end
