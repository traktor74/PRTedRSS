//
//  PKRSSItemViewController.h
//  tedRSS
//
//  Created by Pavel on 24.04.15.
//  Copyright (c) 2015 Pavel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PKRSSItemObject.h"

@interface PKRSSItemViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *videoPlayerView;
@property (weak, nonatomic) IBOutlet UIScrollView *detailsScrollView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

//constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleHeightCOnstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionHeightConstraint;


@property (strong, nonatomic) PKRSSItemObject *currentRSSItemObject;

@end
