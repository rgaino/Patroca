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

@interface ItemDetailsViewController : BaseViewController <UIScrollViewDelegate> {

    int numberOfImages;
}

@property (nonatomic, readwrite) PFObject *itemObject;
@property (weak, nonatomic) IBOutlet UIScrollView *itemImagesScrollView;
@property (weak, nonatomic) IBOutlet UILabel *itemTitleLabel;
@property (weak, nonatomic) IBOutlet UIPageControl *imagesPageControl;
@property (weak, nonatomic) IBOutlet UILabel *ownerNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *ownerProfilePic;

- (void)setupItemImagesScrollView;
- (void)adjustPageControl;
- (void)animateImagesScrollViewIn;

@end
