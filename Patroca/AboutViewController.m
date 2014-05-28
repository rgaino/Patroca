//
//  AboutViewController.m
//  Patroca
//
//  Created by Rafael Gaino on 5/26/14.
//  Copyright (c) 2014 Punk Opera. All rights reserved.
//

#import "AboutViewController.h"
#import "UILabel+Extensions.h"
#import <SDWebImage/UIImageView+WebCache.h>


@implementation AboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupHeaderWithBackButton:YES doneButton:NO addItemButton:YES];
    [self setupAboutScrollView];
}

- (void)setupAboutScrollView {
    
    UIScrollView *aboutScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 44+headerOffset, 320, self.view.frame.size.height - 44 + headerOffset)]; //44 is the header
    [self.view addSubview:aboutScrollView];
    
    float y = 10;
    
    //the Credits label
    UILabel *creditsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, y, self.view.frame.size.width, 0)];
    [creditsLabel setText:NSLocalizedString(@"patroca_credits",nil)];
    [creditsLabel setFont:[UIFont systemFontOfSize:13.0]];
    [creditsLabel setTextColor:[UIColor colorWithRed:67/255.0 green:67/255.0 blue:67/255.0 alpha:1.0f]];
    [creditsLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [creditsLabel setTextAlignment:NSTextAlignmentCenter];
    [creditsLabel setNumberOfLines:0];
    [creditsLabel sizeToFit];
    [creditsLabel setFrame:CGRectMake(creditsLabel.frame.origin.x, creditsLabel.frame.origin.y, self.view.frame.size.width, creditsLabel.frame.size.height)];
    [aboutScrollView addSubview:creditsLabel];
    y += creditsLabel.frame.size.height + 10;
    
    //facebook picture 90x98 frame for non-retina = 45x49
    float frameProfileImageX = 45;
    float frameProfileImageY = 49;
    NSString *urlProfileString = @"https://graph.facebook.com/%@/picture?width=90&height=98";
    
    NSURL *cassProfilePictureURL = [NSURL URLWithString:[NSString stringWithFormat:urlProfileString, @"cassiano"]];
    UIImageView *cassImageView = [[UIImageView alloc] initWithFrame:CGRectMake(48, y, frameProfileImageX, frameProfileImageY)];
    [cassImageView setImageWithURL:cassProfilePictureURL placeholderImage:[UIImage imageNamed:@"avatar_default.png"]];
    [aboutScrollView addSubview:cassImageView];

    NSURL *rgainoProfilePictureURL = [NSURL URLWithString:[NSString stringWithFormat:urlProfileString, @"rgaino"]];
    UIImageView *rgainoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(137, y, frameProfileImageX, frameProfileImageY)];
    [rgainoImageView setImageWithURL:rgainoProfilePictureURL placeholderImage:[UIImage imageNamed:@"avatar_default.png"]];
    [aboutScrollView addSubview:rgainoImageView];

    NSURL *kreigneProfilePictureURL = [NSURL URLWithString:[NSString stringWithFormat:urlProfileString, @"kreigne"]];
    UIImageView *kreigneImageView = [[UIImageView alloc] initWithFrame:CGRectMake(227, y, frameProfileImageX, frameProfileImageY)];
    [kreigneImageView setImageWithURL:kreigneProfilePictureURL placeholderImage:[UIImage imageNamed:@"avatar_default.png"]];
    [aboutScrollView addSubview:kreigneImageView];


    //the header bg image
    UIImageView *aboutHeaderImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"about_header.png"]];
    [aboutHeaderImageView setFrame:CGRectMake(0, y, aboutHeaderImageView.frame.size.width, aboutHeaderImageView.frame.size.height)];
    [aboutScrollView addSubview:aboutHeaderImageView];
    [aboutScrollView addSubview:aboutHeaderImageView];
    
    
    y+=aboutHeaderImageView.frame.size.height;

    
    
}



@end
