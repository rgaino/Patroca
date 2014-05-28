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
    
    aboutScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 44+headerOffset, 320, self.view.frame.size.height - 44 + headerOffset)]; //44 is the header
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
    
    //our facebook pictures (90x98 frame for non-retina = 45x49)
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
    
    
    //our names
    UILabel *cassNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(36, 96, 70, 60)];
    [cassNameLabel setText:@"Cassiano\nSaldanha"];
    [cassNameLabel setTextAlignment:NSTextAlignmentCenter];
    [cassNameLabel setFont:[UIFont boldSystemFontOfSize:15.0]];
    [cassNameLabel setTextColor:[UIColor whiteColor]];
    [cassNameLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [cassNameLabel setNumberOfLines:2];
    [aboutScrollView addSubview:cassNameLabel];

    UILabel *rgainoNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(126, 96, 70, 60)];
    [rgainoNameLabel setText:@"Rafael\nGaino"];
    [rgainoNameLabel setTextAlignment:NSTextAlignmentCenter];
    [rgainoNameLabel setFont:[UIFont boldSystemFontOfSize:15.0]];
    [rgainoNameLabel setTextColor:[UIColor whiteColor]];
    [rgainoNameLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [rgainoNameLabel setNumberOfLines:2];
    [aboutScrollView addSubview:rgainoNameLabel];

    UILabel *kreigneNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(217, 96, 70, 60)];
    [kreigneNameLabel setText:@"Fernando\nKreigne"];
    [kreigneNameLabel setTextAlignment:NSTextAlignmentCenter];
    [kreigneNameLabel setFont:[UIFont boldSystemFontOfSize:15.0]];
    [kreigneNameLabel setTextColor:[UIColor whiteColor]];
    [kreigneNameLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [kreigneNameLabel setNumberOfLines:2];
    [aboutScrollView addSubview:kreigneNameLabel];
    
    
    //thanks
    y = 165;
    UILabel *poweredByParseLabel =[[UILabel alloc] initWithFrame:CGRectMake(0, y, self.view.frame.size.width, 30)];
    [poweredByParseLabel setText:NSLocalizedString(@"powered by parse", nil)];
    [poweredByParseLabel setTextAlignment:NSTextAlignmentCenter];
    [poweredByParseLabel setFont:[UIFont boldSystemFontOfSize:14.0]];
    [poweredByParseLabel setTextColor:[UIColor colorWithRed:60/255.0 green:145/255.0 blue:152/255.0 alpha:1.0f]];
    [aboutScrollView addSubview:poweredByParseLabel];
    
    y+=40;
    UILabel *githubTitleLabel =[[UILabel alloc] initWithFrame:CGRectMake(0, y, self.view.frame.size.width, 30)];
    [githubTitleLabel setText:NSLocalizedString(@"github thanks", nil)];
    [githubTitleLabel setTextAlignment:NSTextAlignmentCenter];
    [githubTitleLabel setFont:[UIFont boldSystemFontOfSize:14.0]];
    [githubTitleLabel setTextColor:[UIColor colorWithRed:60/255.0 green:145/255.0 blue:152/255.0 alpha:1.0f]];
    [aboutScrollView addSubview:githubTitleLabel];

    y += 10;
    UILabel *githubClassesLabel =[[UILabel alloc] initWithFrame:CGRectMake(0, y, self.view.frame.size.width, 100)];
    [githubClassesLabel setText:@"SVPullToRefresh\nMPNotificationView\nMBProgressHud\nSDWebImage"];
    [githubClassesLabel setTextAlignment:NSTextAlignmentCenter];
    [githubClassesLabel setNumberOfLines:4];
    [githubClassesLabel setFont:[UIFont boldSystemFontOfSize:14.0]];
    [githubClassesLabel setTextColor:[UIColor colorWithRed:139/255.0 green:139/255.0 blue:139/255.0 alpha:1.0f]];
    [aboutScrollView addSubview:githubClassesLabel];

    y+=100;
    UILabel *noumTitleLabel =[[UILabel alloc] initWithFrame:CGRectMake(0, y, self.view.frame.size.width, 30)];
    [noumTitleLabel setText:NSLocalizedString(@"noum thanks", nil)];
    [noumTitleLabel setTextAlignment:NSTextAlignmentCenter];
    [noumTitleLabel setFont:[UIFont boldSystemFontOfSize:14.0]];
    [noumTitleLabel setTextColor:[UIColor colorWithRed:60/255.0 green:145/255.0 blue:152/255.0 alpha:1.0f]];
    [aboutScrollView addSubview:noumTitleLabel];
    
    y += 20;
    UILabel *noumIconsLabel =[[UILabel alloc] initWithFrame:CGRectMake(0, y, self.view.frame.size.width, 30)];
    [noumIconsLabel setText:NSLocalizedString(@"noum names", nil)];
    [noumIconsLabel setTextAlignment:NSTextAlignmentCenter];
    [noumIconsLabel setNumberOfLines:1];
    [noumIconsLabel setFont:[UIFont boldSystemFontOfSize:14.0]];
    [noumIconsLabel setTextColor:[UIColor colorWithRed:139/255.0 green:139/255.0 blue:139/255.0 alpha:1.0f]];
    [aboutScrollView addSubview:noumIconsLabel];


    //Terms and Privacy
    y = 380;
    
    termsWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, y, self.view.frame.size.width, 500)];
    NSURLRequest *termsURLRequest= [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://patroca.com/terms.html"]];
    [termsWebView loadRequest:termsURLRequest];
    [termsWebView.scrollView setScrollEnabled:NO];
    [termsWebView setDelegate:self];
    termsWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [aboutScrollView addSubview:termsWebView];
    
    loadingTermsActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    CGRect frame = loadingTermsActivityIndicator.frame;
    frame.origin.x = self.view.frame.size.width / 2 - frame.size.width / 2;
    frame.origin.y = y+3;
    [loadingTermsActivityIndicator setFrame:frame];
    [loadingTermsActivityIndicator startAnimating];
    [loadingTermsActivityIndicator setHidesWhenStopped:YES];
    [aboutScrollView addSubview:loadingTermsActivityIndicator];
    
    [aboutScrollView setContentSize:CGSizeMake(self.view.frame.size.width, frame.origin.y+400)];
}

- (void) webViewDidFinishLoad:(UIWebView *)webView {
    
    [loadingTermsActivityIndicator stopAnimating];

    CGRect frame = termsWebView.frame;
    CGSize fittingSize = [termsWebView sizeThatFits:CGSizeZero];
    frame.size = fittingSize;
    termsWebView.frame = frame;
    [termsWebView setBackgroundColor:[UIColor redColor]];
    [aboutScrollView setContentSize:CGSizeMake(self.view.frame.size.width, aboutScrollView.contentSize.height+frame.size.height)];    
}

@end
