//
//  StringParser.m
//  MEReader
//
//  Created by Mahmoud Ennabah on 5/15/19.
//  Copyright © 2019 Mohammed Ennabah. All rights reserved.
//

#import "StringParser.h"

@interface StringParser ()

@property (nonatomic, copy) NSMutableArray<NSString *> *statements;

@end

@implementation StringParser

- (instancetype)initWithString:(NSString *)string {
  self = [super init];
  if (self) {
    self.string = string;
    self.statements = [NSMutableArray array];
  }
  return self;
}

- (void)splitStringIntoStatements {
  // we may split our string and store it into an array so have direct access in `statementAtIndex:`.
  
}


/// @param index is the char index in the provided string.
/// @return NSString of the statement the char index falls in.

- (NSString *)statementAtIndex:(NSUInteger)index {
  if (index >= self.string.length) {
    return nil;
  }
  
//  NSUInteger statementStartIndex;
//  NSUInteger statementEndIndex;
  
  NSLinguisticTagger *tagger = [[NSLinguisticTagger alloc] initWithTagSchemes:@[NSLinguisticTagSchemeTokenType] options:0];
  tagger.string = self.string;
  NSRange range = NSMakeRange(0, self.string.length);
  //  NSLinguisticTaggerOptions *options = NSLinguisticTagWhitespace;
  [tagger enumerateTagsInRange:range unit:NSLinguisticTaggerUnitSentence scheme:NSLinguisticTagSchemeTokenType options:0 usingBlock:^(NSLinguisticTag  _Nullable tag, NSRange tokenRange, BOOL * _Nonnull stop) {
    NSString *subs = [self.string substringWithRange:tokenRange];
    if (NSLocationInRange(index, tokenRange)) {
      NSLog(@"✅ %@", subs);
    } else {
      NSLog(@"%@", subs);
    }
  }];
  
  
//  [self.string enumerateLinguisticTagsInRange:<#(NSRange)#> scheme:(NSLinguisticTagScheme) options:(NSLinguisticTaggerUnitSentence) orthography:<#(nullable NSOrthography *)#> usingBlock:<#^(NSLinguisticTag  _Nullable tag, NSRange tokenRange, NSRange sentenceRange, BOOL * _Nonnull stop)block#>]
  
  return nil;
}

@end
