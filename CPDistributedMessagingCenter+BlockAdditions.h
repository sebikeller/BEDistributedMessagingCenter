//
//  CPDistributedMessagingCenter+BlockAdditions.h
//  automuter
//
//  Created by Sebastian Keller on 19.05.14.
//
//

#import <AppSupport/CPDistributedMessagingCenter.h>

//Define CPDMAnswerBlock block type, to simplify the Methods declarations
typedef void (^CPDMCAnswerBlock)(id);

@interface CPDistributedMessagingCenter (BlockAdditions)

- (void)sendMessageAndReceiveReplyName:(NSString*)messageName userInfo:(NSDictionary*)userInfo toCallbackBlock:(CPDMCAnswerBlock)block;

@end
