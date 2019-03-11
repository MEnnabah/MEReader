//
//  BookBrowserTableViewCell.m
//  MEReader
//
//  Created by Mohammed Ennabah on 3/10/19.
//  Copyright © 2019 Mohammed Ennabah. All rights reserved.
//

#import "BookBrowserTableViewCell.h"

@interface BookBrowserTableViewCell ()

@property (nonatomic, strong) UILabel *bookTitleLabel;
@property (nonatomic, strong) UIProgressView *progressBar;
@property (nonatomic, strong) UILabel *progressLabel;

@end

@implementation BookBrowserTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
  
  [self.contentView addSubview:self.bookTitleLabel];
  [self.contentView addSubview:self.progressBar];
  [self.contentView addSubview:self.progressLabel];
  
  self.progressBar.hidden = YES;
  self.progressLabel.hidden = YES;
  
  [self.bookTitleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
  [self.progressBar setTranslatesAutoresizingMaskIntoConstraints:NO];
  [self.progressLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
  
  [[self.bookTitleLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:8] setActive:YES];
  [[self.bookTitleLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:8] setActive:YES];
  [[self.bookTitleLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-8] setActive:YES];
  [[self.bookTitleLabel.bottomAnchor constraintEqualToAnchor:self.progressLabel.topAnchor constant:-8] setActive:YES];
  
  [[self.progressLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:8] setActive:YES];
  [[self.progressLabel.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-8] setActive:YES];
  
  [[self.progressBar.leadingAnchor constraintEqualToAnchor:self.progressLabel.trailingAnchor constant:4] setActive:YES];
  [[self.progressBar.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-4] setActive:YES];
  [[self.progressBar.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor] setActive:YES];
}

- (void)updateProgressBar:(float)progress {
  [self.progressBar setProgress:progress];
}

- (void)setProgressText:(NSString *)text {
  self.progressLabel.text = text;
}

- (void)setProgressBarHidden:(BOOL)hidden {
  self.progressBar.hidden = hidden;
}

- (void)setProgressLabelHidden:(BOOL)hidden {
  self.progressLabel.hidden = hidden;
}

- (void)setBookTitle:(NSString *)title {
  self.bookTitleLabel.text = title;
}

- (NSString *)bookTitle {
  return self.bookTitleLabel.text;
}

@end
