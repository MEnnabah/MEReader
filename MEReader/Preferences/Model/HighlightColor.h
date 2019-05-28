//
//  HighlightColor.h
//  MEReader
//
//  Created by Mohammed Ennabah on 5/27/19.
//  Copyright © 2019 Mohammed Ennabah. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HighlightColor : NSObject<NSCoding>

@property (strong, nonatomic) UIColor *color;
@property (copy, nonatomic) NSString *name;

- (instancetype)initWithColor:(UIColor *)color named:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
