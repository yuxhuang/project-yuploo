//
//  YupooObserver.m
//  Yuploo
//
//  Created by Felix Huang on 25/02/08.
//  Copyright 2008 Two Fathoms Deep. All rights reserved.
//

#import "YupooObserver.h"
#import "YupooResult.h"

@implementation YupooObserver

@synthesize observer, keyPath;

- (id)initWithObserver:(id)anObserver keyPath:(NSString *)aKeyPath
{
	self = [super init];
	
	if (nil != self) {
		observer = [anObserver retain];
		keyPath = [aKeyPath copy];
	}
	
	return self;
}

- (void)dealloc
{
	[observer release];
	[keyPath release];
	[super dealloc];
}

@end
