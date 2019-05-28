//
//  ColorPreferencesTableViewCell.m
//  MEReader
//
//  Created by Mohammed Ennabah on 5/26/19.
//  Copyright © 2019 Mohammed Ennabah. All rights reserved.
//

#import "ColorPreferencesTableViewCell.h"

@interface ColorPreferencesTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *colorNameLabel;
@property (weak, nonatomic) IBOutlet UIView *colorIndicatorView;

@end

@implementation ColorPreferencesTableViewCell

- (void)awakeFromNib {
  [super awakeFromNib];
  
  self.selectionStyle = UITableViewCellSelectionStyleNone;
  
  self.colorIndicatorView.layer.cornerRadius = self.colorIndicatorView.frame.size.height / 2;
  self.colorIndicatorView.layer.masksToBounds = YES;
  
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];
  self.accessoryType = selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
}

- (NSString *)colorName {
  return self.colorNameLabel.text;
}

- (void)setColorName:(NSString *)name {
  self.colorNameLabel.text = name;
}

- (UIColor *)color {
  return self.colorIndicatorView.backgroundColor;
}

- (void)setColor:(UIColor *)color {
  self.colorIndicatorView.backgroundColor = color;
}

@end
