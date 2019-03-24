//
//  DownloadOperation.m
//  MEReader
//
//  Created by Mohammed Ennabah on 3/10/19.
//  Copyright © 2019 Mohammed Ennabah. All rights reserved.
//

#import "DownloadOperation.h"
#import "NotificationName.h"
#import "MEReader+CoreDataModel.h"
#import "AppDelegate.h"

@interface DownloadOperation () <NSURLSessionDownloadDelegate>

@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;

@end

@implementation DownloadOperation

DownloadInfo *_downloadInfo;
NSURLSession *_session;
NSManagedObjectContext *_context;
NSTimeInterval lastSaveTime; // throttle coredata save

- (instancetype)initWithURL:(NSURL *)url bookID:(NSString *)bookID {
  self = [super init];
  if (self) {
    self.url = url;
    self.bookID = bookID;
    lastSaveTime = [[NSDate date] timeIntervalSince1970];
  }
  return self;
}

- (NSManagedObjectContext *)context {
  if (!_context) {
    dispatch_async(dispatch_get_main_queue(), ^{
      _context = AppDelegate.sharedDelegate.persistentContainer.newBackgroundContext;
    });
  }
  return _context;
}

- (DownloadInfo *)downloadInfo {
  if (!_downloadInfo) {
    NSFetchRequest *downloadInfoFetchRequest = [DownloadInfo fetchRequest];
    downloadInfoFetchRequest.predicate = [NSPredicate predicateWithFormat:@"book.uniqueID = %@", self.bookID];
    downloadInfoFetchRequest.fetchLimit = 1;
    NSError *downloadInfoFetchRequestError;
    _downloadInfo = [[self context] executeFetchRequest:downloadInfoFetchRequest error:&downloadInfoFetchRequestError].firstObject;
  }
  return _downloadInfo;
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
  _downloadInfo.downloadState = DownloadStateDownloading;
  [self saveWithCurrentContext];
  self.downloadTask = [[self session] downloadTaskWithURL:self.url];
  [self.downloadTask resume];
}

- (void)cancel {
  [self downloadInfo].downloadState = DownloadStatePaused;
  [self saveWithCurrentContext];
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
  
  [self downloadInfo].progress = progress;
  [self downloadInfo].sizeInBytes = totalBytesWritten;
  
  // throttle save
  NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
  if ((now - lastSaveTime >= 0.5) || (progress == 1.0)) {
    lastSaveTime = [[NSDate date] timeIntervalSince1970];
    [self saveWithCurrentContext];
  }
  
}

- (void)saveWithCurrentContext {
  NSError *saveError;
  [[self context] save:&saveError];
  if (saveError) {
    NSLog(@"Error saving context %@", saveError.localizedDescription);
  }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
  
  if (error) {
    NSLog(@"%@", error.localizedDescription);
    if (error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled) {
      [self downloadInfo].downloadState = DownloadStatePaused;
    } else {
      [self downloadInfo].downloadState = DownloadStateFailed;
    }
  } else {
    [self downloadInfo].downloadState = DownloadStateCompleted;
  }
  [self saveWithCurrentContext];
  [self finish];
}

- (void)URLSession:(nonnull NSURLSession *)session downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(nonnull NSURL *)location {
  
  NSString *ext = downloadTask.currentRequest.URL.pathExtension;
  if (!ext) {
    ext = @"pdf";
  }
  NSString *uuidStr = [[NSUUID alloc] init].UUIDString;
  NSString *fileName = [NSString stringWithFormat:@"%@.%@", uuidStr, ext];
  NSURL *dir = [DownloadInfo offlineLocation];
  NSURL *newLocation = [dir URLByAppendingPathComponent:fileName];
  newLocation = [NSURL fileURLWithPath:newLocation.absoluteString];
  
  if (![NSFileManager.defaultManager fileExistsAtPath:dir.path]) {
    NSError *directoryCreationError;
    [NSFileManager.defaultManager createDirectoryAtPath:dir.path withIntermediateDirectories:NO attributes:nil error:&directoryCreationError];
  }
  
  NSError *fileManagerFileMoveError;
  [NSFileManager.defaultManager moveItemAtURL:location toURL:newLocation error:&fileManagerFileMoveError];
  NSError *fileManagerAttributesError;
  NSDictionary<NSFileAttributeKey, id> *attrs = [NSFileManager.defaultManager attributesOfItemAtPath:newLocation.path error:&fileManagerAttributesError];
  
  if (fileManagerFileMoveError || fileManagerAttributesError) {
    NSLog(@"Move file error %@", fileManagerFileMoveError.localizedDescription);
    NSLog(@"Attributes error %@", fileManagerAttributesError.localizedDescription);
  }
  
  [[self context] performBlockAndWait:^{
    [self downloadInfo].progress = 1.0;
    [self downloadInfo].sizeInBytes = [(NSNumber *)attrs[NSFileSize] intValue];
    [self downloadInfo].path = newLocation.path;
  }];
  
  NSLog(@"File downloaded at: %@", location.absoluteString);
  NSLog(@"File moved to %@", newLocation.absoluteString);
}

@end
