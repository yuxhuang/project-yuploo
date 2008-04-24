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
        nameForDownload = [[self.path lastPathComponent] copy];;
        useMultiPartStream = NO;
        self.public = YES;
        self.contact = NO;
        self.friend = NO;
        self.family = NO;
        
        #warning XXX deal with memory consuming problem of NSImage here!
        
        // generate the full size image in a zone
        NSImage *fullSizeImage = [[NSImage alloc] initWithContentsOfFile:path];
        [fullSizeImage setCacheMode:NSImageCacheNever];
        
        // calculate the new image size
        NSSize fullSize;
        NSImageRep *fullSizeRep = [fullSizeImage bestRepresentationForDevice:nil];
        
        fullSize.width = [fullSizeRep pixelsWide];
        fullSize.height = [fullSizeRep pixelsHigh];
        
        // resize the image
        [image setScalesWhenResized:YES];
        [image setSize:fullSize];
        
        // resize to create a smaller photo
        CGFloat smallPhotoSize = 100.0;
        CGFloat longSide = [fullSizeRep pixelsWide] < [fullSizeRep pixelsHigh] ? [fullSizeRep pixelsHigh]
                : [fullSizeRep pixelsWide];
        CGFloat scale = smallPhotoSize / longSide;
        
        NSSize smallSize;
        smallSize.width = [fullSizeRep pixelsWide] * scale;
        smallSize.height = [fullSizeRep pixelsHigh] * scale;
        
        // draw a small size image
        NSImage *smallImage = [[NSImage alloc] initWithSize:smallSize];
        [smallImage lockFocus];
        [fullSizeRep drawInRect:NSMakeRect(0.0, 0.0, smallSize.width, smallSize.height)];
        [smallImage unlockFocus];
        
        // reset the image
        image = smallImage;
        
        // tell the garbage collector to collect things
        [fullSizeImage removeRepresentation:fullSizeRep];
        [fullSizeImage release];
        
        if (nil == image) {
            [self dealloc];
            self = nil;
        }
    }

    return self;
}

- (void)dealloc {
	[nameForDownload release];
	[image release];
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
