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
    
    //the background image pointing to the login button
    float y = 55;
    UIImageView *helpLoginImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"help_login.png"]];
    float x = (self.frame.size.width - helpLoginImageView.frame.size.width)/2;
    [helpLoginImageView setFrame:CGRectMake(x, y, helpLoginImageView.frame.size.width, helpLoginImageView.frame.size.height)];
    [self addSubview:helpLoginImageView];
    
    //the text
    y+=85;

    UILabel *welcomeTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, y, self.frame.size.width, 18)];
    [welcomeTitle setText:NSLocalizedString(@"welcome!", nil)];
    [welcomeTitle setTextAlignment:NSTextAlignmentCenter];
    [welcomeTitle setTextColor:[UIColor whiteColor]];
    [welcomeTitle setFont:[UIFont boldSystemFontOfSize:22]];
    [welcomeTitle setBackgroundColor:[UIColor clearColor]];
    [self addSubview:welcomeTitle];

    y+=35;
    float width = helpLoginImageView.frame.size.width - 20;
    x = (self.frame.size.width - width)/2;
    UILabel *loginHelpTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, 10)];
    [loginHelpTextLabel setText:NSLocalizedString(@"login_profile_help", nil)];
    [loginHelpTextLabel setFont:[UIFont systemFontOfSize:16]];
    [loginHelpTextLabel setTextColor:[UIColor whiteColor]];
    [loginHelpTextLabel setTextAlignment:NSTextAlignmentCenter];
    [loginHelpTextLabel setBackgroundColor:[UIColor clearColor]];
    [loginHelpTextLabel setNumberOfLines:0];
    [loginHelpTextLabel sizeToFitFrameWidth];
    [self addSubview:loginHelpTextLabel];

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
