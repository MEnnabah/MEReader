//
//  PDFAnnotationManager.m
//  MEReader
//
//  Created by Mohammed Ennabah on 5/25/19.
//  Copyright © 2019 Mohammed Ennabah. All rights reserved.
//

#import "PDFAnnotationManager.h"
#import "ReaderDefaults.h"

@interface PDFAnnotationManager ()

@property (strong, nonatomic) NSMutableArray<PDFAnnotation *> *words;
@property (strong, nonatomic) NSMutableArray<NSArray <PDFAnnotation *> *> *sentencesWords;

@property (assign, nonatomic) PDFAnnotationSubtype wordAnnotationType;
@property (assign, nonatomic) PDFAnnotationSubtype sentenceAnnotationType;

@property (strong, nonatomic) UIColor *wordColor;
@property (strong, nonatomic) UIColor *sentenceColor;
@end

@implementation PDFAnnotationManager

- (instancetype)init
{
  self = [super init];
  if (self) {
    self.words = [NSMutableArray array];
    self.sentencesWords = [NSMutableArray array];
    
    HighlightStyle wordStyle = [ReaderDefaults wordHighlightStyle];
    if (wordStyle == HighlightStyleBackgroundColor) {
      self.wordAnnotationType = PDFAnnotationSubtypeHighlight;
    } else {
      self.wordAnnotationType = PDFAnnotationSubtypeUnderline;
    }
    
    HighlightStyle sentenceStyle = [ReaderDefaults sentenceHighlightStyle];
    if (sentenceStyle == HighlightStyleUnderline) {
      self.sentenceAnnotationType = PDFAnnotationSubtypeUnderline;
    } else {
      self.sentenceAnnotationType = PDFAnnotationSubtypeHighlight;
    }
    
    self.wordColor = [ReaderDefaults preferedWordHighlightColor].color;
    self.sentenceColor = [ReaderDefaults preferedSentenceHighlightColor].color;
    
  }
  return self;
}

#pragma mark - Public

- (void)addWordAnnotationToPage:(PDFPage *)page withRange:(NSRange)range {
  PDFAnnotation *wordAnnotation = [self addAnnotationsToPage:page withRanges:@[[NSValue valueWithRange:range]] color:self.wordColor annotationType:self.wordAnnotationType].firstObject;
  [self.words addObject:wordAnnotation];
}

- (void)addSentenceAnnotationToPage:(PDFPage *)page withRangeValues:(NSArray<NSValue *> *)ranges {
  NSArray<PDFAnnotation *> *sentenceWords = [self addAnnotationsToPage:page withRanges:ranges color:[self.sentenceColor colorWithAlphaComponent:0.75] annotationType:self.sentenceAnnotationType];
  [self.sentencesWords addObject:sentenceWords];
}

- (void)removeRecentlyAddedWordAnnotationToPage:(PDFPage *)page {
  [page removeAnnotation:self.words.lastObject];
  [self.words removeLastObject];
}

- (void)removeRecentlyAddedSentenceAnnotationToPage:(PDFPage *)page {
  NSArray<PDFAnnotation *> *lastSentenceWords = self.sentencesWords.lastObject;
  for (PDFAnnotation *wordAnnotation in lastSentenceWords) {
    [self removeAnnotation:wordAnnotation atPage:page];
  }
}

- (void)removeAllAnnotationsAtPage:(PDFPage *)page {
  for (NSArray<PDFAnnotation *> *sentence in self.sentencesWords) {
    for (PDFAnnotation *word in sentence) {
      [page removeAnnotation:word];
    }
  }
  
  for (PDFAnnotation *word in self.words) {
    [page removeAnnotation:word];
  }
  
  [self.sentencesWords removeAllObjects];
  [self.words removeAllObjects];
}

#pragma mark - Private

- (NSArray<PDFAnnotation *> *)addAnnotationsToPage:(PDFPage *)page withRanges:(NSArray<NSValue *> *)ranges color:(UIColor *)color annotationType:(PDFAnnotationSubtype)type {
  
  NSMutableArray<PDFAnnotation *> *annotations = [NSMutableArray array];
  for (NSValue *range in ranges) {
    PDFSelection *selection = [page selectionForRange:range.rangeValue];
    PDFAnnotation *highlight = [[PDFAnnotation alloc] initWithBounds:[selection boundsForPage:page] forType:type withProperties:nil];
    highlight.color = color;
    [page setDisplaysAnnotations:YES];
    [page addAnnotation:highlight];
    
    [annotations addObject:highlight];
  }
  
  return annotations;
}

- (void)removeAnnotation:(PDFAnnotation *)annotation atPage:(PDFPage *)page {
  [page removeAnnotation:annotation];
}

@end
