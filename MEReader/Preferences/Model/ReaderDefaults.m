//
//  ReaderDefaults.m
//  MEReader
//
//  Created by Mohammed Ennabah on 5/26/19.
//  Copyright © 2019 Mohammed Ennabah. All rights reserved.
//

#import "ReaderDefaults.h"
#import <UIKit/UIKit.h>

@implementation ReaderDefaults

static NSString *const ReaderDefaultsAvailableColors = @"ReaderDefaultsAvailableColorsDefaultsKey";
static NSString *const ReaderDefaultsDefaultHighlightContent = @"ReaderDefaultsDefaultHighlightContentDefaultsKey";
static NSString *const ReaderDefaultsWordHighlightStyle = @"ReaderDefaultsWordHighlightStyleDefaultsKey";
static NSString *const ReaderDefaultsSentenceHighlightStyle = @"ReaderDefaultsSentenceHighlightStyleDefaultsKey";
static NSString *const ReaderDefaultsSentenceHighlightColor = @"ReaderDefaultsSentenceHighlightColorDefaultsKey";
static NSString *const ReaderDefaultsWordHighlightColor = @"ReaderDefaultsWordHighlightColorDefaultsKey";

+ (void)syncAvailableHighlightColors {
  
  HighlightColor *blue = [[HighlightColor alloc] initWithColor:[[UIColor alloc] initWithRed:173/255.0 green:216/255.0 blue:255/255.0 alpha:1.0]
                                                         named:@"Blue"];
  HighlightColor *yellow = [[HighlightColor alloc] initWithColor:[[UIColor alloc] initWithRed:255/255.0 green:235/255.0 blue:107/255.0 alpha:1.0]
                                                           named:@"Yellow"];
  HighlightColor *green = [[HighlightColor alloc] initWithColor:[[UIColor alloc] initWithRed:192/255.0 green:237/255.0 blue:114/255.0 alpha:1.0]
                                                          named:@"Green"];
  HighlightColor *pink = [[HighlightColor alloc] initWithColor:[[UIColor alloc] initWithRed:254/255.0 green:176/255.0 blue:202/255.0 alpha:1.0]
                                                         named:@"Pink"];
  HighlightColor *purble = [[HighlightColor alloc] initWithColor:[[UIColor alloc] initWithRed:216/255.0 green:178/255.0 blue:255/255.0 alpha:1.0]
                                                           named:@"Purble"];

  
  NSArray<HighlightColor *> *availableColors = @[blue, yellow, green, pink, purble];
  NSError *archiveError;
  NSData *data = [NSKeyedArchiver archivedDataWithRootObject:availableColors requiringSecureCoding:NO error:&archiveError];
  [NSUserDefaults.standardUserDefaults setValue:data forKey:ReaderDefaultsAvailableColors];
}

+ (NSArray<HighlightColor *> *)availableHighlightColors {
  NSData *colorsData = [NSUserDefaults.standardUserDefaults valueForKey:ReaderDefaultsAvailableColors];
  NSError *keyedUnarchiverInitializerError;
  NSKeyedUnarchiver *colorsUnarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:colorsData error:&keyedUnarchiverInitializerError];
  colorsUnarchiver.requiresSecureCoding = NO;
  NSArray *classesArr = @[[NSArray class], [HighlightColor class]];
  NSSet<Class> *classes = [[NSSet alloc] initWithArray:classesArr];
  NSArray<HighlightColor *> *availableColors = [colorsUnarchiver decodeObjectOfClasses:classes forKey:NSKeyedArchiveRootObjectKey];
  return availableColors;
}

+ (HighlightColor *)preferedWordHighlightColor {
  HighlightColor *wordHighlightColor = [self insecureCodingUnarchiveObjectForKey:ReaderDefaultsWordHighlightColor class:[HighlightColor class]];
  
  if (!wordHighlightColor) {
    NSArray<HighlightColor *> *allColors = [self availableHighlightColors];
    __block HighlightColor *defaultColor;
    [allColors enumerateObjectsUsingBlock:^(HighlightColor * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
      if ([obj.name isEqualToString:@"Yellow"]) {
        defaultColor = obj;
      }
    }];
    return defaultColor;
  }
  
  return wordHighlightColor;
}

