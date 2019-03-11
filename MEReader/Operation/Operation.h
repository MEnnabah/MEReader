//
//  Operation.h
//  MEReader
//
//  Created by Mohammed Ennabah on 3/9/19.
//  Copyright © 2019 Mohammed Ennabah. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Operation : NSOperation

- (void)execute;
- (void)finish;

@end

NS_ASSUME_NONNULL_END
