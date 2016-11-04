//
//  UsersTableViewController.m
//  CoreData
//
//  Created by EnzoF on 01.11.16.
//  Copyright © 2016 EnzoF. All rights reserved.
//

#import "ManagerTableViewController.h"
#import "Course.h"

#import "DataManager.h"

#import "User+CoreDataProperties.h"
#import "Teacher+CoreDataProperties.h"
#import "Course+CoreDataProperties.h"


static NSString *strEntityNameCourse  = @"Course";
static NSString *strEntityNameUser    = @"User";
static NSString *strEntityNameTeacher = @"Teacher";

@interface ManagerTableViewController ()

@end

@implementation ManagerTableViewController

@synthesize fetchedResultsController = _fetchedResultsController;


-(void)viewDidLoad{
    [super viewDidLoad];
   // self.navigationItem.title = @"Users";
    

    
    UIBarButtonItem *actionCancelBarButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(actionCancel:)];
    self.navigationItem.leftBarButtonItem = actionCancelBarButton;

    
    UIBarButtonItem *actionCompleteBarButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(actionComplete:)];
    self.navigationItem.rightBarButtonItem = actionCompleteBarButton;

    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    [self.tableView setEditing:YES animated:YES];
    
}



#pragma mark - action

-(void)actionCancel:(UIBarButtonItem*)sender{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)actionComplete:(UIBarButtonItem*)sender{
    
    NSArray *allSelectedRows = [self.tableView  indexPathsForSelectedRows];
    NSMutableArray *users = [[NSMutableArray alloc]init];
    for (NSIndexPath *indexPath in allSelectedRows)
    {
        [users addObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
    }
    [self.delegate upDataArray:users witEntityName:self.entityName];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}



#pragma mark - CoreData
- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:self.entityName inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSString *keySort = @"lastName";
    if([self.entityName isEqualToString:strEntityNameCourse])
    {
        keySort = @"title";
    }
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:keySort ascending:YES];
    
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]
                                                             initWithFetchRequest:fetchRequest
                                                             managedObjectContext:self.managedObjectContext
                                                             sectionNameKeyPath:nil
                                                             cacheName:self.entityName];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _fetchedResultsController;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self.entityName isEqualToString:strEntityNameTeacher]) {
        
        if ([[self.tableView indexPathsForSelectedRows] count] == 2) {
            [tableView deselectRowAtIndexPath:[[self.tableView indexPathsForSelectedRows] firstObject] animated:YES];
        }
    }
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    if([self.entityName isEqualToString:strEntityNameCourse]){
        Course *course = [self.fetchedResultsController objectAtIndexPath:indexPath];
        cell.textLabel.text = course.title;
        Teacher *teacher = (Teacher*)self.dataObj;
        NSSet<Course *> *allCourses = teacher.courses;
        if([allCourses containsObject:course])
        {
            [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
        }
        
    }else if([self.entityName isEqualToString:strEntityNameUser]){
        
        User *user = [self.fetchedResultsController objectAtIndexPath:indexPath];
        cell.textLabel.text = user.lastName;
        cell.detailTextLabel.text = user.firstName;
        
        Course *course = (Course*)self.dataObj;
        NSSet<User *> *allUsers = course.users;
        if([allUsers containsObject:user])
        {
            [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
        }
        
    }else if([self.entityName isEqualToString:strEntityNameTeacher]){
        
        Teacher *teacher = [self.fetchedResultsController objectAtIndexPath:indexPath];
        cell.textLabel.text = teacher.lastName;
        cell.detailTextLabel.text = teacher.firstName;
    
        Course *course = (Course*)self.dataObj;
        if([teacher isEqual:course.teachers])
        {
            [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
        }
        
    }
}







@end