+ (void)setPreferedWordHighlightColor:(HighlightColor *)color {
  [self setInsecureDataWithObject:color forKey:ReaderDefaultsWordHighlightColor];
}

+ (HighlightColor *)preferedSentenceHighlightColor {
  HighlightColor *sentenceHighlightColor = [self insecureCodingUnarchiveObjectForKey:ReaderDefaultsSentenceHighlightColor class:[HighlightColor class]];
  
  if (!sentenceHighlightColor) {
    NSArray<HighlightColor *> *allColors = [self availableHighlightColors];
    __block HighlightColor *defaultColor;
    [allColors enumerateObjectsUsingBlock:^(HighlightColor * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
      if ([obj.name isEqualToString:@"Purble"]) {
        defaultColor = obj;
      }
    }];
    return defaultColor;
    
  }
  
  return sentenceHighlightColor;
}

+ (void)setPreferedSentenceHighlightColor:(HighlightColor *)color {
  [self setInsecureDataWithObject:color forKey:ReaderDefaultsSentenceHighlightColor];
}

+ (DefaultHighlightContent)defaultHighlightContent {
  NSInteger highlightContent = [NSUserDefaults.standardUserDefaults integerForKey:ReaderDefaultsDefaultHighlightContent];
  if (!highlightContent || highlightContent == NSNotFound) {
    highlightContent = DefaultHighlightContentWords;
  }
  return highlightContent;
}

+ (void)setDefaultHighlightContent:(DefaultHighlightContent)defaultHighlightContent {
  [NSUserDefaults.standardUserDefaults setInteger:defaultHighlightContent forKey:ReaderDefaultsDefaultHighlightContent];
}

+ (HighlightStyle)wordHighlightStyle {
  NSInteger highlightStyle = [NSUserDefaults.standardUserDefaults integerForKey:ReaderDefaultsWordHighlightStyle];
  if (!highlightStyle || highlightStyle == NSNotFound) {
    return HighlightStyleBackgroundColor;
  }
  return highlightStyle;
}

+ (void)setWordHighlightStyle:(HighlightStyle)wordHighlightStyle {
  [NSUserDefaults.standardUserDefaults setInteger:wordHighlightStyle forKey:ReaderDefaultsWordHighlightStyle];
}

+ (HighlightStyle)sentenceHighlightStyle {
  NSInteger highlightStyle = [NSUserDefaults.standardUserDefaults integerForKey:ReaderDefaultsSentenceHighlightStyle];
  if (!highlightStyle || highlightStyle == NSNotFound) {
    return HighlightStyleUnderline;
  }
  return highlightStyle;
}

+ (void)setSentenceHighlightStyle:(HighlightStyle)sentenceHighlightStyle {
  [NSUserDefaults.standardUserDefaults setInteger:sentenceHighlightStyle forKey:ReaderDefaultsSentenceHighlightStyle];
}

+ (id)insecureCodingUnarchiveObjectForKey:(NSString *)key class:(Class)aClass {
  NSData *data = [NSUserDefaults.standardUserDefaults valueForKey:key];
  NSError *keyedUnarchiverInitializerError;
  NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:data error:&keyedUnarchiverInitializerError];
  unarchiver.requiresSecureCoding = NO;
  return [unarchiver decodeObjectOfClass:aClass forKey:NSKeyedArchiveRootObjectKey];
}

+ (void)setInsecureDataWithObject:(id)object forKey:(NSString *)key {
  NSError *archiveError;
  NSData *data = [NSKeyedArchiver archivedDataWithRootObject:object requiringSecureCoding:NO error:&archiveError];
  [NSUserDefaults.standardUserDefaults setValue:data forKey:key];
}

@end
