//
//  RJOperationQueueManager.m
//  myClasses
//
//  Created by Ryan Jake on 6/12/13.
//  Copyright (c) 2013 Ryan Jake. All rights reserved.
//

#import "RJOperationQueueManager.h"

#import "RJDebugViewController.h"

#import "RJOperationQueue.h"
#import "RJOperationGroup.h"
#import "RJSerialOperationQueue.h"
#import "RJOperationInfo.h"
#import "RJRequestConstants.h"


static RJOperationQueueManager *_instance = nil;

@interface RJOperationQueueManager ()

- (UIWindow *)_findVisibleWindow;
- (void)_addDebugButtonOnWindow:(UIWindow *)window;
- (void)_onPressShowDebugView:(id)sender;
- (void)_onReceiveMemoryWarning:(NSNotification *)notification;
- (void)_addOperationInfo:(RJOperationInfo *)operationInfo;

- (RJOperationQueue *)_defaultQueueWithType:(RJQueueType)queueType;
- (RJOperationQueue *)_defaultConcurrentQueue;
- (RJOperationQueue *)_defaultSerialQueue;
- (RJOperationQueue *)_operationQueueWithKey:(NSString *)requestQueueKey;
- (RJOperationQueue *)_createRequestQueueWithKey:(NSString *)operationQueueKey withQueueType:(RJQueueType)queueType;

@property (nonatomic, strong) NSMutableDictionary *	dictionaryQueue;

@property (nonatomic, strong) NSMutableArray *		arrayOperationInfo;

@end


@implementation RJOperationQueueManager

@synthesize dictionaryQueue =	_dictionaryQueue;
@synthesize arrayOperationInfo = _arrayOperationInfo;

+ (RJOperationQueueManager *)operationQueueManager
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_instance = [[self alloc] init];
	});
	return _instance;
}

- (void)initializeDebugWindow
{
	[self _addDebugButtonOnWindow:[self _findVisibleWindow]];
}

- (id)init
{
	self = [super init];
	if (self) {

		self.dictionaryQueue = [[NSMutableDictionary alloc] initWithCapacity:4];

#ifdef ENABLE_DEBUG_DISPLAY
		self.arrayOperationInfo = [[NSMutableArray alloc] initWithCapacity:10];
#endif
	
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_onReceiveMemoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
		
	}
	return self;
}

#pragma mark -
#pragma mark Private

- (void)_addOperationInfo:(RJOperationInfo *)operationInfo
{
	if (operationInfo != nil) {

		if ([self.arrayOperationInfo count] >= 100) {
			[self.arrayOperationInfo removeLastObject];
		}
		
		[self.arrayOperationInfo insertObject:operationInfo atIndex:0];
	}
	
	
}

- (void)_addDebugButtonOnWindow:(UIWindow *)window
{
#ifdef ENABLE_DEBUG_DISPLAY
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.frame = CGRectMake(0.0f, window.bounds.size.height - 50.0f, 50.0f, 50.0f);
	[button setTitle:@"" forState:UIControlStateNormal];
	[button addTarget:self action:@selector(_onPressShowDebugView:) forControlEvents:UIControlEventTouchUpInside];
	[window addSubview:button];
#endif
}

- (UIWindow *)_findVisibleWindow
{
	UIWindow *visibleWindow = nil;
	
	// if the rootViewController property (available >= iOS 4.0) of the main window is set, we present the modal view controller on top of the rootViewController

	NSArray *windows = [[UIApplication sharedApplication] windows];
	for (UIWindow *window in windows) {
		if (!window.hidden && !visibleWindow) {
			visibleWindow = window;
		}
		if ([UIWindow instancesRespondToSelector:@selector(rootViewController)]) {
			if ([window rootViewController]) {
				visibleWindow = window;
				RJLOGINFO1(@"UIWindow with rootViewController found: %@", visibleWindow);
				break;
			}
		}
	}
	
	if (visibleWindow == nil) {
		
		id <UIApplicationDelegate> delegate = [[UIApplication sharedApplication] delegate];
		
		return [delegate window];

	}
	
	return visibleWindow;
}

- (void)_onPressShowDebugView:(id)sender
{
	UIWindow *visibleWindow = [self _findVisibleWindow];
	UIViewController *rootViewController = [visibleWindow rootViewController];
	RJDebugViewController *controller = [[RJDebugViewController alloc] initWithNibName:@"RJDebugViewController" bundle:nil];
	controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
	[rootViewController presentViewController:navController animated:YES completion:^{}];
}

