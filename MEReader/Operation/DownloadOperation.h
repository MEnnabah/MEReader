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

@interface DownloadOperation : Operation

@property (nonatomic, strong) Book *book;

- (instancetype)initBook:(Book *)book;
- (void)cancel;

@end

NS_ASSUME_NONNULL_END
