//
//  IKBController.m
//  Yuploo
//
//  Created by Felix Huang on 24/04/08.
//  Copyright 2008 Two Fathoms Deep. All rights reserved.
//

#import "YuplooPhotoViewController.h"
#import "YuplooMainWindowController.h"
#import "YuplooAttributeEditor.h"
#import "PhotoItem.h"

@implementation YuplooPhotoViewController

@synthesize view, browserView, browserImages, dndLabel;

- (id)initWithMainWindowController:(YuplooMainWindowController *)controller
{
	self = [super init];
	
	if (nil != self) {
		mainWindowController = [controller retain];
		// allocate some space for the data source
		browserImages = [[NSMutableArray alloc] initWithCapacity:10];
		importedImages = [[NSMutableArray alloc] initWithCapacity:10];
	}
	
	return self;
}

- (void)dealloc
{
	[mainWindowController release];
	[browserImages release];
	[importedImages release];
	[super dealloc];
}

- (void)postUpdateNotification
{
    // post notificaiton
    [[NSNotificationCenter defaultCenter] postNotificationName:YUPLOO_NOTIFICATION_UPDATE_DATA_SOURCE
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                [NSNumber numberWithUnsignedInteger:browserImages.count], @"count"
                                                                , nil]];
}

- (void)updateDataSource
{
	[browserImages addObjectsFromArray:importedImages];
	[importedImages removeAllObjects];
	[browserView reloadData];
    [self postUpdateNotification];
}

- (void)loadNib
{
	[NSBundle loadNibNamed:@"PhotoView" owner:self];
	
	// fancy view
    browserView.animates = YES;
    browserView.allowsReordering = YES;
    browserView.canControlQuickLookPanel = YES;
	
	//Browser UI setup (can also be set in IB)
    browserView.delegate = self;
    browserView.dataSource = self;
    browserView.draggingDestinationDelegate = self;
    
    // change background
    [browserView setValue:[NSColor colorWithDeviceRed:0 green:0 blue:0 alpha:0] forKey:IKImageBrowserBackgroundColorKey];
//    NSColor *black = [NSColor redColor];
//    browserView.backgroundLayer.backgroundColor = CGColorCreateGenericRGB([black redComponent], [black greenComponent], [black blueComponent], [black alphaComponent]);
}

- (void)removeAllPhotos
{
	[browserImages removeAllObjects];
	[self updateDataSource];
}

- (void)removePhotos:(NSArray *)photos
{
	[photos retain];
	[browserImages removeObjectsInArray:photos];
	[self updateDataSource];
	[photos release];
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
	item = [[PhotoItem alloc] initWithPath:path];
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
#pragma mark IKImageBrowserDelegate

// change photo status
- (void)imageBrowserSelectionDidChange:(IKImageBrowserView *)aBrowser
{
	NSIndexSet * selection = [[browserView selectionIndexes] retain];
	if ([selection count] == 0) {
		mainWindowController.photoStatus = nil;
		[mainWindowController.attributeEditor endEditing];
	}
	else if ([selection count] == 1) {
		NSUInteger index = [selection firstIndex];
		PhotoItem *item = [[browserImages objectAtIndex:index] retain];
		mainWindowController.photoStatus = item.path;
		[mainWindowController.attributeEditor startEditing];
		[item release];
	}
	else {
		[mainWindowController.attributeEditor startEditing];
		mainWindowController.photoStatus = @"Multiple photos";
	}
}

#pragma mark -
#pragma mark IKImageBrowserDataSource

- (NSUInteger)numberOfItemsInImageBrowser:(IKImageBrowserView *)view
{
	return [browserImages count];
}

- (id)imageBrowser:(IKImageBrowserView *)view itemAtIndex:(NSUInteger) index
{
	return [browserImages objectAtIndex:index];
}

- (void) imageBrowser:(IKImageBrowserView *) view removeItemsAtIndexes: (NSIndexSet *) indexes
{
    [browserImages removeObjectsAtIndexes:indexes];
    [self postUpdateNotification];
}

- (BOOL) imageBrowser:(IKImageBrowserView *) view  moveItemsAtIndexes: (NSIndexSet *)indexes toIndex:(NSUInteger)destinationIndex
{
	NSUInteger index;
	NSMutableArray *temporaryArray;
	
	temporaryArray = [[NSMutableArray alloc] init];
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
    
    [temporaryArray release];
	
    [self postUpdateNotification];

	return YES;
}

#pragma mark - 
#pragma mark Browser Drag and Drop Methods
- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    return NSDragOperationCopy;
}

- (NSUInteger)draggingUpdated:(id <NSDraggingInfo>)sender
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
