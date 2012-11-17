//
//  MasterViewController.m
//  Patroca
//
//  Created by Rafael Gaino on 11/16/12.
//  Copyright (c) 2012 Punk Opera. All rights reserved.
//

#import "MasterViewController.h"

@implementation MasterViewController

//@synthesize featuredLabel, friendsLabel, nearbyLabel, menuBarView;
//@synthesize menuArrowImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        //Colors and patterns
        labelSelectedColor = [UIColor colorWithRed:36/255.0 green:190/255.0 blue:212/255.0 alpha:1.0f];
        labelUnselectedColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1.0f];

        UIColor *backgroundPattern = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background_repeat.png"]];
        [[self view] setBackgroundColor:backgroundPattern];
        
        //making menu bar labels tappable
        UITapGestureRecognizer *featuredTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTappedOnFeatured)];
        [_featuredLabel addGestureRecognizer:featuredTap];

        UITapGestureRecognizer *friendsTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTappedOnFriends)];
        [_friendsLabel addGestureRecognizer:friendsTap];

        UITapGestureRecognizer *nearbyTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTappedOnNearby)];
        [_nearbyLabel addGestureRecognizer:nearbyTap];
        
        
        _welcomeMessageWebView.opaque = NO;
        _welcomeMessageWebView.backgroundColor = [UIColor clearColor];NSString *htmlString = @"<body style='background-color: transparent;'><b>Hello.<br/>This is Patroca.<br/></b>Here's a list of items<br/>available for you.<br/></body>";
        [_welcomeMessageWebView loadHTMLString:htmlString baseURL:nil];
        
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    CGRect arrowFrame = _menuArrowImage.frame;
    [_menuArrowImage setFrame:CGRectMake(-100, arrowFrame.origin.y, arrowFrame.size.width, arrowFrame.size.height)];
    [self userTappedOnFeatured];
}

- (void)userTappedOnFeatured {
    [_featuredLabel setTextColor:labelSelectedColor];
    [_friendsLabel setTextColor:labelUnselectedColor];
    [_nearbyLabel setTextColor:labelUnselectedColor];
    [self moveMenuArrowTo:49];
}

- (void)userTappedOnFriends {
    [_featuredLabel setTextColor:labelUnselectedColor];
    [_friendsLabel setTextColor:labelSelectedColor];
    [_nearbyLabel setTextColor:labelUnselectedColor];
    [self moveMenuArrowTo:153];
}

- (void)userTappedOnNearby {
    [_featuredLabel setTextColor:labelUnselectedColor];
    [_friendsLabel setTextColor:labelUnselectedColor];
    [_nearbyLabel setTextColor:labelSelectedColor];
    [self moveMenuArrowTo:264];
}

- (void)moveMenuArrowTo:(float)xPosition {
    
    [UIView animateWithDuration:1.0f
            delay:0
            options:UIViewAnimationOptionCurveEaseInOut
            animations:^{
                CGRect arrowFrame = _menuArrowImage.frame;
                [_menuArrowImage setFrame:CGRectMake(xPosition, arrowFrame.origin.y, arrowFrame.size.width, arrowFrame.size.height)];
            } completion:nil
     ];
}

@end
