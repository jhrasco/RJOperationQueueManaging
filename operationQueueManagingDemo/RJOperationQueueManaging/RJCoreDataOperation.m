//
//  RJCoreDataOperation.m
//  LO2
//
//  Created by Ryan Jake on 8/12/13.
//
//

#import "RJCoreDataOperation.h"

#import "RJRequestConstants.h"

@interface RJCoreDataOperation ()

- (NSManagedObjectContext *)_createNewPrivateContextFromMainContext;

@property (nonatomic, strong) NSManagedObjectContext *mainContext;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation RJCoreDataOperation

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	self.persistentStoreCoordinator = nil;
	self.mainContext = nil;
}

- (id)initWithMainContext:(NSManagedObjectContext *)context shouldCallSaveInContextAfterExecution:(BOOL)shouldCallSaveInContextAfterExecution
{
	self = [super init];
	if (self) {
		_shouldCallSaveInContextAfterExecution = shouldCallSaveInContextAfterExecution;
		_mainContext = context;
		_persistentStoreCoordinator = context.persistentStoreCoordinator;
	}
	return self;
}

- (NSManagedObjectContext *)_createNewPrivateContextFromMainContext
{
	NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
	
    NSAssert(context != nil, @"Context in Core Data Operation not set");
    
	context.persistentStoreCoordinator = self.persistentStoreCoordinator;

    NSAssert(context.persistentStoreCoordinator != nil, @"Persistent Store Coordinator of context in Core Data Operation not set");

	return context;
}

- (void)operationWillBeginExecution:(RJOperation *)operation
{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(otherContextDidSave:)
												 name:NSManagedObjectContextDidSaveNotification
											   object:nil];
	
	[self coreDataOperationWillBeginExecution];
}

- (void)operationMain:(RJOperation *)operation
{
	NSManagedObjectContext *context = [self _createNewPrivateContextFromMainContext];
	
	[self coreDataOperationMain:context];

	if (self.shouldCallSaveInContextAfterExecution == YES) {
		
		NSError *error = nil;
		
		[context save:&error];
		
		if (error) {
			RJLOGINFO1(@"Error while doing a save in context");
		}
	}

}

- (void)coreDataOperationMain:(NSManagedObjectContext *)context
{
	
}

- (void)operationWillFinishExecution:(RJOperation *)operation
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	[self coreDataOperationWillFinishExecution];
}

- (void)operationWillCancelExecution:(RJOperation *)operation
{
	[self coreDataOperationWillCancelExecution];
}

- (void)otherContextDidSave:(NSNotification *)didSaveNotification
{
	NSManagedObjectContext *context = (NSManagedObjectContext *)didSaveNotification.object;
    
    if( context.persistentStoreCoordinator == self.persistentStoreCoordinator ) {
        [self.mainContext performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:)
                                        withObject:didSaveNotification
									 waitUntilDone:NO];
	}
}

- (void)coreDataOperationWillBeginExecution
{
	
}

- (void)coreDataOperationWillFinishExecution
{
	
}

- (void)coreDataOperationWillCancelExecution
{
	
}

- (void)insertObject:(NSManagedObject *)managedObject context:(NSManagedObjectContext *)context
{
	if (managedObject == nil) {
		RJLOGINFO1(@"ManagedObject is nil."); return;
	}
	
	[context insertObject:managedObject];
}

- (void)deleteObject:(NSManagedObject *)managedObject context:(NSManagedObjectContext *)context
{
	if (managedObject == nil) {
		RJLOGINFO1(@"ManagedObject is nil."); return;
	}
	
	[context deleteObject:managedObject];
}

@end
