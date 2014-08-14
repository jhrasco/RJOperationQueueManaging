//
//  RJCoreDataOperation.h
//  LO2
//
//  Created by Ryan Jake on 8/12/13.
//
//

#import "RJAsynchronousOperation.h"
#import <CoreData/CoreData.h>

/*
 - This class is intended for asynchronous execution in core data.
 - When using this class, do not use the default operationWillXXExecution methods.
 - Instead, use the coreDataOperationXXExecution methods.
 - Perform the core data query/saving in coreDataOperationMain: and use only the context passed by that method.
 - coreDataOperationMain: is asynchronous, so do not access other objects in that method (like singletons) that can cause threading issues.
 
 - Utility methods and category methods that reuses objects inside cannot be used as well. (Unless documented as thread safe, but that could slow down the process)
 - Rewrite that method instead, and allocate a new instance to avoid threading issues.

 - When performing a loop inside coreDataOperationMain: make sure to check self.isCancelled every cycle.
 - Call return if you see self.isCancelled to prevent unnecessary CPU process consumption, like this:
 
 if (self.isCancelled) {
	return;
 }
 
 DO NOT USE OR ACCESS THE MAIN CONTEXT OR THE PERSISTENT STORE COORDINATOR FROM coreDataOperationMain:
 NO NEED TO CALL SAVE IF YOU HAVE THE PARAMETER shouldCallSaveInContextAfterExecution set to YES.
 
 */


@interface RJCoreDataOperation : RJAsynchronousOperation

- (id)initWithMainContext:(NSManagedObjectContext *)context shouldCallSaveInContextAfterExecution:(BOOL)shouldCallSaveInContextAfterExecution;

- (void)coreDataOperationWillBeginExecution;
- (void)coreDataOperationMain:(NSManagedObjectContext *)context;
- (void)coreDataOperationWillFinishExecution;
- (void)coreDataOperationWillCancelExecution;

- (void)insertObject:(NSManagedObject *)managedObject context:(NSManagedObjectContext *)context;
- (void)deleteObject:(NSManagedObject *)managedObject context:(NSManagedObjectContext *)context;


@property (nonatomic, assign) BOOL shouldCallSaveInContextAfterExecution;

@end
