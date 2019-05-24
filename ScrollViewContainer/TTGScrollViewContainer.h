//
//    The TTGScrollViewContainer.h is part of the Cosmos project.
//    Copyright © 2019 KSTT. All rights reserved.Proprietary and confidential.	
//    Unauthorized copying of this file via any medium is strictly prohibited.
//

#import <UIKit/UIKit.h>

@interface TTGScrollViewContainer : UIViewController

// Do not change any layout, only for appearance UI adjustments.
@property (strong, nonatomic) IBOutlet UIView *mainContainer;
@property (strong, nonatomic) IBOutlet UIScrollView *mainScrollView;

// Designated setup method
- (void)setupWithContentController:(UIViewController *)contentVC;

// Add navigation accessory view (multiple fields on screen case)
- (void)setupTextFieldsToolbarAccessory:(NSArray *)fields;

// Call this method when field begins editing
- (void)activateField:(UITextField *)textField;

// Call this method when field ends editing
- (void)deactivateField:(UITextField *)textField;

// Call to do dismiss container with completion block
- (void)dismissWithCompletion:(void(^)(void))completion;

@end
