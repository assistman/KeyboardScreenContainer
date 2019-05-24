//
//    The TTGScrollViewContainer.m is part of the Cosmos project.
//    Copyright © 2019 KSTT. All rights reserved.Proprietary and confidential.	
//    Unauthorized copying of this file via any medium is strictly prohibited.
//

#import "TTGScrollViewContainer.h"
#import "ContentViewController.h"

static CGFloat const TTGTopTextFieldGap = 16.0;
static CGFloat const TTGBottomTextFieldGap = 16.0;
static CGFloat const TTGAccessoryToolbarHeight = 50.0;

@interface TTGScrollViewContainer () <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIView *mainContainer;
@property (strong, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *scrollContainerConstraint;
@property (strong, nonatomic) IBOutlet UIView *contentContainer;
@property (strong, nonatomic) UITextField *activeField;
@property (strong, nonatomic) NSArray <UITextField *>*allFields;
@property (assign, nonatomic) BOOL toolbarEnabled;
@property (strong, nonatomic) UIViewController <TTGKeyboardContainerEmbedable>*contentVC;
- (IBAction)close:(id)sender;

// Add navigation accessory view (multiple fields on screen case)
- (void)setupTextFieldsToolbarAccessory:(NSArray *)fields;

@end

@implementation TTGScrollViewContainer

#pragma mark - View Life Cycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self subscribeForNotifications];
    [self setupUI];
}

#pragma mark - Setup

// Designated setup method
- (void)setupWithContentController:(UIViewController <TTGKeyboardContainerEmbedable>*)contentVC withToolbar:(BOOL)addToolbar {
    self.contentVC = contentVC;
    self.toolbarEnabled = addToolbar;
}

- (void)setupWithContentVC:(UIViewController <TTGKeyboardContainerEmbedable>*)contentVC
                    fields:(NSArray <UITextField *>*)fields
            toolbarEnabled:(BOOL)toolbarEnabled {
    self.contentVC = contentVC;
    self.allFields = fields;
    self.toolbarEnabled = toolbarEnabled;
}

// UI adjustments
- (void)setupUI {
    [self setupScrollView];
    [self addChildController:self.contentVC];
    if (self.toolbarEnabled) {
        [self setupTextFieldsToolbarAccessory:self.contentVC.allTextFields];
    }
}

- (void)setupScrollView {
    // This is needed to have a small gaps when keyboard appears and scrolls text field to visible
    self.mainScrollView.contentInset = UIEdgeInsetsMake(TTGTopTextFieldGap, 0, TTGBottomTextFieldGap, 0);
}

#pragma mark - Child Controller

- (void)addChildController:(UIViewController*)childController {
    childController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self addChildViewController:childController];
    [self.contentContainer addSubview:childController.view];
    [self stretchToSuperviewEdges:childController.view];
    [childController.view setNeedsLayout];
    [childController didMoveToParentViewController:self];
}

- (void)removeChildController:(UIViewController*)childController {
    [childController willMoveToParentViewController:nil];
    [childController.view removeFromSuperview];
    [childController removeFromParentViewController];
}

#pragma mark - Keyboard Accessory View (UIToolBar with Next, Previous buttons)

- (void)setupTextFieldsToolbarAccessory:(NSArray *)fields {
    UIView *toolbarView = [self createToolbar];
    for (UITextField *field in fields) {
        field.delegate = self;
        field.inputAccessoryView = toolbarView;
    }
    self.allFields = fields;
}

- (UIToolbar *)createToolbar {
    CGFloat width = CGRectGetWidth(UIScreen.mainScreen.bounds);
    UIToolbar *toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, width, TTGAccessoryToolbarHeight)];
    toolbar.barStyle = UIBarStyleBlackTranslucent;
    UIBarButtonItem *space = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                          target:nil
                                                                          action:nil];
    // TODO: localized
    UIBarButtonItem *previous = [[UIBarButtonItem alloc]initWithTitle:@"Previous"
                                                            style:UIBarButtonItemStyleDone
                                                           target:self
                                                           action:@selector(previousField)];
    UIBarButtonItem *next = [[UIBarButtonItem alloc]initWithTitle:@"Next"
                                                            style:UIBarButtonItemStyleDone
                                                           target:self
                                                           action:@selector(nextField)];
    toolbar.items = @[previous, space, next];
    [toolbar sizeToFit];
    
    return toolbar;
}

- (void)previousField {
    if (!self.activeField) {
        return;
    }
    NSUInteger idx = [self.allFields indexOfObject:self.activeField] - 1;
    if (idx == NSNotFound || idx == NSUIntegerMax) {
        return;
    }
    
    UITextField *previous = self.allFields[idx];
    [previous becomeFirstResponder];
}

