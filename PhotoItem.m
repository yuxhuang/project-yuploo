//
//  PhotoItem.m
//  Yuploo
//
//  Created by Felix Huang on 24/04/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PhotoItem.h"
#import "Photo.h"

@implementation PhotoItem

@synthesize path, photo;

- (id)initWithPath:(NSString *)aPath {
	self = [super init];
	
	if (nil != self) {
		path = [aPath copy];
		photo = [[Photo alloc] initWithPath:path];
	}
	
	return self;
}

- (void)dealloc
{
	[path release];
	[photo release];
	[super dealloc];
}

- (NSString *)imageRepresentationType
{
	return IKImageBrowserPathRepresentationType;
}

- (id)imageRepresentation
{
	return self.path;
}

- (NSString *)imageUID
{
	return self.path;
}

@end
