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

@interface ItemDetailsViewController ()

@end

@implementation ItemDetailsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupHeaderWithBackButton:YES];
    [self setupItemImagesScrollView];
    [_itemTitleLabel setText:[_itemObject objectForKey:DB_FIELD_ITEM_NAME]];
}

- (void)setupItemImagesScrollView {
    
    PFQuery *itemImagesQuery = [PFQuery queryWithClassName:DB_TABLE_ITEM_IMAGES];
    [itemImagesQuery whereKey:DB_FIELD_ITEM_ID equalTo:_itemObject];
    [itemImagesQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        [_imagesPageControl setNumberOfPages:[objects count]];
        [_imagesPageControl setCurrentPage:0];
        
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
    }];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = _itemImagesScrollView.frame.size.width;
    int page = floor((_itemImagesScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    [_imagesPageControl setCurrentPage:page];
}

@end
