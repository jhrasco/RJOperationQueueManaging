//
//  RJDebugAllOperationsViewController.h
//  myClasses
//
//  Created by Ryan Jake on 6/18/13.
//  Copyright (c) 2013 Ryan Jake. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RJDebugAllOperationsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end
