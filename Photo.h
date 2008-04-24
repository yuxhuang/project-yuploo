//
//  PhotoAttribute.h
//  Yupload
//
//  Created by Felix Huang on 18/02/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol YuplooWorker;
@class WIMultiPartInputStream;

@interface Photo : NSObject {
    NSString *path;
    NSString *nameForDownload;
    NSString *title;
    NSString *description;
    NSString *tags;
    BOOL useMultiPartStream;
    BOOL public;
    BOOL contact;
    BOOL friend;
    BOOL family;
}

@property(readwrite,copy) NSString *title, *description, *tags;
@property(readonly) NSString *path, *nameForDownload;
@property(readwrite) BOOL public, contact, friend, family;
@property(readonly) BOOL useMultiPartStream;

- (id)initWithPath:(NSString *)file;

// the data of image
- (NSData *)data;

// streaming input
- (void)useMultiPartStreamWithWorker:(id<YuplooWorker>)aWorker;
- (WIMultiPartInputStream *)multiPartInputStream;

@end
