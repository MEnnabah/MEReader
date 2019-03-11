//
//  DownloadOperation.m
//  MEReader
//
//  Created by Mohammed Ennabah on 3/10/19.
//  Copyright © 2019 Mohammed Ennabah. All rights reserved.
//

#import "DownloadOperation.h"
#import "NotificationName.h"

@interface DownloadOperation () <NSURLSessionDownloadDelegate>

@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;

@end

@implementation DownloadOperation

NSURLSession *_session;

- (instancetype)initWithURL:(NSURL *)url bookID:(NSString *)bookID {
  self = [super init];
  if (self) {
    self.url = url;
    self.bookID = bookID;
  }
  return self;
}

- (NSURLSession *)session {
  if (!_session) {
    _session = [NSURLSession sessionWithConfiguration:NSURLSessionConfiguration.defaultSessionConfiguration
                delegate:self
                delegateQueue:nil];
  }
  return _session;
}

- (void)execute {
  
  self.downloadTask = [[self session] downloadTaskWithURL:self.url];
  [self.downloadTask resume];
  
}

- (void)cancel {
  [self.downloadTask cancel];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
  float progress = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
  NSDictionary *userInfo = @{
                             @"bookID": self.bookID,
                             @"downloadProgress": [NSNumber numberWithFloat:progress],
                             @"totalBytesWritten": [NSNumber numberWithLongLong:totalBytesWritten],
                             @"totalBytesExpectedToWrite": [NSNumber numberWithLongLong:totalBytesExpectedToWrite]
                             };
  dispatch_async(dispatch_get_main_queue(), ^{
    [NSNotificationCenter.defaultCenter postNotificationName:[NotificationName downloadProgress] object:self userInfo:userInfo];
  });
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
  NSLog(@"%@", error.localizedDescription);
  [self finish];
}

- (void)URLSession:(nonnull NSURLSession *)session downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(nonnull NSURL *)location {
  NSLog(@"File downloaded at: %@", location.absoluteString);
}

@end
