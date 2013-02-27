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

@interface ItemDetailsViewController : BaseViewController <UIScrollViewDelegate, UITextViewDelegate> {

    UIScrollView *wholeScreenScrollView;
    UIScrollView *itemImagesScrollView;
    UITextView *newCommentTextView;
    UIButton *sendCommentButton;
    UIActivityIndicatorView *loadingCommentsActivityIndicator;
    UIView *commentsView;
    
    int numberOfImages;
    NSMutableArray *commentObjects;
    float commentsViewYPosition;
    float contentHeightWithoutCommentsView;
}

@property (nonatomic, readwrite) PFObject *itemObject;
@property (weak, nonatomic) IBOutlet UIButton *makeOfferButton;
@property (weak, nonatomic) IBOutlet UIView *footerView;

- (IBAction)recommendThisItem:(id)sender;
- (IBAction)reportThisItem:(id)sender;
- (void)setupItemImagesScrollView;
- (void)animateImagesScrollViewIn;
- (void)setupWholeScreenScrollView;
- (void)showItemComments;
- (void)sendCommentButtonPressed;
- (void)keyboardDidShow:(NSNotification*)notification;
- (void)keyboardDidHide:(NSNotification*)notification;
- (void)scrollWholeScreenToBottom;
- (void)tapDetected;
- (IBAction)userTappedOnProfile:(id)sender;

@end
