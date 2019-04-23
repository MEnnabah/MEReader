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

@interface DownloadOperation ()

@property (nonatomic, strong) NSManagedObjectContext *context;

@end

@implementation DownloadOperation

#pragma mark - Initializer

- (instancetype)initBook:(Book *)book {
  self = [super init];
  if (self) {
    self.book = book;
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

#pragma mark - Override

- (void)execute {
  
  if (!self.delegate) {
    [NSException raise:@"nil delegate" format:@"Download Operation delegate should be set upon "];
  }
  
  self.book.downloadInfo.downloadState = DownloadStateDownloading;
  self.downloadTask = [self.delegate downloadOperation:self downloadTaskForBook:self.book withURL:[NSURL URLWithString:self.book.url]];
  [self.downloadTask resume];
}

- (void)cancel {
  self.book.downloadInfo.downloadState = DownloadStatePaused;
  [self.delegate downloadOperation:self didCancelURL:[NSURL URLWithString:self.book.url]];
  [self.downloadTask cancel];
  [self finish];
}

- (void)finish {
  if ([self.delegate respondsToSelector:@selector(downloadOperationDidFinish:)]) {
    [self.delegate downloadOperationDidFinish:self];    
  }
  [super finish];
}

@end
