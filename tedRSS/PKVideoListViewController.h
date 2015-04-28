//
//  PKVideoListViewController.h
//  tedRSS
//
//  Created by Pavel on 24.04.15.
//  Copyright (c) 2015 Pavel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PKVideoListViewController : UIViewController <NSXMLParserDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *rssTableView;

@end
