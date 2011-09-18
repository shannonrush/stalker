//
//  BaseController.m
//  stalker
//
//  Created by Shannon Rush on 9/17/11.
//  Copyright (c) 2011 Rush Devo. All rights reserved.
//

#import "BaseController.h"

@implementation BaseController

-(void) noConnectionAlert {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to Connect" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
}

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
	//Override in subclasses unless your response is a no-op for some reason
}

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
    NSLog(@"%@", data);
    [self handleAsynchResponse:data];
}

@end
