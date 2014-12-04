#import <Cocoa/Cocoa.h>

// Mostly from the reference post:
// http://engineering.oysterbooks.com/post/74290088019/getting-creative-with-uiwebview-and-nsurlprotocol

@interface NSURL (AppURLProtocolAdditions)

- (NSString *) app_expectedMIMEType;

@end
