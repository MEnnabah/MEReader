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

@property (nonatomic, strong) NSMutableArray *books;
@property (nonatomic, strong) NSFetchedResultsController<Book *> *fetchedResultsController;
@property (nonatomic, strong) NSPersistentContainer* container;

@end

@implementation BookBrowserViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.books = [NSMutableArray array];
  self.container = AppDelegate.sharedDelegate.persistentContainer;
  
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewURL:)];
  [self.navigationItem.leftBarButtonItem setEnabled:NO];
  [self.tableView registerClass:[BookBrowserTableViewCell class] forCellReuseIdentifier:@"BookCell"];
  
  [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(downloadProgressNotification:) name:[NotificationName downloadProgress] object:nil];
  [self loadSavedBooks];
}

- (void)loadSavedBooks {
  NSFetchRequest *fetchRequest = [Book fetchRequest];
  fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"uniqueID" ascending:YES]];
  self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                      managedObjectContext:self.container.viewContext
                                                                        sectionNameKeyPath:nil
                                                                                 cacheName:nil];
  self.fetchedResultsController.delegate = self;
  NSError *fetchError;
  BOOL fetched = [self.fetchedResultsController performFetch:&fetchError];
  NSLog(@"did fetch books?: %i", fetched);
  NSLog(@"%@", fetchError);
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
  book.title = @"The love of my Wi-Fi";
  [DownloadController.sharedInstance downloadBook:book];
}

- (BOOL)isStringAPDFURL:(NSString *)string {
  NSURL *url = [NSURL URLWithString:string];
  return (url && [url.pathExtension.lowercaseString isEqual: @"pdf"]);
}

- (void)downloadProgressNotification:(NSNotification *)notification {
  NSNumber *progress = notification.userInfo[@"downloadProgress"];
  NSString *bookID = notification.userInfo[@"bookID"];
  Book *associatedBook = [self bookWithID:bookID];
  associatedBook.downloadInfo.progress = [progress floatValue];
  NSIndexPath *associatedBookIndexPath = [self indexPathForBook:associatedBook];
  if ([[self.tableView indexPathsForVisibleRows] containsObject:associatedBookIndexPath]) {
    [self.tableView reloadRowsAtIndexPaths:@[associatedBookIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    NSLog(@"Reloading row");
  } else {
    NSLog(@"Row not visisble");
  }
}

- (Book *)bookWithID:(NSString *)bookID {
  __block Book* book;
  [self.fetchedResultsController.fetchedObjects enumerateObjectsUsingBlock:^(Book * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    if (obj.uniqueID == bookID) {
      book = obj;
      *stop = YES;
    }
  }];
  return book;
}

- (NSIndexPath *)indexPathForBook:(Book *)book {
  return [self.fetchedResultsController indexPathForObject:book];
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
  [cell setProgressBarHidden:NO];
  [cell setProgressLabelHidden:NO];
  [cell updateProgressBar:book.downloadInfo.progress];
  NSLog(@"%f", book.downloadInfo.progress);
  [cell setProgressText:@"100%"];
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

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
  NSLog(@"%@", controller);
  [self loadSavedBooks];
}
@end
