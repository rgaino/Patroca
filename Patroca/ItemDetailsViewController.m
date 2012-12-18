//
//  ItemDetailsViewController.m
//  Patroca
//
//  Created by Rafael Gaino on 12/10/12.
//  Copyright (c) 2012 Punk Opera. All rights reserved.
//

#import "ItemDetailsViewController.h"
#import <Parse/Parse.h>
#import "DatabaseConstants.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UserCache.h"
#import "UILabel+UILabel_Resize.h"

@interface ItemDetailsViewController ()

@end

@implementation ItemDetailsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    UIColor *backgroundPattern = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background_repeat.png"]];
    [[self view] setBackgroundColor:backgroundPattern];
    
    [self setupHeaderWithBackButton:YES];
    [self setupItemImagesScrollView];
    
    [_itemTitleLabel setText:[_itemObject objectForKey:DB_FIELD_ITEM_NAME]];

    PFUser *itemUser = [_itemObject objectForKey:DB_FIELD_USER_ID];
    NSString *userId = [itemUser objectId];
    
    PFUser *userObject = [[UserCache getInstance] getCachedUserForId:userId];
    [self.ownerNameLabel setText:[userObject objectForKey:DB_FIELD_USER_NAME]];
    
    NSString *facebookProfilePicString = [NSString stringWithFormat:FB_PROFILE_PICTURE_URL, [userObject objectForKey:DB_FIELD_USER_FACEBOOK_ID]];
    NSURL *facebookProfilePicURL = [NSURL URLWithString:facebookProfilePicString];
    [_ownerProfilePic setImageWithURL:facebookProfilePicURL];
    

}

- (void)viewDidAppear:(BOOL)animated {
    [self animateImagesScrollViewIn];
}

- (void)viewDidLayoutSubviews {
    [self setupWholeScreenScrollView];
}

- (void)setupWholeScreenScrollView {
    
    float contentHeight = _itemImagesScrollView.frame.size.height;
    
    UILabel *itemDescriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(15,515, 290, 15)];
    [itemDescriptionLabel setText:[_itemObject objectForKey:DB_FIELD_ITEM_DESCRIPTION]];
    [itemDescriptionLabel setFont:[UIFont systemFontOfSize:14]];
    [itemDescriptionLabel setBackgroundColor:[UIColor clearColor]];
    [itemDescriptionLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [itemDescriptionLabel setNumberOfLines:0];
    [itemDescriptionLabel setMinimumScaleFactor:0.6f];
    [itemDescriptionLabel setAdjustsFontSizeToFitWidth:NO];
    [itemDescriptionLabel setAdjustsLetterSpacingToFitWidth:NO];
    [itemDescriptionLabel setTextColor:[UIColor colorWithRed:60/255.0 green:60/255.0 blue:60/255.0 alpha:1.0f]];
    [itemDescriptionLabel adjustHeight];
    [_wholeScreenScrollView addSubview:itemDescriptionLabel];
    
    contentHeight += (itemDescriptionLabel.frame.origin.y - _wholeScreenScrollView.frame.size.height);
    contentHeight += itemDescriptionLabel.frame.size.height;
    
    [_wholeScreenScrollView setContentSize:CGSizeMake(320,contentHeight)];
}

- (void)animateImagesScrollViewIn {
    
    CGRect scrollFrame = _itemImagesScrollView.frame;
    scrollFrame.origin.x = 500;
    [_itemImagesScrollView setFrame:scrollFrame];
    [_itemImagesScrollView setHidden:NO];

    [UIView beginAnimations:@"scrollViewIn" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];

    scrollFrame = _itemImagesScrollView.frame;
    scrollFrame.origin.x = 0;
    [_itemImagesScrollView setFrame:scrollFrame];

    [UIView commitAnimations];

    
}


- (void)setupItemImagesScrollView {
    
    PFQuery *itemImagesQuery = [PFQuery queryWithClassName:DB_TABLE_ITEM_IMAGES];
    [itemImagesQuery whereKey:DB_FIELD_ITEM_ID equalTo:_itemObject];
    
    [itemImagesQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        [_imagesPageControl setNumberOfPages:[objects count]];
        [_imagesPageControl setCurrentPage:0];
        numberOfImages = [objects count];

        float xPosition = 0;
        
        //load all item images into the image caroussel
        for(PFObject *item in objects) {
        
            PFFile *imageFile = [item objectForKey:DB_FIELD_ITEM_IMAGE];
            NSString *imageURL = [imageFile url];

            UIImageView *itemImageView = [[UIImageView alloc] init];
            [itemImageView setFrame:CGRectMake(xPosition, 0, 320, 480)];
            [itemImageView setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
            
            [_itemImagesScrollView addSubview:itemImageView];
            
            xPosition += itemImageView.frame.size.width;
         }
        [_itemImagesScrollView setContentSize:CGSizeMake(xPosition, 480)];
        
         [self performSelector:@selector(adjustPageControl) withObject:nil afterDelay:1.0f];

    }];
}

- (void)adjustPageControl {
    
//    //this method is a workaround for a bug where the PageControl's frame would not change unless we wait a second after the view loads completely
//    
//    float pageControlWidth = _imagesPageControl.frame.size.width;
//    float pageControlNewWidth = 16 * numberOfImages;
//    float pageControlNewX = _imagesPageControl.frame.origin.x + (pageControlWidth-pageControlNewWidth);
//    [_imagesPageControl setFrame:CGRectMake(pageControlNewX, _imagesPageControl.frame.origin.y,
//                                            pageControlNewWidth, _imagesPageControl.frame.size.height)];
//    
//    float xPosition = 307;
//    for(int i=1; i<=numberOfImages; i++) {
//        UIImageView *circleShadeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(xPosition, 158, 8, 8)];
//        [circleShadeImageView setImage:[UIImage imageNamed:@"circle_shade.png"]];
//        [self.view addSubview:circleShadeImageView];
//        
//        xPosition-=16;
//    }
//
//    [self.view bringSubviewToFront:_imagesPageControl];
//    
//    [_imagesPageControl setHidden:NO];
}


- (void)scrollViewDidScroll:(UIScrollView *)sender {

    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = _itemImagesScrollView.frame.size.width;
    int page = floor((_itemImagesScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    [_imagesPageControl setCurrentPage:page];
}

@end
