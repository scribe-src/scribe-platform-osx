#import "FileSystem.h"

// This points to the zipped data (which possibly has null chars)
extern char assets     __asm("section$start$__DATA$__assets");

// This points to a String containing the length in ASCII ("1534")
extern char assets_len __asm("section$start$__DATA$__assets_len");

static FileSystem *sharedInstance = nil;

@implementation FileSystem

+ (id) shared {
  if (!sharedInstance) {
    sharedInstance = [self new];
  }
  return sharedInstance;
}

- (id) init {
  if (self = [super init]) {
    int length = atoi((char*)&assets_len);
    _zip = [[FastZip alloc] initWithBuffer: (char*)&assets size: length];
  }
  return self;
}

- (NSData *) fileAtPath: (NSString *) path {
  return [_zip dataForKey: path];
}

@end
