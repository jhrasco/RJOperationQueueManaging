//
//  RJTimeDelayOperation.h
//  LO2
//
//  Created by Ryan Jake on 7/29/13.
//
//

#import "RJSynchronousOperation.h"

@interface RJTimeDelayOperation : RJSynchronousOperation

- (id)initWithTimeInterval:(NSTimeInterval)timeInterval;

@property (nonatomic, readonly, assign) NSTimeInterval timeInterval;

@end
