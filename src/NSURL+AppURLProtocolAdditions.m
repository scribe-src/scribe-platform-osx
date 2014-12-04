#import "NSURL+AppURLProtocolAdditions.h"

@implementation NSURL (AppURLProtocolAdditions)

// Infer the MIME type of the resource from its path extension
// Source: http://stackoverflow.com/a/9802467/452816
- (NSString *) app_expectedMIMEType {
  NSString *ext = [[self path] pathExtension];
  CFStringRef type = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, ext, NULL);
  NSString *MIMEType = (NSString *)UTTypeCopyPreferredTagWithClass(type, kUTTagClassMIMEType);

  if (type != NULL) {
    CFRelease(type), type = NULL;
  }
  
  return [MIMEType autorelease];
}

@end