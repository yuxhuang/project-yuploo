//
//  PhotoAttribute.h
//  Yupload
//
//  Created by Felix Huang on 18/02/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Photo : NSObject {
    NSString *path;
    NSString *title;
    NSString *description;
    NSString *tags;
    NSImage *image;
    BOOL public;
    BOOL contact;
    BOOL friend;
    BOOL family;
}

@property(readwrite,copy) NSString *path, *title, *description, *tags;
@property(readonly) NSImage *image;
@property(readwrite,assign) BOOL public, contact, friend, family;

- (id)initWithContentsOfFile:(NSString *)file;

@end
