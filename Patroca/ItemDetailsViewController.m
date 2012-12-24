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
#import "NSDate+NSDate_Formatter.h"

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)keyboardDidShow:(NSNotification*)notification {
    
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    
    CGRect scrollViewFrame = _wholeScreenScrollView.frame;
    
    [_wholeScreenScrollView setFrame:CGRectMake(scrollViewFrame.origin.x, scrollViewFrame.origin.y, scrollViewFrame.size.width, scrollViewFrame.size.height - keyboardFrameBeginRect.size.height)];
}

- (void)keyboardDidHide:(NSNotification*)notification {

    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    
    CGRect scrollViewFrame = _wholeScreenScrollView.frame;
    
    [_wholeScreenScrollView setFrame:CGRectMake(scrollViewFrame.origin.x, scrollViewFrame.origin.y, scrollViewFrame.size.width, scrollViewFrame.size.height + keyboardFrameBeginRect.size.height)];
}

- (void)viewDidAppear:(BOOL)animated {
    [self animateImagesScrollViewIn];
}

- (void)viewDidLayoutSubviews {
    [self setupWholeScreenScrollView];
}

- (void)setupWholeScreenScrollView {
    
    contentHeightWithoutCommentsView = _itemImagesScrollView.frame.size.height;
    
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
    
    contentHeightWithoutCommentsView += (itemDescriptionLabel.frame.origin.y - _wholeScreenScrollView.frame.size.height);
    contentHeightWithoutCommentsView += itemDescriptionLabel.frame.size.height;
    
    loadingCommentsActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [loadingCommentsActivityIndicator setFrame:CGRectMake(142, contentHeightWithoutCommentsView-37, 37, 37)];
    [loadingCommentsActivityIndicator setHidesWhenStopped:YES];
    [loadingCommentsActivityIndicator startAnimating];
    commentsViewYPosition = loadingCommentsActivityIndicator.frame.origin.y;
    [_wholeScreenScrollView addSubview:loadingCommentsActivityIndicator];
    contentHeightWithoutCommentsView += loadingCommentsActivityIndicator.frame.size.height;
    
    PFQuery *commentsQuery = [PFQuery queryWithClassName:DB_TABLE_ITEM_COMMENTS];
    [commentsQuery whereKey:DB_FIELD_ITEM_ID equalTo:_itemObject];
    [commentsQuery findObjectsInBackgroundWithBlock:^(NSArray *commentObjects, NSError *error) {
        
        if(!error) {  //TODO: error handling
            [self showItemComments:commentObjects];
        }
    }];
    
    [_wholeScreenScrollView setContentSize:CGSizeMake(320, contentHeightWithoutCommentsView)];
}

