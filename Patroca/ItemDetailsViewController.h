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

@interface ItemDetailsViewController : BaseViewController {

}

@property (nonatomic, readwrite) PFObject *itemObject;
@property (weak, nonatomic) IBOutlet UIScrollView *itemImagesScrollView;
@property (weak, nonatomic) IBOutlet UILabel *itemTitleLabel;

- (void)setupItemImagesScrollView;

@end