- (void)_onReceiveMemoryWarning:(NSNotification *)notification
{
	[self destroyAllIdleOperationQueues];
}

- (void)resumeOperationQueueWithKey:(NSString *)requestQueueKey
{
	NSOperationQueue *operationQueue = self.dictionaryQueue[requestQueueKey];
	[operationQueue setSuspended:NO];
}

- (void)resumeAllOperations
{
	NSDictionary *dictionaryQueue = [self.dictionaryQueue copy];
	for (NSString *key in dictionaryQueue) {
		RJOperationQueue *operationQueue = self.dictionaryQueue[key];
		[operationQueue setSuspended:NO];
	}
}

- (void)suspendOperationQueueWithKey:(NSString *)operationQueueKey
{
	RJOperationQueue *operationQueue = self.dictionaryQueue[operationQueueKey];
	[operationQueue setSuspended:YES];
}

- (void)suspendAllOperations
{
	NSDictionary *dictionaryQueue = [self.dictionaryQueue copy];
	for (NSString *key in dictionaryQueue) {
		RJOperationQueue *operationQueue = dictionaryQueue[key];
		[operationQueue setSuspended:YES];
	}
}

- (void)suspendAllOperationsExceptQueueWithKey:(NSString *)operationQueueKey
{
	NSDictionary *dictionaryQueue = [self.dictionaryQueue copy];
	for (NSString *key in dictionaryQueue) {
		if ([key isEqualToString:operationQueueKey]) {
			continue;
		}
		RJOperationQueue *operationQueue = dictionaryQueue[key];
		[operationQueue setSuspended:YES];
	}

}

- (void)abortOperationQueueWithKey:(NSString *)requestQueueKey
{
	RJOperationQueue *operationQueue = self.dictionaryQueue[requestQueueKey];
	[operationQueue cancelAllOperations];

	for (RJOperation *operation in [operationQueue operations]) {
		[operation abort];
	}

#ifdef ENABLE_DEBUG_DISPLAY
	for (RJOperation *operation in [operationQueue operations]) {
		[self.arrayOperationInfo removeObject:operation.operationInfo];
	}
#endif
	
}

- (void)abortAllOperations
{
	NSDictionary *dictionaryQueue = [self.dictionaryQueue copy];
	for (NSString *key in dictionaryQueue) {
		RJOperationQueue *operationQueue = dictionaryQueue[key];
		for (RJOperation *operation in [operationQueue operations]) {
			[operation abort];
		}
	}
}

- (void)cancelOperationQueueWithKey:(NSString *)requestQueueKey
{
	RJOperationQueue *operationQueue = self.dictionaryQueue[requestQueueKey];
	[operationQueue cancelAllOperations];
    
#ifdef ENABLE_DEBUG_DISPLAY
	for (RJOperation *operation in [operationQueue operations]) {
		[self.arrayOperationInfo removeObject:operation.operationInfo];
	}
#endif
}

- (void)cancelAllOperations
{
	NSDictionary *dictionaryQueue = [self.dictionaryQueue copy];
	for (NSString *key in dictionaryQueue) {
		RJOperationQueue *operationQueue = dictionaryQueue[key];
		[operationQueue cancelAllOperations];
	}
}

- (void)destroyOperationQueueWithKey:(NSString *)operationQueueKey
{
	RJOperationQueue *operationQueue = self.dictionaryQueue[operationQueueKey];
	[operationQueue cancelAllOperations];
    
#ifdef ENABLE_DEBUG_DISPLAY
	for (RJOperation *operation in [operationQueue operations]) {
		[self.arrayOperationInfo removeObject:operation.operationInfo];
	}
#endif
	[self.dictionaryQueue removeObjectForKey:operationQueueKey];
	operationQueue = nil;
}

- (void)destroyAllOperationQueues
{
	[self cancelAllOperations];
	
#ifdef ENABLE_RJLOGINFO1
	for (NSString *key in self.dictionaryQueue) {
		RJLOGINFO1(@"Destroying idle operationQueue with key: %@", self.dictionaryQueue[key]);
	}
#endif
	
	[self.dictionaryQueue removeAllObjects];

}

