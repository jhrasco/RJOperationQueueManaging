//
//  RJDebugViewController.h
//  myClasses
//
//  Created by Ryan Jake on 11/26/12.
//  Copyright (c) 2012 Ryan Jake. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RJDebugViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end
