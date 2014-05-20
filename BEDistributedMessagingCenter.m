//
//  BEDistributedMessagingCenter.m
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
#import "BEDistributedMessagingCenter.h"

//Private wrapper class to store the blocks, since CPDistributedMessagingCenter can only callback to methods.
@interface BEBlockMapper : NSObject
+ (instancetype)sharedInstance;
- (void *)addBlock:(BEDMCAnswerBlock)block;
@end

@implementation BEBlockMapper {
    NSMutableDictionary *_callbacks;
    NSUInteger _key;
    OSSpinLock _spinLock;
}

+ (instancetype)sharedInstance {
    static BEBlockMapper* mapperInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mapperInstance = [[self alloc] init];
    });
    return mapperInstance;
}

- (instancetype)init {
    if ((self = [super init])) {
        _callbacks = [[NSMutableDictionary alloc] init];
    }
    return self;
}

/**
 @private 
 generates a new contextID
 @return context ID.
 */
- (NSUInteger)nextContextID {
    NSUInteger nextKey = _key++;
    while (_callbacks[@(nextKey)]) {
        nextKey = _key++;
    }
    return nextKey;
}

/**
 Store a new block for dispatching, and return its context ID
 Example usage:
 @code
 static BEBlockMapper* mapper = nil;
 ...
 if (!mapper) {
 static dispatch_once_t onceToken;
 dispatch_once(&onceToken, ^{
 mapper = [[BEBlockMapper alloc] init];
 });
 }
 ...
 [mapper addBlock:someBlock];
 @endcode
 @param BEDMCAnswerBlock block - the block to be added to the mapper.
 @return context ID to register/call the block on the mapper.
 */
- (void *)addBlock:(BEDMCAnswerBlock)block {
    OSSpinLockLock(&_spinLock);
    NSUInteger contextId = [self nextContextID];
    _callbacks[@(contextId)] = block;
    OSSpinLockUnlock(&_spinLock);
    return (void *)contextId;
}

/**
 @private method to handle the calling of the passed blocks
 */
- (void)messagingCenter:(CPDistributedMessagingCenter *)messagingCenter gotReply:(id)reply unknown:(void *)unknown context:(void *)context {
    if (![messagingCenter isKindOfClass:[BEDistributedMessagingCenter class]]) {
        NSLog(@"BEDistributedMessagingCenter: Unexpected type of messagingCenter: %@", [messagingCenter class]);
    }
    NSUInteger contextId = (NSUInteger)context;
    NSNumber *key = @(contextId);
    OSSpinLockLock(&_spinLock);
    BEDMCAnswerBlock callback = _callbacks[key];
    [_callbacks removeObjectForKey:key];
    OSSpinLockUnlock(&_spinLock);
    if (callback) {
        callback(reply);
    }
}

@end

@implementation BEDistributedMessagingCenter

+ (instancetype)centerNamed:(NSString *)centerName {
    return (BEDistributedMessagingCenter*)[super centerNamed:centerName];
}

/**
 Send a message with given name and userInfo-data and calls the passed block when a reply is received.
 Example usage:
 @code
 BEDistributedMessagingCenter* center = [BEDistributedMessagingCenter centerNamed:aCenterName];
 [center sendMessageAndReceiveReplyName:aMessageName userInfo:userInfoDictionary toCallbackBlock:^(id answer) {
     //do something with answer;
 }];
 @endcode
 @param NSString* messageName - the name of the message to send.
 @param id userInfo - data to pass to the message receiver.
 @param BEDMCAnswerBlock block - the block to be executed on reply.
 */
- (void)sendMessageAndReceiveReplyName:(NSString*)messageName userInfo:(id)userInfo toCallbackBlock:(BEDMCAnswerBlock)block {
    [self sendMessageAndReceiveReplyName:messageName userInfo:userInfo toTarget:[BEBlockMapper sharedInstance] selector:@selector(messagingCenter:gotReply:unknown:context:) context:[[BEBlockMapper sharedInstance] addBlock:block]];
}

@end