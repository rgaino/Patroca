//
//  ItemDetailsViewController.h
//  Patroca
//
//  Created by Rafael Gaino on 12/10/12.
//  Copyright (c) 2012 Punk Opera. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@class PFObject;
@class PFUser;

@interface ItemDetailsViewController : BaseViewController <UIScrollViewDelegate, UITextViewDelegate, UIActionSheetDelegate> {

    UIScrollView *wholeScreenScrollView;
    UIScrollView *itemImagesScrollView;
    UITextView *newCommentTextView;
    UIButton *sendCommentButton;
    UIActivityIndicatorView *loadingCommentsActivityIndicator;
    UIView *commentsView;
    UIView *footerBackgroundView;
    PFUser *userObject;
    CGRect scrollViewFrame;
    NSUInteger numberOfImages;
    NSMutableArray *commentObjects;
    float commentsViewYPosition;
    float contentHeightWithoutCommentsView;
}

@property (nonatomic, readwrite) PFObject *itemObject;

- (void)setupWholeScreenScrollView;
- (void)setupItemImagesScrollView;
- (void)setupFooter;
- (void)animateImagesScrollViewIn;
- (void)showItemComments;
- (void)sendCommentButtonPressed;
- (void)keyboardDidShow:(NSNotification*)notification;
- (void)keyboardDidHide:(NSNotification*)notification;
- (void)scrollWholeScreenToBottom;
- (void)tapDetected;

- (IBAction)userTappedOnProfile:(id)sender;
- (IBAction)makeOfferButtonPressed:(id)sender;
- (IBAction)recommendThisItem:(id)sender;
- (IBAction)reportThisItem:(id)sender;

@end
