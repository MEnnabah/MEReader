//
//  BookBrowserViewController.m
//  MEReader
//
//  Created by Mohammed Ennabah on 3/8/19.
//  Copyright © 2019 Mohammed Ennabah. All rights reserved.
//

#import "AppDelegate.h"
#import "BookBrowserViewController.h"
#import "BookViewController.h"
#import "NotificationName.h"
#import "BookBrowserTableViewCell.h"
#import <CoreData/CoreData.h>
#import "Book.h"
#import "MEReader+CoreDataModel.h"
#import "DownloadController.h"

@interface BookBrowserViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController<Book *> *fetchedResultsController;
@property (nonatomic, strong) NSPersistentContainer* container;

@end

@implementation BookBrowserViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.container = AppDelegate.sharedDelegate.persistentContainer;
  
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewURL:)];
  [self.navigationItem.leftBarButtonItem setEnabled:NO];
  
  [self.tableView registerClass:[BookBrowserTableViewCell class] forCellReuseIdentifier:@"BookCell"];
  [self loadSavedBooks];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}

- (void)loadSavedBooks {
  NSFetchRequest *fetchRequest = [Book fetchRequest];
  fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"downloadInfo.downloadedAt" ascending:NO]];
  self.fetchedResultsController = [[NSFetchedResultsController alloc]
                                   initWithFetchRequest:fetchRequest
                                   managedObjectContext:self.container.viewContext
                                   sectionNameKeyPath:nil
                                   cacheName:nil];
  
  self.fetchedResultsController.delegate = self;
  NSError *fetchError;
  [self.fetchedResultsController performFetch:&fetchError];
  if (fetchError) {
    NSLog(@"%@", fetchError);
  }
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.tableView reloadData];
  });
}

- (void)addNewURL:(UIBarButtonItem *)sender {
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
  Book *book = [[Book alloc] initWithContext:self.container.viewContext];
  book.uniqueID = NSUUID.UUID.UUIDString;
  book.url = url;
  book.title = [NSString stringWithFormat:@"Book no. %@", @(self.fetchedResultsController.sections[0].objects.count + 1)];
  [DownloadController.sharedInstance downloadBook:book];
}

- (BOOL)isStringAPDFURL:(NSString *)string {
  NSURL *url = [NSURL URLWithString:string];
  return (url && [string.pathExtension.lowercaseString isEqual: @"pdf"]);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.fetchedResultsController.sections[section].numberOfObjects;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  BookBrowserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BookCell" forIndexPath:indexPath];
  Book *book = [self.fetchedResultsController objectAtIndexPath:indexPath];
  
  [cell setBookTitle: book.title];
  return cell;
}

- (void)updateProgress:(float)progress ofCell:(BookBrowserTableViewCell *)cell {
  [cell setProgressText: [[NSString alloc] initWithFormat:@"%2.0f %%", (progress * 100)]];
  // progress < 0.0 means the server doesn't return Content-Length header for the downloading file.
  // we may provide a way to indicate a currently downloading task instead of hiding the progress view
  // this could be a circle that keeps moving like the App Store one.
  BOOL isNegative = progress < 0.0;
  if (!isNegative) {
    [cell updateProgressBar:progress];
    [cell setProgressViewHidden:isNegative];
    [cell setProgressLabelHidden:isNegative];
  }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  Book *selectedBook = [self.fetchedResultsController objectAtIndexPath:indexPath];
  NSString *downloadPath = selectedBook.downloadInfo.path;
//  NSURL *absoluteURLPath = [[NSURL alloc] initFileURLWithPath:downloadPath];
  NSURL *relativePath = [DownloadInfo relativeDocumentDirectory];
  NSURL *fullPath = [relativePath URLByAppendingPathComponent:downloadPath];
  [self presentDocumentAtURL:fullPath];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
  return [[UIView alloc] init];
}

- (void)presentDocumentAtURL:(NSURL *)documentURL {
  BookViewController *bookVC = [[BookViewController alloc] initWithDocumentAtURL:documentURL];
  UINavigationController *bookNavigationController = [[UINavigationController alloc] initWithRootViewController:bookVC];
  [self presentViewController:bookNavigationController animated:YES completion:nil];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
  switch (type) {
    case NSFetchedResultsChangeInsert:
      [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
      break;
    case NSFetchedResultsChangeUpdate:
      if ([self.tableView.indexPathsForVisibleRows containsObject:indexPath]) {
        BookBrowserTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [self updateProgress:[self.fetchedResultsController objectAtIndexPath:indexPath].downloadInfo.progress ofCell:cell];
      }
      break;
    default:
      NSLog(@"NSFetchedResultsChangeType case that we don't yet handle");
      break;
  }
}

@end
