//
//  UsersTableViewController.h
//  CoreData
//
//  Created by EnzoF on 01.11.16.
//  Copyright © 2016 EnzoF. All rights reserved.
//

#import "MainTableViewController.h"
#import <CoreData/CoreData.h>

@class Course;
@protocol ManagerTableViewDelegate;
@interface ManagerTableViewController : MainTableViewController

@property (nonatomic,strong) id dataObj;
@property (nonatomic,weak) id<ManagerTableViewDelegate> delegate;
@property (nonatomic,strong) NSString *entityName;
@end

@protocol ManagerTableViewDelegate <NSObject>

-(void)upDataArray:(NSArray *)array witEntityName:(NSString*)entityName;

@end
