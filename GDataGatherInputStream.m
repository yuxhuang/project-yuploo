/* Copyright (c) 2007 Google Inc.
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

#import "GDataGatherInputStream.h"

@implementation GDataGatherInputStream

+ (NSInputStream *)streamWithArray:(NSArray *)dataArray {
  return [[[self alloc] initWithArray:dataArray] autorelease]; 
}

- (id)initWithArray:(NSArray *)dataArray {
  self = [super init];
  if (self) {
    dataArray_ = [dataArray retain];
    arrayIndex_ = 0;
    dataOffset_ = 0;
    
    [self setDelegate:self];  // An NSStream's default delegate should be self.
    
    // We use a dummy input stream to handle all the various undocumented
    // messages the system sends to an input stream.
    //
    // Contrary to documentation, inputStreamWithData neither copies nor
    // retains the data in Mac OS X 10.4, so we must retain it.
    // (Radar 5167591)
    
    dummyData_ = [[NSData alloc] initWithBytes:"x" length:1];
    dummyStream_ = [[NSInputStream alloc] initWithData:dummyData_];     
  }
  return self;
}

- (void) dealloc {
  [dataArray_ release];
  [dummyStream_ release];
  [dummyData_ release];
  
  [super dealloc];
}

- (int)read:(uint8_t *)buffer maxLength:(unsigned int)len {
  
  unsigned int bytesRead = 0;
  unsigned int bytesRemaining = len;
  
  // read bytes from the currently-indexed array
  while ((bytesRemaining > 0) && (arrayIndex_ < [dataArray_ count])) {
    
    NSData* data = [dataArray_ objectAtIndex:arrayIndex_];
    
    int dataLen = [data length];
    int dataBytesLeft = dataLen - (unsigned int)dataOffset_;
    
    unsigned int bytesToCopy = MIN(bytesRemaining, dataBytesLeft);
    NSRange range = NSMakeRange((unsigned int) dataOffset_, bytesToCopy);

    [data getBytes:(buffer + bytesRead) range:range];

    bytesRead += bytesToCopy;
    dataOffset_ += bytesToCopy;
    bytesRemaining -= bytesToCopy;
    
    if (dataOffset_ == dataLen) {
      dataOffset_ = 0;
      arrayIndex_++;
    }    
  }
  
  if (bytesRead == 0) {
    // We are at the end our our stream, so we read all of the data on our
    // dummy input stream to make sure it is in the "fully read" state.
    uint8_t buffer[2];
    (void) [dummyStream_ read:buffer maxLength:sizeof(buffer)];    
  }
  
  return bytesRead;
}

- (BOOL)getBuffer:(uint8_t **)buffer length:(unsigned int *)len {
  return NO;  // We don't support this style of reading.
}

- (BOOL)hasBytesAvailable {
  // if we return no, the read never finishes, even if we've already
  // delivered all the bytes
  return YES;
}

#pragma mark -

// Pass other expected messages on to the dummy input stream

- (void)open {
  [dummyStream_ open];
}

- (void)close {
  [dummyStream_ close];
}

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
  if (delegate_ != self) {
    [delegate_ stream:self handleEvent:streamEvent];
  }
}

- (id)delegate {
  return delegate_;
}

- (void)setDelegate:(id)delegate {
  if (delegate == nil) {
    delegate_ = self;
    [dummyStream_ setDelegate:nil];
  } else {
    delegate_ = delegate;
    [dummyStream_ setDelegate:self];
  }
}

- (id)propertyForKey:(NSString *)key {
  return [dummyStream_ propertyForKey:key]; 
}

- (BOOL)setProperty:(id)property forKey:(NSString *)key {
  return [dummyStream_ setProperty:property forKey:key]; 
}

- (void)scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode {
  [dummyStream_ scheduleInRunLoop:aRunLoop forMode:mode];
}

- (void)removeFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode {
  [dummyStream_ removeFromRunLoop:aRunLoop forMode:mode];
}

- (NSStreamStatus)streamStatus {
  return [dummyStream_ streamStatus];
}
- (NSError *)streamError {
  return [dummyStream_ streamError];
}

#pragma mark -

// We'll forward all unexpected messages to our dummy stream

+ (NSMethodSignature*)methodSignatureForSelector:(SEL)selector {  
  return [NSInputStream methodSignatureForSelector:selector];
}

+ (void)forwardInvocation:(NSInvocation*)invocation {
  [invocation invokeWithTarget:[NSInputStream class]];
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector {
  return [dummyStream_ methodSignatureForSelector:(SEL)selector];
}

- (void)forwardInvocation:(NSInvocation*)invocation {
  
#if 0
  // uncomment this section to see the messages the NSInputStream receives
  SEL selector;
  NSString *selName;
  
  selector=[invocation selector];
  selName=NSStringFromSelector(selector);
  NSLog(@"-forwardInvocation: %@",selName);
#endif
  
  [invocation invokeWithTarget:dummyStream_];
}

@end
