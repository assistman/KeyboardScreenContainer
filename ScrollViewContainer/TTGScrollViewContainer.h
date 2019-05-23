//
//    The TTGScrollViewContainer.h is part of the Cosmos project.
//    Copyright © 2019 KSTT. All rights reserved.Proprietary and confidential.	
//    Unauthorized copying of this file via any medium is strictly prohibited.
//

#import <UIKit/UIKit.h>

@protocol TTGTextFieldResizableContainer <NSObject>

@optional
// Pass text fields which should contain UIToolBar with 'Next' and 'Previous' buttons
- (void)setupTextFieldsToolbarAccessory:(NSArray *)fields;

// Call this method when field begins editing
- (void)activateField:(UITextField *)textField;

// Call this method when field ends editing
- (void)deactivateField:(UITextField *)textField;
@end

@interface TTGScrollViewContainer : UIViewController <TTGTextFieldResizableContainer>

// Do not change any layout, only for appearance UI adjustments.
@property (strong, nonatomic) IBOutlet UIView *mainContainer;
@property (strong, nonatomic) IBOutlet UIScrollView *mainScrollView;

@end
