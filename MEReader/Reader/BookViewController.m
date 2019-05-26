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
#import "PDFAnnotationManager.h"

@interface BookViewController () <PDFViewDelegate, PDFDocumentDelegate, AVSpeechSynthesizerDelegate>

@property (strong, nonatomic) PDFView *pdfView;
@property (strong, nonatomic) PDFDocument *pdfDocument;

@property (strong, nonatomic) AVSpeechSynthesizer *speechSynthesizer;
@property (strong, nonatomic) StringParser *parser;
@property (strong, nonatomic) PDFAnnotationManager *annotationManager;

@property (strong, nonatomic) PDFPage *currentPage;
@property (assign, nonatomic) NSRange currentUtteranceRange;
@property (assign, nonatomic) NSUInteger currentSentenceIndex;

@end

@implementation BookViewController

#pragma mark - Initializer

- (instancetype)initWithDocumentAtURL:(NSURL *)documentURL {
  self = [super initWithNibName:nil bundle:nil];
  
  if (self) {
    self.pdfDocument = [[PDFDocument alloc] initWithURL:documentURL];
    self.annotationManager = [[PDFAnnotationManager alloc] init];
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

- (void)showsStopButton:(BOOL)flag {
  if (flag == YES) {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Stop"] style:(UIBarButtonItemStyleDone) target:self action:@selector(stopSpeaking)];
  } else {
    self.navigationItem.rightBarButtonItem = nil;
  }
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  self.pdfView.autoScales = YES;
  
  self.navigationController.hidesBarsOnSwipe = YES;
  self.navigationController.hidesBarsOnTap = YES;
}

- (void)doneViewingBook {
  [self.speechSynthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
  [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Highlighting

- (void)viewTapped:(UITapGestureRecognizer *)tapGesture {
  if (self.speechSynthesizer.isSpeaking) {
    if (self.speechSynthesizer.isPaused) {
      [self.speechSynthesizer continueSpeaking];
    } else {
      [self.speechSynthesizer pauseSpeakingAtBoundary:(AVSpeechBoundaryImmediate)];
      [self.navigationController setNavigationBarHidden:NO];
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
  
  self.currentSentenceIndex = [self.parser indexOfSentenceAtCharIndex:charIndex];
  [self updateUtteranceAtCurrentSentenceIndex];
}

- (void)updateUtteranceAtCurrentSentenceIndex {
  NSRange sentenceRange = [self.parser rangeForSentenceAtIndex:self.currentSentenceIndex];
  
  if (sentenceRange.location == NSNotFound) {
    // Next sentence is out of page's range. We may go to next page and start reading.
    return;
  }
  
  self.currentUtteranceRange = sentenceRange;
  
  NSArray<NSValue *> *ranges = [self.parser wordsRangesInSentenceAtIndex:self.currentSentenceIndex withOffset:sentenceRange.location];
  [self.annotationManager removeRecentlyAddedSentenceAnnotationToPage:self.currentPage];
  [self.annotationManager addSentenceAnnotationToPage:self.currentPage withRangeValues:ranges];
  
  NSString *sentence = [self.parser sentenceAtIndex:self.currentSentenceIndex];
  [self speakString:sentence];
}

- (NSInteger)charIndexOfPage:(PDFPage *)page atPoint:(CGPoint)point {
  PDFPoint pagePoint = [self.pdfView convertPoint:point toPage:self.currentPage];
  NSInteger charIndex = [page characterIndexAtPoint:pagePoint];
  return charIndex;
}

#pragma mark - Playback

- (void)speakString:(NSString *)string {
  AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:[string lowercaseString]];
  [self.speechSynthesizer speakUtterance:utterance];
  [self showsStopButton:YES];
}

- (void)stopSpeaking {
  [self.speechSynthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
  [self.annotationManager removeAllAnnotationsAtPage:self.currentPage];
  [self showsStopButton:NO];
}

#pragma mark - AVSpeechSynthesizerDelegate

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer willSpeakRangeOfSpeechString:(NSRange)characterRange utterance:(AVSpeechUtterance *)utterance {
  NSRange relativeRange = NSMakeRange(self.currentUtteranceRange.location + characterRange.location, characterRange.length);
  [self.annotationManager removeRecentlyAddedWordAnnotationToPage:self.currentPage];
  [self.annotationManager addWordAnnotationToPage:self.currentPage withRange:relativeRange];
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance {
  self.currentSentenceIndex++;
  [self.annotationManager removeRecentlyAddedSentenceAnnotationToPage:self.currentPage];
  [self.annotationManager removeRecentlyAddedWordAnnotationToPage:self.currentPage];
  [self updateUtteranceAtCurrentSentenceIndex];
}

@end
