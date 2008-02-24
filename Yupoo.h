//
//  Yupoo.h
//  Yuploo
//
//  Created by Felix Huang on 22/02/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class YupooResult;
@class Photo;

@interface Yupoo : NSObject {
    NSString *apiKey, *secret, *authToken, *username, *userId, *frob, *nickname;
    NSString *restURL, *uploadURL, *authenticationURL;
    NSTimeInterval timeout;
}

@property(readonly,copy) NSString *authToken, *username, *userId, *nickname;
@property(readwrite) NSTimeInterval timeout;
//@property(readonly,copy) NSURL *restURL, *uplaodURL, *authenticationURL;

+ (id)yupooWithApiKey:(NSString *)anApiKey secret:(NSString *)aSecret;

- (id)initWithApiKey:(NSString *)anApiKey secret:(NSString *)aSecret;
- (id)connectRest:(NSString *)aRestURL upload:(NSString *)anUploadURL authentication:(NSString *)anAuthURL;

- (YupooResult *)authenticateWithToken:(NSString *)token;
- (NSURL *)authenticate;
- (YupooResult *)confirm;

- (YupooResult *)uploadPhoto:(Photo *)photo;

@end
