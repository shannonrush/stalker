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
    
    tracksToSave = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSMutableArray array],@"destinationStrings",[NSMutableArray array],@"tracks",nil];
    for (NSManagedObject *track in tracks) {
        NSString *latitude = [track valueForKey:@"lat"];
        NSString *longitude = [track valueForKey:@"lng"];
        NSDictionary *trackDict = [NSDictionary dictionaryWithObjectsAndKeys:latitude,@"lat",longitude,@"lng",[track valueForKey:@"trackAt"],@"trackAt",nil];
        [[tracksToSave objectForKey:@"tracks"]addObject:trackDict];
        [self getDestinationInfoWithLatitude:[latitude doubleValue] WithLongitude:[longitude doubleValue]];
        [context deleteObject:track];
        NSError *error;
        [context save:&error];
    }
}

-(void)sendTracks {
    NSArray *tracks = [tracksToSave objectForKey:@"tracks"];
    for (NSDictionary *track in tracks) {
        NSMutableString *dataString = [NSMutableString stringWithFormat:@"[stalker_track]stalker_user_id=1&[stalker_track]lat=%@&[stalker_track]lng=%@&[stalker_track]track_at=%@",
                                       [track valueForKey:@"lat"],
                                       [track valueForKey:@"lng"],
                                       [track valueForKey:@"trackAt"]];
        NSString *destinationString = [[tracksToSave objectForKey:@"destinationStrings"]objectAtIndex:[tracks indexOfObject:track]];
        [dataString appendString:destinationString];
        NSString *urlString = [NSString stringWithFormat:@"%@/stalker_tracks.json",DOMAIN]; 
        [self asynchRequest:urlString withMethod:@"POST" withContentType:@"application/x-www-form-urlencoded" withData:dataString];
    }
    tracksToSave = nil;
}

-(void) handleAsynchResponse:(id)data {
    if ([[data allKeys]containsObject:@"response"]) {
        NSMutableString *destinationString = [NSMutableString string];
        NSArray *destinations = [[data objectForKey:@"response"]objectForKey:@"venues"];
        for (NSDictionary *destination in destinations) {
            NSArray *categories = [destination objectForKey:@"categories"];
            NSString *category = [categories count]>0 ? [[categories objectAtIndex:0]objectForKey:@"name"] : @"";
            NSString *name = [destination objectForKey:@"name"];
            [destinationString appendFormat:@"&[stalker_track]stalker_destinations_attributes[][category]=%@&[stalker_track]stalker_destinations_attributes[][name]=%@",[category escapeString],[name escapeString]];
        }
        [[tracksToSave objectForKey:@"destinationStrings"]addObject:destinationString];
        if ([[tracksToSave objectForKey:@"destinationStrings"]count]==[[tracksToSave objectForKey:@"tracks"]count]) {
            [self sendTracks];
        }
    }
}

@end
