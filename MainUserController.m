//
//  MainUserController.m
//  CoreData
//
//  Created by EnzoF on 29.10.16.
//  Copyright © 2016 EnzoF. All rights reserved.
//

#import "MainUserController.h"
#import "AddUserViewController.h"
#import "DataManager.h"
#import "User.h"
#import "User+CoreDataProperties.h"

@interface MainUserController ()

@property (nonatomic,strong) AddUserViewController *addUserVC;

@end

@implementation MainUserController

@synthesize fetchedResultsController = _fetchedResultsController;


-(void)viewDidLoad{
    [super viewDidLoad];
        self.navigationItem.title = @"Users";
    
}


#pragma mark - action
-(void)actionAdd:(UIBarButtonItem*)barButton{
    
    self.addUserVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AddUserViewController"];
    
    UINavigationController *navC = [[UINavigationController alloc]initWithRootViewController:self.addUserVC];
    
    //addUserTVC.modalPresentationStyle = UIModalPresentationFullScreen;
    
    [self presentViewController:navC animated:YES completion:nil];

}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    User *user = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    AddUserViewController *addUserVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AddUserViewController"];
    addUserVC.user = user;
    
    UINavigationController *navC = [[UINavigationController alloc]initWithRootViewController:addUserVC];
    [self presentViewController:navC animated:YES completion:nil];
}

#pragma mark - CoreData
- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:YES];
    
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
    
    User *user = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = user.lastName;
    cell.detailTextLabel.text = user.firstName;
}



@end
