//
//  YupooSession.m
//  Yuploo
//
//  Created by Felix Huang on 22/02/08.
//  Copyright 2008 Two Fathoms Deep. All rights reserved.
//

#import "YupooSession.h"
#import "YupooResultNode.h"
#import "Yupoo.h"
#import "YupooObserver.h"
#import "GDataHTTPFetcher.h"
#import "GDataProgressMonitorInputStream.h"

@interface YupooSession (PrivateAPI)

// xml loading
- (NSXMLElement *)loadXMLElementWithData:(NSData *)data;

@end

@implementation YupooSession

@synthesize _completed, _failed, _successful, status, rootNode, deliveredBytes, totalBytes;

+ (id)resultOfRequest:(NSURLRequest *)request inYupoo:(Yupoo *)aYupoo
{
    return [[[YupooSession alloc] initWithRequest:request yupoo:aYupoo] autorelease];
}

- (id)initWithRequest:(NSURLRequest *)request yupoo:(Yupoo *)aYupoo
{
	self = [super init];
	
	if (nil != self) {
        _completed = NO;
        _failed = NO;
        _successful = NO;
        
        status = @"Waiting";
        
        xmlElement = nil;
		observers = [[NSMutableArray alloc] initWithCapacity:5];
		
		fetcher_ = [[GDataHTTPFetcher alloc] initWithRequest:request];
		yupoo = [aYupoo retain];
	}
	
	return self;
}

- (id)initWithRequest:(NSURLRequest *)request yupoo:(Yupoo *)aYupoo uploadStream:(NSInputStream *)input length:(unsigned long long)length
{
	[input retain];

	self = [self initWithRequest:request yupoo:yupoo];
	
	if (nil != self) {
		GDataProgressMonitorInputStream *stream = [[GDataProgressMonitorInputStream alloc] initWithStream:input length:length];
		[stream setDelegate:nil];
		[stream setMonitorDelegate:[[self retain] autorelease]];
		[stream setMonitorSelector:@selector(inputStream:hasDeliveredBytes:ofTotalBytes:)];
		[fetcher_ setPostStream:stream];
		[stream release];
	}

	[input release];
	
	return self;
}

- (void)dealloc
{
	// remove all observers
	[self overlookAll];
	[observers release];
	// clear root node
	[rootNode release];
	[fetcher_ release];
	[yupoo release];
	[super dealloc];
}

- (void)setMonitor:(id)delegate selector:(SEL)selector
{
	monitorDelegate_ = delegate;
	monitorSelector_ = selector;
}


#pragma mark Connection Methods

- (BOOL)begin
{
	return [fetcher_ beginFetchWithDelegate:self
						  didFinishSelector:@selector(fetcher:finishedWithData:)
				  didFailWithStatusSelector:@selector(fetcher:failedWithStatus:data:)
				   didFailWithErrorSelector:@selector(fetcher:failedWithError:)];
}

// the connection is totally completed. (but it does not mean the transaction is successful.
// connection is completed.
// to determine whether the result is useful, first test completed, then failed, finally successful
- (void)cancel
{
	[fetcher_ stopFetching];
}

#pragma mark Observation related

- (void)observe:(NSObject *)anObserver forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context
{
    [self addObserver:anObserver forKeyPath:keyPath options:options context:context];
	YupooObserver *observer = [[YupooObserver alloc] initWithObserver:anObserver keyPath:keyPath];
	[observers addObject:observer];
	[observer release];
}

- (void)overlook:(NSString *)keyPath withObject:(id)anObject
{
	for (YupooObserver *observer in observers) {
		if ([observer.observer isEqualTo:anObject] && [observer.keyPath isEqualToString:keyPath]) {
			[observers removeObject:observer];
			break;
		}
	}
    [self removeObserver:anObject forKeyPath:keyPath];
}

- (void)overlookAll
{
	for (YupooObserver *observer in observers) {
		[self removeObserver:observer.observer forKeyPath:observer.keyPath];
	}
	[observers removeAllObjects];
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

#pragma mark GDataHTTPFetcher Delegate Methods

- (void)fetcher:(GDataHTTPFetcher *)fetcher finishedWithData:(NSData *)retrievedData
{
	[retrievedData retain];
    // transform received data into xml
    xmlElement = [self loadXMLElementWithData:retrievedData];
    rootNode = [[YupooResultNode alloc] initWithXMLElement:xmlElement];
    // set it to nil. so let the garbage collector frees it.
    [retrievedData release];
	
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

- (void)fetcher:(GDataHTTPFetcher *)fetcher failedWithStatus:(int)statusCode data:(NSData *)data
{
    // gosh! we have a failed connection

    [self setValue:[NSNumber numberWithBool:YES] forKey:@"failed"];
    
    // log the error
    [self setValue:[NSString stringWithFormat:@"Connection failed! %d", statusCode] forKey:@"status"];
	
    NSLog(status);
    
    NSRunAlertPanel(@"Error", status, @"Oops!", nil, nil);
    
    // we have changed these values
    [self setValue:[NSNumber numberWithBool:YES] forKey:@"completed"];
}

- (void)fetcher:(GDataHTTPFetcher *)fetcher failedWithError:(NSError *)error
{
    // gosh! we have a failed connection
    
    [self setValue:[NSNumber numberWithBool:YES] forKey:@"failed"];
    
    // log the error
    [self setValue:[NSString stringWithFormat:@"Connection failed! %@ %@", [error localizedDescription],
					[[error userInfo] objectForKey:NSErrorFailingURLStringKey]] forKey:@"status"];
	
    NSLog(status);

    NSRunAlertPanel(@"Error", status, @"Oops!", nil, nil);
    
    // we have changed these values
    [self setValue:[NSNumber numberWithBool:YES] forKey:@"completed"];
}

- (void)inputStream:(GDataProgressMonitorInputStream *)stream hasDeliveredBytes:(unsigned long long)numReadSoFar ofTotalBytes:(unsigned long long)total
{
	[self setValue:[NSNumber numberWithLongLong:numReadSoFar] forKey:@"deliveredBytes"];
	[self setValue:[NSNumber numberWithLongLong:total] forKey:@"totalBytes"];
	
	if (monitorDelegate_ && monitorSelector_) {
		NSMethodSignature *signature = [monitorDelegate_ methodSignatureForSelector:monitorSelector_];
		NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
		[invocation setSelector:monitorSelector_];
		[invocation setTarget:monitorDelegate_];
		[invocation setArgument:&numReadSoFar atIndex:2];
		[invocation setArgument:&total atIndex:3];
		[invocation invoke];
    }
	
}

@end

@implementation YupooSession (PrivateAPI)

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

        NSRunAlertPanel(@"Error", status, @"Oops!", nil, nil);
        
        return nil;
    }

    // correct, then go ahead
    NSXMLElement *rootElement = [[[doc rootElement] retain] autorelease];
    
	[doc release];
    return rootElement;
}


@end

@implementation YupooSession (Error)

- (NSInteger)errorCode
{
    NSString *error = [self $:@"err:code"];
    
    if (nil == error) {
        return YupooSessionErrorCodeFailure;
    }
    
    NSInteger code = 0xdeadbeef;
    // deal with wrong representation with NSScanner
    NSScanner *scanner = [NSScanner scannerWithString:error];
    
    if (![scanner scanInteger:&code])
        return YupooSessionErrorCodeFailure;
    
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

@implementation YupooSession (Authentication)

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