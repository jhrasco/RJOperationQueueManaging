//
//  RJOperationDebugTableCell.m
//  myClasses
//
//  Created by Ryan Jake on 6/20/13.
//  Copyright (c) 2013 Ryan Jake. All rights reserved.
//

#import "RJOperationDebugTableCell.h"
#import "RJOperationDebugging.h"

@implementation RJOperationDebugTableCell

@synthesize operationQueueKeyLabel = _operationQueueKeyLabel;
@synthesize operationKeyAndTag = _operationKeyAndTag;
@synthesize operationStatus = _operationStatus;
@synthesize timeElapsedLabel = _timeElapsedLabel;

+ (CGFloat)cellHeight
{
	return 48.0f;
}

+ (NSString *)cellID
{
	return @"cellID_RJOperationDebugTableCell";
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)updateCell:(id)operationDebugging
{
	id <RJOperationDebugging> debuggable = operationDebugging;
	self.operationQueueKeyLabel.text = [debuggable debugOperationQueueKey];
	self.operationKeyAndTag.text = [NSString stringWithFormat:@"%@ : %d", [debuggable debugOperationKey], [debuggable debugOperationTag]];
	self.operationStatus.text = [debuggable debugOperationState];
	self.timeElapsedLabel.text = [NSString stringWithFormat:@"%.2f", [debuggable debugSecondsElapsed]];
}

@end