- (void)showItemComments:(NSArray*)commentObjects {
    
    float commentsViewFinalHeight = 75; //the minimum size before the comments are loaded
    
    //building the header images and title for commentsView
    UIImageView *commentsHeaderImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"comments_header.png"]];
    [commentsHeaderImageView setFrame:CGRectMake(0, commentsViewYPosition+70, 320, 44)];
    
    UILabel *commentsViewTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, commentsHeaderImageView.frame.origin.y + 52, 320, 20)];
    [commentsViewTitleLabel setTextAlignment:NSTextAlignmentCenter];
    [commentsViewTitleLabel setBackgroundColor:[UIColor clearColor]];
    [commentsViewTitleLabel setTextColor:[UIColor colorWithRed:205/255.f green:220/255.f blue:40/255.f alpha:1.0f]];
    [commentsViewTitleLabel setText:@"Troca-ideia"];

    commentsView = [[UIView alloc] init];
    [commentsView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7f]];
    
    //building every comment into a UIView and adding to commentsView
    float commentViewYPosition = 55;
    
    for(PFObject *commentObject in commentObjects) {
        
        UIView *singleCommentView = [[UIView alloc] initWithFrame:CGRectMake(0, commentViewYPosition, 320, 80)];
        commentViewYPosition += singleCommentView.frame.size.height;
        
        //The comment text UILabel
        UILabel *commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 0, 242, 61)];
        [commentLabel setText:[commentObject objectForKey:DB_FIELD_ITEM_COMMENT_TEXT]];
        [commentLabel setBackgroundColor:[UIColor clearColor]];
        [commentLabel setTextColor:[UIColor colorWithRed:204/255.f green:204/255.f blue:204/255.f alpha:1.0f]];
        [commentLabel setFont:[UIFont systemFontOfSize:12]];
        [commentLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [commentLabel setNumberOfLines:0];
        [commentLabel setMinimumScaleFactor:0.6f];
        [commentLabel setAdjustsFontSizeToFitWidth:NO];
        [commentLabel setAdjustsLetterSpacingToFitWidth:NO];
        [singleCommentView addSubview:commentLabel];
        
        
        //The divider lines, vertical and horizontal
        UIImageView *bottomLineImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"comment_bottom_line.png"]];
        [bottomLineImageView setFrame:CGRectMake(88, 78, bottomLineImageView.frame.size.width, bottomLineImageView.frame.size.height)];
        [singleCommentView addSubview:bottomLineImageView];
        
        UIImageView *verticalLineImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"comment_divider_line.png"]];
        [verticalLineImageView setFrame:CGRectMake(262, 11, verticalLineImageView.frame.size.width, verticalLineImageView.frame.size.height)];
        [singleCommentView addSubview:verticalLineImageView];
        
        //the clock icon
        UIImageView *clockIconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"clock_icon.png"]];
        [clockIconImageView setFrame:CGRectMake(14, 74, clockIconImageView.frame.size.width, clockIconImageView.frame.size.height)];
        [singleCommentView addSubview:clockIconImageView];

        //The timestamp text label
        UILabel *timeStampLabel = [[UILabel alloc] initWithFrame:CGRectMake(28, 75, 56, 8)];
        [timeStampLabel setText:[commentObject.createdAt prettyDateDiffFormat]];
        [timeStampLabel setBackgroundColor:[UIColor clearColor]];
        [timeStampLabel setTextColor:[UIColor colorWithRed:205/255.f green:220/255.f blue:40/255.f alpha:1.0f]];
        [timeStampLabel setFont:[UIFont systemFontOfSize:8]];
        [timeStampLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [timeStampLabel setNumberOfLines:1];
        [timeStampLabel setMinimumScaleFactor:0.6f];
        [timeStampLabel setAdjustsFontSizeToFitWidth:YES];
        [timeStampLabel setAdjustsLetterSpacingToFitWidth:NO];
        [singleCommentView addSubview:timeStampLabel];
        
        //The commenter profile picture and white border around
        UIView *profilePictureWhiteBorder = [[UIView alloc] initWithFrame:CGRectMake(272, 21, 34, 34)];
        [profilePictureWhiteBorder setBackgroundColor:[UIColor whiteColor]];
        [singleCommentView addSubview:profilePictureWhiteBorder];
        
        PFUser *commentUser = [commentObject objectForKey:DB_FIELD_USER_ID];
        NSString *userId = [commentUser objectId];
        PFUser *userObject = [[UserCache getInstance] getCachedUserForId:userId];
        UIImageView *profilePictureImageView = [[UIImageView alloc] initWithFrame:CGRectMake(274, 23, 30, 30)];

        NSString *profilePicString = [NSString stringWithFormat:FB_PROFILE_PICTURE_URL, [userObject objectForKey:DB_FIELD_USER_FACEBOOK_ID]];
        NSURL *profilePicURL = [NSURL URLWithString:profilePicString];
        [profilePictureImageView setImageWithURL:profilePicURL];
        [singleCommentView addSubview:profilePictureImageView];

        
        [commentsView addSubview:singleCommentView];
    }
    commentsViewFinalHeight += commentViewYPosition - 30;
    
    //The new comment text area (image on the BG and text area with no borders in front
    UIImageView *newCommentBackgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"comment_text_area.png"]];
    [newCommentBackgroundImageView setFrame:CGRectMake(14, commentsViewFinalHeight, newCommentBackgroundImageView.frame.size.width, newCommentBackgroundImageView.frame.size.height)];
    [commentsView addSubview:newCommentBackgroundImageView];
    commentsViewFinalHeight += newCommentBackgroundImageView.frame.size.height;

    newCommentTextView = [[UITextView alloc] initWithFrame:CGRectMake(48, newCommentBackgroundImageView.frame.origin.y+14, 241, 76)];
    [newCommentTextView setEditable:YES];
    [newCommentTextView setBackgroundColor:[UIColor clearColor]];
    [newCommentTextView setTextColor:[UIColor colorWithRed:102/255.f green:102/255.f blue:102/255.f alpha:1.0f]];
    [newCommentTextView setDelegate:self];
    
    UIButton *sendCommentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendCommentButton setFrame:CGRectMake(217, newCommentBackgroundImageView.frame.origin.y + newCommentBackgroundImageView.frame.size.height-22, 103, 45)];
    [sendCommentButton setImage:[UIImage imageNamed:@"send_comment_button.png"] forState:UIControlStateNormal];
    commentsViewFinalHeight += 22; //half the button's height
    [sendCommentButton addTarget:self action:@selector(sendCommentButtonPressed) forControlEvents:UIControlEventTouchUpInside];

    [commentsView addSubview:newCommentBackgroundImageView];
    [commentsView addSubview:newCommentTextView];
    [commentsView addSubview:sendCommentButton];
    
    
    commentsViewFinalHeight += 20; //some spacing at the end so it's not too tight
    [commentsView setFrame:CGRectMake(0, commentsHeaderImageView.frame.origin.y + 18, _wholeScreenScrollView.frame.size.width, commentsViewFinalHeight)];

    
    [loadingCommentsActivityIndicator stopAnimating];
    [_wholeScreenScrollView addSubview:commentsView];
    [_wholeScreenScrollView addSubview:commentsViewTitleLabel];
    [_wholeScreenScrollView addSubview:commentsHeaderImageView];
    [_wholeScreenScrollView setContentSize:CGSizeMake(320, contentHeightWithoutCommentsView+commentsView.frame.size.height)];
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

- (void)sendCommentButtonPressed {
    [newCommentTextView resignFirstResponder];
}

#pragma mark DELEGATES

- (void)textViewDidBeginEditing:(UITextView *)textView {
    
}

- (void)textViewDidEndEditing:(UITextView *)textView {
}


- (void)scrollViewDidScroll:(UIScrollView *)sender {

    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = _itemImagesScrollView.frame.size.width;
    int page = floor((_itemImagesScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    [_imagesPageControl setCurrentPage:page];
}

@end
