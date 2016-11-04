//
//  AddCoursesViewController.m
//  CoreData
//
//  Created by EnzoF on 01.11.16.
//  Copyright © 2016 EnzoF. All rights reserved.
//

#import "AddCoursesViewController.h"
#import "MainUserController.h"
#import "ManagerTableViewController.h"
#import "AddUserViewController.h"
#import "AddTeacherViewController.h"


#import "DataManager.h"
#import "Course+CoreDataProperties.h"
#import "Teacher.h"
#import "Teacher+CoreDataProperties.h"
#import "User+CoreDataProperties.h"

#import "AddUserCell.h"
#import "CourseCell.h"
#import "UserCell.h"




static  NSString *kTitleAtributeNameDictionary      = @"Название";
static  NSString *kDisciplineAtributeNameDictionary = @"Предмет";
static  NSString *kSphereAtributeNameDictionary     = @"Направление";
static  NSString *kTeacherAtributeNameDictionary    = @"Преподаватель";


static  NSString *strEntityNameCourse     = @"Course";
static  NSString *strEntityNameUser       = @"User";
static  NSString *strEntityNameTeacher    = @"Teacher";



typedef enum{
    AddCourseViewControllerTitleAtributeNameDictionary      = 0,
    AddCourseViewControllerDisciplineAtributeNameDictionary = 1,
    AddCourseViewControllerSphereAtributeNameDictionary     = 2,
    AddCourseViewControllerTeacherAtributeNameDictionary    = 3,
}AddUserViewControllerAtributeNameDictionary;




typedef enum{
    AddCoursesViewControllerSectionGeneral  = 0,
    AddCoursesViewControllerSectionTeacher  = 1,
    AddCoursesViewControllerSectionUser     = 2
}AddCoursesViewControllerSectionType;

@interface AddCoursesViewController ()<ManagerTableViewDelegate>

@property(nonatomic,strong) NSDictionary *atributeNameDictionary;
@property(nonatomic,strong) NSDictionary *atributeNameCourseDictionary;
@property(nonatomic,strong) NSArray *arrayUsers;


@property (strong,nonatomic) NSString *titleCourse;
@property (strong,nonatomic) NSString *disciplineCourse;
@property (strong,nonatomic) NSString *sphereCourse;
@property (strong,nonatomic) NSString *teacherCourse;

@end

@implementation AddCoursesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isEditMode = NO;
    if(self.course)
    {
        self.isEditMode = YES;
        
        self.arrayUsers = [[NSArray alloc] initWithArray:[self.course.users allObjects]];
        
        [self upAtributeDictionary];
        
    }else{
        self.course = [NSEntityDescription insertNewObjectForEntityForName:strEntityNameCourse inManagedObjectContext:self.managedObjectContext];
    }
    
    self.atributeNameDictionary = [[NSDictionary alloc]initWithObjectsAndKeys:
                                   @"Введите название курса",kTitleAtributeNameDictionary,
                                   @"Введите предмет",kDisciplineAtributeNameDictionary,
                                   @"Введите направление",kSphereAtributeNameDictionary,
                                   @"Выберите преподавателя",kTeacherAtributeNameDictionary,nil];
    
    self.navigationItem.title = self.isEditMode ? @"Edit Course" : @"Add Course";
    

    
    
    UIBarButtonItem *actionCancelBarButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(actionCancel:)];

    self.navigationItem.leftBarButtonItem = actionCancelBarButton;
    
    UIBarButtonItem *actionCompleteBarButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(actionComplete:)];
    self.navigationItem.rightBarButtonItem = actionCompleteBarButton;
    
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
    if([self.navigationController.viewControllers count] > 1)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];

    }
}


