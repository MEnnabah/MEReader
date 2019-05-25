//
//  StringParser.h
//  MEReader
//
//  Created by Mahmoud Ennabah on 5/15/19.
//  Copyright © 2019 Mohammed Ennabah. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//typedef NS_ENUM(NSUInteger, TagUnit) {
//  TagUnitSentence,
//  TagUnitWord
//};

@interface StringParser : NSObject

@property (nonatomic, copy) NSString *string;
//@property (nonatomic, assign) TagUnit* unit;

//- (instancetype)initWithString:(NSString *)string unit:(TagUnit *)tag;
- (instancetype)initWithString:(NSString *)string;

- (NSUInteger)indexOfSentenceAtCharIndex:(NSUInteger)index;
- (NSString *)sentenceAtIndex:(NSUInteger)index;
- (NSRange)rangeForSentenceAtIndex:(NSUInteger)index;
- (NSArray<NSValue *> *)wordsRangesInSentenceAtIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
