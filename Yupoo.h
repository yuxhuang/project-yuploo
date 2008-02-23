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
    NSURL *restURL, *uploadURL, *authenticationURL;
}

@property(readonly,copy) NSString *apiKey, *secret, *authToken, *username, *userId, *frob, *nickname;
@property(readonly,copy) NSURL *restURL, *uplaodURL, *authenticationURL;

+ (id)yupooWithApiKey:(NSString *)anApiKey andSecret:(NSString *)aSecret;

- (id)initWithApiKey:(NSString *)anApiKey andSecret:(NSString *)aSecret;
- (id)connectRest:(NSURL *)aRestURL andUpload:(NSURL *)anUploadURL andAuthentication:(NSURL *)anAuthURL;

- (YupooResult *)authenticateWithToken:(NSString *)token;
- (NSURL *)authenticate;
- (YupooResult *)confirm;

- (YupooResult *)uploadPhoto:(Photo *)photo;

@end
