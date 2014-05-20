//
//  CPDistributedMessagingCenter+BlockAdditions.m
//  automuter
//
//  Created by Sebastian Keller on 19.05.14.
//
//

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#import <libkern/OSAtomic.h>
#import <objc/runtime.h>
#import "CPDistributedMessagingCenter+BlockAdditions.h"

//Private wrapper class to store the blocks, since CPDistributedMessagingCenter can only callback to methods.
@interface BlockMapperClass : NSObject
- (void *)addBlock:(CPDMCAnswerBlock)block;
@end

@implementation BlockMapperClass {
    NSMutableDictionary *_callbacks;
    NSUInteger _key;
    OSSpinLock _spinLock;
}

- (instancetype)init {
    if ((self = [super init])) {
        _callbacks = [[NSMutableDictionary alloc] init];
    }
    return self;
}

/**
 Store a new block for dispatching, and return its context ID
 Example usage:
 @code
 static BlockMapperClass* mapper = nil;
 ...
 if (!mapper) {
 	static dispatch_once_t onceToken;
 	dispatch_once(&onceToken, ^{
 		mapper = [[BlockMapperClass alloc] init];
 	});
 }
 ...
 [mapper addBlock:someBlock];
 @endcode
 @param CPDMCAnswerBlock block - the block to be added to the mapper.
 @return context ID to register/call the block on the mapper.
 */
- (void *)addBlock:(CPDMCAnswerBlock)block {
    OSSpinLockLock(&_spinLock);
    NSUInteger contextId = _key;
    _key++;
    _callbacks[@(contextId)] = block;
    OSSpinLockUnlock(&_spinLock);
    return (void *)contextId;
}

- (void)messagingCenter:(CPDistributedMessagingCenter *)messagingCenter gotReply:(id)reply unknown:(void *)unknown context:(void *)context {
    NSUInteger contextId = (NSUInteger)context;
    NSNumber *key = @(contextId);
    OSSpinLockLock(&_spinLock);
    CPDMCAnswerBlock callback = _callbacks[key];
    [_callbacks removeObjectForKey:key];
    OSSpinLockUnlock(&_spinLock);
    if (callback) {
        callback(reply);
    }
}

@end

static BlockMapperClass* mapper = nil;

@implementation CPDistributedMessagingCenter (BlockAdditions)

/**
 Send a message with given name and userInfo-data and calls the passed block when a reply is received.
 Example usage:
 @code
 CPDistributedMessagingCenter* center = [CPDistributedMessagingCenter centerNamed:aCenterName];
 [center sendMessageAndReceiveReplyName:aMessageName userInfo:userInfoDictionary toCallbackBlock:^(id answer) {
 	//do something with answer;
 }];
 @endcode
 @param NSString* messageName - the name of the message to send.
 @param id userInfo - data to pass to the message receiver.
 @param CPDMCAnswerBlock block - the block to be executed on reply.
 */
- (void)sendMessageAndReceiveReplyName:(NSString*)messageName userInfo:(id)userInfo toCallbackBlock:(CPDMCAnswerBlock)block {
	if (!mapper) {
		static dispatch_once_t onceToken;
		dispatch_once(&onceToken, ^{
			mapper = [[BlockMapperClass alloc] init];
		});
	}

	[self sendMessageAndReceiveReplyName:messageName userInfo:userInfo toTarget:mapper selector:@selector(messagingCenter:gotReply:unknown:context:) context:[mapper addBlock:block]];
}

@end
