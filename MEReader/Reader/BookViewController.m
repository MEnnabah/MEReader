//
//  BookViewController.m
//  MEReader
//
//  Created by Mohammed Ennabah on 3/8/19.
//  Copyright © 2019 Mohammed Ennabah. All rights reserved.
//

#import "BookViewController.h"
#import <PDFKit/PDFKit.h>
#import <AVFoundation/AVFoundation.h>
#import "StringParser.h"

@interface BookViewController () <PDFViewDelegate, PDFDocumentDelegate, AVSpeechSynthesizerDelegate>

@property (strong, nonatomic) PDFView *pdfView;
@property (strong, nonatomic) PDFDocument *pdfDocument;

@property (strong, nonatomic) StringParser *parser;
@property (strong, nonatomic) AVSpeechSynthesizer *speechSynthesizer;

@property (strong, nonatomic) PDFPage *currentPage;
@property (assign, nonatomic) NSRange currentUtteranceRange;

@end

@implementation BookViewController

#pragma mark - Initializer

- (instancetype)initWithDocumentAtURL:(NSURL *)documentURL {
  self = [super initWithNibName:nil bundle:nil];
  
  if (self) {
    self.pdfDocument = [[PDFDocument alloc] initWithURL:documentURL];
    [self prepareSpeechSynthesizer];
  }
  
  return self;
}

#pragma mark Helpers

- (void)prepareSpeechSynthesizer {
  NSError *setCategoryError = nil;
  NSError *setActiveError = nil;
  [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&setCategoryError];
  [[AVAudioSession sharedInstance] setActive:YES error:&setActiveError];
  
  self.speechSynthesizer = [[AVSpeechSynthesizer alloc] init];
  self.speechSynthesizer.delegate = self;
}

- (void)setupPDFView {
  self.pdfView = [[PDFView alloc] init];
  self.pdfView.document = self.pdfDocument;
  self.pdfView.delegate = self;
  self.pdfView.translatesAutoresizingMaskIntoConstraints = NO;
  [self.view addSubview:self.pdfView];
  [[self.pdfView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor] setActive:YES];
  [[self.pdfView.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor] setActive:YES];
  [[self.pdfView.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor] setActive:YES];
  [[self.pdfView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor] setActive:YES];
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  
  UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
  [self.view addGestureRecognizer:tapGesture];

  self.view.backgroundColor = UIColor.lightGrayColor;
  self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneViewingBook)];
  
  [self setupPDFView];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  self.pdfView.autoScales = YES;
}

- (void)doneViewingBook {
  [self.speechSynthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
  [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Highlighting and Speaking

- (void)viewTapped:(UITapGestureRecognizer *)tapGesture {
  if (self.speechSynthesizer.isSpeaking) {
    if (self.speechSynthesizer.isPaused) {
      [self.speechSynthesizer continueSpeaking];
    } else {
      [self.speechSynthesizer pauseSpeakingAtBoundary:(AVSpeechBoundaryImmediate)];
    }
    return;
  }
  
  
  CGPoint location = [tapGesture locationInView:self.pdfView];
  
  PDFPage *tappedPage = [self.pdfView pageForPoint:location nearest:NO]; // may return nil
  
  if (!tappedPage) {
    return;
  }
  if (tappedPage != self.currentPage) {
    self.currentPage = tappedPage;
    self.parser = [[StringParser alloc] initWithString:tappedPage.string];
  }
  
  NSUInteger charIndex = [self charIndexOfPage:self.currentPage atPoint:location];
  
  if (charIndex >= tappedPage.string.length) {
    // we should have the charindex inside the string length.
    return;
  }
  
  NSUInteger sentenceIndex = [self.parser indexOfSentenceAtCharIndex:charIndex];
  
  NSRange sentenceRange = [self.parser rangeForSentenceAtIndex:sentenceIndex];
  self.currentUtteranceRange = sentenceRange;
  
  NSArray<NSValue *> *ranges = [self.parser wordsRangesInSentenceAtIndex:sentenceIndex withOffset:sentenceRange.location];
  [self highlightRanges:ranges ofFocusedPageWithColor:[[UIColor magentaColor] colorWithAlphaComponent:0.25] annotationType:(PDFAnnotationSubtypeUnderline)];
  
  NSString *sentence = [self.parser sentenceAtIndex:sentenceIndex];
  [self speakString:sentence];
}

- (NSInteger)charIndexOfPage:(PDFPage *)page atPoint:(CGPoint)point {
  PDFPoint pagePoint = [self.pdfView convertPoint:point toPage:self.currentPage];
  NSInteger charIndex = [page characterIndexAtPoint:pagePoint];
  return charIndex;
}

- (void)speakString:(NSString *)string {
  AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:[string lowercaseString]];
  [self.speechSynthesizer speakUtterance:utterance];
}

- (void)highlightRanges:(NSArray<NSValue *> *)ranges ofFocusedPageWithColor:(UIColor *)color annotationType:(PDFAnnotationSubtype)type {
  for (NSValue *range in ranges) {
    PDFSelection *selection = [self.currentPage selectionForRange:range.rangeValue];
    PDFAnnotation *highlight = [[PDFAnnotation alloc] initWithBounds:[selection boundsForPage:self.currentPage] forType:type withProperties:nil];
    highlight.color = color;
    [self.currentPage setDisplaysAnnotations:YES];
    [self.currentPage addAnnotation:highlight];
  }
}

#pragma mark - AVSpeechSynthesizerDelegate

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer willSpeakRangeOfSpeechString:(NSRange)characterRange utterance:(AVSpeechUtterance *)utterance {
  NSRange relativeRange = NSMakeRange(self.currentUtteranceRange.location + characterRange.location, characterRange.length);
  [self highlightRanges:@[[NSValue valueWithRange:relativeRange]] ofFocusedPageWithColor:[UIColor yellowColor] annotationType:PDFAnnotationSubtypeHighlight];
}

@end
