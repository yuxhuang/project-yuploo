//
//  PhotoAttribute.m
//  Yupload
//
//  Created by Felix Huang on 18/02/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Photo.h"


@implementation Photo

@synthesize path, nameForDownload, title, description, tags, public, contact, friend, family, image, useMultiPartStream;

- (id)initWithContentsOfFile:(NSString *)file
{
    self = [super init];
    
    if (nil != self) {
        path = file;
        self.title = nil;
        self.description = nil;
        self.tags = nil;
        nameForDownload = [self.path lastPathComponent];
        useMultiPartStream = NO;
        self.public = YES;
        self.contact = NO;
        self.friend = NO;
        self.family = NO;
        
        #warning FIXME this preview image should be resized!!!
        image = [[NSImage alloc] initWithContentsOfFile:path];
        
        if (nil == image) {
            [self dealloc];
            self = nil;
        }
    }

    return self;
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
