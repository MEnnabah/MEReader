//
//  ColorPreferenceTableViewController.m
//  MEReader
//
//  Created by Mohammed Ennabah on 5/26/19.
//  Copyright © 2019 Mohammed Ennabah. All rights reserved.
//

#import "ColorPreferenceTableViewController.h"
#import "ReaderDefaults.h"
#import "ColorPreferencesTableViewCell.h"

@interface ColorPreferenceTableViewController ()

@property (strong, nonatomic) NSArray<HighlightColor *> *colors;

@end

@implementation ColorPreferenceTableViewController {
  NSUInteger currentlySelectedColorIndex;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.tableView.allowsSelection = YES;
  
  self.colors = [NSArray array];
  self.colors = [ReaderDefaults availableHighlightColors];
  
  [self.colors enumerateObjectsUsingBlock:^(HighlightColor * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    if ([obj.name isEqualToString:self.currentColor.name]) {
      *stop = YES;
      self->currentlySelectedColorIndex = idx;
    }
  }];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:currentlySelectedColorIndex inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.colors.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  ColorPreferencesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ColorPreferencesTableViewCell" forIndexPath:indexPath];
  [cell setColor:self.colors[indexPath.row].color];
  [cell setColorName:self.colors[indexPath.row].name];
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [self.delegate colorPreferenceTableViewController:self didSelectColor:self.colors[indexPath.row]];
}

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
