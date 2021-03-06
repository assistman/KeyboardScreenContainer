//
//    The ViewController.m is part of the ScrollViewContainer project.
//    Copyright © 2019 Stanislav Razbiegin. All rights reserved.Proprietary and confidential.	
//    Unauthorized copying of this file via any medium is strictly prohibited.
//

#import "ViewController.h"
#import "ContentViewController.h"

@interface ViewController ()

- (IBAction)openContainer:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)openScrollViewContainer {
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"ViewContainers" bundle:nil];
    ContentViewController *contentVC = [story instantiateViewControllerWithIdentifier:@"ContentViewController"];
    UINavigationController *nav = [story instantiateInitialViewController];
    self.containerVC = (TTGScrollViewContainer *)nav.topViewController;
    
    // All you need to setup container is the following:
    [contentVC loadViewIfNeeded];
    [self.containerVC setupWithContentVC:contentVC fields:contentVC.allFields toolbarEnabled:YES];
    [self presentViewController:nav animated:YES completion:nil];
}

- (IBAction)openContainer:(id)sender {
    [self openScrollViewContainer];
}

@end
