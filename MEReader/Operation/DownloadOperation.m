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
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic) NSTimeInterval lastSaveTime;  // throttle coredata save

@end

@implementation DownloadOperation

- (instancetype)initBook:(Book *)book {
  self = [super init];
  if (self) {
    NSLog(@"Initing download operation %@", self);
    self.book = book;
    self.session = [NSURLSession sessionWithConfiguration:NSURLSessionConfiguration.defaultSessionConfiguration
                                  delegate:self
                             delegateQueue:nil];
    self.lastSaveTime = [[NSDate date] timeIntervalSince1970];
  }
  return self;
}

- (NSManagedObjectContext *)context {
  if (!_context) {
    __weak DownloadOperation *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
      weakSelf.context = AppDelegate.sharedDelegate.persistentContainer.newBackgroundContext;
    });
  }
  return _context;
}

- (void)execute {
  self.book.downloadInfo.downloadState = DownloadStateDownloading;
  [self saveWithCurrentContext];
  self.downloadTask = [self.session downloadTaskWithURL:[NSURL URLWithString:self.book.url]];
  [self.downloadTask resume];
}

- (void)cancel {
  self.book.downloadInfo.downloadState = DownloadStatePaused;
  [self saveWithCurrentContext];
  [self.downloadTask cancel];
  [self finish];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
  
  float progress = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
  
  self.book.downloadInfo.progress = progress;
  self.book.downloadInfo.sizeInBytes = totalBytesWritten;
  self.book.title = self.book.title;
  
  // throttle save
  NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
  if ((now - self.lastSaveTime >= 0.5) || (progress == 1.0)) {
    self.lastSaveTime = [[NSDate date] timeIntervalSince1970];
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
      self.book.downloadInfo.downloadState = DownloadStatePaused;
    } else {
      self.book.downloadInfo.downloadState = DownloadStateFailed;
    }
  } else {
    self.book.downloadInfo.downloadState = DownloadStateCompleted;
  }
  [self saveWithCurrentContext];
  [self finish];
}

- (void)finish {
  [self.session finishTasksAndInvalidate];
  [super finish];
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
  
  __weak DownloadOperation *weakSelf = self;
  [[self context] performBlockAndWait:^{
    weakSelf.book.downloadInfo.progress = 1.0;
    weakSelf.book.downloadInfo.sizeInBytes = [(NSNumber *)attrs[NSFileSize] intValue];
    weakSelf.book.downloadInfo.path = newLocation.path;
  }];
}

- (void)dealloc {
  NSLog(@"Deallocating operation %@", self);
}

@end
