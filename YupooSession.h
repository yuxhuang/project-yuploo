//
//  YupooSession.h
//  Yuploo
//
//  Created by Felix Huang on 22/02/08.
//  Copyright 2008 Two Fathoms Deep. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Yupoo;
@class YupooResultNode;
@class GDataHTTPFetcher;

@interface YupooSession : NSObject {
    NSURLConnection *connection;
    NSXMLElement *xmlElement;
    YupooResultNode *rootNode;
    Yupoo *yupoo;
    
    // use internally
    BOOL _completed;
    BOOL _failed;
    BOOL _successful;
    NSString *status;
	NSMutableArray *observers;
	
	// GData related
	GDataHTTPFetcher *fetcher_;
	unsigned long long deliveredBytes; // for KVC
	unsigned long long totalBytes; // for KVC
	
	// monitor
	id monitorDelegate_;
	SEL monitorSelector_;
}

@property(readonly,getter=completed) BOOL _completed;
@property(readonly,getter=failed) BOOL _failed;
@property(readonly,getter=successful) BOOL _successful;
@property(retain) NSString *status;
@property(retain) YupooResultNode *rootNode;

@property(readonly) unsigned long long deliveredBytes, totalBytes;

+ (id)resultOfRequest:(NSURLRequest *)request inYupoo:(Yupoo *)aYupoo;

// new fetcher connection
- (id)initWithRequest:(NSURLRequest *)request
				yupoo:(Yupoo *)aYupoo;

- (id)initWithRequest:(NSURLRequest *)request
				yupoo:(Yupoo *)aYupoo
		 uploadStream:(NSInputStream *)input
			   length:(unsigned long long)length;

// session oriented
- (BOOL)begin;
- (void)cancel;
// the selector should have a deliveredBytes:(unsigned long long)delivered ofTotalBytes:(unsigned long long)totalBytes
- (void)setMonitor:(id)delegate selector:(SEL)selector; // not retained

// observer related
- (void)observe:(NSObject *)anObserver forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context;
- (void)overlook:(NSString *)keyPath withObject:(id)anObject;
- (void)overlookAll;

// element parsing methods
// first correspondence
- (NSString *)$:(NSString *)path;
// all attributes of the first correspondence
- (NSDictionary *)$A:(NSString *)path;

@end

const static int YupooSessionErrorCodeFailure = -1;

@interface YupooSession(Error)

- (NSInteger)errorCode;
- (NSString *)errorMessage;
- (NSString *)failureReason;

@end

@interface YupooSession(Authentication)

- (NSURL *)webAuthenticationURL;
- (NSString *)authFrob;
- (NSString *)authToken;
- (NSString *)authPerms;
- (NSString *)authUserId;
- (NSString *)authUserName;
- (NSString *)authNickName;

@end

