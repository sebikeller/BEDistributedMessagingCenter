//
//  BEDistributedMessagingCenter.h
//  automuter
//
//  Created by Sebastian Keller on 19.05.14.
//
//

#import <AppSupport/CPDistributedMessagingCenter.h>

//Define CPDMAnswerBlock block type, to simplify the Methods declarations
typedef void (^BEDMCAnswerBlock)(id);

@interface BEDistributedMessagingCenter : CPDistributedMessagingCenter

+ (instancetype)centerNamed:(NSString *)centerName;

- (void)sendMessageAndReceiveReplyName:(NSString*)messageName userInfo:(id)userInfo toCallbackBlock:(BEDMCAnswerBlock)block;

@end
