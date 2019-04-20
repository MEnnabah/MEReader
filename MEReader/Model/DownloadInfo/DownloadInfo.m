//
//  DownloadInfo.m
//  MEReader
//
//  Created by Mohammed Ennabah on 3/19/19.
//  Copyright © 2019 Mohammed Ennabah. All rights reserved.
//

#import "DownloadInfo.h"
#import "DownloadInfo+CoreDataProperties.h"

@implementation DownloadInfo

- (void)setDownloadState:(DownloadState)downloadState {
  int16_t status = -1;
  if (downloadState == DownloadStatePending) {
    status = 0;
  } else if (downloadState == DownloadStateDownloading) {
    status = 1;
  } else if (downloadState == DownloadStatePaused) {
    status = 2;
  } else if (downloadState == DownloadStateFailed) {
    status = 3;
  } else if (downloadState == DownloadStateCompleted) {
    status = 4;
  } else {
    [NSException raise:@"Invalid download state" format:@"Download state should have a value from the DownloadState enum"];
  }
  self.statusValue = status;
}

- (DownloadState)downloadState {
  if (self.statusValue == 0) {
    return DownloadStatePending;
  } else if (self.statusValue == 1) {
    return DownloadStateDownloading;
  }  else if (self.statusValue == 2) {
    return DownloadStatePaused;
  } else if (self.statusValue == 3) {
    return DownloadStateFailed;
  } else if (self.statusValue == 4) {
    return DownloadStateCompleted;
  } else {
    [NSException raise:@"invalid download state" format:@"Trying to return download state but it has an invalid value"];
    return -1;
  }
}

+ (NSString *)absoluteDownloadsPath {
  return [NSString stringWithFormat:@".downloads/"];
}

+ (NSURL *)relativeDocumentDirectory {
  NSFileManager *manager = NSFileManager.defaultManager;
  NSURL *docs = [manager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject;
  return docs;
}

@end
