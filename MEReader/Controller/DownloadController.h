//
//  DownloadController.h
//  MEReader
//
//  Created by Mohammed Ennabah on 3/19/19.
//  Copyright © 2019 Mohammed Ennabah. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DownloadController : NSObject

+ (instancetype)sharedInstance;
- (void)downloadBook:(Book *)book;

@end

NS_ASSUME_NONNULL_END
