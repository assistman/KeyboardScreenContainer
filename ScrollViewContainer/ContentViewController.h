//
//    The ContentViewController.h is part of the ScrollViewContainer project.
//    Copyright © 2019 Stanislav Razbiegin. All rights reserved.Proprietary and confidential.	
//    Unauthorized copying of this file via any medium is strictly prohibited.
//

#import <UIKit/UIKit.h>
#import "TTGScrollViewContainer.h"

@interface ContentViewController : UIViewController <TTGKeyboardContainerEmbedable>

// This is the only thing that is needed for the text fields toolbar to work
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *allFields;


@end
