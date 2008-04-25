//
//  PhotoAttribute.m
//  Yupload
//
//  Created by Felix Huang on 18/02/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Photo.h"

@implementation Photo

@synthesize path, nameForDownload, title, description, tags, public, contact, friend, family, useMultiPartStream;

- (id)initWithPath:(NSString *)file
{
    self = [super init];
    
    if (nil != self) {
        path = [file copy];
        self.title = @"";
        self.description = @"";
        self.tags = @"";
        nameForDownload = [[self.path lastPathComponent] copy];;
        useMultiPartStream = NO;
        self.public = YES;
        self.contact = NO;
        self.friend = NO;
        self.family = NO;
	}
	
	return self;
}

- (void)dealloc
{
	[path release];
	[nameForDownload release];
	[super dealloc];
}

- (NSData *)data
{
    return [NSData dataWithContentsOfFile:self.path];
}

// streaming!

- (void)useMultiPartStreamWithWorker:(id<YuplooWorker>)aWorker
{
    #warning TODO lack of implementation
}

- (WIMultiPartInputStream *)multiPartInputStream
{
    #warning TODO lack of implementation
    // FIXME
    return nil;
}

@end
