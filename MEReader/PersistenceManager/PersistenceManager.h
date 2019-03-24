//
//  PersistenceManager.h
//  MEReader
//
//  Created by Mohammed Ennabah on 3/19/19.
//  Copyright © 2019 Mohammed Ennabah. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface PersistenceManager : NSObject

@property (nonatomic, strong) NSPersistentContainer *sharedContainer;

+ (instancetype)sharedInstance;
- (void)saveWithContext:(NSManagedObjectContext *)context error:(NSError **)error;


@end

NS_ASSUME_NONNULL_END
