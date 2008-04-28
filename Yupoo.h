//
//  Yupoo.h
//  Yuploo
//
//  Created by Felix Huang on 22/02/08.
//  Copyright 2008 Two Fathoms Deep. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class YupooResult;
@class Photo;

@interface Yupoo : NSObject {
    NSString *apiKey, *secret, *authToken, *username, *userId, *nickname, *frob;
    NSString *restURL, *uploadURL, *authenticationURL;
    NSTimeInterval timeout;
}

@property(readonly,copy) NSString *apiKey, *authToken, *username, *userId, *nickname;
@property(readwrite) NSTimeInterval timeout;
@property(readonly,copy) NSString *restURL, *uploadURL, *authenticationURL;

- (id)initWithApiKey:(NSString *)anApiKey secret:(NSString *)aSecret;
- (id)connectRest:(NSString *)aRestURL upload:(NSString *)anUploadURL authentication:(NSString *)anAuthURL;

- (NSURL *)URLWith:(NSString *)aURL params:(NSDictionary *)params;
- (NSDictionary *)paramsEncodedAndSigned:(NSDictionary *)oldParams;

// authentication
- (YupooResult *)authenticateWithToken:(NSString *)token;
- (YupooResult *)initiateAuthentication; // to get frob
- (YupooResult *)completeAuthentication:(NSString *)frob;

- (YupooResult *)uploadPhoto:(Photo *)photo;

@end
