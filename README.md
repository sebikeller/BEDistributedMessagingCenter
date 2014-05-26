# BEDistributedMessagingCenter 
### (BlocksEnhancedCPDistributedMessagingCenter)

This is a replacement class for [CPDistributedMessagingCenter][] (Part
of the [AppSupport.framework][] on iOS), which gives you the posibility
to process a reply **asynchronously** in a [block][].

### Usage:

``` objective-c
#import "BEDistributedMessagingCenter.h"
//...
BEDistributedMessagingCenter* center = [BEDistributedMessagingCenter centerNamed:@"aCenterName"];
rocketbootstrap_distributedmessagingcenter_apply(center); //iOS 7+ only
//...
[center sendMessageAndReceiveReplyName:@"aMessageName" userInfo:@{@"someKey": someData} toCallbackBlock:^(id answer) {
    //do something with answer;
}];
```


To use in your own project make sure you link to the library available in Cydia.
Update your ([Theos][]) makefile: include [libbedistributedmessagingcenter][] and [rocketbootstrap][] (iOS 7+).

Also make sure [ARC][] is on.

``` make
TARGET := iphone:clang
[...]
ADDITIONAL_OBJCFLAGS = -fobjc-arc
[...]
yourProjectName_LIBRARIES = [...] rocketbootstrap libbedistributedmessagingcenter
```

## Special Thanks

[@joedj][] - for rewriting the block caching

[@rpetrich][] - for pointing out memory leaks (unretainable blocks) and for the very streamlined version

[@uroboro][] - for good tips

[@DHowett][] - for clarification on ARC and blocks

  [CPDistributedMessagingCenter]: http://iphonedevwiki.net/index.php/CPDistributedMessagingCenter
  [AppSupport.framework]: https://github.com/nst/iOS-Runtime-Headers/blob/master/PrivateFrameworks/AppSupport.framework/CPDistributedMessagingCenter.h
  [block]: https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/Blocks/Articles/00_Introduction.html
  [Theos]: http://iphonedevwiki.net/index.php/Theos/Getting_Started
  [libbedistributedmessagingcenter]: http://cydia.saurik.com/package/ch.sebikeller.libbedistributedmessagingcenter/
  [rocketbootstrap]: http://iphonedevwiki.net/index.php/Updating_extensions_for_iOS_7#Inter-process_communication
  [ARC]: https://developer.apple.com/library/ios/releasenotes/ObjectiveC/RN-TransitioningToARC/Introduction/Introduction.html
  [@joedj]: https://github.com/joedj
  [@rpetrich]: https://github.com/rpetrich/
  [@uroboro]: https://github.com/uroboro/
  [@DHowett]: https://github.com/DHowett/
