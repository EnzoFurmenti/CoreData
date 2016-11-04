//
//  CourseTableViewController.m
//  CoreData
//
//  Created by EnzoF on 01.11.16.
//  Copyright © 2016 EnzoF. All rights reserved.
//

#import "CourseTableViewController.h"
#import "AddCoursesViewController.h"
#import "Course.h"
#import "Teacher+CoreDataProperties.h"

@interface CourseTableViewController ()


@end

@implementation CourseTableViewController

@synthesize fetchedResultsController = _fetchedResultsController;

-(void)viewDidLoad{
    [super viewDidLoad];
    self.navigationItem.title = @"Courses";
    
}


#pragma mark - action
-(void)actionAdd:(UIBarButtonItem*)barButton{
    
    AddCoursesViewController *addCourseVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AddCoursesViewController"];
    
      UINavigationController *navC = [[UINavigationController alloc]initWithRootViewController:addCourseVC];
    
    [self presentViewController:navC animated:YES completion:nil];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
     AddCoursesViewController *addCoursesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AddCoursesViewController"];
    
    Course *course = [self.fetchedResultsController objectAtIndexPath:indexPath];
    addCoursesVC.course = course;
    [self.navigationController pushViewController:addCoursesVC animated:YES];
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
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]
                                                             initWithFetchRequest:fetchRequest
                                                             managedObjectContext:self.managedObjectContext
                                                             sectionNameKeyPath:nil
                                                             cacheName:@"User"];
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
    cell.textLabel.text = course.title;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@",course.teachers.lastName,course.teachers.firstName];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

@end
