//
//  YuplooMainWindowController
//  Yuploo
//
//  Created by Felix Huang on 21/02/08.
//  Copyright 2008 Two Fathoms Deep. All rights reserved.
//

#import "YuplooMainWindowController.h"
#import "YuplooLoginController.h"
#import "YuplooUploadController.h"
#import "YuplooPhotoViewController.h"
#import "YuplooController.h"
#import "YuplooAttributeEditor.h"
#import "YuplooPreferencePanelController.h"
#import "YuplooBackgroundView.h"

@implementation YuplooMainWindowController

@synthesize windowTitle, photoStatus, loginStatus, loginProgressValue, loginProgressHidden,
        ownerObjectController, targetScrollView, yupoo;

@dynamic loginController, uploadController, photoViewController, attributeEditor, preferenceController;

+ (id)mainWindowController
{
    return [[[self alloc] init] autorelease];
}

- (id)init
{
    self = [super initWithWindowNibName:@"MainWindow"];
    
    if (nil != self) {
        windowTitle = [[NSApp delegate] displayName];
        photoStatus = nil;
        loginStatus = nil;
        loginProgressValue = 0.0;
        loginProgressHidden = YES;
		
		loginController_ = nil;
		uploadController_ = nil;
		photoViewController_ = nil;
		attributeEditor_ = nil;
		preferenceController_ = nil;
        
    }

	
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

	[loginController_ autorelease];
	[uploadController_ autorelease];
	[photoViewController_ autorelease];
	[attributeEditor_ autorelease];
	[preferenceController_ autorelease];
    [super dealloc];
}

#pragma mark Window Delegate Methods

- (void)windowDidLoad
{
	// trigger the property to load the photo view
	self.photoViewController;
        
    yupoo = [[YuplooController sharedController] yupoo];

    targetScrollView.drawsBackground = NO;
    targetScrollView.hasVerticalScroller = YES;
    
    // register observer
    [[NSNotificationCenter defaultCenter] addObserverForName:YUPLOO_NOTIFICATION_UPDATE_DATA_SOURCE
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *notification)
     {
         NSDictionary *userInfo = notification.userInfo;
         if (nil != userInfo) {
             NSNumber *count = (NSNumber*) [userInfo objectForKey:@"count"];
             if ([count unsignedIntegerValue] > 0) {
                 backgroundView.drawsBackground = NO;
                 backgroundView.needsDisplay = YES;
             }
             else {
                 backgroundView.drawsBackground = YES;
                 backgroundView.needsDisplay = YES;
             }
         }
         
     }];
    
}

- (void)windowWillClose:(NSNotification *)notification
{
    [self.ownerObjectController setContent:nil];
    [NSApp terminate:self];
}

#pragma mark NIB-related Methods
- (void) awakeFromNib
{

}

#pragma mark Accessor Methods

- (YuplooLoginController *)loginController
{
	if (nil == loginController_) {
		loginController_ = [[YuplooLoginController alloc] initWithMainWindowController:self];
	}
	
	NSAssert(nil != loginController_, @"YuplooMainWindowController>-init: loginController cannot be nil.");
	
	return loginController_;
		
}

- (YuplooUploadController *)uploadController
{
	if (nil == uploadController_) {
		uploadController_ = [[YuplooUploadController alloc] initWithMainWindowController:self];
	}
	
	return uploadController_;
}

- (YuplooPhotoViewController *)photoViewController
{
	if (nil == photoViewController_) {
		photoViewController_ = [[YuplooPhotoViewController alloc] initWithMainWindowController:self];
		
		// add the photo view
		[photoViewController_ loadNib];
		[targetScrollView setDocumentView: photoViewController_.browserView];
		
		// make sure we have resized the photo view to match its 
		[photoViewController_.browserView setFrame:targetScrollView.bounds];
	}
	
	NSAssert(nil != photoViewController_, @"YuplooMainWindowController>-init: photoViewController cannot be nil.");
	
	return photoViewController_;
}

- (YuplooAttributeEditor *)attributeEditor
{
	if (nil == attributeEditor_) {
		attributeEditor_ = [[YuplooAttributeEditor alloc] initWithMainWindowController:self];
		// attribute editor
		[attributeEditor_ loadView];
	}
	
	NSAssert(nil != attributeEditor_, @"YuplooMainWindowController>-init: attributeEditor cannot be nil.");
	
	return attributeEditor_;
}

- (YuplooPreferencePanelController *)preferenceController
{
	if (nil == preferenceController_) {
		preferenceController_ = [[YuplooPreferencePanelController alloc] initWithMainWindowController:self];
	}
	return preferenceController_;
}

#pragma mark UI Actions

- (BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)userInterfaceItem
{
    SEL action = [userInterfaceItem action];
    
    if (action == @selector(login:)) {
        // check login status
        return YES;
    }
    else if (action == @selector(upload:)) {
        // check with upload status
        return YES;
    }
    else {
        return NO;
    }
}

- (IBAction)login:(id)sender
{
    [self.loginController login];
}

- (IBAction)upload:(id)sender
{
	// disable editing
	[self.attributeEditor endEditing];
	// start uploading
    [self.uploadController upload];
}

- (void)showLoginSheet
{
    [self.loginController showLoginSheet];
}

- (void)showUploadSheet
{

}


@end
