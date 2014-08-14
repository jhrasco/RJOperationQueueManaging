//
//  RJRequestCommonData.h
//  myClasses
//
//  Created by Ryan Jake on 12/2/12.
//  Copyright (c) 2012 Ryan Jake. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RJRequestCommonData : NSObject

- (id)initWithData:(NSData *)data;
- (id)initWithPath:(NSString *)path;

- (NSString *)utf8String;
- (NSString *)asciiString;
- (NSString *)stringWithEncoding:(NSStringEncoding)encoding;

- (UIImage *)image;

- (NSArray *)arrayObject;
- (NSDictionary *)dictionaryObject;

- (BOOL)isValidString;
- (BOOL)isValidImage;
- (BOOL)isValidJPEG;
- (BOOL)isValidJSON;

- (void)clear;

@property (nonatomic, readonly, strong) NSData *data;
@property (nonatomic, readonly, strong) NSString *path;

@end
