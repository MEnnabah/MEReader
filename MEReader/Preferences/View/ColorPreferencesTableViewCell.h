//
//  ColorPreferencesTableViewCell.h
//  MEReader
//
//  Created by Mohammed Ennabah on 5/26/19.
//  Copyright © 2019 Mohammed Ennabah. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ColorPreferencesTableViewCell : UITableViewCell

- (NSString *)colorName;
- (void)setColorName:(NSString *)name;

- (UIColor *)color;
- (void)setColor:(UIColor *)color;

@end

NS_ASSUME_NONNULL_END
