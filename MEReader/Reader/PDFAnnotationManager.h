//
//  PDFAnnotationManager.h
//  MEReader
//
//  Created by Mohammed Ennabah on 5/25/19.
//  Copyright © 2019 Mohammed Ennabah. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PDFKit/PDFKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PDFAnnotationManager : NSObject

- (void)addWordAnnotationToPage:(PDFPage *)page withRange:(NSRange)range;
- (void)addSentenceAnnotationToPage:(PDFPage *)page withRangeValues:(NSArray<NSValue *> *)ranges;
- (void)removeRecentlyAddedWordAnnotationToPage:(PDFPage *)page;
- (void)removeRecentlyAddedSentenceAnnotationToPage:(PDFPage *)page;
- (void)removeAllAnnotationsAtPage:(PDFPage *)page;

@end

NS_ASSUME_NONNULL_END
