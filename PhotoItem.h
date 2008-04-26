//
//  PhotoItem.h
//  Yuploo
//
//  Created by Felix Huang on 24/04/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

@class Photo;

@interface PhotoItem : NSObject {
	NSString *path;
	Photo *photo;
}

@property(readonly) NSString *path;
@property(readonly) Photo *photo;
@property(assign) NSString *title;
@property(assign) NSString *description;
@property(assign) NSString *tags;
@property(assign) BOOL public, contact, friend, family;

- (id)initWithPath:(NSString *)aPath;

@end
