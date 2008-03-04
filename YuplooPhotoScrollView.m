//
//  YuplooPhotoScrollView.m
//  Yuploo
//
//  Created by Felix Huang on 03/03/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "YuplooPhotoScrollView.h"
#import "YuplooPhotoViewController.h"


@implementation YuplooPhotoScrollView

@synthesize photoViewController;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.

    }
    return self;
}

- (void)awakeFromNib
{
    // drag and drop support
    [self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
}

- (void)drawRect:(NSRect)rect {
    // Drawing code here.
}

#pragma mark Drag and Drop Methods

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    NSPasteboard *pboard;
    NSDragOperation sourceDragMask;
    
    // determine the dragging operation
    sourceDragMask = [sender draggingSourceOperationMask];
    pboard = [sender draggingPasteboard];
    
    if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {

        // set background color when something acceptable is moving in
        [self setBackgroundColor:[NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha:0.5]];
    
        if (sourceDragMask & NSDragOperationCopy) {
            return NSDragOperationCopy;
        }
        else if (sourceDragMask & NSDragOperationLink) {
            return NSDragOperationLink;
        }
    }
    
    return NSDragOperationNone;
}

- (void)draggingEnded:(id <NSDraggingInfo>)sender
{
    // reset the original background color
    [self setBackgroundColor:[NSColor whiteColor]];
}

- (void)draggingExited:(id <NSDraggingInfo>)sender
{
    // reset the original background color
    [self setBackgroundColor:[NSColor whiteColor]];
}

// prepare for the operation, if it is not an image, don't accept it
- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
    NSPasteboard *pboard;
    NSArray *fileList;
    
    pboard = [sender draggingPasteboard];
    // check available pboard type
    if ( ![NSFilenamesPboardType isEqualTo:[pboard availableTypeFromArray:
            [NSArray arrayWithObjects:NSFilenamesPboardType, nil]]] )
        return NO;
    
    // check if files are of supported image types
    fileList = [pboard propertyListForType:NSFilenamesPboardType];
    
    for (NSString *path in fileList) {
        // check image
        NSImage *image = [[NSImage alloc] initWithContentsOfFile:path];
        if (nil == image) {
            return NO;
        }
        // destroy it
        [image release];
    }
    
    return YES;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    NSPasteboard *pboard;
    NSArray *files;
    
    pboard = [sender draggingPasteboard];
    // get the file list
    files = [pboard propertyListForType:NSFilenamesPboardType];

    // add the photos
    for (NSString *file in files) {
        [photoViewController addPhotoWithContentsOfFile:file];
        [[NSGarbageCollector defaultCollector] collectExhaustively];
    }
    
    [[photoViewController photoView] setNeedsDisplay:YES];

    return YES;
}

- (BOOL)concludeDragOperation:(id <NSDraggingInfo>)sender
{
    // reset the original background color
    [self setBackgroundColor:[NSColor whiteColor]];
    return YES;
}

@end
