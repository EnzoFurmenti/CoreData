//
//  AddUserViewController.m
//  CoreData
//
//  Created by EnzoF on 29.10.16.
//  Copyright © 2016 EnzoF. All rights reserved.
//

#import "AddUserViewController.h"
#import "DataManager.h"
#import "UserCell.h"
#import "User.h"



static  NSString *kFirstNameAtributeNameDictionary = @"Имя";
static  NSString *kLastNameAtributeNameDictionary  = @"Фамилия";
static  NSString *kEmailAtributeNameDictionary = @"email";

typedef enum{
    AddUserViewControllerFirstNameAtributeNameDictionary = 0,
    AddUserViewControllerLastNameAtributeNameDictionary  = 1,
    AddUserViewControllerEmailAtributeNameDictionary     = 2,
}AddUserViewControllerAtributeNameDictionary;

#define  ATRIBUTECOUNT 3
@interface AddUserViewController ()

@property(nonatomic,strong) NSDictionary *atributeNameDictionary;
@property(nonatomic,strong) NSDictionary *atributeNameUserDictionary;


@end

@implementation AddUserViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.isEditMode = NO;
    if(self.user)
    {
        self.isEditMode = YES;
        self.atributeNameUserDictionary = [[NSDictionary alloc]initWithObjectsAndKeys:self.user.firstName,kFirstNameAtributeNameDictionary,
                                                                                      self.user.lastName,kLastNameAtributeNameDictionary,
                                                                                      self.user.email,kEmailAtributeNameDictionary,nil];
    }
    
    self.navigationItem.title = self.isEditMode ? @"Edit User" : @"Add User";
    
    
    self.atributeNameDictionary = [[NSDictionary alloc]initWithObjectsAndKeys:@"Введите имя",kFirstNameAtributeNameDictionary,
                                                                              @"Введите фамилию",kLastNameAtributeNameDictionary,
                                                                              @"введите email",kEmailAtributeNameDictionary,nil];
    
    
    
    
        UIBarButtonItem *actionCancelBurButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(actionCancel:)];
    
        self.navigationItem.leftBarButtonItem = actionCancelBurButton;
    
        UIBarButtonItem *actionCompleteBurButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(actionComplete:)];
        self.navigationItem.rightBarButtonItem = actionCompleteBurButton;
    
    

}

#pragma mark - lazy initialization
-(NSManagedObjectContext*)managedObjectContext{
    
    if(!_managedObjectContext)
    {
        _managedObjectContext = [[DataManager sharedDataManager] managedObjectContext];
    }
    return _managedObjectContext;
}


#pragma mark - action

-(void)actionCancel:(UIBarButtonItem*)sender{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)actionComplete:(UIBarButtonItem*)sender{
    
    
    NSArray<__kindof UITableViewCell *> *atributes = self.tableView.visibleCells;
    BOOL isEmptyAtributes = NO;
    for (UserCell *userCell in atributes)
    {
        if([userCell.atributeText.text length] == 0)
        {
            isEmptyAtributes = YES;
            break;
        }
    }
    if (isEmptyAtributes) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Внимание"
                                                                       message:@"Имеются не заполненные поля."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }else{
        NSError *error = nil;
        if(!self.user)
            {
            User *user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:self.managedObjectContext];
            user.firstName = [(UserCell*)[atributes objectAtIndex:0] atributeText].text;
            user.lastName = [(UserCell*)[atributes objectAtIndex:1] atributeText].text;
            user.email = [(UserCell*)[atributes objectAtIndex:2] atributeText].text;
        }
        else{
            
            self.user.firstName = [(UserCell*)[atributes objectAtIndex:0] atributeText].text;
            self.user.lastName = [(UserCell*)[atributes objectAtIndex:1] atributeText].text;
            self.user.email = [(UserCell*)[atributes objectAtIndex:2] atributeText].text;
        }
        
        if(![self.managedObjectContext save:&error])
        {
            NSLog(@"%@",[error localizedDescription]);
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}





#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ATRIBUTECOUNT;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"UserCell";
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    [self atributeNameForCell:cell indexPath:indexPath];
    return cell;
}

-(void)atributeNameForCell:(UserCell*)userCell indexPath:(NSIndexPath*)indexPath{
    NSString *keyAtributeName = nil;
    
    
    if(indexPath.row == AddUserViewControllerFirstNameAtributeNameDictionary)
    {
        keyAtributeName = kFirstNameAtributeNameDictionary;
    }else if(indexPath.row == AddUserViewControllerLastNameAtributeNameDictionary){
        
        keyAtributeName = kLastNameAtributeNameDictionary;
    }else if(indexPath.row == AddUserViewControllerEmailAtributeNameDictionary){
        
        keyAtributeName = kEmailAtributeNameDictionary;
    }
    userCell.atribute.text = keyAtributeName;
    if(!self.isEditMode)
    {
        userCell.atributeText.placeholder = [self.atributeNameDictionary objectForKey:keyAtributeName];
    }else{
        userCell.atributeText.text = [self.atributeNameUserDictionary objectForKey:keyAtributeName];
    }

}

@end
