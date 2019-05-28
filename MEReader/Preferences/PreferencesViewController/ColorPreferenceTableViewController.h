//
//  ColorPreferencesTableViewController.h
//  MEReader
//
//  Created by Mohammed Ennabah on 5/26/19.
//  Copyright © 2019 Mohammed Ennabah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HighlightColor.h"

NS_ASSUME_NONNULL_BEGIN

@class ColorPreferenceTableViewController;

@protocol ColorPreferencesTableViewControllerDelegate <NSObject>

- (void)colorPreferenceTableViewController:(ColorPreferenceTableViewController *)viewController didSelectColor:(HighlightColor *)color;

@end

@interface ColorPreferenceTableViewController : UITableViewController

@property (weak, nonatomic) id <ColorPreferencesTableViewControllerDelegate> delegate;
@property (strong, nonatomic) HighlightColor *currentColor;

@end

NS_ASSUME_NONNULL_END
