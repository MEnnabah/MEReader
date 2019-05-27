//
//  ReaderDefaults.h
//  MEReader
//
//  Created by Mohammed Ennabah on 5/26/19.
//  Copyright © 2019 Mohammed Ennabah. All rights reserved.
//

#import <Foundation/Foundation.h>

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

@property (class, assign, nonatomic) DefaultHighlightContent defaultHighlightContent;
@property (class, assign, nonatomic) HighlightStyle wordHighlightStyle;
@property (class, assign, nonatomic) HighlightStyle sentenceHighlightStyle;

+ (void)syncAvailableHighlightColors;
+ (NSDictionary *)availableHighlightColors;

+ (NSDictionary *)preferedWordHighlightColor;
+ (NSDictionary *)preferedSentenceHighlightColor;

+ (DefaultHighlightContent)defaultHighlightContent;
+ (void)setDefaultHighlightContent:(DefaultHighlightContent)defaultHighlightContent;

+ (HighlightStyle)wordHighlightStyle;
+ (void)setWordHighlightStyle:(HighlightStyle)wordHighlightStyle;

+ (HighlightStyle)sentenceHighlightStyle;
+ (void)setSentenceHighlightStyle:(HighlightStyle)sentenceHighlightStyle;

@end

NS_ASSUME_NONNULL_END
