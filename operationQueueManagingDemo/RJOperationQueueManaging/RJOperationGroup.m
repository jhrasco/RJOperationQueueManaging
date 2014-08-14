//
//  RJOperationGroup.m
//  LO2
//
//  Created by Ryan Jake on 7/14/13.
//
//

#import "RJOperationGroup.h"

@interface RJInternalReferenceHolderOperation : RJSynchronousOperation

@property (nonatomic, strong) RJOperationGroup *operationGroupReference;

@end

@implementation RJInternalReferenceHolderOperation

@end

@interface RJOperationGroup ()

@property (nonatomic, strong) NSMutableArray *internalOperations;
@property (nonatomic, strong) RJInternalReferenceHolderOperation *internalCompletionHandler;

@property (nonatomic, copy) NSString *tempOperationQueueKey;
@property (nonatomic, assign) RJQueueType tempQueueType;

@property (nonatomic, assign) BOOL isAborted;

- (void)setIsRunning:(BOOL)isRunning;

@end

@implementation RJOperationGroup

@synthesize operationQueueKey = _operationQueueKey;
@synthesize queueType = _queueType;
@synthesize completionHandler = _completionHandler;
@synthesize operationGroupKey = _operationGroupKey;

@synthesize internalOperations = _internalOperations;

- (id)init
{
	self = [super init];
	if (self) {

		self.internalOperations = [[NSMutableArray alloc] init];
		_operationQueueKey = nil;
		_queueType = RJQueueTypeDefault;
		
		_tempOperationQueueKey = nil;
		_tempQueueType = RJQueueTypeDefault;
	}
	return self;
}

- (NSArray *)operations
{
	return [NSArray arrayWithArray:self.internalOperations];
}

- (void)addOperation:(RJOperation *)operation
{
	[self.internalOperations addObject:operation];
	
	operation.operationGroup = self;
	
}

- (void)clearAllOperations
{
	[self.internalOperations removeAllObjects];
}

- (void)setupOperations
{
	NSAssert(NO, @"%@ must be overriden by subclass.", NSStringFromSelector(_cmd));
}

- (void)runOperationGroupWithOperationQueueKey:(NSString *)operationQueueKey withQueueType:(RJQueueType)queueType
{
	self.tempOperationQueueKey = operationQueueKey;
	self.tempQueueType = queueType;

	[self runOperationGroup];
	
	self.tempOperationQueueKey = nil;
	self.tempQueueType = -1;
	
}

- (void)runOperationGroup
{
	if (self.shouldBlockWhenRunning == YES && self.isRunning == YES) {
		RJLOGINFO1(@"An instance of this group is running."); return;
	}
	
	[self clearAllOperations];
	[self setupOperations];

	if ([self.internalOperations count] == 0) {
		return;
	}

	_isRunning = YES;
    _isAborted = NO;
	
	if (self.completionHandler == nil || [self.completionHandler.operationKey isEqualToString:@"RJ_OPERATION_GROUP_DEFAULT_COMPLETION_HANDLER"]) {
		self.completionHandler = [[RJSynchronousOperation alloc] init];
		self.completionHandler.operationKey = @"RJ_OPERATION_GROUP_DEFAULT_COMPLETION_HANDLER";
		self.completionHandler.operationGroup = self;
	}
	
	__weak __block RJOperationGroup *tempSelf = self;
	
	self.internalCompletionHandler = [[RJInternalReferenceHolderOperation alloc] init];
	self.internalCompletionHandler.operationGroup = self;
	self.internalCompletionHandler.operationGroupReference = self;
	[self.internalCompletionHandler setOperationCompletionBlock:^(RJOperation *operation) {
		[tempSelf setIsRunning:NO];
		RJ_BLOCK_DISPATCH(tempSelf.completionBlock, tempSelf);
		if (tempSelf.shouldRunAgain == YES) {
			[tempSelf runOperationGroup];
			tempSelf.shouldRunAgain = NO;
		}
	}];
	[self.internalCompletionHandler setOperationCancelBlock:^(RJOperation *operation) {
		[tempSelf setIsRunning:NO];
	}];
	
	NSString *operationQueueKey = self.tempOperationQueueKey ? self.tempOperationQueueKey : self.operationQueueKey;
    
	RJQueueType queueType = self.tempQueueType != RJQueueTypeDefault ? self.tempQueueType : self.queueType;
	
	RJOperationQueueManager *operationQueueManager = [RJOperationQueueManager operationQueueManager];
	
	if (operationQueueKey == nil || queueType == RJQueueTypeDefault) {
		for (RJOperation *operation in self.internalOperations) {
			[self.completionHandler addDependency:operation];
			[operationQueueManager addOperation:operation];
		}
		self.completionHandler.operationGroup = self;
		[operationQueueManager addOperation:self.completionHandler];

		[self.internalCompletionHandler addDependency:self.completionHandler];
		[operationQueueManager addOperation:self.internalCompletionHandler];

	}
	else {
		for (RJOperation *operation in self.internalOperations) {
			[self.completionHandler addDependency:operation];
			[operationQueueManager addOperation:operation withQueueKey:operationQueueKey withQueueType:queueType];
		}
		self.completionHandler.operationGroup = self;
		[operationQueueManager addOperation:self.completionHandler withQueueKey:operationQueueKey withQueueType:queueType];

		[self.internalCompletionHandler addDependency:self.completionHandler];
		[operationQueueManager addOperation:self.internalCompletionHandler withQueueKey:operationQueueKey withQueueType:queueType];
	}
	
}

- (void)acknowledgeSuccessOperationGroup
{
	RJ_BLOCK_DISPATCH(self.successBlock, self);
}

- (void)cancelOperationGroup
{
	for (RJOperation *operation in self.internalOperations) {
		[operation cancel];
	}
	[self.internalOperations removeAllObjects];

	[self.completionHandler cancel];
	self.completionHandler = nil;
	
	[self.internalCompletionHandler cancel];
	self.internalCompletionHandler = nil;
	
	_isRunning = NO;
	
	RJ_BLOCK_DISPATCH(self.cancelBlock, self);
}

- (void)abortOperationGroup
{
	if (self.isAborted == YES) {
		return;
	}
	
	self.isAborted = YES;
	
	for (RJOperation *tempOperation in self.internalOperations) {
		[tempOperation abort];
	}
	[self.internalOperations removeAllObjects];
	RJ_BLOCK_DISPATCH(self.abortBlock,self);
}

- (void)setOperationQueueKey:(NSString *)operationQueueKey queueType:(RJQueueType)queueType
{
	_operationQueueKey = [operationQueueKey copy];
	_queueType = queueType;
}

- (void)setIsRunning:(BOOL)isRunning
{
	_isRunning = isRunning;
}

- (void)setSuccessBlock:(void (^)(RJOperationGroup*operation))successBlock
{
	_successBlock = successBlock;
}

- (void)setCancelBlock:(void (^)(RJOperationGroup*operation))cancelBlock
{
	_cancelBlock = cancelBlock;
}

- (void)setAbortBlock:(void (^)(RJOperationGroup*operation))abortBlock
{
	_abortBlock = abortBlock;
}

- (void)setCompletionBlock:(void (^)(RJOperationGroup*operation))completionBlock
{
	_completionBlock = completionBlock;
}


@end
