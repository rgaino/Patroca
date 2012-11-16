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
        
        //background pattern
        UIColor *backgroundPattern = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background_repeat.png"]];
        [[self view] setBackgroundColor:backgroundPattern];
        
        //making menu bar labels tappable
        UITapGestureRecognizer *featuredTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTappedOnFeatured:)];
        [featuredLabel addGestureRecognizer:featuredTap];

        UITapGestureRecognizer *friendsTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTappedOnFriends:)];
        [friendsLabel addGestureRecognizer:friendsTap];

        UITapGestureRecognizer *nearbyTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTappedOnNearby:)];
        [nearbyLabel addGestureRecognizer:nearbyTap];
    }
    return self;
}


#pragma mark Tap Events

- (void)userTappedOnFeatured:(UIGestureRecognizer*)gestureRecognizer {
    NSLog(@"Featured");
}

- (void)userTappedOnFriends:(UIGestureRecognizer*)gestureRecognizer {
    NSLog(@"Friends");
}

- (void)userTappedOnNearby:(UIGestureRecognizer*)gestureRecognizer {
    NSLog(@"Nearby");
}


@end
