//
//  Operation.m
//  MEReader
//
//  Created by Mohammed Ennabah on 3/9/19.
//  Copyright © 2019 Mohammed Ennabah. All rights reserved.
//

#import "Operation.h"

@implementation Operation

- (BOOL)isAsynchronous {
  return true;
}

BOOL _isExecuting;
- (BOOL)isExecuting {
  return _isExecuting;
}

BOOL _isFinished;;
- (BOOL)isFinished {
  return _isFinished;
}

- (void)start {
  [self willChangeValueForKey:@"isExecuting"];
  _isExecuting = YES;
  [self didChangeValueForKey:@"isExecuting"];
  
  [self execute];
}

- (void)execute {
  [NSException raise:@"OperationException" format:@"You must override this and provide your own execution, without calling super"];
}

- (void)finish {
  [self willChangeValueForKey:@"isExecuting"];
  _isExecuting = NO;
  [self didChangeValueForKey:@"isExecuting"];
  
  [self willChangeValueForKey:@"isFinished"];
  _isFinished = YES;
  [self didChangeValueForKey:@"isFinished"];
}

@end
