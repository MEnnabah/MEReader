//
//  StringParser.m
//  MEReader
//
//  Created by Mahmoud Ennabah on 5/15/19.
//  Copyright © 2019 Mohammed Ennabah. All rights reserved.
//

#import "StringParser.h"

@interface StringParser ()

@property (copy, nonatomic) NSArray<NSValue *> *sentencesRanges;

@end

@implementation StringParser

#pragma mark - Initializer

- (instancetype)initWithString:(NSString *)string {//unit:(TagUnit *)tag {
  self = [super init];
  if (self) {
    self.string = string;
//    self.unit = tag;
    self.sentencesRanges = [self sentencesRangesInString];
  }
  return self;
}

#pragma mark - Public

- (NSUInteger)indexOfSentenceAtCharIndex:(NSUInteger)index {
  
  __block NSUInteger fallingIndex;
  [self.sentencesRanges enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    NSRange enumeratingRange = obj.rangeValue;
    if (NSLocationInRange(index, enumeratingRange)) {
      fallingIndex = idx;
    }
  }];
  
  return fallingIndex;
}

- (NSString *)sentenceAtIndex:(NSUInteger)index {
  NSRange sentenceRange = [self.sentencesRanges objectAtIndex:index].rangeValue;
  NSString *sentence =  [self.string substringWithRange:sentenceRange];
  return sentence;
}

- (NSRange)rangeForSentenceAtIndex:(NSUInteger)index {
  if (index < self.sentencesRanges.count) {
    return [self.sentencesRanges objectAtIndex:index].rangeValue;
  } else {
    return NSMakeRange(NSNotFound, 0);
  }
}

#pragma mark - Tokenizing

- (NSArray<NSValue *> *)sentencesRangesInString {
  NSLinguisticTagger *tagger = [self taggerInString:self.string];
  NSRange range = NSMakeRange(0, self.string.length);
  
  NSMutableArray<NSValue *> *ranges = [NSMutableArray array];
  [tagger enumerateTagsInRange:range unit:NSLinguisticTaggerUnitSentence scheme:NSLinguisticTagSchemeTokenType options:0 usingBlock:^(NSLinguisticTag  _Nullable tag, NSRange tokenRange, BOOL * _Nonnull stop) {
    [ranges addObject:[NSValue valueWithRange:tokenRange]];
  }];
  
  return ranges;
}

/**
 The word tokens related to a single sentence of a string.
 
 @param index The sentence index of the entire string.
 Can be obtained from `indexOfSentenceAtCharIndex:`.
 @param offset Used to offset the range of every word.
 
 @return NSRange of every word casted to NSValue object.
*/

- (NSArray<NSValue *> *)wordsRangesInSentenceAtIndex:(NSUInteger)index withOffset:(NSUInteger)offset {
  NSString *sentence = [self sentenceAtIndex:index];
  NSLinguisticTagger *tagger = [self taggerInString:sentence];
  NSRange range = NSMakeRange(0, sentence.length);
  
  NSMutableArray<NSValue *> *ranges = [NSMutableArray array];
  [tagger enumerateTagsInRange:range unit:NSLinguisticTaggerUnitWord scheme:NSLinguisticTagSchemeTokenType options:0 usingBlock:^(NSLinguisticTag  _Nullable tag, NSRange tokenRange, BOOL * _Nonnull stop) {
    [ranges addObject:[NSValue valueWithRange:NSMakeRange(tokenRange.location + offset, tokenRange.length)]];
  }];
  
  return ranges;
}

- (NSLinguisticTagger *)taggerInString:(NSString *)processingString {
  
  NSArray<NSLinguisticTagScheme> *tags = @[NSLinguisticTagSchemeTokenType];
  NSLinguisticTaggerOptions options = NSLinguisticTaggerOmitWhitespace | NSLinguisticTaggerJoinNames | NSLinguisticTaggerOmitOther;
  
  NSLinguisticTagger *tagger = [[NSLinguisticTagger alloc] initWithTagSchemes:tags options:options];
  tagger.string = processingString;
  
  return tagger;
}

@end
