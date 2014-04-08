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
#import "UILabel+Extensions.h"
#import "ViewProfileViewController.h"
#import "MPNotificationView.h"

@implementation ItemDetailsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    [self.view setFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height)];


    [self setupHeaderWithBackButton:YES doneButton:NO addItemButton:YES];
    [self setupWholeScreenScrollView];
    [self setupItemImagesScrollView];
    [self setupFooter];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];

    //detect taps to dismiss keyboard
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected)];
    tapRecognizer.numberOfTapsRequired = 1;
    tapRecognizer.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:tapRecognizer];

}

- (void)keyboardDidShow:(NSNotification*)notification {
    
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    
    [wholeScreenScrollView setFrame:CGRectMake(scrollViewFrame.origin.x, scrollViewFrame.origin.y, scrollViewFrame.size.width, scrollViewFrame.size.height - keyboardFrameBeginRect.size.height+24)];
    [self scrollWholeScreenToBottom];
}

- (void)keyboardDidHide:(NSNotification*)notification {

    [wholeScreenScrollView setFrame:scrollViewFrame];
}

- (void)viewDidAppear:(BOOL)animated {
    [self animateImagesScrollViewIn];
    [super viewDidAppear:animated];
}


- (void)setupWholeScreenScrollView {
    
    wholeScreenScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 44+headerOffset, 320, self.view.frame.size.height - 44 - 44 + headerOffset)]; //44 is the header, and the other 44 is the footer
    scrollViewFrame = wholeScreenScrollView.frame;

    [self.view addSubview:wholeScreenScrollView];
    
    //Item images scroll view
    itemImagesScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
    [itemImagesScrollView setAlwaysBounceVertical:NO];
    [itemImagesScrollView setHidden:YES];
    [itemImagesScrollView setPagingEnabled:YES];
    [itemImagesScrollView setDirectionalLockEnabled:YES];
    [wholeScreenScrollView addSubview:itemImagesScrollView];
    
    
    //Title view 75% opaque) and item title label
    UIView *titleBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 65)];    
    UILabel *itemTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 300, 55)];
    [titleBackgroundView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7f]];
    [itemTitleLabel setText:[_itemObject objectForKey:DB_FIELD_ITEM_NAME]];
    [itemTitleLabel setBackgroundColor:[UIColor clearColor]];
    [itemTitleLabel setTextColor:[UIColor whiteColor]];
    [itemTitleLabel setFont:[UIFont systemFontOfSize:18]];
    [itemTitleLabel setNumberOfLines:0];
    [itemTitleLabel setAdjustsLetterSpacingToFitWidth:YES];
    [itemTitleLabel setAdjustsFontSizeToFitWidth:YES];
    [itemTitleLabel setMinimumScaleFactor:0.6f];
    
    [titleBackgroundView addSubview:itemTitleLabel];
    [wholeScreenScrollView addSubview:titleBackgroundView];
    
    
    //Owner name
    UILabel *ownerNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(46, 324, 270, 20)];
    [ownerNameLabel setBackgroundColor:[UIColor clearColor]];
    [ownerNameLabel setTextColor:[UIColor colorWithRed:102/255.0f green:102/255.0f blue:102/255.0f alpha:1.0f]];
    [ownerNameLabel setFont:[UIFont boldSystemFontOfSize:10.0f]];
    [wholeScreenScrollView addSubview:ownerNameLabel];
    
    //Owner profile pic white background
    UIView *ownerProfilePicBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(6, 305, 34, 34)];
    [ownerProfilePicBackgroundView setBackgroundColor:[UIColor whiteColor]];
    [wholeScreenScrollView addSubview:ownerProfilePicBackgroundView];

    //Owner profile pic
    UIImageView *ownerProfilePic = [[UIImageView alloc] initWithFrame:CGRectMake(8, 307, 30, 30)];
    [ownerProfilePic setContentMode:UIViewContentModeScaleAspectFit];
    [wholeScreenScrollView addSubview:ownerProfilePic];
    
    //An invisible button over the profiile pic and name, so it's tappable without hacks
    UIButton *profileInvisibleButton = [UIButton buttonWithType:UIButtonTypeCustom];;
    [profileInvisibleButton setFrame:CGRectMake(0, 307, 320, 37)];
    [profileInvisibleButton setTag:-1]; //each comment has its own tag, this one is the owner
    [profileInvisibleButton addTarget:self action:@selector(userTappedOnProfile:) forControlEvents:UIControlEventTouchUpInside];
    [wholeScreenScrollView addSubview:profileInvisibleButton];
    
    //Owner's profiel pic from Facebook
    PFUser *itemUser = [_itemObject objectForKey:DB_FIELD_USER_ID];
    NSString *userId = [itemUser objectId];
    
    userObject = [[UserCache getInstance] getCachedUserForId:userId];
    [ownerNameLabel setText:[userObject objectForKey:DB_FIELD_USER_NAME]];
    
    NSString *facebookProfilePicString = [NSString stringWithFormat:FB_PROFILE_PICTURE_URL, [userObject objectForKey:DB_FIELD_USER_FACEBOOK_ID]];
    NSURL *facebookProfilePicURL = [NSURL URLWithString:facebookProfilePicString];
    [ownerProfilePic setImageWithURL:facebookProfilePicURL];

    
    UILabel *itemDescriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 355, 290, 15)];
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
    [wholeScreenScrollView addSubview:itemDescriptionLabel];
    
    contentHeightWithoutCommentsView = itemDescriptionLabel.frame.origin.y + itemDescriptionLabel.frame.size.height;
    
    loadingCommentsActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [loadingCommentsActivityIndicator setFrame:CGRectMake(142, contentHeightWithoutCommentsView+5, 37, 37)];
    [loadingCommentsActivityIndicator setHidesWhenStopped:YES];
    [loadingCommentsActivityIndicator startAnimating];
    commentsViewYPosition = loadingCommentsActivityIndicator.frame.origin.y;
    [wholeScreenScrollView addSubview:loadingCommentsActivityIndicator];
    contentHeightWithoutCommentsView += loadingCommentsActivityIndicator.frame.size.height;
    
    PFQuery *commentsQuery = [PFQuery queryWithClassName:DB_TABLE_ITEM_COMMENTS];
    [commentsQuery whereKey:DB_FIELD_ITEM_ID equalTo:_itemObject];
    [commentsQuery addAscendingOrder:DB_FIELD_CREATED_AT];
    [commentsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if(!error) {  //TODO: error handling
            commentObjects = [NSMutableArray arrayWithArray:objects];
            [self showItemComments];
        }
    }];
    
    [wholeScreenScrollView setContentSize:CGSizeMake(320, contentHeightWithoutCommentsView)];
}


