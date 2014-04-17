//
//  TaskHeaderView.m
//  AlfrescoApp
//
//  Created by Tauseef Mughal on 24/02/2014.
//  Copyright (c) 2014 Alfresco. All rights reserved.
//

#import "TaskHeaderView.h"
#import "Utility.h"

static CGFloat const kCalendarCornerRadius = 10.0f;
static CGFloat const kCalendarStrokeWidth = 0.5f;

typedef NS_ENUM(NSUInteger, WorkflowPriorityType)
{
    WorkflowPriorityTypeHigh = 1,
    WorkflowPriorityTypeMedium,
    WorkflowPriorityTypeLow
};

@interface TaskHeaderView ()

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, weak) IBOutlet UIView *calendarBackgroundView;
@property (nonatomic, weak) IBOutlet UILabel *calendarMonthLabel;
@property (nonatomic, weak) IBOutlet UILabel *calendarDateLabel;
@property (nonatomic, weak) IBOutlet UILabel *taskNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *taskTypeLabel;
@property (nonatomic, weak) IBOutlet UILabel *taskInitiatorLabel;
@property (nonatomic, weak) IBOutlet UIImageView *taskPriorityImageView;
@property (nonatomic, weak) IBOutlet UILabel *taskPriorityLabel;

@end

@implementation TaskHeaderView

- (void)awakeFromNib
{
    [self commonInit];
}

#pragma mark - Private Functions

- (void)commonInit
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self setupCalendarBackgroundView];
}

- (void)setupCalendarBackgroundView
{
    self.calendarBackgroundView.layer.cornerRadius = kCalendarCornerRadius;
    self.calendarBackgroundView.layer.borderWidth = kCalendarStrokeWidth;
    self.calendarBackgroundView.layer.borderColor = [[UIColor blackColor] CGColor];
    self.calendarBackgroundView.backgroundColor = [UIColor whiteColor];
}

- (NSString *)priortyStringFromPriority:(NSNumber *)priority
{
    NSString *priorityString = nil;
    
    switch (priority.integerValue)
    {
        case WorkflowPriorityTypeHigh:
            priorityString = NSLocalizedString(@"tasks.priority.high", @"High Priority");
            break;
            
        case WorkflowPriorityTypeMedium:
            priorityString = NSLocalizedString(@"tasks.priority.medium", @"Medium Priority");
            break;
            
        case WorkflowPriorityTypeLow:
            priorityString = NSLocalizedString(@"tasks.priority.low", @"Low Priority");
            break;
    }
    
    return priorityString;
}

- (void)setPriorityLevel:(NSNumber *)priority
{
    self.taskPriorityImageView.image = [Utility imageForPriority:priority];
    self.taskPriorityLabel.text = [self priortyStringFromPriority:priority];
}

#pragma mark - Public Functions

- (void)updateTaskFilterLabelToString:(NSString *)taskTypeString
{
    self.taskTypeLabel.text = taskTypeString;
}

- (void)configureViewForProcess:(AlfrescoWorkflowProcess *)process
{
    [self.dateFormatter setDateFormat:@"MMMM"];
    self.calendarMonthLabel.text = [self.dateFormatter stringFromDate:process.dueAt];
    [self.dateFormatter setDateFormat:@"dd"];
    self.calendarDateLabel.text = [self.dateFormatter stringFromDate:process.dueAt];
    self.taskNameLabel.text = (process.name) ? process.name : NSLocalizedString(@"tasks.process.unnamed", @"Unnamed process");
    self.taskTypeLabel.text = @"";
    self.taskInitiatorLabel.text = process.initiatorUsername;
    [self setPriorityLevel:process.priority];
}

- (void)configureViewForTask:(AlfrescoWorkflowTask *)task
{
    [self.dateFormatter setDateFormat:@"MMMM"];
    self.calendarMonthLabel.text = [self.dateFormatter stringFromDate:task.dueAt];
    [self.dateFormatter setDateFormat:@"dd"];
    self.calendarDateLabel.text = [self.dateFormatter stringFromDate:task.dueAt];
    self.taskNameLabel.text = (task.name) ? task.name : NSLocalizedString(@"tasks.process.unnamed", @"Unnamed process");
    self.taskTypeLabel.text = @"";
    self.taskInitiatorLabel.text = task.assigneeIdentifier;
    [self setPriorityLevel:task.priority];
}

@end