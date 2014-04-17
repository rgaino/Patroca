//
//  HelpView.m
//  Patroca
//
//  Created by Rafael Gaino on 4/16/14.
//  Copyright (c) 2014 Punk Opera. All rights reserved.
//

#import "HelpView.h"
#import "UILabel+Extensions.h"

@implementation HelpView


- (id)initWithStyle:(HelpViewType)helpViewType {
    
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
//    self = [UIButton buttonWithType:UIButtonTypeCustom];
//    [self setFrame:[[UIScreen mainScreen] bounds]];
    [self setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.7f]];
    
    if (self) {
        
        switch(helpViewType) {
        case HelpViewTypeLogin:
            [self buildLoginScreen];
            break;
        case HelpViewTypeAddItem:
            break;
        }
    }
    return self;
}

- (void)buildLoginScreen {
    
    UIColor *patrocaColor = [UIColor colorWithRed:237/255.0 green:22/255.0 blue:81/255.0 alpha:1.0f];
    
    //the arrow image pointing to the login button
    float y = 45;
    UIImageView *arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"help_login_arrow.png"]];
    [arrowImageView setFrame:CGRectMake(25, y, arrowImageView.frame.size.width, arrowImageView.frame.size.height)];
    [self addSubview:arrowImageView];
    
    //the text
    float x = 20;
    y+=45;
    float width = self.frame.size.width - x-5;
    UILabel *loginHelpTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, 10)];
    [loginHelpTextLabel setText:NSLocalizedString(@"login_profile_help", nil)];
    [loginHelpTextLabel setTextColor:[UIColor whiteColor]];
    [loginHelpTextLabel setBackgroundColor:patrocaColor];
    [loginHelpTextLabel setNumberOfLines:0];
    [loginHelpTextLabel sizeToFitFrameWidth];
    [self addSubview:loginHelpTextLabel];

    //the dismiss button
//    UIButton *dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [dismissButton setTitle:NSLocalizedString(@"got it",nil) forState:UIControlStateNormal];
//    [dismissButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [dismissButton setBackgroundColor:patrocaColor];
//    [dismissButton setFrame:CGRectMake(x+20, y+loginHelpTextLabel.frame.size.height, 80, 30)];
//    [self addSubview:dismissButton];
    
    UITapGestureRecognizer *gestureRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    gestureRecogniser.numberOfTapsRequired = 1;
    [self addGestureRecognizer:gestureRecogniser];
}

- (void)handleTap:(UIGestureRecognizer*)tap {
    
    [UIView animateWithDuration:1.0f animations:^{
        [self setAlpha:0.0f];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
