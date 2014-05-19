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

#import <objc/runtime.h>
#import "CPDistributedMessagingCenter+BlockAdditions.h"

//Private wrapper class to store the blocks as methods, since CPDistributedMessagingCenter can only callback to methods.
@interface BlockMapperClass : NSObject
- (SEL)addBlock:(CPDMCAnswerBlock)block;
@end

@implementation BlockMapperClass

/**
 Generate new method name for the block we want to store on the mapper class
 Example usage:
 @code
 SEL newMethod = [self getMethodNameForBlock];
 @endcode
 @return cString the new generated Name.
 */
- (const char*)getMethodNameForBlock {
	return [[NSString stringWithFormat:@"__block__%llu:", [@([[NSDate date] timeIntervalSince1970]*1000) unsignedLongLongValue]] UTF8String];
}

/**
 Generate new method name for the block we want to store on the mapper class
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
 @return SEL to register/call the a block on the mapper.
 */
- (SEL)addBlock:(CPDMCAnswerBlock)block {
	SEL funcsel = sel_registerName([self getMethodNameForBlock]);
	class_addMethod([BlockMapperClass class], funcsel, imp_implementationWithBlock(^(id _self, CPDistributedMessagingCenter* center, id answer){
		block(answer);
	}), "v@@@");
	return funcsel;
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
	
	[self sendMessageAndReceiveReplyName:messageName userInfo:userInfo toTarget:mapper selector:[mapper addBlock:block] context:NULL];
}

@end