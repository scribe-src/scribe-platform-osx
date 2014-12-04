#import <Foundation/Foundation.h>
#import "FastZip.h"

@interface FileSystem: NSObject {
  FastZip *_zip;
}

+ (id) shared;
- (NSData *) fileAtPath: (NSString *) path;

@end