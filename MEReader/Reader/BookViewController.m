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

@interface BookViewController () <PDFViewDelegate, PDFDocumentDelegate, AVSpeechSynthesizerDelegate>

@property (strong, nonatomic) PDFView *pdfView;
@property (strong, nonatomic) PDFDocument *pdfDocument;
@property (strong, nonatomic) AVSpeechSynthesizer *speechSynthesizer;
@property (strong, nonatomic) PDFPage *currentPage;
@property (assign, nonatomic) NSRange currentUtteranceRange;

@end

@implementation BookViewController

// pdfView -> [PDFPage] -> convert point to string at point -> get the statement.

- (instancetype)initWithDocumentAtURL:(NSURL *)documentURL {
  self = [super initWithNibName:nil bundle:nil];
  
  if (self) {
    self.pdfDocument = [[PDFDocument alloc] initWithURL:documentURL];
    
    NSError *setCategoryError = nil;
    NSError *setActiveError = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&setCategoryError];
    [[AVAudioSession sharedInstance] setActive:YES error:&setActiveError];
    
    self.speechSynthesizer = [[AVSpeechSynthesizer alloc] init];
    self.speechSynthesizer.delegate = self;
  }
  
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
  [self.view addGestureRecognizer:tapGesture];

  self.view.backgroundColor = UIColor.lightGrayColor;
  self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneViewingBook)];
  
  [self setupPDFView];
}

- (void)viewTapped:(UITapGestureRecognizer *)tapGesture {
  CGPoint location = [tapGesture locationInView:self.pdfView];
  PDFSelection *selection = [self selectionForStatementAtPoint:location];
  // what to do with selection?
}

- (PDFSelection *)selectionForStatementAtPoint:(CGPoint)point {
  
  self.currentPage = [self.pdfView pageForPoint:point nearest:NO]; // may return nil
  PDFPoint pagePoint = [self.pdfView convertPoint:point toPage:self.currentPage];
  NSInteger charIndex = [self.currentPage characterIndexAtPoint:pagePoint];
  if (charIndex < NSIntegerMax && charIndex >= 0) {
    
    NSLinguisticTagger *tagger = [[NSLinguisticTagger alloc] initWithTagSchemes:@[NSLinguisticTagSchemeTokenType] options:0];
    tagger.string = self.currentPage.string;
    NSRange range = NSMakeRange(0, self.currentPage.string.length);
    //  NSLinguisticTaggerOptions *options = NSLinguisticTagWhitespace;
    
    [tagger enumerateTagsInRange:range unit:NSLinguisticTaggerUnitSentence scheme:NSLinguisticTagSchemeTokenType options:0 usingBlock:^(NSLinguisticTag  _Nullable tag, NSRange tokenRange, BOOL * _Nonnull stop) {
      if (NSLocationInRange(charIndex, tokenRange)) {
        
//        PDFSelection *statementSelection = [self.currentPage selectionForRange:tokenRange];
//        PDFAnnotation *statementHighlight = [[PDFAnnotation alloc] initWithBounds:[statementSelection boundsForPage:self.currentPage]
//                                                                          forType:PDFAnnotationSubtypeHighlight withProperties:nil];
//        statementHighlight.color = [UIColor greenColor];
//        [self.currentPage addAnnotation:statementHighlight];
//        [self.currentPage setDisplaysAnnotations:YES];
        
        NSString *subs = [self.currentPage.string substringWithRange:tokenRange];
        self.currentUtteranceRange = tokenRange;
        AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:subs];
        utterance.volume = 1.0;
        [self.speechSynthesizer speakUtterance:utterance];
      }
    }];
    
  }
  
  return nil;
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  self.pdfView.autoScales = YES;
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

- (void)doneViewingBook {
  [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer willSpeakRangeOfSpeechString:(NSRange)characterRange utterance:(AVSpeechUtterance *)utterance {
  NSRange relativeRange = NSMakeRange(self.currentUtteranceRange.location + characterRange.location, characterRange.length);
  PDFSelection *wordSelection = [self.currentPage selectionForRange:relativeRange];
  PDFAnnotation *statementHighlight = [[PDFAnnotation alloc] initWithBounds:[wordSelection boundsForPage:self.currentPage] forType:PDFAnnotationSubtypeHighlight withProperties:nil];
  statementHighlight.color = [UIColor yellowColor];
  [self.currentPage setDisplaysAnnotations:YES];
  [self.currentPage addAnnotation:statementHighlight];
}

@end
