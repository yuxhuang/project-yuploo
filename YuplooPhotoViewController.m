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
	// register for drag and drop support
	[browserView registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
	
	// allocate some space for the data source
	browserImages = [[NSMutableArray alloc] initWithCapacity:10];
	importedImages = [[NSMutableArray alloc] initWithCapacity:10];
	
	// fancy view
	[browserView setAnimates:YES];
	
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
- (unsigned int)draggingEntered:(id <NSDraggingInfo>)sender
{
	
	if([sender draggingSource] != self){
		NSPasteboard *pb = [sender draggingPasteboard];
		NSString * type = [pb availableTypeFromArray:[NSArray arrayWithObject:NSFilenamesPboardType]];
		
		if(type != nil){
			return NSDragOperationEvery;
		}
	}
	return NSDragOperationNone;
}

- (unsigned int)draggingUpdated:(id <NSDraggingInfo>)sender
{
	return NSDragOperationEvery;
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
	return YES;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
	//Get the files from the drop
	NSArray * files = [[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType];
	
	[self addImagesWithPaths: files];
	
	if ([importedImages count] > 0)
		return YES;
	else
		return NO;
}

- (void)concludeDragOperation:(id < NSDraggingInfo >)sender
{
	[self updateDataSource];
}


@end
