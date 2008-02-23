//
//  YupooResult.h
//  Yuploo
//
//  Created by Felix Huang on 22/02/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Yupoo;

@interface YupooResult : NSObject {
    NSURLConnection *connection;
    NSXMLElement *xmlElement;
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

+ (id)resultOfRequest:(NSURLRequest *)request inYupoo:(Yupoo *)aYupoo;

// connection
- (BOOL)completed;
- (BOOL)failed;
- (void)cancel;

// result status
- (BOOL)successful;
// element parsing methods
// the first matched text element
- (NSString *)$T:(NSString *)path;
// all matched text elements
- (NSArray *)$TT:(NSString *)path;
// the first matched attribute element
- (NSString *)$A:(NSString *)path;
// all matched attributes
- (NSArray *)$AA:(NSString *)path;


@end
