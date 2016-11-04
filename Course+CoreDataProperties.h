//
//  Course+CoreDataProperties.h
//  CoreData
//
//  Created by EnzoF on 01.11.16.
//  Copyright © 2016 EnzoF. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Course.h"

NS_ASSUME_NONNULL_BEGIN

@interface Course (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *discipline;
@property (nullable, nonatomic, retain) NSString *sphere;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) Teacher *teachers;
@property (nullable, nonatomic, retain) NSSet<User *> *users;

@end

@interface Course (CoreDataGeneratedAccessors)

- (void)addUsersObject:(User *)value;
- (void)removeUsersObject:(User *)value;
- (void)addUsers:(NSSet<User *> *)values;
- (void)removeUsers:(NSSet<User *> *)values;

@end

NS_ASSUME_NONNULL_END
