//
//  IKBController.m
//  Yuploo
//
//  Created by Felix Huang on 24/04/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "YuplooPhotoViewController.h"
#import "YuplooMainWindowController.h"
#import "PhotoItem.h"

@implementation YuplooPhotoViewController

@synthesize view, browserView, browserImages;

- (id)initWithMainWindowController:(YuplooMainWindowController *)mainWindowController
{
	self = [super init];
	
	if (nil != self) {
		// allocate some space for the data source
		browserImages = [[NSMutableArray alloc] initWithCapacity:10];
		importedImages = [[NSMutableArray alloc] initWithCapacity:10];

	}
	
	return self;
}

- (void)loadNib
{
	[NSBundle loadNibNamed:@"PhotoView" owner:self];
	
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


- (void)addAnImageWithPath:(NSString *)path
{
	// check the path conforms to an image first
	NSError *error;
	NSString *type = [[NSWorkspace sharedWorkspace] typeOfFile:path error:&error];
	if (type == nil) {
		// no uti is found for this file
		return;
	}
	// we only support jpeg and png
	if (![[NSWorkspace sharedWorkspace] type:type conformsToType:(NSString *)kUTTypeJPEG] &&
		![[NSWorkspace sharedWorkspace] type:type conformsToType:(NSString *)kUTTypePNG]) {
		return;
	}
					  
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
#pragma mark IKImageBrowserDataSource

- (int)numberOfItemsInImageBrowser:(IKImageBrowserView *)view
{
	return [browserImages count];
}

- (id)imageBrowser:(IKImageBrowserView *)view itemAtIndex:(int) index
{
	return [browserImages objectAtIndex:index];
}

- (void) imageBrowser:(IKImageBrowserView *) view removeItemsAtIndexes: (NSIndexSet *) indexes
{
    [browserImages removeObjectsAtIndexes:indexes];
}

- (BOOL) imageBrowser:(IKImageBrowserView *) view  moveItemsAtIndexes: (NSIndexSet *)indexes toIndex:(unsigned int)destinationIndex
{
	int index;
	NSMutableArray *temporaryArray;
	
	temporaryArray = [[[NSMutableArray alloc] init] autorelease];
	for(index=[indexes lastIndex]; index != NSNotFound;
		index = [indexes indexLessThanIndex:index])
	{
		if (index < destinationIndex)
			destinationIndex --;
		
		id obj = [browserImages objectAtIndex:index];
		[temporaryArray addObject:obj];
		[browserImages removeObjectAtIndex:index];
	}
	
	// Insert at the new destination
	int n = [temporaryArray count];
	for(index=0; index < n; index++){
		[browserImages insertObject:[temporaryArray objectAtIndex:index]
					  atIndex:destinationIndex];
	}
	
	return YES;
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
