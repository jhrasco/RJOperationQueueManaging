//
//  RJOperationDebugTableCell.h
//  myClasses
//
//  Created by Ryan Jake on 6/20/13.
//  Copyright (c) 2013 Ryan Jake. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RJOperationDebugTableCell : UITableViewCell

+ (CGFloat)cellHeight;
+ (NSString *)cellID;

- (void)updateCell:(id)operationDebugging;

@property (nonatomic, strong) IBOutlet UILabel *operationQueueKeyLabel;
@property (nonatomic, strong) IBOutlet UILabel *operationKeyAndTag;
@property (nonatomic, strong) IBOutlet UILabel *operationStatus;
@property (nonatomic, strong) IBOutlet UILabel *timeElapsedLabel;

@end
