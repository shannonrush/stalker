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

+(NSManagedObject *)currentTrack {
    return currentTrack;
}

+(void)setCurrentTrack:(NSManagedObject *)track {
    currentTrack = track;
}

-(void)savePendingTrackWithLatitude:(double)latitude WithLongitude:(double)longitude {
    AppDelegate *appDelegate=[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext*context=[appDelegate managedObjectContext];
    NSManagedObject *track=[NSEntityDescription
                            insertNewObjectForEntityForName:@"PendingTrack"
                            inManagedObjectContext:context];    
    [track setValue:[NSNumber numberWithDouble:latitude] forKey:@"lat"];
    [track setValue:[NSNumber numberWithDouble:longitude] forKey:@"lng"];
    [track setValue:[NSDate date] forKey:@"trackAt"];
    NSError *error;
    [context save:&error];
}

-(void)sendTracks:(NSMutableArray *)tracks {
    @autoreleasepool {
        for (NSManagedObject *track in tracks) {
            [PendingTrack setCurrentTrack:track];
            [self getDestinationInfoWithLatitude:[[track valueForKey:@"lat"]doubleValue] WithLongitude:[[track valueForKey:@"longitude"]doubleValue]];
        }
    }
}

-(void) handleAsynchResponse:(id)data {
    if ([[data allKeys]containsObject:@"response"]) {
        NSManagedObject *track = [PendingTrack currentTrack];
        NSMutableString *dataString = [NSMutableString stringWithFormat:@"[stalker_track]stalker_user_id=1&[stalker_track]lat=%g&[stalker_track]lng=%g&[stalker_track]track_at=%@",
                                       [track valueForKey:@"lat"],
                                       [track valueForKey:@"lng"],
                                       [track valueForKey:@"trackAt"]];
        NSArray *destinations = [[data objectForKey:@"response"]objectForKey:@"venues"];
        for (NSDictionary *destination in destinations) {
            NSArray *categories = [destination objectForKey:@"categories"];
            NSString *category = [categories count]>0 ? [[categories objectAtIndex:0]objectForKey:@"name"] : @"";
            NSString *name = [destination objectForKey:@"name"];
            [dataString appendFormat:@"&[stalker_track]stalker_destinations_attributes[][category]=%@&[stalker_track]stalker_destinations_attributes[][name]=%@",[category escapeString],[name escapeString]];
        }
        NSString *urlString = @"http://10.0.1.17:3000/stalker_tracks.json";
        [self asynchRequest:urlString withMethod:@"POST" withContentType:@"application/x-www-form-urlencoded" withData:dataString];
        [[track managedObjectContext] deleteObject:track];
        NSError *error;
        [[track managedObjectContext] save:&error];
    }
}

@end
