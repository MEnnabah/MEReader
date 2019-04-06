//
//  BookBrowserTableViewCell.m
//  MEReader
//
//  Created by Mohammed Ennabah on 3/10/19.
//  Copyright © 2019 Mohammed Ennabah. All rights reserved.
//

#import "BookBrowserTableViewCell.h"
#import "PieProgressView.h"

@interface BookBrowserTableViewCell ()

@property (nonatomic, strong) UILabel *bookTitleLabel;
@property (nonatomic, strong) UILabel *progressLabel;
@property (nonatomic, strong) PieProgressView *progressView;

@end

@implementation BookBrowserTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  
  if (self) {
    
    [self setupBookTitleLabel];
    [self setupProgressView];
    [self setupProgressLabel];
    
    [self.contentView addSubview:self.bookTitleLabel];
    [self.contentView addSubview:self.progressView];
    [self.contentView addSubview:self.progressLabel];
    
    [self activateViewsConstraints];
  }
  
  return self;
}

- (void)setupBookTitleLabel {
  self.bookTitleLabel = [[UILabel alloc] init];
  self.bookTitleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
  [self.bookTitleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
}

- (void)setupProgressView {
  self.progressView = [[PieProgressView alloc] initWithFrame:(CGRectMake(10, 10, 50, 50))];
  [self.progressView setTranslatesAutoresizingMaskIntoConstraints:NO];
}

- (void)setupProgressLabel {
  self.progressLabel = [[UILabel alloc] init];
  self.progressLabel.textAlignment = NSTextAlignmentLeft;
  self.progressLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightThin];
  [self.progressLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
}

- (void)activateViewsConstraints {
  [NSLayoutConstraint activateConstraints:@[
                                            [self.bookTitleLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:8],
                                            [self.bookTitleLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:8],
                                            [self.bookTitleLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-8],
                                            
                                            [self.progressView.topAnchor constraintEqualToAnchor:self.bookTitleLabel.bottomAnchor constant:8],
                                            [self.progressView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-8],
                                            [self.progressView.leadingAnchor constraintEqualToAnchor:self.bookTitleLabel.leadingAnchor],
                                            [self.progressView.heightAnchor constraintEqualToConstant:25],
                                            [self.progressView.widthAnchor constraintEqualToConstant:25],
                                            
                                            [self.progressLabel.leadingAnchor constraintEqualToAnchor:self.progressView.trailingAnchor constant:4],
                                            [self.progressLabel.centerYAnchor constraintEqualToAnchor:self.progressView.centerYAnchor]
                                            ]];
}

- (void)updateProgressBar:(float)progress {
  [self.progressView setProgress:progress];
}

- (void)setProgressText:(NSString *)text {
  self.progressLabel.text = text;
}

- (void)setProgressBarHidden:(BOOL)hidden {
  self.progressView.hidden = hidden;
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

//- (void)prepareForReuse {
//  [super prepareForReuse];
//  [self.progressBar setProgress:0.0 animated:NO];
//  [self.progressView setProgress:0.0];
//}

@end
