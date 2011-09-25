//
//  PendingTrack.h
//  stalker
//
//  Created by Shannon Rush on 9/24/11.
//  Copyright (c) 2011 Rush Devo. All rights reserved.
//

#import "BaseController.h"


@interface PendingTrack : BaseController {
    NSMutableDictionary *tracksToSave;
}

-(void)processTracks;
-(void)sendTracks;
-(void)savePendingTrackWithLatitude:(double)latitude WithLongitude:(double)longitude;

@end
