//
//  DownloadOperation.h
//  MEReader
//
//  Created by Mohammed Ennabah on 3/10/19.
//  Copyright © 2019 Mohammed Ennabah. All rights reserved.
//

#import "Operation.h"
#import "MEReader+CoreDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@class DownloadOperation;

@protocol DownloadOperationDelegate <NSObject>

@optional
- (void)downloadOperation:(DownloadOperation *)downloadOperation didCancelURL:(NSURL *)url;
- (void)downloadOperationDidFinish:(DownloadOperation *)downloadOperation;
@required
- (NSURLSessionDownloadTask *)downloadOperation:(DownloadOperation *)downloadOperation downloadTaskForBook:(Book *)book withURL:(NSURL *)url;

@end

@interface DownloadOperation : Operation

@property (nonatomic, strong) Book *book;
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, weak) id <DownloadOperationDelegate> delegate;

- (instancetype)initBook:(Book *)book;
- (void)cancel;

@end

NS_ASSUME_NONNULL_END
