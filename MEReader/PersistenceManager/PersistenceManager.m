//
//  PersistenceManager.m
//  MEReader
//
//  Created by Mohammed Ennabah on 3/19/19.
//  Copyright © 2019 Mohammed Ennabah. All rights reserved.
//

#import "PersistenceManager.h"

@implementation PersistenceManager

+ (instancetype)sharedInstance {
  static PersistenceManager *shared = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    shared = [[PersistenceManager alloc] init];
  });
  return shared;
}
//- (BOOL)save:(NSError **)error;

- (void)saveWithContext:(NSManagedObjectContext *)context error:(NSError **)error {
  NSManagedObjectContext *ctx = context;
  while (ctx != nil) {
    [ctx save:error];
    ctx = ctx.parentContext;
  }
}

@end
