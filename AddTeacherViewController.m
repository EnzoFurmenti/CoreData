//
//  AddTeacher.m
//  CoreData
//
//  Created by EnzoF on 02.11.16.
//  Copyright © 2016 EnzoF. All rights reserved.
//

#import "AddTeacherViewController.h"
#import "AddCoursesViewController.h"
#import "Teacher.h"
#import "Teacher+CoreDataProperties.h"
#import "ManagerTableViewController.h"

#import "DataManager.h"
#import "Course+CoreDataProperties.h"

#import "AddUserCell.h"
#import "UserCell.h"





static  NSString *kFirstNameAtributeNameDictionary = @"Имя";
static  NSString *kLastNameAtributeNameDictionary  = @"Фамилия";


typedef enum{
    AddTeacherViewControllerFirstNameAtributeNameDictionary = 0,
    AddTeacherViewControllerLastNameAtributeNameDictionary  = 1,
}AddTeacherViewControllerAtributeNameDictionary;

typedef enum{
    AddTeacherViewControllerGeneralSection = 0,
    AddTeacherViewControllerCourseSection  = 1,
}AddTeacherViewControllerSection;



@interface AddTeacherViewController ()<UITextFieldDelegate,ManagerTableViewDelegate>

@property(nonatomic,strong) NSDictionary *atributeNameDictionary;
@property(nonatomic,strong) NSDictionary *atributeNameTeacherDictionary;

@property (strong,nonatomic) NSString *firstName;
@property (strong,nonatomic) NSString *lastName;

@property (strong,nonatomic) NSArray *arrayCourses;

@end


@implementation AddTeacherViewController


-(void)viewDidLoad{
    [super viewDidLoad];
    
    
    self.isEditMode = NO;
    if(self.teacher)
    {
        self.isEditMode = YES;
        [self upAtributeDictionary];
    }else{
        
        self.atributeNameDictionary = [[NSDictionary alloc]initWithObjectsAndKeys:
                                       @"Введите имя",kFirstNameAtributeNameDictionary,
                                       @"Введите фамилию",kLastNameAtributeNameDictionary,nil];
        
        self.teacher = [NSEntityDescription insertNewObjectForEntityForName:@"Teacher" inManagedObjectContext:self.managedObjectContext];
    }
    
    [self upDataCourseArray];
    
    
    self.navigationItem.title = self.isEditMode ? @"Edit Teacher" : @"Add Teacher";
    
    
    UIBarButtonItem *actionCancelBarButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(actionCancel:)];
    
    self.navigationItem.leftBarButtonItem = actionCancelBarButton;
    
    UIBarButtonItem *actionCompleteBarButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(actionComplete:)];
    self.navigationItem.rightBarButtonItem = actionCompleteBarButton;
    
     self.firstName =  self.teacher.firstName;
     self.lastName = self.teacher.lastName;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChangeNotification:) name:UITextFieldTextDidChangeNotification object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self upAtributeDictionary];
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
    
    self.teacher.firstName = self.firstName;
    self.teacher.lastName = self.lastName;
    
    BOOL isEmptyAtributes = NO;
    if([self.teacher.firstName length] < 1 || [self.teacher.lastName length] < 1)
    {
        isEmptyAtributes = YES;
    }
    if (isEmptyAtributes)
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Внимание"
                                                                       message:@"Не заполненно поле название."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        

    }else{
        NSError *error = nil;
        if(![[[DataManager sharedDataManager] managedObjectContext]save:&error])
        {
            NSLog(@"%@",[error localizedDescription]);
        }else{
            [self dismissVC];
        }
    }
}



