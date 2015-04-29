//
//  PKVideoListViewController.m
//  tedRSS
//
//  Created by Pavel on 24.04.15.
//  Copyright (c) 2015 Pavel. All rights reserved.
//

#import <AFNetworkReachabilityManager.h>
#import "PKVideoListViewController.h"
#import "PKRSSItemObject.h"
#import "PKRSSListCell.h"
#import "PKRSSItemViewController.h"

@interface PKVideoListViewController ()
@property (nonatomic, strong) NSXMLParser *parser;
@property (strong, nonatomic) NSDateFormatter *dateFormatterForPubDate;
@property (nonatomic, strong) PKRSSItemObject *currentRSSItem;
@property (nonatomic, strong) NSArray *rssItemsArray;
@property (nonatomic, strong) NSOperationQueue *thumbDownloadQueue;
@property (nonatomic) NSInteger selectedRowNumber;
@property (strong, nonatomic) UIImage *placeholderImage;
@end

#define VISIBLE_CELL_NUMBER 4
#define VISIBLE_CELL_NUMBER_PAD 10
#define CELL_IMAGE_HEIGHT 99
#define CELL_IMAGE_TOP_OFFSET 10

@implementation PKVideoListViewController {
    NSMutableString *title;
    NSMutableString *descriptionString;
    NSMutableString *pubDateString;
    NSString *currentElement;
}

static NSString *placeholderImageName = @"tedPlaceholder.jpg";
//static NSString *rssURLString = @"http://www.ted.com/themes/rss/id/6";
static NSString *rssURLString = @"http://feeds2.feedburner.com/tedtalks_video/";
static NSString *rssItemsCellIdentifier = @"rssItemsListCell2";

#pragma mark - lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    _rssItemsArray = [[NSArray alloc]init];
    _thumbDownloadQueue = [[NSOperationQueue alloc] init];
    _thumbDownloadQueue.maxConcurrentOperationCount = 1;
    _dateFormatterForPubDate = [[NSDateFormatter alloc] init];
    [_dateFormatterForPubDate setDateFormat:@"dd MMMM yyyy"];
    
    
    _rssTableView.hidden = YES;
    
    //checck avialibity
    [self configureInternetReachabilityManager];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    //TODO: release images on warning
}

#pragma mark - view methods

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    //TODO: add implementation when status bar hidden on rotate
}

#pragma mark - tableview delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_rssItemsArray count];
}

 - (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger visibleCellsNum;
    CGFloat navBarHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat statusBarHeight = 0;
    
    BOOL statusBarVisible = ![[UIApplication sharedApplication] isStatusBarHidden];
    
    if (statusBarVisible)
    {
        statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    }
    
    // calculate cell height
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        visibleCellsNum = VISIBLE_CELL_NUMBER_PAD;
    } else {
        visibleCellsNum = VISIBLE_CELL_NUMBER;
    }
    
    CGFloat cellHeight = (_rssTableView.frame.size.height - navBarHeight - statusBarHeight)/visibleCellsNum;
    
    if (cellHeight < CELL_IMAGE_HEIGHT + (CELL_IMAGE_TOP_OFFSET*2))
    {
        return CELL_IMAGE_HEIGHT+(CELL_IMAGE_TOP_OFFSET *2);
    }
    
    return cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PKRSSListCell *cell = [tableView dequeueReusableCellWithIdentifier:rssItemsCellIdentifier];
    PKRSSItemObject *rssItem = [_rssItemsArray objectAtIndex:indexPath.row];
    // set labels
    cell.titleLabel.text = rssItem.title;

    if (rssItem.pubDate)
    {
        cell.pubDateLabel.text = [_dateFormatterForPubDate stringFromDate:rssItem.pubDate];
    }
    
    //load thumbnails images
    if (rssItem.thumbImage)
    {
        cell.thumbImageView.image = rssItem.thumbImage;
    } else {
        cell.thumbImageView.image = [UIImage imageNamed:placeholderImageName];
        cell.thumbImageView.backgroundColor = [UIColor clearColor];
        [_thumbDownloadQueue addOperationWithBlock:^{
            NSURL *thumbImageURL = [NSURL URLWithString:rssItem.thumbURLString];
            NSData *thumbImageData = [[NSData alloc] initWithContentsOfURL:thumbImageURL];
            UIImage *imageToLoad = [[UIImage alloc] initWithData:thumbImageData];
            if (imageToLoad)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    rssItem.thumbImage = imageToLoad;
                    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                });
            }
        }];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedRowNumber = indexPath.row;
    [self performSegueWithIdentifier:@"showItemSegue" sender:self];
}

