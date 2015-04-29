//
//  PKRSSItemObject.m
//  tedRSS
//
//  Created by Pavel on 24.04.15.
//  Copyright (c) 2015 Pavel. All rights reserved.
//

#import "PKRSSItemObject.h"

@implementation PKRSSItemObject
@synthesize title = _title;
@synthesize descriptionString = _descriptionString;
@synthesize pubDate = _pubDate;
@synthesize videoURLString320 = _videoURLString320;
@synthesize thumbURLString = _thumbURLString;
@synthesize thumbImage = _thumbImage;

/*! singletone - NSDateFormatter for make publication NSDate from xml response
 */
+ (NSDateFormatter *)formatterForPubDate
{
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss Z"];
        [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] ];
    });
    
    return dateFormatter;
}

- (void) setPubDateString:(NSString *)pubDateString
{
    _pubDateString = pubDateString;
    
    //if set string - make nsdate and set to object
    if (pubDateString)
    {
        NSString *resultString = [pubDateString stringByReplacingOccurrencesOfString:@"\t" withString:@""];
        resultString = [resultString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        
        NSDate *date = [[PKRSSItemObject formatterForPubDate] dateFromString:resultString];
        if (date) _pubDate = date;
    }
}

- (void) setDescriptionString:(NSString *)descriptionString
{
    //removing html img src tags
    NSString *descriptionsStringWithoutHTMLTags = [descriptionString stringByReplacingOccurrencesOfString:@"<img[^>]*>" withString:@"" options:NSCaseInsensitiveSearch | NSRegularExpressionSearch range:NSMakeRange(0, [descriptionString length])];
    _descriptionString = descriptionsStringWithoutHTMLTags;
}

@end
