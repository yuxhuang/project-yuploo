//
//  PhotoItem.m
//  Yuploo
//
//  Created by Felix Huang on 24/04/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PhotoItem.h"


@implementation PhotoItem

@synthesize path;

- (void)dealloc
{
	[path release];
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