#pragma mark - rss xml parser methods

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    NSLog(@"%@",[parseError localizedDescription]);
}

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError
{
    NSLog(@"%@",[validationError localizedDescription]);
}

- (void) configureParser
{
    NSLog(@"%s start ",__PRETTY_FUNCTION__);
    NSURL *rssURL = [NSURL URLWithString:rssURLString];
    _parser = [[NSXMLParser alloc] initWithContentsOfURL:rssURL];
    [_parser setDelegate:self];
    [_parser setShouldResolveExternalEntities:NO];
    [_parser parse];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    currentElement = elementName;

    if ([elementName isEqualToString:@"item"])
    {
        //begin of rss item - init object
        _currentRSSItem = [[PKRSSItemObject alloc] init];
        title = [[NSMutableString alloc] init];
        descriptionString = [[NSMutableString alloc] init];
        pubDateString = [[NSMutableString alloc] init ];
    } else if ([currentElement isEqualToString:@"media:content"]){
        NSString *bitrate = [attributeDict valueForKey: @"bitrate"];
        if ([bitrate isEqualToString:@"320"])
        {
            _currentRSSItem.videoURLString320 = [attributeDict valueForKey:@"url"];
        } else if (!bitrate) {
            _currentRSSItem.videoURLString320 = [attributeDict valueForKey:@"url"];
        }
    } else if ([currentElement isEqualToString:@"media:thumbnail"]) {
        _currentRSSItem.thumbURLString = [attributeDict valueForKey:@"url"];
    }
    
}

 -(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if ([currentElement isEqualToString:@"title"])
    {
        [title appendString:string];
    } else if  ([currentElement isEqualToString:@"description"]) {
        [descriptionString appendString:string];
    } else if ([currentElement isEqualToString:@"pubDate"]) {
        [pubDateString appendString:string];
    }
    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"item"])
    {
        //end of rss item - set data to object
        _currentRSSItem.title = title;
        _currentRSSItem.descriptionString = descriptionString;
        _currentRSSItem.pubDateString = pubDateString;
        NSMutableArray *mutRSSItemsArray = [_rssItemsArray mutableCopy];
        [mutRSSItemsArray addObject:_currentRSSItem];
        _rssItemsArray = mutRSSItemsArray;
    } else if ([elementName isEqualToString:@"rss"]){
        NSLog(@"end of rss, count - %li",(long)_rssItemsArray.count);
        if (_rssItemsArray.count >0)
        {
            _rssTableView.delegate = self;
            _rssTableView.dataSource = self;
            //TODO: add lazy datasource update
            [_rssTableView reloadData];
        }

    }
}

#pragma mark - network methods 
/*! configure AFNetworkReachabilityManager to call configureParser only if network connection available
 */
- (void) configureInternetReachabilityManager
{
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status == AFNetworkReachabilityStatusNotReachable)
        {
            UIAlertView *noConnectionAlertView = [[UIAlertView alloc] initWithTitle:@"No Connection" message:@"Internet connection appears to be offline, try again later" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [noConnectionAlertView show];
        } else if (status == AFNetworkReachabilityStatusReachableViaWiFi || status == AFNetworkReachabilityStatusReachableViaWWAN){
            _rssTableView.hidden = NO;
            [self configureParser];
            [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
        }
    }];
}

#pragma mark - segue methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showItemSegue"])
    {
        PKRSSItemViewController *destinationViewController = segue.destinationViewController;
        destinationViewController.currentRSSItemObject = [_rssItemsArray objectAtIndex:_selectedRowNumber];
    }
}

@end