- (void)setupItemImagesScrollView {
    
    PFQuery *itemImagesQuery = [PFQuery queryWithClassName:DB_TABLE_ITEM_IMAGES];
    [itemImagesQuery orderByAscending:DB_FIELD_CREATED_AT];
    [itemImagesQuery whereKey:DB_FIELD_ITEM_ID equalTo:_itemObject];
    
    [itemImagesQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        numberOfImages = [objects count];
        
        float xPosition = 0;
        
        //load all item images into the image caroussel
        for(PFObject *item in objects) {
            
            PFFile *imageFile = [item objectForKey:DB_FIELD_ITEM_IMAGE];
            NSString *imageURL = [imageFile url];
            
            UIImageView *itemImageView = [[UIImageView alloc] init];
            [itemImageView setFrame:CGRectMake(xPosition, 0, 320, 320)];
            [itemImageView setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
            
            [itemImagesScrollView addSubview:itemImageView];
            
            xPosition += itemImageView.frame.size.width;
        }
        [itemImagesScrollView setContentSize:CGSizeMake(xPosition, 320)];
    }];
}


- (void)setupFooter {
    
    //the footer black background
    footerBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-44, 320, 44)];
    [footerBackgroundView setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:footerBackgroundView];
    
    //make offer button
    if( ![[userObject objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        
        /*
        //only show the Make Offer and Report button if owner of this item is NOT the current user
        UIButton *makeOfferButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [makeOfferButton setBackgroundImage:[UIImage imageNamed:@"make_offer_button.png"] forState:UIControlStateNormal];
        [makeOfferButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
        [makeOfferButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [makeOfferButton setTitle:NSLocalizedString(@"make offer", nil) forState:UIControlStateNormal];
        [makeOfferButton setFrame:CGRectMake(55, footerBackgroundView.frame.origin.y-22, 210, 45)];
        [makeOfferButton addTarget:self action:@selector(makeOfferButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:makeOfferButton];
         */
        
        //report button (if logged in)
        if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
            UIButton *reportButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [reportButton setImage:[UIImage imageNamed:@"report_this_item.png"] forState:UIControlStateNormal];
            [reportButton setFrame:CGRectMake(15, footerBackgroundView.frame.origin.y+11, 24, 21)];
            [reportButton addTarget:self action:@selector(reportThisItem:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:reportButton];
        }
    }

    //share on Facebook button
    UIButton *recommendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [recommendButton setImage:[UIImage imageNamed:@"recommend_item_button.png"] forState:UIControlStateNormal];
    [recommendButton setFrame:CGRectMake(281, footerBackgroundView.frame.origin.y+11, 24, 22)];
    [recommendButton addTarget:self action:@selector(recommendThisItem:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:recommendButton];
}


- (void)animateImagesScrollViewIn {
    
    CGRect scrollFrame = itemImagesScrollView.frame;
    scrollFrame.origin.x = 500;
    [itemImagesScrollView setFrame:scrollFrame];
    [itemImagesScrollView setHidden:NO];

    [UIView beginAnimations:@"scrollViewIn" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];

    scrollFrame = itemImagesScrollView.frame;
    scrollFrame.origin.x = 0;
    [itemImagesScrollView setFrame:scrollFrame];

    [UIView commitAnimations];
}

- (void)showItemComments {
    
    if(commentsView) {
        [commentsView removeFromSuperview];
        commentsView = nil;
    }
    commentsView = [[UIView alloc] init];
    [commentsView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7f]];
    
    
    float commentsViewFinalHeight = 75; //the minimum size before the comments are loaded
    
    //building the header images and title for commentsView
    UIImageView *commentsHeaderImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"comments_header.png"]];
    [commentsHeaderImageView setFrame:CGRectMake(0, commentsViewYPosition+30, 320, 44)];
    
    UILabel *commentsViewTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, commentsHeaderImageView.frame.origin.y + 52, 320, 20)];
    [commentsViewTitleLabel setTextAlignment:NSTextAlignmentCenter];
    [commentsViewTitleLabel setBackgroundColor:[UIColor clearColor]];
    [commentsViewTitleLabel setTextColor:[UIColor colorWithRed:205/255.f green:220/255.f blue:40/255.f alpha:1.0f]];
    [commentsViewTitleLabel setText:NSLocalizedString(@"comments section", nil)];
    
    
    //building every comment into a UIView and adding to commentsView
    float commentViewYPosition = 55;
    
    NSInteger commentIndex=0;
    for(PFObject *commentObject in commentObjects) {
        
        UIView *singleCommentView = [[UIView alloc] initWithFrame:CGRectMake(0, commentViewYPosition, 320, 80)];
        commentViewYPosition += singleCommentView.frame.size.height;
        
        //The comment text UILabel
        UILabel *commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 8, 242, 61)];
        [commentLabel setText:[commentObject objectForKey:DB_FIELD_ITEM_COMMENT_TEXT]];
        [commentLabel setBackgroundColor:[UIColor clearColor]];
        [commentLabel setTextColor:[UIColor colorWithRed:204/255.f green:204/255.f blue:204/255.f alpha:1.0f]];
        [commentLabel setFont:[UIFont systemFontOfSize:12]];
        [commentLabel setNumberOfLines:0];
        [commentLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [commentLabel autoShrinkWithMultipleLinesConstraindToSize];
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
        [timeStampLabel setText:(commentObject.createdAt!=nil?[commentObject.createdAt prettyDateDiffFormat]:[[NSDate date] prettyDateDiffFormat])]; //commentObject.createdAt can be nil if the object was just created but not saved on the server, so just show the current timestamp
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
        
        UIImageView *profilePictureImageView = [[UIImageView alloc] initWithFrame:CGRectMake(274, 23, 30, 30)];
        
        PFUser *commentUser = [commentObject objectForKey:DB_FIELD_USER_ID];
        NSString *userId = [commentUser objectId];
        PFUser *commenterUserObject = [[UserCache getInstance] getCachedUserForId:userId];
        NSString *profilePicString = [NSString stringWithFormat:FB_PROFILE_PICTURE_URL, [commenterUserObject objectForKey:DB_FIELD_USER_FACEBOOK_ID]];
        NSURL *profilePicURL = [NSURL URLWithString:profilePicString];
        [profilePictureImageView setImageWithURL:profilePicURL];
        [singleCommentView addSubview:profilePictureImageView];
        
        UIButton *commenterProfileInvisibleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [commenterProfileInvisibleButton setFrame:[profilePictureWhiteBorder frame]];
        [commenterProfileInvisibleButton setTag:commentIndex];
        [commenterProfileInvisibleButton addTarget:self action:@selector(userTappedOnProfile:) forControlEvents:UIControlEventTouchUpInside];
        [singleCommentView addSubview:commenterProfileInvisibleButton];
        
        [commentsView addSubview:singleCommentView];
        commentIndex++;
    }
    commentsViewFinalHeight += commentViewYPosition - 45;
    
    //show Write Comment section only if user is logged in
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        
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
        
        sendCommentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [sendCommentButton setFrame:CGRectMake(217, newCommentBackgroundImageView.frame.origin.y + newCommentBackgroundImageView.frame.size.height-22, 103, 45)];
        [sendCommentButton setBackgroundImage:[UIImage imageNamed:@"send_comment_button.png"] forState:UIControlStateNormal];
        [sendCommentButton setTitle:NSLocalizedString(@"send", nil) forState:UIControlStateNormal];
        [sendCommentButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [sendCommentButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
        commentsViewFinalHeight += 22; //half the button's height
        [sendCommentButton setEnabled:NO];
        [sendCommentButton addTarget:self action:@selector(sendCommentButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        
        [commentsView addSubview:newCommentBackgroundImageView];
        [commentsView addSubview:newCommentTextView];
        [commentsView addSubview:sendCommentButton];
    }
    
    commentsViewFinalHeight+=70; //some additional space at the bottom to make room for the footer
    
    //finalize it
    [commentsView setFrame:CGRectMake(0, commentsHeaderImageView.frame.origin.y + 18, wholeScreenScrollView.frame.size.width, commentsViewFinalHeight)];
    
    [loadingCommentsActivityIndicator stopAnimating];
    [wholeScreenScrollView addSubview:commentsView];
    [wholeScreenScrollView addSubview:commentsHeaderImageView];
    [wholeScreenScrollView addSubview:commentsViewTitleLabel];
    [wholeScreenScrollView setContentSize:CGSizeMake(320, contentHeightWithoutCommentsView+commentsViewFinalHeight)];
}


- (void)textViewDidChange:(UITextView *)textView {
    if( newCommentTextView.text.length >0 ) {
        [sendCommentButton setEnabled:YES];
    } else {
        [sendCommentButton setEnabled:NO];
    }
}

- (void)tapDetected {
    //dismiss keyboard on tap outside of the text area
    if([newCommentTextView isFirstResponder]) {
        [newCommentTextView resignFirstResponder];
    }
}


- (void)sendCommentButtonPressed {
    
    [newCommentTextView resignFirstResponder];
    
    //save the comment
    PFObject *newItemComment = [PFObject objectWithClassName:DB_TABLE_ITEM_COMMENTS];
    [newItemComment setObject:[newCommentTextView text] forKey:DB_FIELD_ITEM_COMMENT_TEXT];
    [newItemComment setObject:_itemObject forKey:DB_FIELD_ITEM_ID];
    [newItemComment setObject:[PFUser currentUser] forKey:DB_FIELD_USER_ID];
    [commentObjects addObject:newItemComment];
    [newItemComment saveEventually];
    
    //subscribe the user for push notifications on this item
    NSString *subscribeChannel = [NSString stringWithFormat:NOTIFICATIONS_COMMENTS_ON_ITEM, _itemObject.objectId];
    [PFPush subscribeToChannelInBackground:subscribeChannel];
    
    [self showItemComments];
}

- (void)scrollWholeScreenToBottom {
    
    CGPoint bottomOffset = CGPointMake(0, wholeScreenScrollView.contentSize.height - wholeScreenScrollView.frame.size.height);
    [wholeScreenScrollView setContentOffset:bottomOffset animated:NO];
}


#pragma mark Actions

- (IBAction)userTappedOnProfile:(id)sender {
    
    UIButton *senderButton = (UIButton*)sender;
    
    ViewProfileViewController *viewProfileViewController = [[ViewProfileViewController alloc] initWithNibName:@"ViewProfileViewController" bundle:nil];
    
    NSString *userID = [[_itemObject objectForKey:DB_FIELD_USER_ID] objectId];

    //tapped on owner's profile?
    if(senderButton.tag != -1) {
        //tapped on commenter's profile
        PFObject *commentObject = [commentObjects objectAtIndex:senderButton.tag];
        PFUser *commentUser = [commentObject objectForKey:DB_FIELD_USER_ID];
        userID = [ commentUser objectId];
    }

    [viewProfileViewController setupViewWithUserID:userID];
    
    [self.navigationController pushViewController:viewProfileViewController animated:YES];
}


- (IBAction)makeOfferButtonPressed:(id)sender {}

- (IBAction)recommendThisItem:(id)sender {}

- (IBAction)reportThisItem:(id)sender {

    UIActionSheet *reportItemActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"sure_report_item_question", nil)
                                                    delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"no", nil)
                                                    destructiveButtonTitle:NSLocalizedString(@"yes", nil)
                                                    otherButtonTitles:nil];
    
    [reportItemActionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    [reportItemActionSheet showInView:self.view];
    
}

 -(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
     
     if(buttonIndex == 0) {
        //report this item and leave
        PFObject *reported = [PFObject objectWithClassName:DB_TABLE_REPORTED_ITEMS];
        [reported setObject:_itemObject forKey:DB_FIELD_ITEM_ID];
        [reported setObject:[PFUser currentUser] forKey:DB_FIELD_USER_ID];
        [reported saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
            [MPNotificationView notifyWithText:NSLocalizedString(@"item_reported", nil) detail:NSLocalizedString(@"thanks_for_reporting", nil)
                                image:[UIImage imageNamed:@"report_this_item.png"] andDuration:PT_NOTIFICATION_DURATION];

        }];
         
        [self.navigationController popViewControllerAnimated:YES];
     }
}


@end
