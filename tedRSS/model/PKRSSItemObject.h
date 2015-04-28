//
//  PKRSSItemObject.h
//  tedRSS
//
//  Created by Pavel on 24.04.15.
//  Copyright (c) 2015 Pavel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PKRSSItemObject : NSObject
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *descriptionString;
@property (nonatomic,strong) NSString *pubDateString;
@property (nonatomic, strong) NSDate *pubDate;
@property (nonatomic, strong) NSString  *videoURLString320;
@property (nonatomic, strong) NSString  *thumbURLString;
@property (nonatomic, strong) UIImage *thumbImage;

@end
