//
//  YupooResult.h
//  Yuploo
//
//  Created by Felix Huang on 22/02/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
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
}

@property(readonly) NSURLConnection *connection;
@property(readonly) long long expectedReceivedDataLength, receivedDataLength;
@property(readonly,getter=completed) BOOL _completed;
@property(readonly,getter=failed) BOOL _failed;
@property(readonly,getter=successful) BOOL _successful;
@property(readonly) NSString *status;
@property(readonly) YupooResultNode *rootNode;

+ (id)resultOfRequest:(NSURLRequest *)request inYupoo:(Yupoo *)aYupoo;

// connection
- (BOOL)completed;
- (BOOL)failed;
- (void)cancel;

// result status
- (BOOL)successful;
// element parsing methods
// first correspondence
- (NSString *)$:(NSString *)path;
// all attributes of the first correspondence
- (NSDictionary *)$A:(NSString *)path;

@end
