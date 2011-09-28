//
//  PendingTrack.m
//  stalker
//
//  Created by Shannon Rush on 9/24/11.
//  Copyright (c) 2011 Rush Devo. All rights reserved.
//

#import "PendingTrack.h"
#import "AppDelegate.h"

@implementation PendingTrack

-(void)savePendingTrackWithLatitude:(double)latitude WithLongitude:(double)longitude {
    AppDelegate *appDelegate=[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext*context=[appDelegate managedObjectContext];
    NSManagedObject *track=[NSEntityDescription
                            insertNewObjectForEntityForName:@"PendingTrack"
                            inManagedObjectContext:context];
    [track setValue:[NSString stringWithFormat:@"%f",latitude] forKey:@"lat"];
    [track setValue:[NSString stringWithFormat:@"%f",longitude] forKey:@"lng"];
    [track setValue:[NSDate date] forKey:@"trackAt"];
    NSError *error;
    [context save:&error];
}

-(void)processTracks {
    AppDelegate *appDelegate=[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context=[appDelegate managedObjectContext];
    NSEntityDescription *entityDesc=[NSEntityDescription entityForName:@"PendingTrack" inManagedObjectContext:context];
    NSFetchRequest *request=[[NSFetchRequest alloc]init];
    [request setEntity:entityDesc];
    NSError *error;
    NSArray *tracks=[context executeFetchRequest:request error:&error];
    
    for (NSManagedObject *track in tracks) {
        NSString *urlString = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?ll=%g,%g&limit=3&client_id=FW1Q1W4KGQCXCVNO25E4VWC0O4TSOMAA5D2VBSZUPKGIQXOM&client_secret=0AL5RBLTEORZ2GTX0TT20WD2P43NEBOUMB5234ENCQXH4333&v=20110927",[track valueForKey:@"lat"],[track valueForKey:@"lng"]];
        AsynchRequest *asynch = [[AsynchRequest alloc]init];
        asynch.controller = self;
        asynch.managedObjectID = [track objectID];
        [asynch asynchRequest:urlString withMethod:@"GET" withContentType:@"application/x-www-form-urlencoded" withData:nil];
    }
}

-(void) handleAsynchResponse:(id)data {
    if ([[data allKeys]containsObject:@"response"]) {
        AppDelegate *appDelegate=[[UIApplication sharedApplication]delegate];
        NSManagedObjectContext *context=[appDelegate managedObjectContext];
        NSManagedObject *track = [context objectWithID:[data valueForKey:@"managedObjectID"]];
        NSMutableString *destinationString = [NSMutableString string];
        NSArray *destinations = [[data objectForKey:@"response"]objectForKey:@"venues"];
        for (NSDictionary *destination in destinations) {
            NSArray *categories = [destination objectForKey:@"categories"];
            NSString *category = [categories count]>0 ? [[categories objectAtIndex:0]objectForKey:@"name"] : @"";
            NSString *name = [destination objectForKey:@"name"];
            [destinationString appendFormat:@"&[stalker_track]stalker_destinations_attributes[][category]=%@&[stalker_track]stalker_destinations_attributes[][name]=%@",[category escapeString],[name escapeString]];
        }
        NSMutableString *dataString = [NSMutableString stringWithFormat:@"[stalker_track]stalker_user_id=1&[stalker_track]lat=%@&[stalker_track]lng=%@&[stalker_track]track_at=%@",
                                       [track valueForKey:@"lat"],
                                       [track valueForKey:@"lng"],
                                       [track valueForKey:@"trackAt"]];
        [dataString appendString:destinationString];
        NSString *urlString = [NSString stringWithFormat:@"%@/stalker_tracks.json",DOMAIN];
        [self asynchRequest:urlString withMethod:@"POST" withContentType:@"application/x-www-form-urlencoded" withData:dataString];
        [context deleteObject:track];
        NSError *error;
        [context save:&error];
    }
}

@end
