//
//  AddUserViewController.m
//  CoreData
//
//  Created by EnzoF on 29.10.16.
//  Copyright © 2016 EnzoF. All rights reserved.
//

#import "AddUserViewController.h"
#import "ManagerTableViewController.h"
#import "AddCoursesViewController.h"


#import "DataManager.h"
#import "UserCell.h"
#import "User.h"

#import "AddUserCell.h"
#import "Course+CoreDataProperties.h"




static  NSString *kFirstNameAtributeNameDictionary = @"Имя";
static  NSString *kLastNameAtributeNameDictionary  = @"Фамилия";
static  NSString *kEmailAtributeNameDictionary = @"email";

typedef enum{
    AddUserViewControllerFirstNameAtributeNameDictionary = 0,
    AddUserViewControllerLastNameAtributeNameDictionary  = 1,
    AddUserViewControllerEmailAtributeNameDictionary     = 2,
}AddUserViewControllerAtributeNameDictionary;


typedef enum{
    AddUserViewControllerSectionGeneral = 0,
    AddUserViewControllerSectionCourse  = 1
}AddCoursesViewControllerSectionType;


@interface AddUserViewController ()<ManagerTableViewDelegate>

@property(nonatomic,strong) NSDictionary *atributeNameDictionary;
@property(nonatomic,strong) NSDictionary *atributeNameUserDictionary;
@property(nonatomic,strong) NSArray *arrayCourses;

@property (strong,nonatomic) NSString *firstName;
@property (strong,nonatomic) NSString *lastName;
@property (strong,nonatomic) NSString *email;


@end

@implementation AddUserViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.isEditMode = NO;
    if(self.user)
    {
        self.isEditMode = YES;
        
        self.arrayCourses = [[NSArray alloc] initWithArray:[self.user.courses allObjects]];
        
        
        self.firstName  = self.user.firstName;
        self.lastName   = self.user.lastName;
        self.email      = self.user.email;
        
    }else{
        self.user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:self.managedObjectContext];
    }
    
    [self updateAtributeNameUserDictionary];
    
    self.navigationItem.title = self.isEditMode ? @"Edit User" : @"Add User";
    
    
    self.atributeNameDictionary = [[NSDictionary alloc]initWithObjectsAndKeys:
                                   @"Введите имя",kFirstNameAtributeNameDictionary,
                                   @"Введите фамилию",kLastNameAtributeNameDictionary,
                                   @"Введите email",kEmailAtributeNameDictionary,nil];    

        UIBarButtonItem *actionCancelBarButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(actionCancel:)];
        self.navigationItem.leftBarButtonItem = actionCancelBarButton;
    
        UIBarButtonItem *actionCompleteBarButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(actionComplete:)];
        self.navigationItem.rightBarButtonItem = actionCompleteBarButton;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChangeNotification:) name:UITextFieldTextDidChangeNotification object:nil];
    
}

-(void)dealoc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
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
    [[[DataManager sharedDataManager] managedObjectContext] rollback];
    [self dismissVC];
}


-(void)actionComplete:(UIBarButtonItem*)sender{
    
    self.user.firstName = self.firstName;
    self.user.lastName  = self.lastName;
    self.user.email     = self.email;
    

    BOOL isEmptyAtributes = NO;
    if([self.user.firstName length] < 1 || [self.user.lastName length] < 1  || [self.email length] < 1 )
    {
        isEmptyAtributes = YES;
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
        if(![self.managedObjectContext save:&error])
        {
            NSLog(@"%@",[error localizedDescription]);
        }
        [self dismissVC];
    }
}

#pragma mark - metods

-(void)dismissVC{
    if ([self.navigationController.viewControllers count] < 2) {
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    } else {
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma  mark - row metods

-(NSInteger)getRow:(NSInteger)row{
    return row - 1;
}

-(NSInteger)getNumbersOfRow:(NSInteger)count{
    return count + 1;
}



#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.arrayCourses count] > 0 ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rowCount = 0;
    if(section == AddUserViewControllerSectionGeneral)
    {
        rowCount = 2;
    }else if(section == AddUserViewControllerSectionCourse){
        rowCount = [self getNumbersOfRow:[self.arrayCourses count]];
    }
    
    return rowCount;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifierAddCourseCell = @"AddCourseCell";
    static NSString *identifierUserCell      = @"UserCell";
    static NSString *identifierCourseCell    = @"CourseCell";
    
    if(indexPath.section == AddUserViewControllerSectionGeneral)
    {
        UserCell *userCell = [tableView dequeueReusableCellWithIdentifier:identifierUserCell];
        [self atributeNameForCell:userCell indexPath:indexPath];
        return userCell;
        
    }else if(indexPath.section == AddUserViewControllerSectionCourse){
        if(indexPath.row == 0)
        {
            AddUserCell *addCourseCell = [tableView dequeueReusableCellWithIdentifier:identifierAddCourseCell];
            return addCourseCell;
        }else{
            UITableViewCell *courseCell = [tableView dequeueReusableCellWithIdentifier:identifierCourseCell];
            if(!courseCell)
            {
                courseCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifierCourseCell];
            }
            Course *course = [self.arrayCourses objectAtIndex:[self getRow:indexPath.row]];
            courseCell.textLabel.text = course.title;
            return courseCell;
        }
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.section == AddUserViewControllerSectionCourse)
    {
        if(indexPath.row == 0)
        {
            
            ManagerTableViewController *managerTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ManagerTableViewController"];
            
            managerTVC.dataObj = self.user;
            managerTVC.entityName = @"Course";
            managerTVC.delegate = self;
            UINavigationController *navC = [[UINavigationController alloc]initWithRootViewController:managerTVC];
            
            [self presentViewController:navC animated:YES completion:nil];
            
        }else{
            
            Course *course = [self.arrayCourses objectAtIndex:[self getRow:indexPath.row]];
            AddCoursesViewController *addCourseVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AddCoursesViewController"];
            addCourseVC.course = course;
            [self.navigationController pushViewController:addCourseVC animated:YES];
        }
    }
}



