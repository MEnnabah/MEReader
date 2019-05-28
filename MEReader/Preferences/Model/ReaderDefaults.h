//
//  ReaderDefaults.h
//  MEReader
//
//  Created by Mohammed Ennabah on 5/26/19.
//  Copyright © 2019 Mohammed Ennabah. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HighlightColor.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, DefaultHighlightContent) {
  DefaultHighlightContentWords,
  DefaultHighlightContentSentences,
  DefaultHighlightContentWordsAndSentnces,
};

typedef NS_ENUM(NSUInteger, HighlightStyle) {
  HighlightStyleBackgroundColor,
  HighlightStyleUnderline,
};

@interface ReaderDefaults : NSObject

+ (void)syncAvailableHighlightColors;
+ (NSArray<HighlightColor *> *)availableHighlightColors;

+ (DefaultHighlightContent)defaultHighlightContent;
+ (void)setDefaultHighlightContent:(DefaultHighlightContent)defaultHighlightContent;

+ (HighlightStyle)wordHighlightStyle;
+ (void)setWordHighlightStyle:(HighlightStyle)wordHighlightStyle;

+ (HighlightStyle)sentenceHighlightStyle;
+ (void)setSentenceHighlightStyle:(HighlightStyle)sentenceHighlightStyle;

+ (HighlightColor *)preferedWordHighlightColor;
+ (void)setPreferedWordHighlightColor:(HighlightColor *)color;

+ (HighlightColor *)preferedSentenceHighlightColor;
+ (void)setPreferedSentenceHighlightColor:(HighlightColor *)color;

@end

NS_ASSUME_NONNULL_END
