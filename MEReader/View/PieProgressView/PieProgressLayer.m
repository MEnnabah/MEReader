//
//  PieProgressLayer.m
//  MEReader
//
//  Created by Mohammed Ennabah on 4/6/19.
//  Copyright © 2019 Mohammed Ennabah. All rights reserved.
//

#import "PieProgressLayer.h"

@implementation PieProgressLayer

@dynamic progress;

+ (BOOL)needsDisplayForKey:(NSString *)key {
  return [key isEqualToString:@"progress"] || [super needsDisplayForKey:key];
}

- (id<CAAction>)actionForKey:(NSString *)key {
  if ([key isEqualToString:@"progress"]) {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:key];
    animation.fromValue = [self.presentationLayer valueForKey:key];
    return animation;
  }
  return [super actionForKey:key];
}

- (void)drawInContext:(CGContextRef)context {
  
  // Configure context
  CGContextRotateCTM(context, M_PI / 2);
  CGContextTranslateCTM(context, 0, -self.bounds.size.height);
  
  // Configure line drawing
  CGFloat lineWidth = 2;
  CGContextSetLineWidth(context, lineWidth);
  CGContextSetLineCap(context, kCGLineCapRound);
  
  CGColorRef fillBackgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0].CGColor;
  CGColorRef fillForegroundColor = UIColor.blueColor.CGColor;

  CGContextSetStrokeColorWithColor(context, fillBackgroundColor);

  // Prepare the surface rect
  CGFloat midX = CGRectGetMidX(self.bounds);
  CGFloat midY = CGRectGetMidY(self.bounds);
  CGFloat radius = MIN(midX, midY) - lineWidth;
  CGFloat startAngle = 0.0;

  // Draw background arc
  CGContextAddArc(context, midX, midY, radius, startAngle, M_PI * 2, YES);
  CGContextStrokePath(context);

  // Draw progress arc
  CGContextSetStrokeColorWithColor(context, fillForegroundColor);
  CGFloat p = MIN(self.progress, 0.99);
  CGFloat endAngle = M_PI * 2 * (1 - p);
  CGContextAddArc(context, midX, midY, radius, startAngle, endAngle, YES);
  CGContextStrokePath(context);
  

  
  [super drawInContext:context];
}

@end
