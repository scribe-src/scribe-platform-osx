#import "AppURLProtocol.h"
#import "NSURL+AppURLProtocolAdditions.h"
#import "FileSystem.h"

@implementation AppURLProtocol

+ (NSURLRequest *) canonicalRequestForRequest: (NSURLRequest *) request {
  return request;
}

+ (BOOL) canInitWithRequest: (NSURLRequest *) request {
  return [[[request URL] scheme] caseInsensitiveCompare: @"app"] == NSOrderedSame;
}

- (void) startLoading {
  NSURL *requestURL = [[self request] URL];
  NSString *path = [requestURL path];
  while ([path hasPrefix: @"/"]) {
    path = [path substringFromIndex: 1];
  }

  NSLog(@"Loading URL %@ %@", requestURL, path);

  NSData *data = nil;
  if (path && path.length > 0) {
    data = [[FileSystem shared] fileAtPath: path];
  }

  if (data && [data length] > 0) {
    NSURLResponse *response = [[NSURLResponse alloc]
                   initWithURL: requestURL
                      MIMEType: [requestURL app_expectedMIMEType] //@"text/html"
         expectedContentLength: [data length] textEncodingName: nil];

    [[self client] URLProtocol: self didReceiveResponse: response cacheStoragePolicy: NSURLCacheStorageAllowed];
    [[self client] URLProtocol: self didLoadData: data];
    [[self client] URLProtocolDidFinishLoading: self];
  } else {
    [[self client] URLProtocol: self didFailWithError:
      [NSError errorWithDomain: NSURLErrorDomain
                          code: NSURLErrorFileDoesNotExist
                      userInfo: nil]
    ];
  }
}

- (void) stopLoading {
}

@end
