//
//  IKBController.m
//  Yuploo
//
//  Created by Felix Huang on 24/04/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "YuplooPhotoViewController.h"
#import "PhotoItem.h"

@implementation YuplooPhotoViewController

@synthesize browserView, browserImages;

- (void)awakeFromNib
{
	// allocate some space for the data source
	browserImages = [[NSMutableArray alloc] initWithCapacity:10];
	importedImages = [[NSMutableArray alloc] initWithCapacity:10];
	
	// fancy view
	[browserView setAnimates:YES];
	[browserView setAllowsReordering:YES];
	
	//Browser UI setup (can also be set in IB)
	[browserView setDelegate:self];
	[browserView setDataSource:self];
	[browserView setDraggingDestinationDelegate:self];
}

- (void)dealloc
{
	[browserImages release];
	[importedImages release];
	[super dealloc];
}

- (void)updateDataSource
{
	[browserImages addObjectsFromArray:importedImages];
	[importedImages removeAllObjects];
	[browserView reloadData];
}

- (int)numberOfItemsInImageBrowser:(IKImageBrowserView *)view
{
	return [browserImages count];
}

- (id)imageBrowser:(IKImageBrowserView *)view itemAtIndex:(int) index
{
	return [browserImages objectAtIndex:index];
}

- (void)addAnImageWithPath:(NSString *)path
{
	PhotoItem *item;
	item = [[PhotoItem alloc] init];
	item.path = path;
	[importedImages addObject:item];
	[item release];
}

- (void)addImagesWithPath:(NSString *)path recursive:(BOOL)recursive
{
	BOOL dir;
	[[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&dir];
	
	if (dir) {
		NSArray *content = [[NSFileManager defaultManager] directoryContentsAtPath:path];
		for (NSString *p in content) {
			if (recursive) {
				[self addImagesWithPath: [path stringByAppendingPathComponent:p] recursive:recursive];
			}
			else {
				[self addAnImageWithPath: [path stringByAppendingPathComponent:p]];
			}
		}
	}
	else {
		[self addAnImageWithPath: path];
	}
}

- (void)addImagesWithPaths:(NSArray *)paths
{
	[paths retain];
	
	for (NSString *path in paths) {
		[self addImagesWithPath:path recursive:NO];
	}
	
	[paths release];
}

#pragma mark - 
#pragma mark Browser Drag and Drop Methods
- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    return NSDragOperationCopy;
}

- (unsigned int)draggingUpdated:(id <NSDraggingInfo>)sender
{
	return NSDragOperationEvery;
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
	return YES;
}

- (BOOL) performDragOperation:(id <NSDraggingInfo>)sender
{
    NSData *data = nil;
    NSString *errorDescription;
    NSPasteboard *pasteboard = [sender draggingPasteboard];
	
    if ([[pasteboard types] containsObject:NSFilenamesPboardType])
        data = [pasteboard dataForType:NSFilenamesPboardType];
    if(data){
        NSArray *filenames = [NSPropertyListSerialization
							  propertyListFromData:data
							  mutabilityOption:kCFPropertyListImmutable
							  format:nil
							  errorDescription:&errorDescription];
        int i;
        int n = [filenames count];
        for(i=0; i<n; i++){
            [self addImagesWithPath:[filenames objectAtIndex:i] recursive:NO];
        }
        [self updateDataSource];
    }
	
    return YES;
}


@end
