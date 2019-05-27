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
  
  wordColorPreferenceViewControllerTitle = @"Word Color";
  sentenceColorPreferenceViewControllerTitle = @"Sentence Color";
}



#pragma mark - Table view data source

/*
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
 
 // Configure the cell...
 
 return cell;
 }
 */


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section != 4) {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
    } else if ([identifier isEqualToString:@"sentenceHighlightColorSegue"]) {
      colorPref.title = sentenceColorPreferenceViewControllerTitle;
    }
  }
}

- (void)colorPreferenceTableViewController:(nonnull ColorPreferenceTableViewController *)viewController didSelectColor:(nonnull HighlightColor *)color {
  // update cache
  if ([viewController.title isEqualToString:wordColorPreferenceViewControllerTitle]) {
    [self updateLabel:self.wordLabel highlightColor:color.color named:color.name style:[ReaderDefaults wordHighlightStyle]];
  } else if ([viewController.title isEqualToString:sentenceColorPreferenceViewControllerTitle]) {
    [self updateLabel:self.sentenceLabel highlightColor:color.color named:color.name style:[ReaderDefaults sentenceHighlightStyle]];
  }
}

- (void)updateLabel:(UILabel *)label highlightColor:(UIColor *)color named:(NSString *)name style:(HighlightStyle)style {
  NSMutableDictionary<NSAttributedStringKey, id> *attributes = [NSMutableDictionary dictionary];
  
  if (style == HighlightStyleUnderline) {
    [attributes setObject:[NSNumber numberWithDouble:2.0] forKey:NSUnderlineStyleAttributeName];
    [attributes setObject:color forKey:NSUnderlineColorAttributeName];
  } else if (style == HighlightStyleBackgroundColor) {
    [attributes setObject:color forKey:NSBackgroundColorAttributeName];
  }
  
  NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:name attributes:attributes];
  label.attributedText = attributedString;
}

@end
