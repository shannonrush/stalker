//
//  NSObject+escape.m
//  stalker
//
//  Created by Shannon Rush on 9/18/11.
//  Copyright (c) 2011 Rush Devo. All rights reserved.
//

#import "NSString+escape.h"

@implementation NSString (escape)

-(NSString *)escapeString {
    NSMutableString *escapedString = [NSMutableString stringWithString:[self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [escapedString replaceOccurrencesOfString:@"&" withString:@"%26" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escapedString length])];
    return escapedString;
}

@end