- (void)destroyAllIdleOperationQueues
{
	NSMutableArray *idleOperationQueues = [[NSMutableArray alloc] init];
	
	for (NSString *key in [self.dictionaryQueue copy]) {
		RJOperationQueue *operationQueue = self.dictionaryQueue[key];
		if ([[operationQueue operations] count] == 0) {
			[idleOperationQueues addObject:operationQueue];
		}
	}

	for (RJOperationQueue *operationQueue in idleOperationQueues) {
		[self.dictionaryQueue removeObjectForKey:operationQueue.operationQueueKey];
	}

	[idleOperationQueues removeAllObjects];
	idleOperationQueues = nil;
	
}

#pragma mark -
#pragma mark Queue Management

- (void)addOperation:(RJOperation *)operation
{
	[self _addOperation:operation toOperationQueue:[self _defaultConcurrentQueue]];
}

- (void)addOperation:(RJOperation *)operation
		withQueueKey:(NSString *)operationQueueKey
	   withQueueType:(RJQueueType)queueType
{
	RJOperationQueue *operationQueue = self.dictionaryQueue[operationQueueKey];
	
	if (operationQueue == nil) {
		operationQueue = [self _createRequestQueueWithKey:operationQueueKey withQueueType:queueType];
	}
	
	NSAssert(abs([operationQueue queueType]) == abs(queueType), @"operationQueue already exists with different queueType");
	
	[self _addOperation:operation toOperationQueue:operationQueue];
}

- (void)cancelOperationWithOperationKey:(NSString *)operationKey
{
	RJOperationQueue *operationQueue = [self _defaultConcurrentQueue];
	for (RJOperation *operation in operationQueue.operations) {
		if ([operation.operationQueueKey isEqualToString:operationKey]) {
			[operation cancel];
		}
	}
}

- (void)cancelOperationWithOperationKey:(NSString *)operationKey operationQueueKey:(NSString *)operationQueueKey queueType:(RJQueueType)queueType
{
	RJOperationQueue *operationQueue = self.dictionaryQueue[operationQueueKey];
	if (operationQueue == nil) {
		operationQueue = [self _createRequestQueueWithKey:operationQueueKey withQueueType:queueType];
	}
	for (RJOperation *operation in operationQueue.operations) {
		if ([operation.operationQueueKey isEqualToString:operationKey]) {
			[operation cancel];
		}
	}
}

- (void)_addOperation:(RJOperation *)operation toOperationQueue:(RJOperationQueue *)operationQueue
{
	operation.operationQueue = operationQueue;
	
	if ([operationQueue customAddOperation:operation]) {
		[self _addOperationInfo:operation.operationInfo];
	}
}

- (void)setMaxConcurrentCount:(NSInteger)maxConcurrentCount withOperationQueueKey:(NSString *)operationQueueKey
{
	RJOperationQueue *operationQueue = [self _operationQueueWithKey:operationQueueKey];
	
	NSAssert(operationQueue.queueType != RJQueueTypeSerial, @"Cannot set max concurrent count for serial queues");
	
	[operationQueue setMaxConcurrentOperationCount:maxConcurrentCount];
}

- (NSInteger)maxConcurrentCountWithOperationQueueKey:(NSString *)operationQueueKey
{
	RJOperationQueue *operationQueue = [self _operationQueueWithKey:operationQueueKey];
	
	return [operationQueue maxConcurrentOperationCount];
}

// *****************************************************************
// WORK IN PROGRESS
// *****************************************************************

- (void)setSupportsUniqueOperationKey:(BOOL)supportUniqueOperationKey
				withOperationQueueKey:(NSString *)operationQueueKey
{
	RJOperationQueue *operationQueue = [self _operationQueueWithKey:operationQueueKey];

	[operationQueue setSupportsUniqueOperationKey:supportUniqueOperationKey];

}

- (BOOL)supportsUniqueOperationKeyWithOperationQueueKey:(NSString *)operationQueueKey
{
	RJOperationQueue *operationQueue = [self _operationQueueWithKey:operationQueueKey];
	
	return [operationQueue supportsUniqueOperationKey];
}

