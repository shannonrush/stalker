//
//  AsynchRequest.m
//  stalker
//
//  Created by Shannon Rush on 9/27/11.
//  Copyright (c) 2011 Rush Devo. All rights reserved.
//

#import "AsynchRequest.h"
#import "UIViewController+handleAsynchResponse.h"

@implementation AsynchRequest

@synthesize managedObjectID, controller;

#pragma mark connections

-(void) asynchRequest:(NSString *)urlString withMethod:(NSString *)method withContentType:(NSString *)contentType withData:(NSString *)dataString {
    NSURL *url = [NSURL URLWithString:urlString]; 
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	
	if (dataString != nil && [dataString length] > 0) 
		[request setHTTPBody:[dataString dataUsingEncoding:NSISOLatin1StringEncoding]];
    [request setHTTPMethod:method];
    [request setValue:contentType forHTTPHeaderField:@"content-type"];
    [[NSURLConnection alloc] initWithRequest:request delegate:self]; 
}

-(void) handleAsynchResponse:(id)data {
    [data setValue:self.managedObjectID forKey:@"managedObjectID"];
    [self.controller handleAsynchResponse:data];
}

#pragma mark error handling

-(void) noConnectionAlert {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to Connect" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
}

#pragma mark NSURLConnection Delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (!responseData) 
        responseData = [[NSMutableData alloc]initWithLength:0];
	[responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	[self noConnectionAlert];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSMutableDictionary *data = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
    [self handleAsynchResponse:data];
}

@end