#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.arrayCourses != nil ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rowCount = 1;
    if(section == AddTeacherViewControllerGeneralSection)
    {
        rowCount = 2;
    }else if(section == AddTeacherViewControllerCourseSection){
        rowCount = [self getNumbersOfRow:[self.arrayCourses count]];
    }
    return rowCount;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString *title = nil;
    if(section == AddTeacherViewControllerGeneralSection)
    {
        title = @"Основные данные";
        
    }else if(section == AddTeacherViewControllerCourseSection){
        
        title = @"Курсы";
    }
    return title;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifierUserCell = @"UserCell";
    static NSString *identifierCourseCell = @"CourseCell";
    static NSString *identifierAddCourseCell = @"AddCourseCell";
    if(indexPath.section == AddTeacherViewControllerGeneralSection)
    {
        UserCell *teacherCell = [tableView dequeueReusableCellWithIdentifier:identifierUserCell];
        [self atributeNameForCell:teacherCell indexPath:indexPath];
        return teacherCell;
        
    }else if(indexPath.section == AddTeacherViewControllerCourseSection){
        if(indexPath.row == 0)
        {
            AddUserCell *addUserCell = [tableView dequeueReusableCellWithIdentifier:identifierAddCourseCell];
            return addUserCell;
        }else{
            UITableViewCell *courseCell = [tableView dequeueReusableCellWithIdentifier:identifierCourseCell];
            if(!courseCell)
            {
                courseCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifierCourseCell];
            }
            courseCell.textLabel.text = [(Course*)[self.arrayCourses objectAtIndex:[self getRow:indexPath.row]] title];
            courseCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return courseCell;
        }
    }
    return  nil;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section == AddTeacherViewControllerCourseSection)
    {
        if(indexPath.row == 0)
        {
            ManagerTableViewController *managerTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ManagerTableViewController"];
            
            managerTVC.dataObj = self.teacher;
            managerTVC.entityName = @"Course";
            managerTVC.delegate = self;
            UINavigationController *navC = [[UINavigationController alloc]initWithRootViewController:managerTVC];
            
            [self presentViewController:navC animated:YES completion:nil];
        }else{
            Course *course = [self.arrayCourses objectAtIndex:[self getRow:indexPath.row]];
            
            AddCoursesViewController *addCoursesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AddCoursesViewController"];
            addCoursesVC.course = course;
            
            [self.navigationController pushViewController:addCoursesVC animated:YES];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    BOOL isEdit = NO;
    if(indexPath.section == AddTeacherViewControllerCourseSection && indexPath.row > 0)
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
        
        [self.teacher setCourses:[NSSet setWithArray:mArrayCourses]];
        
        self.arrayCourses = [[NSArray alloc] initWithArray:mArrayCourses];
        [self upAtributeDictionary];
        
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
}

#pragma mark - UsersTableViewDelegate

-(void)upDataArray:(NSArray *)array witEntityName:(NSString*)entityName{
    
    if([entityName isEqualToString:@"Course"])
    {
        self.arrayCourses = array;
        [self.teacher setCourses:[NSSet setWithArray:self.arrayCourses]];
        
    }
    [self.tableView reloadData];
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




#pragma mark - metods
-(void)dismissVC{
    if ([self.navigationController.viewControllers count] < 2) {
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    } else {
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}


-(void)atributeNameForCell:(UserCell*)teacherCell indexPath:(NSIndexPath*)indexPath{
    NSString *keyAtributeName = nil;
    NSInteger identifierAtributeText = 1000;
    if(indexPath.row == AddTeacherViewControllerFirstNameAtributeNameDictionary)
    {
        keyAtributeName = kFirstNameAtributeNameDictionary;
        identifierAtributeText = AddTeacherViewControllerFirstNameAtributeNameDictionary;
        
    }else if(indexPath.row == AddTeacherViewControllerLastNameAtributeNameDictionary){
        
        keyAtributeName = kLastNameAtributeNameDictionary;
        identifierAtributeText = AddTeacherViewControllerLastNameAtributeNameDictionary;
        
    }
    teacherCell.atribute.text = keyAtributeName;
    teacherCell.atributeText.tag = identifierAtributeText;
    if(!self.isEditMode)
    {
        teacherCell.atributeText.placeholder = [self.atributeNameDictionary objectForKey:keyAtributeName];
    }else{
        teacherCell.atributeText.text = [self.atributeNameTeacherDictionary objectForKey:keyAtributeName];
    }
}

-(void)saveValueFromControl:(UITextField*)textField{
    NSInteger idebtifierAtributeText = textField.tag;
    NSString *text = textField.text;
    //textField.delegate = self;
    if(idebtifierAtributeText == AddTeacherViewControllerFirstNameAtributeNameDictionary)
    {
        self.firstName = text;
        
    }else if(idebtifierAtributeText == AddTeacherViewControllerLastNameAtributeNameDictionary){
        
        self.lastName = text;
    }
    
}


#pragma mark - update
-(void)upAtributeDictionary{
    self.atributeNameTeacherDictionary = [[NSDictionary alloc]initWithObjectsAndKeys:
                                          self.teacher.firstName,kFirstNameAtributeNameDictionary,
                                          self.teacher.lastName,kLastNameAtributeNameDictionary,nil];
}

-(void)upDataCourseArray{
     self.arrayCourses = [[NSArray alloc]initWithArray:[self.teacher.courses allObjects]];
}



#pragma  mark - row metods

-(NSInteger)getRow:(NSInteger)row{
    return row - 1;
}

-(NSInteger)getNumbersOfRow:(NSInteger)count{
    return count + 1;
}



@end
