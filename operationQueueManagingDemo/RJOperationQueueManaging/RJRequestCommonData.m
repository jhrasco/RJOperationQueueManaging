//
//  RJRequestCommonData.m
//  myClasses
//
//  Created by Ryan Jake on 12/2/12.
//  Copyright (c) 2012 Ryan Jake. All rights reserved.
//

#import "RJRequestCommonData.h"
#import "RJRequestConstants.h"

@interface RJRequestCommonData ()

- (NSString *)_cleanHex:(NSString *)string;

// for optimizations, we cache the result.
@property (nonatomic, strong) UIImage *		tempImage;
@property (nonatomic, strong) NSString *	tempString;
@property (nonatomic, strong) NSDictionary *tempDictionary;
@property (nonatomic, strong) NSArray *		tempArray;

@end

@implementation RJRequestCommonData

@synthesize data =				_data;
@synthesize tempImage =			_tempImage;
@synthesize tempString =		_tempString;
@synthesize tempDictionary = 	_tempDictionary;
@synthesize tempArray =			_tempArray;

- (id)initWithData:(NSData *)data
{
	self = [super init];
	if (self) {
		_data = data;
	}
	return self;
}

- (id)initWithPath:(NSString *)path
{
	self = [super init];
	if (self) {

		_data = [NSData dataWithContentsOfFile:path];
		
		// for now let's just open the file here. And save it to the NSData.

	}
	return self;
}

#pragma mark -
#pragma mark String methods

- (NSString *)utf8String
{
	if (self.tempString != nil) {
		return self.tempString;
	}
	
	if ([self.data length] == 0) {
		return nil;
	}

	self.tempString = [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
	
	return self.tempString;
}

- (NSString *)asciiString
{
	if (self.tempString != nil) {
		return self.tempString;
	}

	if ([self.data length] == 0) {
		return nil;
	}

	self.tempString = [[NSString alloc] initWithData:self.data encoding:NSASCIIStringEncoding];
	
	return self.tempString;
}

- (NSString *)stringWithEncoding:(NSStringEncoding)encoding
{
	if (self.tempString != nil) {
		return self.tempString;
	}

	if ([self.data length] == 0) {
		return nil;
	}

	self.tempString = [[NSString alloc] initWithData:self.data encoding:encoding];
	
	return self.tempString;
}

#pragma mark -
#pragma mark - Image methods

- (UIImage *)image
{
	if (self.tempImage != nil) {
		return self.tempImage;
	}
	
	if ([self.data length] == 0) {
		return nil;
	}

	self.tempImage = [[UIImage alloc] initWithData:self.data];
	
	return self.tempImage;
}

#pragma mark -
#pragma mark JSON methods

- (NSDictionary *)dictionaryObject
{
	if (self.tempDictionary != nil) {
		return self.tempDictionary;
	}
	
	if ([self.data length] == 0) {
		return nil;
	}
	
	NSError *error = nil;
	
	self.tempDictionary = [NSJSONSerialization JSONObjectWithData:self.data options:0 error:&error];
    
	if (error) {
		RJLOGINFO1(@"There was an error parsing the dictionary object : %@", error);
	}
	
	if ([self.tempDictionary isKindOfClass:[NSDictionary class]] == NO) {
		return nil;
	}
	
	return self.tempDictionary;
}

- (NSArray *)arrayObject
{
	if (self.tempArray != nil) {
		return self.tempArray;
	}

	if ([self.data length] == 0) {
		return nil;
	}

	NSError *error = nil;
	
	self.tempArray = [NSJSONSerialization JSONObjectWithData:self.data options:0 error:&error];

	if (error) {
		RJLOGINFO1(@"There was an error parsing the dictionary object : %@", error);
	}
	
	if ([self.tempArray isKindOfClass:[NSArray class]] == NO) {
		return nil;
	}
	
	return self.tempArray;
}

#pragma mark -
#pragma mark Validation methods

- (BOOL)isValidString
{
	if ([[self stringWithEncoding:NSUTF8StringEncoding] length] > 0) {
		return YES;
	}
	return NO;
}

- (BOOL)isValidImage
{
	if ([self image]) {
		return YES;
	}
	return NO;
}

- (BOOL)isValidJPEG
{
	if ([self.data length] < 4) {
		return NO;
	}
	
	NSString *hex = [[self _cleanHex:[self.data description]] lowercaseString];
	NSInteger len = [hex length];
	
	if ([[hex substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"ff"] == NO) {
		return NO;
	}
	if ([[hex substringWithRange:NSMakeRange(2, 2)] isEqualToString:@"d8"] == NO) {
		return NO;
	}
	
	if ([[hex substringWithRange:NSMakeRange(len - 4, 2)] isEqualToString:@"ff"] == NO) {
		return NO;
	}
	if ([[hex substringWithRange:NSMakeRange(len - 2, 2)] isEqualToString:@"d9"] == NO) {
		return NO;
	}
	
	return YES;
}

- (BOOL)isValidJSON
{
	NSError *error = nil;
	
	id object = [NSJSONSerialization JSONObjectWithData:self.data options:0 error:&error];
	
	BOOL isValidJSON = [NSJSONSerialization isValidJSONObject:object];
	
	if ([object isKindOfClass:[NSDictionary class]]) {
		self.tempDictionary = (NSDictionary *)object;
	}
	else if ([object isKindOfClass:[NSArray class]]) {
		self.tempArray = (NSArray *)object;
	}
	
	return isValidJSON;
}

#pragma mark -
#pragma mark Other methods

- (void)clear
{
	self.tempString = nil;
	self.tempArray = nil;
	self.tempDictionary = nil;
	self.tempArray = nil;
}

#pragma mark -
#pragma mark Utility methods

- (NSString *)_cleanHex:(NSString *)string
{
	NSMutableString *hexString = [NSMutableString stringWithString:string];
	[hexString replaceOccurrencesOfString:@">" withString:@"" options:0 range:NSMakeRange(0, [hexString length])];
	[hexString replaceOccurrencesOfString:@"<" withString:@"" options:0 range:NSMakeRange(0, [hexString length])];
	[hexString replaceOccurrencesOfString:@" " withString:@"" options:0 range:NSMakeRange(0, [hexString length])];
	return hexString;
}

// TODO : add encryption

@end
