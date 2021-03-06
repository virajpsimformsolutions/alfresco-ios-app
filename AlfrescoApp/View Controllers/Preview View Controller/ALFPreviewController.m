/*******************************************************************************
 * Copyright (C) 2005-2016 Alfresco Software Limited.
 * 
 * This file is part of the Alfresco Mobile iOS App.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *  
 *  http://www.apache.org/licenses/LICENSE-2.0
 * 
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 ******************************************************************************/

#import "ALFPreviewController.h"
#import <QuartzCore/QuartzCore.h>

@interface ALFPreviewController() <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIButton *goFullScreenButton;

@end

@implementation ALFPreviewController

- (instancetype)init
{
    self = [super init];
    if(!self)
    {
        return nil;
    }
    
    self.previewController = [QLPreviewController new];
    self.goFullScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.previewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.previewController.view];
    [self.previewController didMoveToParentViewController:self];
    NSDictionary *views = @{@"previewController":self.previewController.view, @"button":self.goFullScreenButton};
    
    NSArray *previewHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[previewController]|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:views];
    NSArray *previewVerticalContraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[previewController]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views];
    
    [self.view addConstraints:previewHorizontalConstraints];
    [self.view addConstraints:previewVerticalContraints];
    
    self.goFullScreenButton.backgroundColor = [UIColor whiteColor];
    self.goFullScreenButton.alpha = 0.5f;
    self.goFullScreenButton.layer.cornerRadius = 5;
    self.goFullScreenButton.clipsToBounds = YES;
    [self.goFullScreenButton setShowsTouchWhenHighlighted:YES];
    self.goFullScreenButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.goFullScreenButton addTarget:self action:@selector(handleTapGesture:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:self.goFullScreenButton];
    
    NSArray *buttonHorizontalContraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[button(40)]-10-|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:views];
    NSArray *buttonVerticalConstrains = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[button(40)]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views];
    [self.view addConstraints:buttonHorizontalContraints];
    [self.view addConstraints:buttonVerticalConstrains];
}

- (void)handleTapGesture:(id)item
{
    if ([self.gestureDelegate respondsToSelector:@selector(previewControllerWasTapped:)])
    {
        [self.gestureDelegate previewControllerWasTapped:self];
    }
}

- (void)hideButton:(BOOL)shouldHide
{
    [self.goFullScreenButton setHidden:shouldHide];
}

- (void)changeButtonImageIsFullscreen:(BOOL)isFullscreen
{
    UIImage *buttonImage = nil;
    if(isFullscreen)
    {
        buttonImage = [UIImage imageNamed:@"exitFullScreen"];
    }
    else
    {
        buttonImage = [UIImage imageNamed:@"enterFullScreen"];
    }
    [self.goFullScreenButton setImage:buttonImage forState:UIControlStateNormal];
}

@end
