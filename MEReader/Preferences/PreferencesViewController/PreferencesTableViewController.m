//
//  PreferencesTableViewController.m
//  MEReader
//
//  Created by Mohammed Ennabah on 5/26/19.
//  Copyright © 2019 Mohammed Ennabah. All rights reserved.
//

#import "PreferencesTableViewController.h"
#import "ColorPreferenceTableViewController.h"
#import "ReaderDefaults.h"

@interface PreferencesTableViewController () <ColorPreferencesTableViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *wordLabel;
@property (weak, nonatomic) IBOutlet UILabel *sentenceLabel;

@end

@implementation PreferencesTableViewController  {
  NSString *wordColorPreferenceViewControllerTitle;
  NSString *sentenceColorPreferenceViewControllerTitle;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.clearsSelectionOnViewWillAppear = YES;
  self.tableView.allowsMultipleSelection = YES;
  
  wordColorPreferenceViewControllerTitle = @"Word Color";
  sentenceColorPreferenceViewControllerTitle = @"Sentence Color";
  
  [self updateLabel:self.wordLabel highlightColor:[ReaderDefaults preferedWordHighlightColor] style:[ReaderDefaults wordHighlightStyle]];
  [self updateLabel:self.sentenceLabel highlightColor:[ReaderDefaults preferedSentenceHighlightColor] style:[ReaderDefaults sentenceHighlightStyle]];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [self reselectTableViewRows];
}

#pragma mark - Table view data source


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 4) {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    return;
  }
  [self updatePreferencesForIndexPath:indexPath];
  [self reselectTableViewRows];
}

- (void)updatePreferencesForIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 1) {
    [ReaderDefaults setDefaultHighlightContent:indexPath.row];
  } else if (indexPath.section == 2) {
    [ReaderDefaults setWordHighlightStyle:indexPath.row];
    [self updateLabel:self.wordLabel highlightColor:[ReaderDefaults preferedWordHighlightColor] style:indexPath.row];
  } else if (indexPath.section == 3) {
    [ReaderDefaults setSentenceHighlightStyle:indexPath.row];
    [self updateLabel:self.sentenceLabel highlightColor:[ReaderDefaults preferedSentenceHighlightColor] style:indexPath.row];
  }
}

- (void)reselectTableViewRows {
  for (NSIndexPath *ip in self.tableView.indexPathsForSelectedRows) {
    [self.tableView deselectRowAtIndexPath:ip animated:YES];
    [self.tableView cellForRowAtIndexPath:ip].accessoryType = UITableViewCellAccessoryNone;
  }
  
  DefaultHighlightContent highlightContent = [ReaderDefaults defaultHighlightContent];
  HighlightStyle wordHighlightStyle = [ReaderDefaults wordHighlightStyle];
  HighlightStyle sentenceHighlightStyle = [ReaderDefaults sentenceHighlightStyle];
  
  NSIndexPath *highlightContentIndexPath = [NSIndexPath indexPathForRow:highlightContent inSection:1];
  NSIndexPath *wordHighlightStyleIndexPath = [NSIndexPath indexPathForRow:wordHighlightStyle inSection:2];
  NSIndexPath *sentenceHighlightStyleIndexPath = [NSIndexPath indexPathForRow:sentenceHighlightStyle inSection:3];
  
  NSArray<NSIndexPath *> *newIndicies = @[highlightContentIndexPath, wordHighlightStyleIndexPath, sentenceHighlightStyleIndexPath];
  
  for (NSIndexPath *ip in newIndicies) {
    [self.tableView selectRowAtIndexPath:ip animated:YES scrollPosition:(UITableViewScrollPositionNone)];
    [self.tableView cellForRowAtIndexPath:ip].accessoryType = UITableViewCellAccessoryCheckmark;
  }
  
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  ColorPreferenceTableViewController *colorPref = segue.destinationViewController;
  NSString *identifier = segue.identifier;
  
  if (colorPref) {
    colorPref.delegate = self;
    if ([identifier isEqualToString:@"wordHighlightColorSegue"]) {
      colorPref.title = wordColorPreferenceViewControllerTitle;
      colorPref.currentColor = [ReaderDefaults preferedWordHighlightColor];
    } else if ([identifier isEqualToString:@"sentenceHighlightColorSegue"]) {
      colorPref.title = sentenceColorPreferenceViewControllerTitle;
      colorPref.currentColor = [ReaderDefaults preferedSentenceHighlightColor];
    }
  }
}

- (void)colorPreferenceTableViewController:(nonnull ColorPreferenceTableViewController *)viewController didSelectColor:(nonnull HighlightColor *)color {
  // update cache
  if ([viewController.title isEqualToString:wordColorPreferenceViewControllerTitle]) {
    [self updateLabel:self.wordLabel highlightColor:color style:[ReaderDefaults wordHighlightStyle]];
    [ReaderDefaults setPreferedWordHighlightColor:color];
  } else if ([viewController.title isEqualToString:sentenceColorPreferenceViewControllerTitle]) {
    [self updateLabel:self.sentenceLabel highlightColor:color style:[ReaderDefaults sentenceHighlightStyle]];
    [ReaderDefaults setPreferedSentenceHighlightColor:color];
  }
}

- (void)updateLabel:(UILabel *)label highlightColor:(HighlightColor *)color style:(HighlightStyle)style {
  NSMutableDictionary<NSAttributedStringKey, id> *attributes = [NSMutableDictionary dictionary];
  
  if (style == HighlightStyleUnderline) {
    [attributes setObject:[NSNumber numberWithDouble:2.0] forKey:NSUnderlineStyleAttributeName];
    [attributes setObject:color.color forKey:NSUnderlineColorAttributeName];
  } else if (style == HighlightStyleBackgroundColor) {
    [attributes setObject:color.color forKey:NSBackgroundColorAttributeName];
  }
  
  NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:color.name attributes:attributes];
  label.attributedText = attributedString;
}

@end
