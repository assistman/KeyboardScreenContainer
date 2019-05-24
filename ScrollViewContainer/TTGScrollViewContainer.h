//
//    The TTGScrollViewContainer.h is part of the Cosmos project.
//    Copyright © 2019 KSTT. All rights reserved.Proprietary and confidential.	
//    Unauthorized copying of this file via any medium is strictly prohibited.
//

#import <UIKit/UIKit.h>

@class TTGScrollViewContainer;

@protocol TTGKeyboardContainerEmbedable <NSObject>

@property (copy, nonatomic) NSArray *allTextFields;

@optional
- (BOOL)container:(TTGScrollViewContainer *)container textFieldShouldClear:(UITextField *)textField;
- (BOOL)container:(TTGScrollViewContainer *)container textFieldShouldReturn:(UITextField *)textField;
- (BOOL)container:(TTGScrollViewContainer *)container textFieldShouldBeginEditing:(UITextField *)textField;
- (void)container:(TTGScrollViewContainer *)container textFieldDidBeginEditing:(UITextField *)textField;
- (BOOL)container:(TTGScrollViewContainer *)container textFieldShouldEndEditing:(UITextField *)textField;
- (void)container:(TTGScrollViewContainer *)container textFieldDidEndEditing:(UITextField *)textField;
- (void)container:(TTGScrollViewContainer *)container textFieldDidEndEditing:(UITextField *)textField reason:(UITextFieldDidEndEditingReason)reason;
- (BOOL)container:(TTGScrollViewContainer *)container textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
@end

@interface TTGScrollViewContainer : UIViewController

// Designated setup method
- (void)setupWithContentVC:(UIViewController <TTGKeyboardContainerEmbedable>*)contentVC
                    fields:(NSArray <UITextField *>*)fields
            toolbarEnabled:(BOOL)toolbarEnabled;

// Container dismissal
- (void)dismissWithCompletion:(void(^)(void))completion;

@end
