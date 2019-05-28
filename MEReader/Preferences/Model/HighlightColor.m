//
//  HighlightColor.m
//  MEReader
//
//  Created by Mohammed Ennabah on 5/27/19.
//  Copyright © 2019 Mohammed Ennabah. All rights reserved.
//

#import "HighlightColor.h"

@implementation HighlightColor

- (instancetype)initWithColor:(UIColor *)color named:(NSString *)name {
  self = [super init];
  if (self) {
    self.color = color;
    self.name = name;
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
  [coder encodeObject:self.name forKey:@"name"];
  [coder encodeObject:self.color forKey:@"color"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  if (self = [super init]) {
    self.name = [aDecoder decodeObjectForKey:@"name"];
    self.color = [aDecoder decodeObjectForKey:@"color"];
  }
  return self;
}



@end
