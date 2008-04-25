//
//  YupooResult.m
//  Yuploo
//
//  Created by Felix Huang on 22/02/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "YupooResult.h"
#import "YupooResultNode.h"
#import "Yupoo.h"

@interface YupooResult (PrivateAPI)

// private initialization
- (id)initWithYupoo:(Yupoo *)aYupoo;
- (void)bindConnection:(NSURLConnection *)aConnection;

// xml loading
- (NSXMLElement *)loadXMLElementWithData:(NSData *)data;

@end

@implementation YupooResult

@synthesize connection, expectedReceivedDataLength, receivedDataLength, _completed, _failed, _successful, status, rootNode;

+ (id)resultOfRequest:(NSURLRequest *)request inYupoo:(Yupoo *)aYupoo
{
    // initiate the result first
    YupooResult *result = [[[YupooResult alloc] initWithYupoo:aYupoo] autorelease];
    
    // sorry, i have no idea about it.
    if (nil == result)
        return nil;
    
    // create the connection
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:result startImmediately:YES];
    // binds back the connection
    [result bindConnection:connection];

    return result;
}

#pragma mark Connection Methods

- (void)begin
{
//    [connection start];
}

// the connection is totally completed. (but it does not mean the transaction is successful.
// connection is completed.
// to determine whether the result is useful, first test completed, then failed, finally successful
- (void)cancel
{
    @synchronized(self) {
        [connection cancel];
    }
}

- (void)observe:(NSString *)keyPath withObject:(id)anObject
{
    [self addObserver:anObject forKeyPath:keyPath
            options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:nil];
}

- (void)overlook:(NSString *)keyPath withObject:(id)anObject
{
    [self removeObserver:anObject forKeyPath:keyPath];
}

#pragma mark Result Analyze Methods

// this result has stat=ok
- (BOOL) isSuccessful
{
    return _successful;
}

- (NSString *)$:(NSString *)path
{
    return [rootNode $:path];
}

- (NSDictionary *)$A:(NSString *)path
{
    return [rootNode $A:path];
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
	[response retain];
    // deal with response information, initialize lengths
    [self setValue:[NSNumber numberWithInt:[response expectedContentLength]] forKey:@"receivedDataLength"];
    if (NSURLResponseUnknownLength == expectedReceivedDataLength)
        [self setValue:[NSNumber numberWithInt:0] forKey:@"receivedDataLength"];
    
    [self setValue:@"Loading" forKey:@"status"];

    // initiate data
    _receivedData = [[NSMutableData alloc] init];
    [_receivedData setLength:0];
	[response release];
}

- (void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)data
{
	[data retain];
    // we have received more, add to the length
    [self setValue:[NSNumber numberWithInt:(receivedDataLength + [data length])] forKey:@"receivedDataLength"];
    
    // append data
    [_receivedData appendData:data];
	
	[data release];
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error
{
    // gosh! we have a failed connection
    // release the connection
    [connection release];
    // release the received data
    [_receivedData release];
    
    [self setValue:[NSNumber numberWithBool:YES] forKey:@"failed"];
    
    // log the error
    [self setValue:[NSString stringWithFormat:@"Connection failed! %@ %@", [error localizedDescription],
            [[error userInfo] objectForKey:NSErrorFailingURLStringKey]] forKey:@"status"];

    NSLog(status);
    
    // we have changed these values
    [self setValue:[NSNumber numberWithBool:YES] forKey:@"completed"];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)conn
{
    // release the connection
    [connection release];
    
    // transform received data into xml
    xmlElement = [self loadXMLElementWithData:_receivedData];
    rootNode = [[YupooResultNode alloc] initWithXMLElement:xmlElement];
    // set it to nil. so let the garbage collector frees it.
    [_receivedData release];

    // failed to parse. Malformed XML?
    if (nil == xmlElement) {
        [self setValue:[NSNumber numberWithBool:YES] forKey:@"failed"];
        return;
    }
    
    // ok, go ahead with xml
    NSString *stat = [self $:@".:stat"];
    if (nil == stat) {
        // deal with error first
    }
    else if ([stat isEqual:@"ok"]) {
        [self setValue:@"Done" forKey:@"status"];
        [self setValue:[NSNumber numberWithBool:YES] forKey:@"successful"];
    }
    else {
        [self willChangeValueForKey:@"status"];
        status = [NSString stringWithFormat:@"Failed! %@",
                [self $:@"err:msg"]];
        if (nil == status) {
            status = @"XML Error";
        }
        [self didChangeValueForKey:@"status"];
        
        [self setValue:[NSNumber numberWithBool:NO] forKey:@"successful"];
    }
    // we have changed these values.
    // make sure completed comes at the very last.
    [self setValue:[NSNumber numberWithBool:YES] forKey:@"completed"];
}

- (void)dealloc {
	// clear root node
	[rootNode release];
	[yupoo release];
	[super dealloc];
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
    NSXMLElement *rootElement = [[[doc rootElement] retain] autorelease];
    
	[doc release];
    return rootElement;
}


@end

@implementation YupooResult (Error)

- (NSInteger)errorCode
{
    NSString *error = [self $:@"err:code"];
    
    if (nil == error) {
        return YupooResultErrorCodeFailure;
    }
    
    NSInteger code = 0xdeadbeef;
    // deal with wrong representation with NSScanner
    NSScanner *scanner = [NSScanner scannerWithString:error];
    
    if (![scanner scanInteger:&code])
        return YupooResultErrorCodeFailure;
    
    return code;   
}

- (NSString *)errorMessage
{
    NSString *msg = [self $:@"err:msg"];

    return msg; // will be nil if msg is not found.
}

- (NSString *)failureReason
{
    NSString *reason = [self $:@"err"];

    if (nil == reason || [[reason stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqual:@""])
        return nil;

    return reason; // should be nil if err has no reason.
}

@end

@implementation YupooResult (Authentication)

- (NSURL *)webAuthenticationURL
{
    if (!self.successful)
        return nil;
        
    NSString *frob = [self $:@"frob"];
    
    if (nil == frob)
        return nil;

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params setObject:frob forKey:@"frob"];
    [params setObject:@"write" forKey:@"perms"];
    [params setObject:yupoo.apiKey forKey:@"api_key"];
    
    NSDictionary *signedParams = [yupoo paramsEncodedAndSigned:params];
    
    return [yupoo URLWith:yupoo.authenticationURL params:signedParams];
}

- (NSString *)authFrob
{
    if (!self.successful)
        return nil;
    
    return [self $:@"frob"];
}

- (NSString *)authToken
{
    if (!self.successful)
        return nil;
    
    return [self $:@"auth/token"];
}

- (NSString *)authPerms
{
    if (!self.successful)
        return nil;
    
    return [self $:@"auth/perms"];
}

- (NSString *)authUserId
{
    if (!self.successful)
        return nil;
    
    return [self $:@"auth/user:id"];
}

- (NSString *)authUserName
{
    if (!self.successful)
        return nil;
    
    return [self $:@"auth/user:username"];
}

- (NSString *)authNickName
{
    if (!self.successful)
        return nil;
        
    return [self $:@"auth/user:nickname"];
}

@end 