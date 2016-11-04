//
//  AddCoursesViewController.h
//  CoreData
//
//  Created by EnzoF on 01.11.16.
//  Copyright © 2016 EnzoF. All rights reserved.
//

//#import "MainTableViewController.h"
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>


@class Course;


@interface AddCoursesViewController : UITableViewController

@property (strong,nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, assign) BOOL isEditMode ;
@property (nonatomic, strong) Course *course;

@end


