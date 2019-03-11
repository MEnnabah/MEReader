//
//  BookBrowserViewController.m
//  MEReader
//
//  Created by Mohammed Ennabah on 3/8/19.
//  Copyright © 2019 Mohammed Ennabah. All rights reserved.
//

#import "BookBrowserViewController.h"
#import "BookViewController.h"
#import "DownloadOperation.h"
#import "NotificationName.h"
#import "BookBrowserTableViewCell.h"

@interface Book : NSObject

@property (nonatomic, copy) NSString* bookID;
@property (nonatomic, assign) float downloadProgress;

- (instancetype)initWithID:(NSString *)bookID;

@end

@implementation Book

- (instancetype)initWithID:(NSString *)bookID {
  self = [super init];
  if (self) {
    self.bookID = bookID;
  }
  return self;
}

@end

@interface BookBrowserViewController ()

@property (nonatomic, strong) NSMutableArray<Book *> *books;
@property (nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation BookBrowserViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.operationQueue = [[NSOperationQueue alloc] init];
  self.books = [NSMutableArray array];
  
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewBook:)];
  [self.navigationItem.leftBarButtonItem setEnabled:NO];
  [self.tableView registerClass:[BookBrowserTableViewCell class] forCellReuseIdentifier:@"BookCell"];
  
  [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onDownloadProgressNotification:) name:[NotificationName downloadProgress] object:nil];
}

- (void)addNewBook:(UIBarButtonItem *)sender {
  UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"New Book" message:@"Provide the book URL, must be of PDF file format." preferredStyle:(UIAlertControllerStyleAlert)];
  [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
    textField.placeholder = @"https://mybook.pdf";
  }];
  UIAlertAction *download = [UIAlertAction actionWithTitle:@"Download" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    [self startDownload:alert];
  }];
  UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
  
  [alert addAction:download];
  [alert addAction:cancel];
  [self presentViewController:alert animated:YES completion:nil];
}

- (void)startDownload:(UIAlertController *)alertController {
  NSString *url = alertController.textFields.firstObject.text;
  if (![self isStringAPDFURL:url]) {
    return;
  }
  NSString *bookID = @"bookid123";
  
  Book *b = [[Book alloc] initWithID:bookID];
  [self.books addObject:b];
  
  //  [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:(self.books.count - 1) inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
  [self.tableView reloadData];
  DownloadOperation *operation = [[DownloadOperation alloc] initWithURL:[NSURL URLWithString:url] bookID:bookID];
  [self.operationQueue addOperation:operation];
}

- (BOOL)isStringAPDFURL:(NSString *)string {
  NSURL *url = [NSURL URLWithString:string];
  return (url && [url.pathExtension.lowercaseString isEqual: @"pdf"]);
}

- (void)onDownloadProgressNotification:(NSNotification *)notification {
  NSNumber *progress = notification.userInfo[@"downloadProgress"];
  NSString *bookID = notification.userInfo[@"bookID"];
  
  NSUInteger index = [self.books indexOfObjectPassingTest:^BOOL(Book * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    return [obj.bookID isEqualToString:bookID];
  }];
  
  [self.books objectAtIndex:index].downloadProgress = [progress floatValue];
  [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.books.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  BookBrowserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BookCell" forIndexPath:indexPath];
  [cell setBookTitle:self.books[indexPath.row].bookID];
  [cell setProgressBarHidden:NO];
  [cell setProgressLabelHidden:NO];
  [cell updateProgressBar:self.books[indexPath.row].downloadProgress];
  return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
  return [[UIView alloc] init];
}

- (void)presentDocumentAtURL:(NSURL *)documentURL {
  BookViewController *bookVC = [[BookViewController alloc] initWithDocumentAtURL:documentURL];
  UINavigationController *bookNavigationController = [[UINavigationController alloc] initWithRootViewController:bookVC];
  [self presentViewController:bookNavigationController animated:YES completion:nil];
}

@end
