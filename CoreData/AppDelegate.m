//
//  AppDelegate.m
//  CoreData
//
//  Created by EnzoF on 29.10.16.
//  Copyright © 2016 EnzoF. All rights reserved.
//

#import "AppDelegate.h"
#import "DataManager.h"
#import "MainUserController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
//    
//    self.window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
//    self.window.backgroundColor = [UIColor greenColor];
//    
//    MainUserController *mainUserC = [[MainUserController alloc]init];
//    UINavigationController *navC= [[UINavigationController alloc]initWithRootViewController:mainUserC];
//    
//    self.window.rootViewController = navC;
    
    
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [[DataManager sharedDataManager] saveContext];
}


@end
