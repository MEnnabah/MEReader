//
//  AppDelegate.m
//  MEReader
//
//  Created by Mohammed Ennabah on 3/8/19.
//  Copyright © 2019 Mohammed Ennabah. All rights reserved.
//

#import "AppDelegate.h"
#import "BookBrowserViewController.h"
#import "MEReader+CoreDataModel.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (UINavigationController *)setupBooksBrowser {
  BookBrowserViewController *bookBrowserVC = [[BookBrowserViewController alloc] initWithNibName:nil bundle:nil];
  bookBrowserVC.title = @"Library";
  UINavigationController *bookBrowserNVC = [[UINavigationController alloc] initWithRootViewController:bookBrowserVC];
  return bookBrowserNVC;
}

- (UINavigationController *)setupSettings {
  UIViewController *settingsViewController = [[UIViewController alloc] init];
  settingsViewController.view.backgroundColor = [UIColor whiteColor];
  settingsViewController.title = @"Settings";
  UINavigationController *settingsNVC = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
  return settingsNVC;
}

- (void)setupKeyWindow {
  self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
  UITabBarController *mainTabBar = [[UITabBarController alloc] init];
  
  UINavigationController *booksBrowserNVC = [self setupBooksBrowser];
  UINavigationController *settingsNVC = [self setupSettings];
  [mainTabBar setViewControllers:@[booksBrowserNVC, settingsNVC]];
  
  self.window.rootViewController = mainTabBar;
  [self.window makeKeyAndVisible];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [self setupKeyWindow];
  return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  // Saves changes in the application's managed object context before the application terminates.
  [self saveContext];
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)(void))completionHandler {
  NSLog(@"handleEventsForBackgroundURLSession: %@", identifier);
  completionHandler();
}

#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
  // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
  @synchronized (self) {
    if (_persistentContainer == nil) {
      _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"MEReader"];
      [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
        if (error != nil) {
          // Replace this implementation with code to handle the error appropriately.
          // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
          
          /*
           Typical reasons for an error here include:
           * The parent directory does not exist, cannot be created, or disallows writing.
           * The persistent store is not accessible, due to permissions or data protection when the device is locked.
           * The device is out of space.
           * The store could not be migrated to the current model version.
           Check the error message to determine what the actual problem was.
           */
          NSLog(@"Unresolved error %@, %@", error, error.userInfo);
          abort();
        }
      }];
    }
  }
  
  return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
  NSManagedObjectContext *context = self.persistentContainer.viewContext;
  NSError *error = nil;
  if ([context hasChanges] && ![context save:&error]) {
    // Replace this implementation with code to handle the error appropriately.
    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
    abort();
  }
}

+ (AppDelegate *)sharedDelegate {
  return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

@end