-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    BOOL isEdit = NO;
    
    if(indexPath.section == AddUserViewControllerSectionCourse)
    {
        isEdit = YES;
    }
    return isEdit;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        Course *course = [self.arrayCourses objectAtIndex: [self getRow:indexPath.row]];
        NSMutableArray *mArrayCourses = [[NSMutableArray alloc]initWithArray:self.arrayCourses];
        [mArrayCourses removeObject:course];
        
        [self.user setCourses:[NSSet setWithArray:mArrayCourses]];
        
        self.arrayCourses = [[NSArray alloc] initWithArray:mArrayCourses];
        [self updateAtributeNameUserDictionary];
        
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
}


#pragma mark - UITextFieldTextDidChangeNotification

-(void)textDidChangeNotification:(NSNotification*)notification{
    if([notification.object isKindOfClass:[UITextField class]])
    {
        UITextField *textField = (UITextField*)notification.object;
        [self saveValueFromControl:textField];
    }
    NSLog(@"UITextFieldTextDidChangeNotification %@",notification);
}


-(void)atributeNameForCell:(UserCell*)userCell indexPath:(NSIndexPath*)indexPath{
    NSString *keyAtributeName = nil;
    NSInteger identifierAtributeText = 1000;
    if(indexPath.row == AddUserViewControllerFirstNameAtributeNameDictionary)
    {
        keyAtributeName = kFirstNameAtributeNameDictionary;
        identifierAtributeText = AddUserViewControllerFirstNameAtributeNameDictionary;
        
    }else if(indexPath.row == AddUserViewControllerLastNameAtributeNameDictionary){
        
        keyAtributeName = kLastNameAtributeNameDictionary;
        identifierAtributeText = AddUserViewControllerLastNameAtributeNameDictionary;
        
    }else if(indexPath.row == AddUserViewControllerEmailAtributeNameDictionary){
        
        keyAtributeName = kEmailAtributeNameDictionary;
        identifierAtributeText = AddUserViewControllerEmailAtributeNameDictionary;
        
    }
    userCell.atribute.text = keyAtributeName;
    userCell.atributeText.tag = identifierAtributeText;
    if(!self.isEditMode || [[self.atributeNameUserDictionary objectForKey:keyAtributeName] length] < 1)
    {
        userCell.atributeText.placeholder = [self.atributeNameDictionary objectForKey:keyAtributeName];
    }else{
        userCell.atributeText.text = [self.atributeNameUserDictionary objectForKey:keyAtributeName];
    }
    [self saveValueFromControl:userCell.atributeText];
}

-(void)saveValueFromControl:(UITextField*)textField{
    NSInteger idebtifierAtributeText = textField.tag;
    NSString *text = textField.text;
    //textField.delegate = self;
    if(idebtifierAtributeText == AddUserViewControllerFirstNameAtributeNameDictionary)
    {
        self.firstName = text;
        
    }else if(idebtifierAtributeText == AddUserViewControllerLastNameAtributeNameDictionary){
        
        self.lastName = text;
    }else if(idebtifierAtributeText == AddUserViewControllerEmailAtributeNameDictionary){
        
        self.email = text;
    }
}


#pragma mark - ManagerTableViewDelegate

-(void)upDataArray:(NSArray *)array witEntityName:(NSString*)entityName{
    
    
    if([entityName isEqualToString:@"Course"])
    {
        self.arrayCourses = array;
        [self.user setCourses:[NSSet setWithArray:self.arrayCourses]];
    }
    [self.tableView reloadData];
}




#pragma mark - metods

-(void)updateAtributeNameUserDictionary{
    self.atributeNameUserDictionary = [[NSDictionary alloc]initWithObjectsAndKeys:
                                       self.user.firstName,kFirstNameAtributeNameDictionary,
                                       self.user.lastName,kLastNameAtributeNameDictionary,
                                       self.user.email,kEmailAtributeNameDictionary,nil];
}

@end
