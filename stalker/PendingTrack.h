//
//  PendingTrack.h
//  stalker
//
//  Created by Shannon Rush on 9/24/11.
//  Copyright (c) 2011 Rush Devo. All rights reserved.
//

#import "BaseController.h"

NSManagedObject *currentTrack;

@interface PendingTrack : BaseController 

+(NSManagedObject *)currentTrack;
+(void)setCurrentTrack:(NSManagedObject *)track;

-(void)savePendingTrackWithLatitude:(double)latitude WithLongitude:(double)longitude;

@end
