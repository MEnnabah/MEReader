//
//  DownloadOperation.h
//  MEReader
//
//  Created by Mohammed Ennabah on 3/10/19.
//  Copyright © 2019 Mohammed Ennabah. All rights reserved.
//

#import "Operation.h"

NS_ASSUME_NONNULL_BEGIN

@interface DownloadOperation : Operation

@property (nonatomic, copy) NSString *bookID;
@property (nonatomic, strong) NSURL *url;

- (instancetype)initWithURL:(NSURL *)url bookID:(NSString *)bookID;
- (void)cancel;

@end

NS_ASSUME_NONNULL_END
