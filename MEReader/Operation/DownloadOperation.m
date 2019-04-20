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

#pragma mark - Initializer

- (instancetype)initBook:(Book *)book {
  self = [super init];
  if (self) {
    self.book = book;
    self.session = [NSURLSession sessionWithConfiguration:NSURLSessionConfiguration.defaultSessionConfiguration
                                  delegate:self
                             delegateQueue:nil];
    self.lastSaveTime = [[NSDate date] timeIntervalSince1970];
  }
  return self;
}

#pragma mark - Helpers

- (NSManagedObjectContext *)context {
  if (!_context) {
    __weak DownloadOperation *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
      weakSelf.context = AppDelegate.sharedDelegate.persistentContainer.newBackgroundContext;
    });
  }
  return _context;
}

- (void)saveWithCurrentContext {
  NSError *saveError;
  [[self context] save:&saveError];
  if (saveError) {
    NSLog(@"Error saving context %@", saveError.localizedDescription);
  }
}

#pragma mark - Override

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

- (void)finish {
  [self.session finishTasksAndInvalidate];
  [super finish];
}

#pragma mark - NSURLSessionDownloadDelegate

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

///
/// saved with */.downloads/uuid-string-bla-bla.pdf
/// to construct a valid url path, use the absolute path + relative path.
/// that replaces the wildcard with the current platform configs.
/// example: **absolute path-** /var/device/some-device-uuid/application/some-runtime-related-uuid/dir/documents/
/// we need to append to the the abosule path, our current saved relative path.
/// example: /var/device/some-device-uuid/application/some-runtime-related-uuid/dir/documents/.downloads/uuid-string-bla-bla.pdf
///

- (void)URLSession:(nonnull NSURLSession *)session downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(nonnull NSURL *)location {
  
  NSString *ext = downloadTask.currentRequest.URL.pathExtension;
  if (!ext) {
    ext = @"pdf";
  }
  
  NSString *fileName = [NSString stringWithFormat:@"%@.%@", self.book.uniqueID, ext];
  NSString *privateDownloadsDir = [DownloadInfo absoluteDownloadsPath]; // absolute, not valid dir
  // we need to convert it to a valid relative dir.
  NSURL *relativeDownloadsDir = [[DownloadInfo relativeDocumentDirectory] URLByAppendingPathComponent:privateDownloadsDir]; // valid dir
  
//  NSURL *newLocation = [dir URLByAppendingPathComponent:fileName];
//  newLocation = [NSURL fileURLWithPath:newLocation.absoluteString];
  
  if (![NSFileManager.defaultManager fileExistsAtPath:relativeDownloadsDir.path]) {
    NSError *directoryCreationError;
    [NSFileManager.defaultManager createDirectoryAtPath:relativeDownloadsDir.path withIntermediateDirectories:NO attributes:nil error:&directoryCreationError];
  }
  
  NSURL *destinationURL = [relativeDownloadsDir URLByAppendingPathComponent:fileName];
  NSError *fileManagerFileMoveError;
  [NSFileManager.defaultManager moveItemAtURL:location toURL:destinationURL error:&fileManagerFileMoveError];
  NSError *fileManagerAttributesError;
  NSDictionary<NSFileAttributeKey, id> *attrs = [NSFileManager.defaultManager attributesOfItemAtPath:destinationURL.path error:&fileManagerAttributesError];
  
  if (fileManagerFileMoveError || fileManagerAttributesError) {
    NSLog(@"Move file error %@", fileManagerFileMoveError.localizedDescription);
    NSLog(@"Attributes error %@", fileManagerAttributesError.localizedDescription);
  }
  
  NSString *absoluteFilePath = [privateDownloadsDir stringByAppendingString:fileName];
  __weak DownloadOperation *weakSelf = self;
  [[self context] performBlock:^{
    weakSelf.book.downloadInfo.progress = 1.0;
    weakSelf.book.downloadInfo.sizeInBytes = [(NSNumber *)attrs[NSFileSize] intValue];
    weakSelf.book.downloadInfo.path = absoluteFilePath;
    NSLog(@"downloadPath: %@", absoluteFilePath);
  }];
}

@end
