//
//  PieProgressView.m
//  MEReader
//
//  Created by Mohammed Ennabah on 4/6/19.
//  Copyright © 2019 Mohammed Ennabah. All rights reserved.
//

#import "PieProgressView.h"
#import "PieProgressLayer.h"

@implementation PieProgressView

+ (Class)layerClass {
  return [PieProgressLayer class];
}

- (id)init {
  return [self initWithFrame:CGRectMake(0.0f, 0.0f, 37.0f, 37.0f)];
}

- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    self.opaque = NO;
    self.layer.contentsScale = [[UIScreen mainScreen] scale];
    [self.layer setNeedsDisplay];
  }
  return self;
}

- (void)setProgress:(CGFloat)progress {
  NSLog(@"\np:%f", progress);
  [(PieProgressLayer *)self.layer setProgress:progress];
}

- (CGFloat)progress {
  return [(PieProgressLayer *)self.layer progress];
}

@end
