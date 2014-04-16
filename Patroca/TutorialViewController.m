//
//  TutorialViewController.m
//  Patroca
//
//  Created by Rafael Gaino on 4/15/14.
//  Copyright (c) 2014 Punk Opera. All rights reserved.
//

#import "TutorialViewController.h"

@interface TutorialViewController ()

@end

@implementation TutorialViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    MYIntroductionPanel *panel1 = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
                                                               title:NSLocalizedString(@"tutorial_panel_1_title", nil)
                                                               description:NSLocalizedString(@"tutorial_panel_1_description", nil)
                                                               image:[UIImage imageNamed:@"patroca_logo.png"]];
    
    MYIntroductionPanel *panel2 = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
                                                               title:NSLocalizedString(@"tutorial_panel_2_title", nil)
                                                               description:NSLocalizedString(@"tutorial_panel_2_description", nil)
                                                               image:[UIImage imageNamed:@"tutorial_panel_1.png"]];

    MYIntroductionPanel *panel3 = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
                                                               title:NSLocalizedString(@"tutorial_panel_3_title", nil)
                                                                 description:NSLocalizedString(@"tutorial_panel_3_description", nil)];

    MYIntroductionPanel *panel4 = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
                                                               title:NSLocalizedString(@"tutorial_panel_4_title", nil)
                                                               description:NSLocalizedString(@"tutorial_panel_4_description", nil)];

    MYIntroductionPanel *panel5 = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
                                                               title:NSLocalizedString(@"tutorial_panel_5_title", nil)
                                                               description:NSLocalizedString(@"tutorial_panel_5_description", nil)];

    
    MYBlurIntroductionView *introductionView = [[MYBlurIntroductionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [introductionView setDelegate:self];
    NSArray *panels = @[panel1, panel2, panel3, panel4, panel5];
    [introductionView buildIntroductionWithPanels:panels];
    
    [self.view addSubview:introductionView];
}

- (void)introduction:(MYBlurIntroductionView *)introductionView didFinishWithType:(MYFinishType)finishType {
    [self.navigationController popViewControllerAnimated:YES];
//    [_masterViewController menuButtonPressed:_masterViewController.nearbyButton];
    [_masterViewController loginProfileButtonPressed];
}

@end
