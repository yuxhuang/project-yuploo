//
//  PhotoItem.m
//  Yuploo
//
//  Created by Felix Huang on 24/04/08.
//  Copyright 2008 Two Fathoms Deep. All rights reserved.
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

@dynamic title, description, tags, public, contact, friend, family;

- (void)setTitle:(NSString *)title
{
	photo.title = title;
}

- (NSString *)title
{
	return photo.title;
}

- (void)setDescription:(NSString *)description
{
	photo.description = description;
}

- (NSString *)description
{
	return photo.description;
}

- (void)setTags:(NSString *)tags
{
	photo.tags = tags;
}

- (NSString *)tags
{
	return photo.tags;
}

- (void)setFamily:(BOOL)family
{
	photo.family = family;
}

- (BOOL)family
{
	return photo.family;
}

- (void)setPublic:(BOOL)public
{
	photo.public = public;
}

- (BOOL)public
{
	return photo.public;
}

- (void)setContact:(BOOL)contact
{
	photo.contact = contact;
}

- (BOOL)contact
{
	return photo.contact;
}

- (void)setFriend:(BOOL)friend
{
	photo.friend = friend;
}

- (BOOL)friend
{
	return photo.friend;
}

@end
