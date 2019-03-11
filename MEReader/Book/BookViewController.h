//
//  BookViewController.h
//  MEReader
//
//  Created by Mohammed Ennabah on 3/8/19.
//  Copyright © 2019 Mohammed Ennabah. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BookViewController : UIViewController

- (instancetype)initWithDocumentAtURL:(NSURL *)documentURL;

@end

NS_ASSUME_NONNULL_END
