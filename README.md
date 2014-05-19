# CPDistributedMessagingCenter enhanced with Blocks

This is an ObjectiveC Category for [CPDistributedMessagingCenter][]
(Part of the [AppSupport.framework][] on iOS), which gives you the
posibility to process a reply **asynchronously** in a [block][].

### Usage:
``` smalltalk
#import "CPDistributedMessagingCenter+BlockAdditions.h"
//...
CPDistributedMessagingCenter* center = [CPDistributedMessagingCenter centerNamed:@"aCenterName"];
//...
[center sendMessageAndReceiveReplyName:@"aMessageName" userInfo:@{@"someKey": someData} toCallbackBlock:^(id answer) {
    //do something with answer;
}];
```
### Update the Makefile:

Make sure to update your make file, so [Theos][] includes the
AppSupport.framework (and if you need it: [rocketbootstrap][]).
Also make sure [ARC][] is on.
``` make
TARGET := iphone:clang
[...]
ADDITIONAL_OBJCFLAGS = -fobjc-arc
[...]
yourProjectName_FILES = [...] CPDistributedMessagingCenter+BlockAdditions.m
yourProjectName_PRIVATE_FRAMEWORKS = [...] AppSupport
yourProjectName_LIBRARIES = [...] rocketbootstrap
```
  [CPDistributedMessagingCenter]: http://iphonedevwiki.net/index.php/CPDistributedMessagingCenter
  [AppSupport.framework]: https://github.com/nst/iOS-Runtime-Headers/blob/master/PrivateFrameworks/AppSupport.framework/CPDistributedMessagingCenter.h
  [block]: https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/Blocks/Articles/00_Introduction.html
  [Theos]: http://iphonedevwiki.net/index.php/Theos/Getting_Started
  [rocketbootstrap]: http://iphonedevwiki.net/index.php/Updating_extensions_for_iOS_7#Inter-process_communication
  [ARC]: https://developer.apple.com/library/ios/releasenotes/ObjectiveC/RN-TransitioningToARC/Introduction/Introduction.html
