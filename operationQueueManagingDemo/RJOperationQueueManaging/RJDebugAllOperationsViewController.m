//
//  RJDebugAllOperationsViewController.m
//  myClasses
//
//  Created by Ryan Jake on 6/18/13.
//  Copyright (c) 2013 Ryan Jake. All rights reserved.
//

#import "RJDebugAllOperationsViewController.h"
#import "RJOperationQueueManager.h"

#import "RJOperationDebugging.h"
#import "RJOperationInfo.h"

#import "RJOperationDebugTableCell.h"
#import "RJRequestOperationDebugTableCell.h"

#import "RJRequestConstants.h"

@interface RJDebugAllOperationsViewController ()

- (void)_onOperationDidUpdate:(NSNotification *)notification;
- (void)_reloadTableWithRequestOperation:(RJOperation *)operation;

@end

@implementation RJDebugAllOperationsViewController

@synthesize tableView = _tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

#pragma mark -
#pragma mark View LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_onOperationDidUpdate:) name:RJOPERATION_DID_BEGIN_EXECUTING object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_onOperationDidUpdate:) name:RJOPERATION_DID_FINISH_EXECUTING object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_onOperationDidUpdate:) name:RJOPERATION_DID_CANCEL_EXECUTING object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_onOperationDidUpdate:) name:RJOPERATION_WILL_RETRY object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_onOperationDidUpdate:) name:RJOPERATION_DID_GIVE_UP object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_onOperationDidUpdate:) name:RJREQUEST_DID_PROGRESS object:nil];

}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [[[RJOperationQueueManager operationQueueManager] allOperationInfos] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

	NSArray *array = [[RJOperationQueueManager operationQueueManager] allOperationInfos];
	
	id<RJOperationDebugging> debuggableOperation = [array objectAtIndex:indexPath.row];
	
	Class debugTableCellClass;
	
	if ([debuggableOperation conformsToProtocol:@protocol(RJRequestOperationDebugging)]) {
		debugTableCellClass = [RJRequestOperationDebugTableCell class];
	}
	else {
		debugTableCellClass = [RJOperationDebugTableCell class];
	}

	return [debugTableCellClass cellHeight];
	
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	RJOperationDebugTableCell *debugTableCell = nil;
	
	NSArray *array = [[RJOperationQueueManager operationQueueManager] allOperationInfos];
	
	id<RJOperationDebugging> debuggableOperation = [array objectAtIndex:indexPath.row];

	Class debugTableCellClass;
	
	if ([debuggableOperation conformsToProtocol:@protocol(RJRequestOperationDebugging)]) {
		debugTableCellClass = [RJRequestOperationDebugTableCell class];
	}
	else {
		debugTableCellClass = [RJOperationDebugTableCell class];
	}

	debugTableCell = [tableView dequeueReusableCellWithIdentifier:[debugTableCellClass cellID]];

	if (debugTableCell == nil) {

		NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(debugTableCellClass)
																 owner:self
															   options:nil];
		
		debugTableCell = [topLevelObjects objectAtIndex:0];
		
		debugTableCell.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	}
	
	[debugTableCell updateCell:debuggableOperation];
	
	return debugTableCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//	NSArray *array = [[RJOperationQueueManager operationQueueManager] allOperationInfos];
//	
//	id<RJOperationDebugging> debuggableOperation = [array objectAtIndex:indexPath.row];
//	RJOperationInfo *operationInfo = debuggableOperation;
//
//	SPLOGINFO1(@"debuggableOperation : %@", debuggableOperation);
//	SPLOGINFO1(@"operation : %@", operationInfo.operation);
}

#pragma mark -
#pragma mark Private

- (void)_onOperationDidUpdate:(NSNotification *)notification
{
	NSDictionary *userInfo = [notification userInfo];
	
	RJOperation *operation = [userInfo objectForKey:RJREQUEST_USER_INFO_KEY];
	
	[self _reloadTableWithRequestOperation:operation];
}

- (void)_reloadTableWithRequestOperation:(RJOperation *)operation
{
	[self.tableView reloadData];
}


@end
