//
//  RJDebugViewController.m
//  myClasses
//
//  Created by Ryan Jake on 11/26/12.
//  Copyright (c) 2012 Ryan Jake. All rights reserved.
//

#import "RJDebugViewController.h"
#import "RJRequestConstants.h"

#import "RJRequestCategories.h"
#import "RJDebugViewController.h"
#import "RJRequestCommonData.h"
#import "RJDebugViewTypeInfo.h"
#import "RJDebugAllOperationsViewController.h"

static NSString *cellID_RJDebugQueueTableCell = @"cellID_RJDebugQueueTableCell";
static NSString *cellID_RJDebugSelectViewType = @"cellID_RJDebugSelectViewType";

@interface RJDebugViewController ()

- (void)onPressCancel:(id)sender;

@property (nonatomic, strong) NSArray *viewTypeDataSource;

@end

@implementation RJDebugViewController

@synthesize tableView = _tableView;
@synthesize viewTypeDataSource = _viewTypeDataSource;

- (void)dealloc
{

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

		NSMutableArray *arrayViewTypeDataSource = [[NSMutableArray alloc] initWithCapacity:3];

		RJDebugViewTypeInfo *viewTypeDataSouce = [[RJDebugViewTypeInfo alloc] initWithDebugViewType:RJDebugViewTypeAllOperations];
		viewTypeDataSouce.title = @"All operations";
		[arrayViewTypeDataSource addObject:viewTypeDataSouce];

		viewTypeDataSouce = [[RJDebugViewTypeInfo alloc] initWithDebugViewType:RJDebugViewTypeViewByOperationQueue];
		viewTypeDataSouce.title = @"View By Operation Queue";
		[arrayViewTypeDataSource addObject:viewTypeDataSouce];

		viewTypeDataSouce = [[RJDebugViewTypeInfo alloc] initWithDebugViewType:RJDebugViewTypeGroupByOperationQueue];
		viewTypeDataSouce.title = @"Group By Operation Queue";
		[arrayViewTypeDataSource addObject:viewTypeDataSouce];

		self.viewTypeDataSource = [NSArray arrayWithArray:arrayViewTypeDataSource];
		
		self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
																							  target:self
																							  action:@selector(onPressCancel:)];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	[self.tableView reloadData];
	[self.tableView setRowHeight:50.0f];
	[self.navigationController setNavigationBarHidden:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];

}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[self.tableView reloadData];
}

- (void)onPressCancel:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:^{
		
	}];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.viewTypeDataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID_RJDebugQueueTableCell];

	if (cell == nil) {

		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID_RJDebugSelectViewType];
		
		cell.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		
	}

	RJDebugViewTypeInfo *viewTypeInfo = [self.viewTypeDataSource objectAtIndex:indexPath.row];
	
	cell.textLabel.text = viewTypeInfo.title;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	RJDebugViewTypeInfo *viewTypeInfo = [self.viewTypeDataSource objectAtIndex:indexPath.row];

	UIViewController *controller = nil;
	
	if (viewTypeInfo.debugViewType == RJDebugViewTypeAllOperations) {

		controller = [[RJDebugAllOperationsViewController alloc] initWithNibName:nil bundle:nil];
		
	}
	else if (viewTypeInfo.debugViewType == RJDebugViewTypeViewByOperationQueue) {
		
	}
	else if (viewTypeInfo.debugViewType == RJDebugViewTypeGroupByOperationQueue) {
		
	}
	
	if (controller) {
		[self.navigationController pushViewController:controller animated:YES];
	}

}
#pragma mark -
#pragma mark Auto rotate methods

- (BOOL)shouldAutorotate
{
	return NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return NO;
}

@end
