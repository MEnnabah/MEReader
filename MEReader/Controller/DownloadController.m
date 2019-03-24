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
    [self.downloadQueue setSuspended:YES];
    self.downloadQueue.maxConcurrentOperationCount = 1;
  }
  return self;
}

- (void)downloadBook:(Book *)book {
  if (!book.url) {
    return;
  }

  NSManagedObjectContext *context = AppDelegate.sharedDelegate.persistentContainer.viewContext;
  DownloadInfo *downloadInfo = [[DownloadInfo alloc] initWithContext:context];
  downloadInfo.downloadedAt = [[NSDate alloc] init];
  downloadInfo.downloadState = DownloadStatePending;
  downloadInfo.book = book;
  downloadInfo.progress = 0;
  NSError *contextSaveError;
  [context save:&contextSaveError];

  NSURL *bookURL = [NSURL URLWithString:book.url];
  DownloadOperation *downloadOperation = [[DownloadOperation alloc] initWithURL:bookURL bookID:book.uniqueID];
  [self.downloadQueue addOperation:downloadOperation];
  [self.downloadQueue setSuspended:NO];
}


@end
