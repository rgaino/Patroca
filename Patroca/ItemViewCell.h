//
//  ItemViewCell.h
//  Patroca
//
//  Created by Rafael Gaino on 11/22/12.
//  Copyright (c) 2012 Punk Opera. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PFObject;

@interface ItemViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *itemNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *ownerNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *itemImageView;

- (void)setupCellWithItem:(PFObject*)itemObject;

@end
