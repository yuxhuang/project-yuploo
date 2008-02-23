//
//  YupooResult.m
//  Yuploo
//
//  Created by Felix Huang on 22/02/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "YupooResult.h"

@interface YupooResult (PrivateAPI)

// private initialization
- (id)initWithYupoo:(Yupoo *)aYupoo;
- (void)bindConnection:(NSURLConnection *)aConnection;

// xml loading
- (NSXMLElement *)loadXMLElementWithData:(NSData *)data;

@end

@implementation YupooResult

@synthesize connection, expectedReceivedDataLength, receivedDataLength, _completed, _failed, _successful, status;

+ (id)resultOfRequest:(NSURLRequest *)request inYupoo:(Yupoo *)aYupoo
{
    // initiate the result first
    YupooResult *result = [[YupooResult alloc] initWithYupoo:aYupoo];
    
    // sorry, i have no idea about it.
    if (nil == result)
        return nil;
    
    // create the connection
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:result startImmediately:NO];
    // binds back the connection
    [result bindConnection:connection];
    // start the connection then.
    [connection start];
    return [result autorelease];
}

- (void)dealloc
{
    [xmlElement release];
    [connection release];
    [yupoo release];
    [super dealloc];
}

#pragma mark Connection Methods

// the connection is totally completed. (but it does not mean the transaction is successful.
// connection is completed.
// to determine whether the result is useful, first test completed, then failed, finally successful
- (void)cancel
{
    @synchronized(self) {
        [connection cancel];
    }
}

#pragma mark Result Analyze Methods

// this result has stat=ok
- (BOOL) isSuccessful
{
    // FIXME
    return _successful;
}

- (NSString *)$T:(NSString *)path
{
    return nil;
}

- (NSArray *)$TT:(NSString *)path
{
    return nil;
}

- (NSString *)$A:(NSString *)path
{
    return nil;
}

- (NSArray *)$AA:(NSString *)path
{
    return nil;
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)conn didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    // just go straight to delegate
}

- (void)connection:(NSURLConnection *)conn didReceiveAuthentcationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    // just go straight to delegate
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)conn willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    // just go straight to delegate
    return cachedResponse;
}

- (NSURLRequest *)connection:(NSURLConnection *)conn willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse
{
    // just go straight to delegate
    return request;
}

- (void)connection:(NSURLConnection *)conn didReceiveResponse:(NSURLResponse *)response
{
    // deal with response information, initialize lengths
    [self willChangeValueForKey:@"receivedDataLength"];
    receivedDataLength = 0;
    [self didChangeValueForKey:@"receivedDataLength"];
    
    [self willChangeValueForKey:@"expectedReceivedDataLength"];
    expectedReceivedDataLength = [response expectedContentLength];
    if (NSURLResponseUnknownLength == expectedReceivedDataLength)
        expectedReceivedDataLength = 0;
    [self didChangeValueForKey:@"expectedReceivedDataLength"];
    
    [self willChangeValueForKey:@"status"];
    status = @"Loading";
    [self didChangeValueForKey:@"status"];

    // initiate data
    _receivedData = [NSMutableData data];
    [_receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)data
{
    // we have received more, add to the length
    [self willChangeValueForKey:@"receivedDataLength"];
    receivedDataLength += [data length];
    [self didChangeValueForKey:@"receivedDataLength"];
    
    // append data
    [_receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error
{
    // gosh! we have a failed connection
    // release the connection
    [conn release];
    // release the received data
    [_receivedData release];
    
    [self willChangeValueForKey:@"failed"];
    _failed = YES;
    [self willChangeValueForKey:@"failed"];
    
    // log the error
    [self willChangeValueForKey:@"status"];
    status = [NSString stringWithFormat:@"Connection failed! %@ %@", [error localizedDescription],
            [[error userInfo] objectForKey:NSErrorFailingURLStringKey]];
    [self didChangeValueForKey:@"status"];

    NSLog(status);
    
    // we have changed these values
    [self willChangeValueForKey:@"completed"];
    _completed = YES;
    [self didChangeValueForKey:@"completed"];
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)conn
{
    // release the connection
    [conn release];
    
    // transform received data into xml
    xmlElement = [self loadXMLElementWithData:_receivedData];
    // it should be autoreleased.
//    [_receivedData release];

    // failed to parse. Malformed XML?
    if (nil == xmlElement) {
        [self willChangeValueForKey:@"failed"];
        _failed = YES;
        [self didChangeValueForKey:@"failed"];
        return;
    }
    
    // ok, go ahead with xml
    NSString *stat = [self $A:@"/rsp:stat"];
    if ([stat isEqual:@"ok"]) {
        [self willChangeValueForKey:@"status"];
        status = @"Done";
        [self didChangeValueForKey:@"status"];

        [self willChangeValueForKey:@"successful"];
        _successful = YES;
        [self didChangeValueForKey:@"successful"];
    }
    else {
        [self willChangeValueForKey:@"status"];
        status = [NSString stringWithFormat:@"Failed! %@",
                [self $A:@"/rsp/err:msg"]];
        [self didChangeValueForKey:@"status"];
        
        [self willChangeValueForKey:@"successful"];
        _successful = NO;
        [self willChangeValueForKey:@"successful"];
    }

    // we have changed these values.
    // make sure completed comes at the very last.
    [self willChangeValueForKey:@"completed"];
    _completed = YES;
    [self didChangeValueForKey:@"completed"];
    
}

@end

@implementation YupooResult (PrivateAPI)

- (id)initWithYupoo:(Yupoo *)aYupoo
{
    self = [super init];
    
    if (nil != self) {
        _receivedData = nil;
        expectedReceivedDataLength = 0;
        receivedDataLength = 0;
        _completed = NO;
        _failed = NO;
        _successful = NO;
        
        status = @"Waiting";
        
        xmlElement = nil;
        yupoo = [aYupoo retain];
        connection = nil;
    }
    
    return self;
}

- (void)bindConnection:(NSURLConnection *)conn
{
    connection = [conn retain];
}

- (NSXMLElement *)loadXMLElementWithData:(NSData *)data
{
    NSError *error = nil;
    NSXMLDocument *doc = [[NSXMLDocument alloc] initWithData:data options:NSXMLDocumentTidyXML error:&error];
    
    // xml loading error
    if (nil == doc) {
        [self willChangeValueForKey:@"status"];
        status = [NSString stringWithFormat:@"XML Error: %@", [error localizedDescription]];
        [self didChangeValueForKey:@"status"];
        NSLog(status);
        return nil;
    }

    // correct, then go ahead
    NSXMLElement *rootElement = [doc rootElement];
    [doc release];
    
    return [[rootElement retain] autorelease];
}

@end