-(void)actionComplete:(UIBarButtonItem*)sender{
    
    self.course.title = self.titleCourse;
    self.course.discipline = self.disciplineCourse;
    self.course.sphere = self.sphereCourse;
    [self.course setUsers:[NSSet setWithArray:self.arrayUsers]];
    NSError *error = nil;
    
    BOOL isEmptyAtributes = NO;
    if([self.course.title length] < 1)
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
    
        if(![[[DataManager sharedDataManager] managedObjectContext]save:&error])
        {
            NSLog(@"%@",[error localizedDescription]);
        }else{
            
            [self dismissVC];
        }
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

-(void)upAtributeDictionary{
    self.atributeNameCourseDictionary = nil;
    NSString *fullName = nil;
    if(self.course.teachers)
    {
        fullName = [NSString stringWithFormat:@"%@ %@",self.course.teachers.lastName,self.course.teachers.firstName];
    }
    self.atributeNameCourseDictionary  = [[NSDictionary alloc]initWithObjectsAndKeys:
                                          self.course.title,kTitleAtributeNameDictionary,
                                          self.course.discipline,kDisciplineAtributeNameDictionary,
                                          self.course.sphere,kSphereAtributeNameDictionary,
                                          fullName,kTeacherAtributeNameDictionary,nil];
}


-(void)presentManagerControllerWithEntity:(NSString*)antityName{
    
    ManagerTableViewController *managerTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ManagerTableViewController"];
    
    managerTVC.dataObj = self.course;
    managerTVC.entityName = antityName;
    managerTVC.delegate = self;
    UINavigationController *navC = [[UINavigationController alloc]initWithRootViewController:managerTVC];
    
    [self presentViewController:navC animated:YES completion:nil];
}


#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rowsCount = 0;
    if(section == AddCoursesViewControllerSectionGeneral)
    {
        rowsCount = 4;
    }else if(section == AddCoursesViewControllerSectionUser){
        rowsCount = [self getNumbersOfRow:[self.arrayUsers count]];
    }else if(section == AddCoursesViewControllerSectionTeacher){
        
        rowsCount = self.course.teachers != nil ? 2 : 1;
    }
    return rowsCount;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifierAddUserCell = @"AddUserCell";
    static NSString *identifierCourseCell = @"CourseCell";
    static NSString *identifierStudentCell = @"StudentCell";
    
    if(indexPath.section == AddCoursesViewControllerSectionGeneral)
    {
        CourseCell *courseCell = [tableView dequeueReusableCellWithIdentifier:identifierCourseCell];
        [self atributeNameForCell:courseCell indexPath:indexPath];
        [self saveValueFromControl:courseCell.atributeText];
        return courseCell;
    }else if(indexPath.section == AddCoursesViewControllerSectionTeacher){
        
        if(indexPath.row == 0)
        {
            AddUserCell *addUserCell = [tableView dequeueReusableCellWithIdentifier:identifierAddUserCell];
            addUserCell.title.text = @"Add new Teacher";
            return addUserCell;

        }else{
            CourseCell *courseCell = [tableView dequeueReusableCellWithIdentifier:identifierCourseCell];
            courseCell.atributeText.enabled = NO;
            [self atributeNameForCell:courseCell indexPath:indexPath];
            [self saveValueFromControl:courseCell.atributeText];
            return courseCell;
        }
    }else if(indexPath.section == AddCoursesViewControllerSectionUser){
        
        if(indexPath.row == 0)
        {
            AddUserCell *addUserCell = [tableView dequeueReusableCellWithIdentifier:identifierAddUserCell];
            return addUserCell;
        }
        else{
            UITableViewCell *studentCell = [tableView dequeueReusableCellWithIdentifier:identifierStudentCell];
            if(!studentCell)
            {
                studentCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifierStudentCell];
            }
            User *user = [self.arrayUsers objectAtIndex:[self getRow:indexPath.row]];
            studentCell.detailTextLabel.text = user.firstName;
            studentCell.textLabel.text = user.lastName;
            studentCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return studentCell;
        }
    }
    return nil;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section == AddCoursesViewControllerSectionUser)
    {
        if(indexPath.row == 0)
        {
            
            [self presentManagerControllerWithEntity:strEntityNameUser];
        }else{
            User *user = [self.arrayUsers objectAtIndex:[self getRow:indexPath.row]];
            
            AddUserViewController *addUserVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AddUserViewController"];
            addUserVC.user = user;
            
            //UINavigationController *navC = [[UINavigationController alloc]initWithRootViewController:addUserVC];
            [self.navigationController pushViewController:addUserVC animated:YES];
        }
    }else if(indexPath.section == AddCoursesViewControllerSectionTeacher){
        if(indexPath.row == 0)
        {
            [self presentManagerControllerWithEntity:strEntityNameTeacher];
        }else{
            
            Teacher *teacher = self.course.teachers;
            AddTeacherViewController *addTracherVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AddTeacherViewController"];
            addTracherVC.teacher = teacher;
            [self.navigationController pushViewController:addTracherVC animated:YES];
            
        }
    }
}


