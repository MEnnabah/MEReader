//
//  StringParser.h
//  MEReader
//
//  Created by Mahmoud Ennabah on 5/15/19.
//  Copyright © 2019 Mohammed Ennabah. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface StringParser : NSObject

@property (nonatomic, copy) NSString *string;

- (instancetype)initWithString:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
