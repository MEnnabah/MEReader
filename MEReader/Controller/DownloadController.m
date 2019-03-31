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

@interface DownloadController ()

@property (nonatomic, strong) NSOperationQueue *downloadQueue;
@property (nonatomic, strong) NSManagedObjectContext *context;

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
    self.downloadQueue.maxConcurrentOperationCount = 1;
    self.context = AppDelegate.sharedDelegate.persistentContainer.viewContext;
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
  [self.downloadQueue addOperation:downloadOperation];
}


@end
