//
//  TeacherTableViewController.m
//  CoreData
//
//  Created by EnzoF on 02.11.16.
//  Copyright © 2016 EnzoF. All rights reserved.
//

#import "TeacherTableViewController.h"
#import "AddTeacherViewController.h"
#import "Teacher+CoreDataProperties.h"
#import "Course+CoreDataProperties.h"


@interface TeacherTableViewController ()

@end

@implementation TeacherTableViewController

@synthesize fetchedResultsController = _fetchedResultsController;



- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - action
-(void)actionAdd:(UIBarButtonItem*)barButton{

    AddTeacherViewController *addCourseVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AddTeacherViewController"];

UINavigationController *navC = [[UINavigationController alloc]initWithRootViewController:addCourseVC];

[self presentViewController:navC animated:YES completion:nil];
}



#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    AddTeacherViewController *addTeacherVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AddTeacherViewController"];
    
    Course *course = [self.fetchedResultsController objectAtIndexPath:indexPath];
    Teacher *teacher = course.teachers;
    addTeacherVC.teacher = teacher;
    [self.navigationController pushViewController:addTeacherVC animated:YES];
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return sectionInfo.name;
}

#pragma mark - CoreData
- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Course" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"teachers" ascending:YES];
    
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]
                                                             initWithFetchRequest:fetchRequest
                                                             managedObjectContext:self.managedObjectContext
                                                             sectionNameKeyPath:@"title"
                                                             cacheName:@"Teacher"];
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



- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    
    Course *course = [self.fetchedResultsController objectAtIndexPath:indexPath];
    Teacher *teacher = course.teachers;
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",teacher.lastName,teacher.firstName];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}



@end
