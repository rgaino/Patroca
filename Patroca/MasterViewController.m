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
    
    
    
    //test code for UIScroll behavior
    float contentHeight = _welcomeMessageWebView.frame.size.height + _menuBarView.frame.size.height;
    
    for(int i=0; i<100; i++) {
        UIImageView *imageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"add_new_item_button.png"]];
        [imageview setFrame:CGRectMake(10, contentHeight, imageview.frame.size.width, imageview.frame.size.height)];
        [_contentScrollView addSubview:imageview];
        contentHeight+=imageview.frame.size.height;
    }
    
    [_contentScrollView setContentSize:CGSizeMake(320, contentHeight)];
    
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

//#pragma mark UIScrollViewDelegate methods

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    
////    NSLog(@"_menuBarView.frame.origin.y=%.1f and contentOffset.y=%.1f", _menuBarView.frame.origin.y, _contentScrollView.contentOffset.y);
////    if(_menuBarView.frame.origin.y<0) {
////        [_menuBarView setFrame:CGRectMake(_menuBarView.frame.origin.x, 0, _menuBarView.frame.size.width, _menuBarView.frame.size.height)];
////    }
//    
//    if(_contentScrollView.contentOffset.y > 101.0) {
//
//        [_menuBarView setFrame:CGRectMake(_menuBarView.frame.origin.x,
//                                          _contentScrollView.contentOffset.y,
//                                          _menuBarView.frame.size.width, _menuBarView.frame.size.height)];
//        NSLog(@"_menuBarView.frame.origin.y=%.1f", _menuBarView.frame.origin.y);
//
//    }
//    
//}


@end
