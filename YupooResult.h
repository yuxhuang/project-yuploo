//
//  YupooResult.h
//  Yuploo
//
//  Created by Felix Huang on 22/02/08.
//  Copyright 2008 Two Fathoms Deep. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Yupoo;
@class YupooResultNode;

@interface YupooResult : NSObject {
    NSURLConnection *connection;
    NSXMLElement *xmlElement;
    YupooResultNode *rootNode;
    Yupoo *yupoo;
    
    // use internally
    NSMutableData *_receivedData;
    long long expectedReceivedDataLength;
    long long receivedDataLength;
    BOOL _completed;
    BOOL _failed;
    BOOL _successful;
    NSString *status;
	NSMutableArray *observers;
}

@property(retain) NSURLConnection *connection;
@property(readonly) long long expectedReceivedDataLength, receivedDataLength;
@property(readonly,getter=completed) BOOL _completed;
@property(readonly,getter=failed) BOOL _failed;
@property(readonly,getter=successful) BOOL _successful;
@property(retain) NSString *status;
@property(retain) YupooResultNode *rootNode;

+ (id)resultOfRequest:(NSURLRequest *)request inYupoo:(Yupoo *)aYupoo;

// connection
- (void)begin;
- (void)cancel;
- (void)observe:(NSObject *)anObserver forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context;
- (void)overlook:(NSString *)keyPath withObject:(id)anObject;
- (void)overlookAll;

// element parsing methods
// first correspondence
- (NSString *)$:(NSString *)path;
// all attributes of the first correspondence
- (NSDictionary *)$A:(NSString *)path;

@end

const static int YupooResultErrorCodeFailure = -1;

@interface YupooResult (Error)

- (NSInteger)errorCode;
- (NSString *)errorMessage;
- (NSString *)failureReason;

@end

@interface YupooResult (Authentication)

- (NSURL *)webAuthenticationURL;
- (NSString *)authFrob;
- (NSString *)authToken;
- (NSString *)authPerms;
- (NSString *)authUserId;
- (NSString *)authUserName;
- (NSString *)authNickName;

@end

