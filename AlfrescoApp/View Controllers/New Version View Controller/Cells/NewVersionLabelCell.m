/*******************************************************************************
 * Copyright (C) 2005-2014 Alfresco Software Limited.
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
 
#import "NewVersionLabelCell.h"

@interface NewVersionLabelCell () <UITextFieldDelegate>

@end

@implementation NewVersionLabelCell

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.valueTextField.textColor = [UIColor textDimmedColor];
    [self.valueTextField setValue:[UIColor textDimmedColor] forKeyPath:@"_placeholderLabel.textColor"];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return NO;
}

@end
