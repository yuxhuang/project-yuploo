//
//  YuplooPhotoViewController.m
//  Yuploo
//
//  Created by Felix Huang on 22/02/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "YuplooPhotoViewController.h"
#import "YuplooMainWindowController.h"
#import "MUPhotoView.h"


@implementation YuplooPhotoViewController

@synthesize photos, selectionIndexes, photoArrayController, mainWindowController, photoView;

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
    
    // bindings
    [photoView bind:@"photosArray" toObject:photoArrayController withKeyPath:@"arrangedObjects" options:nil];
    [photoView bind:@"selectedPhotoIndexes" toObject:photoArrayController withKeyPath:@"selectionIndexes" options:nil];
    
    // set up default settings for photoview
    [photoView setUseOutlineBorder:YES];
    [photoView setUseBorderSelection:NO];
    [photoView setUseShadowBorder:YES];
    [photoView setUseShadowSelection:YES];
    [photoView setBackgroundColor:[NSColor whiteColor]];
    
}

@end