-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString *title = nil;
    if(section == AddCoursesViewControllerSectionGeneral)
    {
        title = @"Общие данные";
    }
    if(section == AddCoursesViewControllerSectionTeacher)
    {
        title = @"Преподаватель";
    }
    if(section == AddCoursesViewControllerSectionUser)
    {
        title = @"Студенты";
    }
    return title;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 25.f;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        if(indexPath.section == AddCoursesViewControllerSectionUser && indexPath.row != 0)
        {
            User *user = [self.arrayUsers objectAtIndex: [self getRow:indexPath.row]];
            NSMutableArray *mArrayUsers = [[NSMutableArray alloc]initWithArray:self.arrayUsers];
            [mArrayUsers removeObject:user];
            
            [self.course setUsers:[NSSet setWithArray:mArrayUsers]];
            
            self.arrayUsers = [[NSArray alloc] initWithArray:mArrayUsers];
            [self upAtributeDictionary];
            
            [self updateRows:indexPath];
        }else if(indexPath.section == AddCoursesViewControllerSectionTeacher && indexPath.row == 1){
            
            [self.course setTeachers:nil];
            [self updateRows:indexPath];
        }
        
    }


}

-(void)updateRows:(NSIndexPath*)indexPath{
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    
    BOOL isEdit = NO;
    
    if(indexPath.section == AddCoursesViewControllerSectionUser && indexPath.row != 0)
    {
        isEdit = YES;
    }
    if(indexPath.section == AddCoursesViewControllerSectionGeneral && indexPath.row == AddCourseViewControllerTeacherAtributeNameDictionary)
    {
        isEdit = YES;
    }
    if(indexPath.section == AddCoursesViewControllerSectionTeacher && indexPath.row == 1)
    {
        isEdit = YES;
    }
             
    return isEdit;
}





-(void)atributeNameForCell:(CourseCell*)courseCell indexPath:(NSIndexPath*)indexPath{
    NSString *keyAtributeName = nil;
    NSInteger identifierAtributeText = 1000;
    if(indexPath.row == AddCourseViewControllerTitleAtributeNameDictionary)
    {
        keyAtributeName = kTitleAtributeNameDictionary;
        identifierAtributeText = AddCourseViewControllerTitleAtributeNameDictionary;
        
    }else if(indexPath.row == AddCourseViewControllerDisciplineAtributeNameDictionary && indexPath.section != AddCoursesViewControllerSectionTeacher){
        
        keyAtributeName = kDisciplineAtributeNameDictionary;
        identifierAtributeText = AddCourseViewControllerDisciplineAtributeNameDictionary;
        
    }else if(indexPath.row == AddCourseViewControllerSphereAtributeNameDictionary){
        
        keyAtributeName = kSphereAtributeNameDictionary;
        identifierAtributeText = AddCourseViewControllerSphereAtributeNameDictionary;
        
    }else if(indexPath.row == 1 & indexPath.section == AddCoursesViewControllerSectionTeacher ){
        
        keyAtributeName = kTeacherAtributeNameDictionary;
        identifierAtributeText = AddCourseViewControllerTeacherAtributeNameDictionary;
    }

    courseCell.atributeName.text = keyAtributeName;
    courseCell.atributeText.tag = identifierAtributeText;
    

    
    
    if(!self.isEditMode || [[self.atributeNameCourseDictionary objectForKey:keyAtributeName] length] < 1)
    {
        courseCell.atributeText.placeholder = [self.atributeNameDictionary objectForKey:keyAtributeName];
    }else{
        
        courseCell.atributeText.text = [self.atributeNameCourseDictionary objectForKey:keyAtributeName];
    }
}

#pragma  mark - row metods

-(NSInteger)getRow:(NSInteger)row{
    return row - 1;
}

-(NSInteger)getNumbersOfRow:(NSInteger)count{
    return count + 1;
}


-(void)saveValueFromControl:(UITextField*)textField{
    NSInteger idebtifierAtributeText = textField.tag;
    NSString *text = textField.text;
    if(idebtifierAtributeText == AddCourseViewControllerTitleAtributeNameDictionary)
    {
        self.titleCourse = text;
        
    }else if(idebtifierAtributeText == AddCourseViewControllerDisciplineAtributeNameDictionary){
        
       self.disciplineCourse = text;
        
    }else if(idebtifierAtributeText == AddCourseViewControllerSphereAtributeNameDictionary){
        
       self.sphereCourse = text;
        
    }else if(idebtifierAtributeText == AddCourseViewControllerTeacherAtributeNameDictionary){
        
        self.teacherCourse = text;
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

#pragma mark - ManagerTableViewDelegate

-(void)upDataArray:(NSArray *)array witEntityName:(NSString*)entityName{
    
    
    if([entityName isEqualToString:strEntityNameUser])
    {
        self.arrayUsers = array;
        [self.course setUsers:[NSSet setWithArray:self.arrayUsers]];
        
    }else if([entityName isEqualToString:strEntityNameTeacher]){
        
        if([array count] > 0)
        {
            self.course.teachers = [array firstObject];
        }else{
            self.course.teachers = nil;
        }
        [self upAtributeDictionary];
        
    }
    [self.tableView reloadData];
}


@end
