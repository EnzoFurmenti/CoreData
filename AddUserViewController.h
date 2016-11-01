//
//  AddUserViewController.h
//  CoreData
//
//  Created by EnzoF on 29.10.16.
//  Copyright © 2016 EnzoF. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class User;
@interface AddUserViewController : UITableViewController

@property (strong,nonatomic) NSManagedObjectContext *managedObjectContext;


@property (nonatomic, assign) BOOL isEditMode ;
@property (nonatomic, strong) User *user;

@end
