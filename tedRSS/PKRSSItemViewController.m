//
//  PKRSSItemViewController.m
//  tedRSS
//
//  Created by Pavel on 24.04.15.
//  Copyright (c) 2015 Pavel. All rights reserved.
//

#import "PKRSSItemViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface PKRSSItemViewController ()
@property (strong, nonatomic) MPMoviePlayerController *moviePlayerController;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videoPlayerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videoPlayerViewTopConstraint;
@property (nonatomic) CGFloat titleLabelCalculatedHeight;
@property (nonatomic) CGFloat descriptionLabelCalculatedHeight;

@end

@implementation PKRSSItemViewController
#define DETAILS_TEXT_OFFSET 8
#define SPACE_BETWEEN_LABELS 8


#pragma mark - lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _titleLabel.hidden = YES;
    _descriptionLabel.hidden = YES;

    NSURL *movieURL = [NSURL URLWithString:_currentRSSItemObject.videoURLString320];
    _moviePlayerController = [[MPMoviePlayerController alloc] initWithContentURL:movieURL];
    _moviePlayerController.shouldAutoplay = NO;

    _titleLabel.text = _currentRSSItemObject.title;
    _descriptionLabel.text = _currentRSSItemObject.descriptionString;
    
    //calcuate labels height
    _titleLabelCalculatedHeight =  [self calculateHeightOfLabel:_titleLabel];
    _descriptionLabelCalculatedHeight = [self calculateHeightOfLabel:_descriptionLabel];

    //update video top constraint if statusBar is hidden
    BOOL statusBarIsVisible = ![[UIApplication sharedApplication] isStatusBarHidden];
    if (!statusBarIsVisible)
    {
        CGFloat navBarHeight = self.navigationController.navigationBar.frame.size.height;
        _videoPlayerViewTopConstraint.constant = navBarHeight;
    }
    
    //set video date to navBar title
    if (_currentRSSItemObject.pubDate)
    {
        NSDateFormatter *dateFormatterForNavBar = [[NSDateFormatter alloc] init];
        [dateFormatterForNavBar setDateFormat:@"dd MMM yyyy"];
        [self.navigationItem setTitle:[dateFormatterForNavBar stringFromDate:_currentRSSItemObject.pubDate]];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //set constraints
    CGFloat topOffset = _videoPlayerViewTopConstraint.constant;
    _videoPlayerViewHeightConstraint.constant = (self.view.frame.size.height - topOffset)/2;
    _titleWidthConstraint.constant = self.view.frame.size.width - 2*DETAILS_TEXT_OFFSET;
    _titleHeightCOnstraint.constant = _titleLabelCalculatedHeight;
    _descriptionWidthConstraint.constant = self.view.frame.size.width - 2*DETAILS_TEXT_OFFSET;
    _descriptionHeightConstraint.constant = _descriptionLabelCalculatedHeight;
    [self.view setNeedsUpdateConstraints];
    
    //add video player
    [self.videoPlayerView addSubview:_moviePlayerController.view];
    [_moviePlayerController setFullscreen:NO];
    
    _titleLabel.hidden = NO;
    _descriptionLabel.hidden = NO;
    
}

- (void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    _moviePlayerController.view.frame = self.videoPlayerView.bounds;
    
    
    //set content size for description
    CGFloat contentHeight = [self calculateContentHeight];
    
    if (contentHeight)
    {
        [_detailsScrollView setContentSize:CGSizeMake(self.view.frame.size.width, contentHeight)];
    } else {
        [_detailsScrollView setContentSize:CGSizeMake(self.view.frame.size.width, _detailsScrollView.frame.size.height)];
    }
    
}

- (void)dealloc
{
    [_moviePlayerController stop];
}

#pragma mark - view methods
/*! calculate height of input label
 */
- (CGFloat) calculateHeightOfLabel:(UILabel *)inputLabel
{
    CGRect resultRect =  [inputLabel.text boundingRectWithSize:CGSizeMake(self.view.frame.size.width-2*DETAILS_TEXT_OFFSET, CGFLOAT_MAX)
                                                 options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                              attributes:@{
                                                           NSFontAttributeName : inputLabel.font
                                                           }
                                                 context:nil];
    return ceil(resultRect.size.height);
}

/*! calculate content height for scrollView with description
 */
- (CGFloat) calculateContentHeight
{
    CGFloat resultContentHeight = 0;
    
    if (_titleLabelCalculatedHeight)
    {
        resultContentHeight = resultContentHeight + _titleLabelCalculatedHeight;
    }
    if (_descriptionLabelCalculatedHeight)
    {
        resultContentHeight = resultContentHeight + _descriptionLabelCalculatedHeight;
    }
    
    if (resultContentHeight > 0)
    {
        resultContentHeight = resultContentHeight + 3*SPACE_BETWEEN_LABELS;
    }
    
    return resultContentHeight;
}

@end
