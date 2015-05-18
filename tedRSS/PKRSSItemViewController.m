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
#define IPHONE_LANDSCAPE_TOPOFFSET 32
#define IPHONE_PORTRAIT_TOPOFFSET 64

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
    
    CGFloat topOffset = [self.topLayoutGuide length];
    
    //set constraints
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
    
    CGFloat navBarHeight = [self.topLayoutGuide length];
    if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) && self.view.frame.size.width > self.view.frame.size.height)
    {
        //landscape
        _videoPlayerViewHeightConstraint.constant = (self.view.frame.size.height - navBarHeight);
    } else if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)) {
        //portrait
        _videoPlayerViewHeightConstraint.constant = (self.view.frame.size.height - navBarHeight)/2;
    }
    
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

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        CGFloat navBarHeight = [self.topLayoutGuide length];
        if (self.view.frame.size.width > self.view.frame.size.height)
        {
            //landscape
            if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
            {
                _videoPlayerViewHeightConstraint.constant = (self.view.frame.size.height - navBarHeight)/2;
                [UIView animateWithDuration:0.5 animations:^{
                    [self.view layoutIfNeeded];
                }];
            }
            
        } else {
            //portrait
            _videoPlayerViewHeightConstraint.constant = (self.view.frame.size.height - navBarHeight)/2;
            [UIView animateWithDuration:0.5 animations:^{
                [self.view layoutIfNeeded];
            }];
        }
        
        
    }];
    //handle iphone rotation to landscape - hide description, update player frame
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone && (size.width > size.height))
    {
        //iphone lanscape
        _titleWidthConstraint.constant = size.height - 2*DETAILS_TEXT_OFFSET;
        _descriptionWidthConstraint.constant = size.height - 2*DETAILS_TEXT_OFFSET;
        _titleHeightCOnstraint.constant = [self calculateHeightOfLabel:_titleLabel forWidth:size.height];
        _descriptionHeightConstraint.constant = [self calculateHeightOfLabel:_descriptionLabel forWidth:size.height];
        
    } else   if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone && (size.width < size.height)){
        //iphone portrait
        _titleWidthConstraint.constant = size.width - 2*DETAILS_TEXT_OFFSET;
        _descriptionWidthConstraint.constant = size.width - 2*DETAILS_TEXT_OFFSET;
        _titleHeightCOnstraint.constant = [self calculateHeightOfLabel:_titleLabel forWidth:size.width];
        _descriptionHeightConstraint.constant = [self calculateHeightOfLabel:_descriptionLabel forWidth:size.width];
    }
}

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

/*! calculate height of input label for inputWidth
 */
- (CGFloat) calculateHeightOfLabel:(UILabel *)inputLabel forWidth:(CGFloat)inputWidth
{
    CGRect resultRect =  [inputLabel.text boundingRectWithSize:CGSizeMake(inputWidth-2*DETAILS_TEXT_OFFSET, CGFLOAT_MAX)
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