- (void)nextField {
    if (!self.activeField) {
        return;
    }
    NSUInteger idx = [self.allFields indexOfObject:self.activeField] + 1;
    if (idx >= self.allFields.count) {
        return;
    }
    UITextField *next = self.allFields[idx];
    [next becomeFirstResponder];
}

- (void)activateField:(UITextField *)textField {
    self.activeField = textField;
    [textField becomeFirstResponder];
}

- (void)deactivateField:(UITextField *)textField {
    self.activeField = nil;
    [textField resignFirstResponder];
}

#pragma mark - Keyboard Notifications

- (void)subscribeForNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidAppear:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillDisappear:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillAppear:(NSNotification *)notification {
    [self.view layoutIfNeeded];
    UIViewAnimationOptions animationOptions = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    CGFloat animationDuration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat topConstantValue = -CGRectGetHeight(keyboardFrame);
    if (self.scrollContainerConstraint.constant == topConstantValue) {
        return;
    }
    
    // This takes into account iPhoneX screen specifics
    CGFloat adjustment = CGRectGetMaxY(self.view.frame) - CGRectGetMaxY(self.mainContainer.frame);
    self.scrollContainerConstraint.constant = topConstantValue + adjustment;
    typeof(self) __weak weakSelf = self;
    [UIView animateWithDuration:animationDuration delay:0 options:animationOptions animations:^{
        [weakSelf.view setNeedsLayout];
        [weakSelf.view layoutIfNeeded];
    } completion:nil];
}

- (void)keyboardDidAppear:(NSNotification *)notification {
    [self.mainScrollView scrollRectToVisible:self.activeField.frame animated:YES];
}

- (void)keyboardWillDisappear:(NSNotification *)notification {
    [self.view layoutIfNeeded];
    UIViewAnimationOptions animationOptions = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    CGFloat animationDuration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    self.scrollContainerConstraint.constant = 0;
    typeof(self) __weak weakSelf = self;
    [UIView animateWithDuration:animationDuration delay:0 options:animationOptions animations:^{
        [weakSelf.view setNeedsLayout];
        [weakSelf.view layoutIfNeeded];
    } completion:nil];
}

#pragma mark - Dismiss container

- (IBAction)close:(id)sender {
    [self dismissWithCompletion:nil];
}

- (void)dismissWithCompletion:(void(^)(void))completion {
    [self.activeField resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:completion];
}

// TODO: User category
- (void)stretchToSuperviewEdges:(UIView *)view {
    view.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *bindings = NSDictionaryOfVariableBindings(view);
    NSString *formatTemplate = @"%@:|[view]|";
    for (NSString * axis in @[@"H",@"V"]) {
        NSString * format = [NSString stringWithFormat:formatTemplate,axis];
        NSArray * constraints = [NSLayoutConstraint constraintsWithVisualFormat:format
                                                                        options:0
                                                                        metrics:nil
                                                                          views:bindings];
        [NSLayoutConstraint activateConstraints:constraints];
    }
}

#pragma mark - UITextFieldDelegate Wrapper

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if ([self.contentVC respondsToSelector:@selector(container:textFieldShouldBeginEditing:)]) {
        return [self.contentVC container:self textFieldShouldBeginEditing:textField];
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self activateField:textField];
    if ([self.contentVC respondsToSelector:@selector(container:textFieldShouldBeginEditing:)]) {
        [self.contentVC container:self textFieldDidBeginEditing:textField];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if ([self.contentVC respondsToSelector:@selector(container:textFieldShouldBeginEditing:)]) {
        return [self.contentVC container:self textFieldShouldEndEditing:textField];
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self deactivateField:textField];
    if ([self.contentVC respondsToSelector:@selector(container:textFieldShouldBeginEditing:)]) {
        [self.contentVC container:self textFieldDidEndEditing:textField];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField reason:(UITextFieldDidEndEditingReason)reason {
    [self deactivateField:textField];
    if ([self.contentVC respondsToSelector:@selector(container:textFieldShouldBeginEditing:)]) {
        [self.contentVC container:self textFieldDidEndEditing:textField reason:reason];
    }
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([self.contentVC respondsToSelector:@selector(container:textFieldShouldBeginEditing:)]) {
        return [self.contentVC container:self textField:textField shouldChangeCharactersInRange:range replacementString:string];
    }
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    if ([self.contentVC respondsToSelector:@selector(container:textFieldShouldBeginEditing:)]) {
        return [self.contentVC container:self textFieldShouldClear:textField];
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    BOOL shouldReturn = YES;
    if ([self.contentVC respondsToSelector:@selector(container:textFieldShouldBeginEditing:)]) {
        shouldReturn = [self.contentVC container:self textFieldShouldReturn:textField];
    }
    
    if (shouldReturn) {
        [self deactivateField:textField];
    }
    
    return shouldReturn;
}

@end
