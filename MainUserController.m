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
    if(!self.isEditing)
        self.navigationItem.title = @"Users";
    
        UIBarButtonItem *addBurButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(actionAdd:)];
    
        self.navigationItem.rightBarButtonItem = addBurButton;
    
        UIBarButtonItem *editBarButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(actionEdit:)];
        self.navigationItem.leftBarButtonItem = editBarButton;
    
}


#pragma mark - action
-(void)actionAdd:(UIBarButtonItem*)barButton{
    
    self.addUserVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AddUserViewController"];
    
    UINavigationController *navC = [[UINavigationController alloc]initWithRootViewController:self.addUserVC];
    
    //addUserTVC.modalPresentationStyle = UIModalPresentationFullScreen;
    
    [self presentViewController:navC animated:YES completion:nil];

}
-(void)actionEdit:(UIBarButtonItem*)barButton{
    UIBarButtonSystemItem item = self.tableView.editing ? UIBarButtonSystemItemEdit : UIBarButtonSystemItemDone;
    
    UIBarButtonItem *rightItem = self.tableView.editing ? nil : [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(actionAdd:)];
    [self.navigationItem setRightBarButtonItem:rightItem];
    
    [self.tableView setEditing:self.tableView.editing ? NO : YES animated:YES];
    
    UIBarButtonItem *editBarButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:item target:self action:@selector(actionEdit:)];
    [self.navigationItem setLeftBarButtonItem:editBarButton animated:YES];
    
    
}


#pragma mark - data metods
- (void)insertNewObject:(id)sender {
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    [newManagedObject setValue:[NSDate date] forKey:@"timeStamp"];
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

#pragma mark - Segues

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if ([[segue identifier] isEqualToString:@"showDetail"]) {
//        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
//        NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
//        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
//        [controller setDetailItem:object];
//        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
//        controller.navigationItem.leftItemsSupplementBackButton = YES;
//    }
//}



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
