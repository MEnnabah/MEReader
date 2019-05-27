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
  
  UIColor *blue = [[UIColor alloc] initWithRed:173/255.0 green:216/255.0 blue:255/255.0 alpha:1.0];
  UIColor *yellow = [[UIColor alloc] initWithRed:255/255.0 green:235/255.0 blue:107/255.0 alpha:1.0];
  UIColor *green = [[UIColor alloc] initWithRed:192/255.0 green:237/255.0 blue:114/255.0 alpha:1.0];
  UIColor *pink = [[UIColor alloc] initWithRed:254/255.0 green:176/255.0 blue:202/255.0 alpha:1.0];
  UIColor *purble = [[UIColor alloc] initWithRed:216/255.0 green:178/255.0 blue:255/255.0 alpha:1.0];
  
  NSDictionary<NSString *, UIColor *> *availableColors = @{
                                                           @"Blue": blue,
                                                           @"Yellow": yellow,
                                                           @"Green": green,
                                                           @"Pink": pink,
                                                           @"Purble": purble
                                                           };
  NSError *archiveError;
  NSData *data = [NSKeyedArchiver archivedDataWithRootObject:availableColors requiringSecureCoding:NO error:&archiveError];
  [NSUserDefaults.standardUserDefaults setValue:data forKey:ReaderDefaultsAvailableColors];
}

+ (NSDictionary *)availableHighlightColors {
  NSData *colorsData = [NSUserDefaults.standardUserDefaults valueForKey:ReaderDefaultsAvailableColors];
  NSError *unarchiveError;
  NSArray *classesArr = @[[NSDictionary class], [UIColor class], [NSString class]];
  NSSet<Class> *classes = [[NSSet alloc] initWithArray:classesArr];
  return [NSKeyedUnarchiver unarchivedObjectOfClasses:classes fromData:colorsData error:&unarchiveError];
}

+ (NSDictionary *)preferedWordHighlightColor {
  NSDictionary *wordHighlightColor = [NSUserDefaults.standardUserDefaults valueForKey:ReaderDefaultsWordHighlightColor];
 
  if (!wordHighlightColor || wordHighlightColor.count == 0) {
    return [[self availableHighlightColors] objectForKey:@"Yellow"];
  }
  
  return wordHighlightColor;
}

+ (NSDictionary *)preferedSentenceHighlightColor {
  NSDictionary *sentenceHighlightColor = [NSUserDefaults.standardUserDefaults valueForKey:ReaderDefaultsSentenceHighlightColor];
  
  if (!sentenceHighlightColor || sentenceHighlightColor.count == 0) {
    return [[self availableHighlightColors] objectForKey:@"Purble"];
  }
  
  return sentenceHighlightColor;
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

@end
