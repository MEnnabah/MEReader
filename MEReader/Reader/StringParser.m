//
//  StringParser.m
//  MEReader
//
//  Created by Mahmoud Ennabah on 5/15/19.
//  Copyright © 2019 Mohammed Ennabah. All rights reserved.
//

#import "StringParser.h"

@interface StringParser ()

@property (nonatomic, copy) NSMutableArray<NSString *> *paragraphs;

@end

@implementation StringParser

/*
 **Notes about the parser.**
 - It might accept NSAttributedString for easier paragraph splitting.
 - NSAttributedString shows the string with their font family.
 - Reading from NSAttributedString paragraphs reads a word with hyphen space when the word is has no enough space to be represented in one line.
  We might use regex to exclude unwanted characters.
 - We might split our string into paragraphs and add them to array.
 - Each paragraph element should have the start and end index of the paragraph in the entire string.
*/

- (instancetype)initWithString:(NSString *)string {
  self = [super init];
  if (self) {
    self.string = string;
  }
  return self;
}


@end
