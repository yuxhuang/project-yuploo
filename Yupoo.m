//
//  Yupoo.m
//  Yuploo
//
//  Created by Felix Huang on 22/02/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Yupoo.h"

@interface Yupoo (PrivateAPI)
// build up URL and requests
- (NSURL *)URLWith:(NSURL *)aURL params:(NSDictionary *)params;
- (NSURLRequest *)getRequestWithURL:(NSString *)aURL params:(NSDictionary *)params timeoutInterval:(NSTimeInterval)timeout;
- (NSURLRequest *)uploadPhotoRequestWithURL:(NSString *)aURL params:(NSDictionary *)params photo:(Photo *)aPhoto timeoutInterval:(NSTimeInterval)timeout;

// send the request
- (YupooResult *)sendRequest:(NSURLRequest *)aRequest;

// convinience methods
- (NSDictionary *)paramsEncodedAndSigned:(NSDictionary *)oldParams;
- (YupooResult *)yupooResultWithXMLElement:(NSXMLElement *)doc;

@end

@implementation Yupoo

@end
