//
//  DataManager.h
//  CoreData
//
//  Created by EnzoF on 29.10.16.
//  Copyright © 2016 EnzoF. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface DataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;



+(DataManager*)sharedDataManager;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


@end
