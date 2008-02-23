//
//  PhotoAttribute.m
//  Yupload
//
//  Created by Felix Huang on 18/02/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Photo.h"


@implementation Photo

@synthesize path, title, description, tags, public, contact, friend, family, image;

- (id)initWithContentsOfFile:(NSString *)file
{
    self = [super init];
    
    if (nil != self) {
        self.path = file;
        self.title = nil;
        self.description = nil;
        self.tags = nil;
        self.public = YES;
        self.contact = NO;
        self.friend = NO;
        self.family = NO;
        
        image = [[NSImage alloc] initWithContentsOfFile:path];
        
        if (nil == image) {
            [self dealloc];
            self = nil;
        }
    }

    return self;
}

- (void)dealloc
{
    [image release];
    [self.title release];
    [self.description release];
    [self.tags release];
    [super dealloc];
}

@end
