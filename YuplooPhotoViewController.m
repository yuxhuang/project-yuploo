//
//  YuplooPhotoViewController.m
//  Yuploo
//
//  Created by Felix Huang on 22/02/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "YuplooPhotoViewController.h"
#import "YuplooMainWindowController.h"
#import "Photo.h"

@implementation YuplooPhotoViewController

@synthesize photos, selectionIndexes, photoArrayController, photoView, mainWindowController;

- (id)initWithMainWindowController:(YuplooMainWindowController *)controller;
{
    self = [super initWithNibName:@"PhotoView" bundle:nil];
    
    if (nil != self) {
        photos = [NSMutableArray array];
        selectionIndexes = [NSMutableIndexSet indexSet];
    }
    
    mainWindowController = controller;
    self.view = nil;

    return self;
}

- (void)dealloc
{
    [photos release];
    [selectionIndexes release];
    [self.view release];
    [super dealloc];
}

#pragma mark -

- (void)loadNib
{
    [self loadView];
    
}

- (void)addPhotoWithContentsOfFile:(NSString *)path
{
    NSAssert(nil != path, @"YuplooPhotoViewController>-addPhotoWithContentsOfFile: path cannot be nil.");
    
    Photo *photo = [[[Photo alloc] initWithContentsOfFile:[[path copy] autorelease]] retain];
    [photos addObject:photo];
}

@end

@implementation PhotoBox

// do not allow any click against view parts
- (NSView *)hitTest:(id)sender
{
    return nil;
}

@end
