//
//  BookBrowserTableViewCell.h
//  MEReader
//
//  Created by Mohammed Ennabah on 3/10/19.
//  Copyright © 2019 Mohammed Ennabah. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BookBrowserTableViewCell : UITableViewCell

- (void)updateProgressBar:(float)progress;
- (void)setProgressText:(NSString *)text;

- (void)setProgressBarHidden:(BOOL)hidden;
- (void)setProgressLabelHidden:(BOOL)hidden;

- (void)setBookTitle:(NSString *)title;
- (NSString *)bookTitle;

@end

NS_ASSUME_NONNULL_END
