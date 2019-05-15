//
//  BookViewController.m
//  MEReader
//
//  Created by Mohammed Ennabah on 3/8/19.
//  Copyright © 2019 Mohammed Ennabah. All rights reserved.
//

#import "BookViewController.h"
#import <PDFKit/PDFKit.h>

@interface BookViewController () <PDFViewDelegate, PDFDocumentDelegate>

@property (strong) PDFView *pdfView;
@property (strong) PDFDocument *pdfDocument;

@end

@implementation BookViewController

// pdfView -> [PDFPage] -> convert point to string at point -> get the statement.

- (instancetype)initWithDocumentAtURL:(NSURL *)documentURL {
  self = [super initWithNibName:nil bundle:nil];
  
  if (self) {
    
    self.pdfDocument = [[PDFDocument alloc] initWithURL:documentURL];
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
  
  PDFPage *containingPage = [self.pdfView pageForPoint:point nearest:NO]; // may return nil
  PDFPoint pagePoint = [self.pdfView convertPoint:point toPage:containingPage];
  PDFSelection *wordSelection = [containingPage selectionForWordAtPoint:pagePoint];
  NSInteger charIndex = [containingPage characterIndexAtPoint:pagePoint];
  if (charIndex < NSIntegerMax && charIndex >= 0) {
    unichar currentChar = [containingPage.string characterAtIndex:charIndex];
    
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

@end
