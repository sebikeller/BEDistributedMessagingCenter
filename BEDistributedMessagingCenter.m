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

@implementation BEDistributedMessagingCenter

+ (instancetype)centerNamed:(NSString *)centerName {
    return (BEDistributedMessagingCenter*)[super centerNamed:centerName];
}

- (void)messagingCenter:(CPDistributedMessagingCenter *)messagingCenter gotReply:(id)reply unknown:(void *)unknown context:(void *)context {
    if (context) {
        BEDMCAnswerBlock callback = (__bridge_transfer BEDMCAnswerBlock)context;
        callback(reply);
    }
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
    [self sendMessageAndReceiveReplyName:messageName userInfo:userInfo toTarget:self selector:@selector(messagingCenter:gotReply:unknown:context:) context:(__bridge_retained void *)[block copy]];
}

@end