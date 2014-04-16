//
//  TutorialViewController.h
//  Patroca
//
//  Created by Rafael Gaino on 4/15/14.
//  Copyright (c) 2014 Punk Opera. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MYBlurIntroductionView.h"
#import "MasterViewController.h"

@interface TutorialViewController : UIViewController <MYIntroductionDelegate>

@property (weak, nonatomic) MasterViewController *masterViewController;

@end
