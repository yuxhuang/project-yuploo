//
//  PhotoAttribute.m
//  Yupload
//
//  Created by Felix Huang on 18/02/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PhotoAttribute.h"


@implementation PhotoAttribute

@synthesize localPath, title, description, tags, isPublic, isContact, isFriend, isFamily;

-(id)init
{
    self = [super init];
    self.localPath = nil;
    self.title = nil;
    self.description = nil;
    self.tags = nil;
    self.isPublic = YES;
    self.isContact = NO;
    self.isFriend = NO;
    self.isFamily = NO;
    return self;
}

@end
