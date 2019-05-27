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

@property (strong, nonatomic) NSMutableArray<HighlightColor *> *colors;

@end

@implementation ColorPreferenceTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
  self.colors = [NSMutableArray array];
  
  NSDictionary<NSString *, UIColor *> *savedColor = [ReaderDefaults availableHighlightColors];
  [savedColor enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, UIColor * _Nonnull obj, BOOL * _Nonnull stop) {
    HighlightColor *highlightColor = [[HighlightColor alloc] initWithColor:obj named:key];
    [self.colors addObject:highlightColor];
  }];
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
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
