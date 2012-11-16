//
//  MasterViewController.m
//  Patroca
//
//  Created by Rafael Gaino on 11/16/12.
//  Copyright (c) 2012 Punk Opera. All rights reserved.
//

#import "MasterViewController.h"

@implementation MasterViewController

@synthesize featuredLabel, friendsLabel, nearbyLabel;

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
        [featuredLabel addGestureRecognizer:featuredTap];

        UITapGestureRecognizer *friendsTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTappedOnFriends)];
        [friendsLabel addGestureRecognizer:friendsTap];

        UITapGestureRecognizer *nearbyTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTappedOnNearby)];
        [nearbyLabel addGestureRecognizer:nearbyTap];
        
        
    }
    return self;
}

- (void)viewDidLoad {
    [self userTappedOnFeatured];
}

#pragma mark Tap Events

- (void)userTappedOnFeatured {
    [featuredLabel setTextColor:labelSelectedColor];
    [friendsLabel setTextColor:labelUnselectedColor];
    [nearbyLabel setTextColor:labelUnselectedColor];
}

- (void)userTappedOnFriends {
    [featuredLabel setTextColor:labelUnselectedColor];
    [friendsLabel setTextColor:labelSelectedColor];
    [nearbyLabel setTextColor:labelUnselectedColor];
}

- (void)userTappedOnNearby {
    [featuredLabel setTextColor:labelUnselectedColor];
    [friendsLabel setTextColor:labelUnselectedColor];
    [nearbyLabel setTextColor:labelSelectedColor];
}


@end
