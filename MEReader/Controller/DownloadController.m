//
//  DownloadController.m
//  MEReader
//
//  Created by Mohammed Ennabah on 3/19/19.
//  Copyright © 2019 Mohammed Ennabah. All rights reserved.
//

#import "MEReader+CoreDataModel.h"
#import "DownloadController.h"
#import "DownloadOperation.h"
#import "AppDelegate.h"

@interface DownloadController () <NSURLSessionDelegate, DownloadOperationDelegate>

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSOperationQueue *downloadQueue;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSMutableArray<DownloadOperation *> *downloadingBooks;
@property (nonatomic) NSTimeInterval lastSaveTime;  // throttle coredata save

@end

@implementation DownloadController

+ (instancetype)sharedInstance {
  static DownloadController *sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[DownloadController alloc] init];
  });
  return sharedInstance;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    self.downloadQueue = [[NSOperationQueue alloc] init];
    self.downloadQueue.maxConcurrentOperationCount = 3;
    self.context = AppDelegate.sharedDelegate.persistentContainer.viewContext;
    
    self.downloadingBooks = [[NSMutableArray alloc] init];
   
    
    
    NSString *identifier = [NSString stringWithFormat:@"%@.backgroundSessions", NSBundle.mainBundle.bundleIdentifier];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:identifier];
    self.session = [NSURLSession sessionWithConfiguration:config
                                                 delegate:self
                                            delegateQueue:nil];
    self.lastSaveTime = [[NSDate date] timeIntervalSince1970];
  }
  return self;
}

- (void)downloadBook:(Book *)book {
  if (!book.url) {
    return;
  }
  
  DownloadInfo *downloadInfo = [[DownloadInfo alloc] initWithContext:self.context];
  downloadInfo.downloadedAt = [[NSDate alloc] init];
  downloadInfo.downloadState = DownloadStatePending;
  downloadInfo.book = book;
  downloadInfo.progress = 0;
  NSError *contextSaveError;
  [self.context save:&contextSaveError];
  
  DownloadOperation *downloadOperation = [[DownloadOperation alloc] initBook:book];
  
  downloadOperation.delegate = self;
  [self.downloadQueue addOperation:downloadOperation];
}

- (Book *)bookForDownloadTask:(NSURLSessionDownloadTask *)task {
  __block Book *book;
  __block NSManagedObjectID *objectID;
  [self.downloadingBooks enumerateObjectsUsingBlock:^(DownloadOperation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    if (obj.downloadTask == task) {
      book = obj.book;
      objectID = obj.book.objectID;
    }
  }];
  
  if (!book) {
    book = [self bookWithObjectID:objectID];
  }
  
  return book;
}

- (Book *)bookWithObjectID:(NSManagedObjectID *)objID {
  Book *book = [[self context] objectWithID:objID];
  return book;
}

- (void)saveWithCurrentContext {
  NSError *saveError;
  [[self context] save:&saveError];
  if (saveError) {
    NSLog(@"Error saving context %@", saveError.localizedDescription);
  }
}

- (void)stopDownloadingOperation:(DownloadOperation *)op {
  [op finish];
  [self.downloadingBooks removeObject:op];
}

#pragma mark - DownloadOperationDelegate

- (NSURLSessionDownloadTask *)downloadOperation:(DownloadOperation *)downloadOperation downloadTaskForBook:(Book *)book withURL:(NSURL *)url {
  [self saveWithCurrentContext];
  NSURLSessionDownloadTask *task = [self.session downloadTaskWithURL:url];
  [self.downloadingBooks addObject:downloadOperation];
  return task;
}

- (void)downloadOperation:(DownloadOperation *)downloadOperation didCancelURL:(NSURL *)url {
  [self saveWithCurrentContext];
  [self stopDownloadingOperation:downloadOperation];
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
  Book *book = [self bookForDownloadTask:downloadTask];
  float progress = downloadTask.progress.fractionCompleted;
  NSLog(@"%f", progress);
  book.downloadInfo.progress = progress;
  book.downloadInfo.sizeInBytes = totalBytesWritten;
  book.title = book.title;
  
  /// We need throttle saving to CoreData, this could happen by storing an NSTimeInterval of save time. However, we're currently storing a single NSTimeInterval object for all requests.
//   throttle save
  NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
  if ((now - self.lastSaveTime >= 0.5) || (progress == 1.0)) {
    self.lastSaveTime = [[NSDate date] timeIntervalSince1970];
    [self saveWithCurrentContext];
  }
  
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
  Book *book = [self bookForDownloadTask:(NSURLSessionDownloadTask *)task];
  if (error) {
    NSLog(@"%@", error.localizedDescription);
    if (error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled) {
      book.downloadInfo.downloadState = DownloadStatePaused;
    } else {
      book.downloadInfo.downloadState = DownloadStateFailed;
    }
  } else {
    book.downloadInfo.downloadState = DownloadStateCompleted;
  }
  
  [self.downloadingBooks enumerateObjectsUsingBlock:^(DownloadOperation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    if (obj.downloadTask == task) {
      *stop = YES;
      [self stopDownloadingOperation:obj];
    }
  }];
  
  [self saveWithCurrentContext];
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
  Book *book = [self bookForDownloadTask:(NSURLSessionDownloadTask *)downloadTask];
  
  NSString *ext = downloadTask.currentRequest.URL.pathExtension;
  if (!ext) {
    ext = @"pdf";
  }
  
  NSString *fileName = [NSString stringWithFormat:@"%@.%@", book.uniqueID, ext];
  NSString *privateDownloadsDir = [DownloadInfo absoluteDownloadsPath]; // absolute, not valid dir
  // we need to convert it to a valid relative dir.
  NSURL *relativeDownloadsDir = [[DownloadInfo relativeDocumentDirectory] URLByAppendingPathComponent:privateDownloadsDir]; // valid dir
  
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
//  __weak DownloadController *weakSelf = self;
  [[self context] performBlock:^{
    book.downloadInfo.progress = 1.0;
    book.downloadInfo.sizeInBytes = [(NSNumber *)attrs[NSFileSize] intValue];
    book.downloadInfo.path = absoluteFilePath;
    NSLog(@"downloadPath: %@", absoluteFilePath);
    
    [self.downloadingBooks enumerateObjectsUsingBlock:^(DownloadOperation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
      if (obj.downloadTask == downloadTask) {
        *stop = YES;
        [self stopDownloadingOperation:obj];
      }
    }];
  }];
  
}

@end
