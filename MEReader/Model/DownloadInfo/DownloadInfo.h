//
//  DownloadInfo.h
//  MEReader
//
//  Created by Mohammed Ennabah on 3/19/19.
//  Copyright © 2019 Mohammed Ennabah. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "Book.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(int16_t, DownloadState) {
  DownloadStatePending,
  DownloadStateDownloading,
  DownloadStatePaused,
  DownloadStateFailed,
  DownloadStateCompleted,
};

@interface DownloadInfo : NSManagedObject

@property (nonatomic) DownloadState downloadState;
+ (NSString *)absoluteDownloadsPath;
+ (NSURL *)relativeDocumentDirectory;

@end

NS_ASSUME_NONNULL_END
