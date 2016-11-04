//
//  AddTeacher.h
//  CoreData
//
//  Created by EnzoF on 02.11.16.
//  Copyright © 2016 EnzoF. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>


@class Teacher;
@interface AddTeacherViewController : UITableViewController


@property (strong,nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, assign) BOOL isEditMode ;
@property (nonatomic, strong) Teacher *teacher;


@end
