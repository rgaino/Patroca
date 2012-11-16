//
//  MasterViewController.m
//  Patroca
//
//  Created by Rafael Gaino on 11/16/12.
//  Copyright (c) 2012 Punk Opera. All rights reserved.
//

#import "MasterViewController.h"

@interface MasterViewController ()

@end

@implementation MasterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UIColor *backgroundPattern = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background_repeat.png"]];
        [[self view] setBackgroundColor:backgroundPattern];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}




@end