- (BOOL)operationExistsOnOperationQueueWithKey:(NSString *)operationQueueKey withOperationKey:(NSString *)operationKey
{
	RJOperationQueue *operationQueue = [self _operationQueueWithKey:operationQueueKey];
	
    NSAssert(operationQueue.queueType == RJQueueTypeConcurrent, @"Checking of existence of a specific operation in a serial queue is not supported for now.");
    
	return [operationQueue operationExistsWithOperationKey:operationKey];
}

// *****************************************************************
// WORK IN PROGRESS
// *****************************************************************

- (void)setMaxOperationCount:(NSInteger)maxOperationCount withOperationOperationQueueKey:(NSString *)operationQueueKey
{
	RJOperationQueue *operationQueue = [self _operationQueueWithKey:operationQueueKey];

	operationQueue.maxOperationCount = maxOperationCount;
}

- (NSInteger)maxOperationCount:(NSInteger)maxOperationCount withOperationOperationQueueKey:(NSString *)operationQueueKey
{
	RJOperationQueue *operationQueue = [self _operationQueueWithKey:operationQueueKey];

	return operationQueue.maxOperationCount;
}

- (BOOL)operationQueueIsBusyWithKey:(NSString *)operationQueueKey
{
	RJOperationQueue *operationQueue = [self _operationQueueWithKey:operationQueueKey];

	if ([[operationQueue operations] count] > 0) {
		return YES;
	}
	
	return NO;
}

- (void)createOperationQueueWithKey:(NSString *)operationQueueKey withQueueType:(RJQueueType)queueType
{
	RJOperationQueue *operationQueue = self.dictionaryQueue[operationQueueKey];
	
	if (operationQueue == nil) {
		[self _createRequestQueueWithKey:operationQueueKey withQueueType:queueType];
	}
}

#pragma mark -
#pragma mark Create Queue

- (RJOperationQueue *)_defaultQueueWithType:(RJQueueType)queueType
{
	RJOperationQueue *operationQueue = nil;
    
    if (queueType == RJQueueTypeConcurrent) {
		operationQueue = [self _defaultConcurrentQueue];
	}
	else if (queueType == RJQueueTypeSerial) {
		operationQueue = [self _defaultSerialQueue];
	}
	return operationQueue;
}

- (RJOperationQueue *)_defaultConcurrentQueue
{
	RJOperationQueue *operationQueue = self.dictionaryQueue[RJOPERATION_DEFAULT_CONCURRENT_QUEUE];
	
	if (operationQueue == nil) {
		operationQueue = [self _createRequestQueueWithKey:RJOPERATION_DEFAULT_CONCURRENT_QUEUE withQueueType:RJQueueTypeConcurrent];
	}
	
	return operationQueue;
}

- (RJOperationQueue *)_defaultSerialQueue
{
	RJOperationQueue *operationQueue = self.dictionaryQueue[RJOPERATION_DEFAULT_SERIAL_QUEUE];
	
	if (operationQueue == nil) {
		operationQueue = [self _createRequestQueueWithKey:RJOPERATION_DEFAULT_SERIAL_QUEUE withQueueType:RJQueueTypeSerial];
	}
	
	return operationQueue;
}

- (RJOperationQueue *)_operationQueueWithKey:(NSString *)operationQueueKey
{
	RJOperationQueue *operationQueue = self.dictionaryQueue[operationQueueKey];
	
	if (operationQueue == nil) {
		operationQueue = [self _createRequestQueueWithKey:operationQueueKey withQueueType:RJQueueTypeConcurrent];
	}
	return operationQueue;
}

- (RJOperationQueue *)_createRequestQueueWithKey:(NSString *)operationQueueKey withQueueType:(RJQueueType)queueType
{
	RJOperationQueue *operationQueue = nil;

	if (queueType == RJQueueTypeDefault) {
		operationQueue = [self _defaultConcurrentQueue];
	}
	else if (queueType == RJQueueTypeConcurrent) {
		operationQueue = [[RJOperationQueue alloc] initWithOperationQueueKey:operationQueueKey];
	}
	else if (queueType == RJQueueTypeSerial) {
		operationQueue = [[RJSerialOperationQueue alloc] initWithOperationQueueKey:operationQueueKey];
	}

    self.dictionaryQueue[operationQueueKey] = operationQueue;
	
	return operationQueue;
}

- (NSArray *)allOperationInfos
{
//#ifndef ENABLE_DEBUG_DISPLAY
//	return nil;
//#endif
	return [NSArray arrayWithArray:self.arrayOperationInfo];
}

@end
