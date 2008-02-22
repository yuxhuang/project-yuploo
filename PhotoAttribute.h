//
//  PhotoAttribute.h
//  Yupload
//
//  Created by Felix Huang on 18/02/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PhotoAttribute : NSObject {
    NSString *localPath;
    NSString *title;
    NSString *description;
    NSString *tags;
    BOOL isPublic;
    BOOL isContact;
    BOOL isFriend;
    BOOL isFamily;
}

@property(readwrite,assign) NSString *localPath, *title, *description, *tags;
@property(readwrite,assign) BOOL isPublic, isContact, isFriend, isFamily;

@end
