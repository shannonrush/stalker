//
//  BaseController.m
//  stalker
//
//  Created by Shannon Rush on 9/17/11.
//  Copyright (c) 2011 Rush Devo. All rights reserved.
//

#import "BaseController.h"

NSString * const DOMAIN = @"http://rushdevo.com";
NSTimeInterval INTERVAL = -30;

@implementation BaseController

-(void)getDestinationInfoWithLatitude:(double)latitude WithLongitude:(double)longitude {
    NSString *urlString = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?ll=%g,%g&intent=checkin&limit=3&oauth_token=CF3ULZN4PBS3NFQVGICT1ABUNLALPKQH5TTHEEYY3U0CBMEI&v=20110918",
                           latitude,
                           longitude];
    [self asynchRequest:urlString withMethod:@"GET" withContentType:@"application/x-www-form-urlencoded" withData:nil];
}

-(void)sendTrackWithData:(id)data WithDataString:(NSMutableString *)dataString {
    NSArray *destinations = [[data objectForKey:@"response"]objectForKey:@"venues"];
    for (NSDictionary *destination in destinations) {
        NSArray *categories = [destination objectForKey:@"categories"];
        NSString *category = [categories count]>0 ? [[categories objectAtIndex:0]objectForKey:@"name"] : @"";
        NSString *name = [destination objectForKey:@"name"];
        [dataString appendFormat:@"&[stalker_track]stalker_destinations_attributes[][category]=%@&[stalker_track]stalker_destinations_attributes[][name]=%@",[category escapeString],[name escapeString]];
    }
    NSString *urlString = [NSString stringWithFormat:@"%@/stalker_tracks.json",DOMAIN]; 
    [self asynchRequest:urlString withMethod:@"POST" withContentType:@"application/x-www-form-urlencoded" withData:dataString];
}

// connections

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
    [self handleAsynchResponse:data];
}

@end
