//
//  MasterViewController.m
//  Patroca
//
//  Created by Rafael Gaino on 11/16/12.
//  Copyright (c) 2012 Punk Opera. All rights reserved.
//

#import "MasterViewController.h"
#import <Parse/Parse.h>
#import "ItemViewCell.h"
#import "ItemDataSource.h"
#import "LogInViewController.h"

#define CELL_REUSE_IDENTIFIER @"Item_Cell"

@implementation MasterViewController

//@synthesize featuredLabel, friendsLabel, nearbyLabel, menuBarView;
//@synthesize menuArrowImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        //Colors and patterns
        labelSelectedColor = [UIColor colorWithRed:36/255.0 green:190/255.0 blue:212/255.0 alpha:1.0f];
        labelUnselectedColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1.0f];

        UIColor *backgroundPattern = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background_repeat.png"]];
        [[self view] setBackgroundColor:backgroundPattern];
        
        //making menu bar labels tappable
        UITapGestureRecognizer *featuredTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTappedOnFeatured)];
        [_featuredLabel addGestureRecognizer:featuredTap];

        UITapGestureRecognizer *friendsTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTappedOnFriends)];
        [_friendsLabel addGestureRecognizer:friendsTap];

        UITapGestureRecognizer *nearbyTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTappedOnNearby)];
        [_nearbyLabel addGestureRecognizer:nearbyTap];
        
        itemDataSource = [[ItemDataSource alloc] init];
        
    }
    return self;
}

- (void)viewDidLoad {

    [self.contentDisplayCollectionView registerClass:[ItemViewCell class] forCellWithReuseIdentifier:CELL_REUSE_IDENTIFIER];

}

- (void)viewDidAppear:(BOOL)animated {
    CGRect arrowFrame = _menuArrowImage.frame;
    [_menuArrowImage setFrame:CGRectMake(-100, arrowFrame.origin.y, arrowFrame.size.width, arrowFrame.size.height)];
    [self performSelector:@selector(userTappedOnFeatured) withObject:nil afterDelay:1.0f];

    
}

- (void)userTappedOnFeatured {
    [_featuredLabel setTextColor:labelSelectedColor];
    [_friendsLabel setTextColor:labelUnselectedColor];
    [_nearbyLabel setTextColor:labelUnselectedColor];
    [self moveMenuArrowTo:49];
    [self loadFeaturedItems];
}

- (void)userTappedOnFriends {
    [_featuredLabel setTextColor:labelUnselectedColor];
    [_friendsLabel setTextColor:labelSelectedColor];
    [_nearbyLabel setTextColor:labelUnselectedColor];
    [self moveMenuArrowTo:153];
    [self loadFriendsItems];
}

- (void)userTappedOnNearby {
    [_featuredLabel setTextColor:labelUnselectedColor];
    [_friendsLabel setTextColor:labelUnselectedColor];
    [_nearbyLabel setTextColor:labelSelectedColor];
    [self moveMenuArrowTo:264];
}

- (void)moveMenuArrowTo:(float)xPosition {
    
    [UIView animateWithDuration:1.0f
            delay:0
            options:UIViewAnimationOptionCurveEaseInOut
            animations:^{
                CGRect arrowFrame = _menuArrowImage.frame;
                [_menuArrowImage setFrame:CGRectMake(xPosition, arrowFrame.origin.y, arrowFrame.size.width, arrowFrame.size.height)];
            } completion:nil
     ];
}

- (void)loadFeaturedItems {
    
//    int columns = 2;
//    int column = 0;
//    int xSpacing = 5;
//    int ySpacing = 10;
//    float y=ySpacing;
//    
//    float itemsTotalHeight=0;
//    
//    for(int i=0; i<40; i++) {
//        
//        if(column >= columns) { column = 0; }
//        
//        ItemProfileViewController *item = [[ItemProfileViewController alloc] initWithNibName:@"ItemProfileViewController" bundle:nil];
//        float x = (xSpacing * (column+1)) + (item.view.frame.size.width*column);
//        [[item view] setFrame:CGRectMake(x, y, item.view.frame.size.width, item.view.frame.size.height)];
//        [_contentScrollView addSubview:item.view];
//        
//        column++;
//        
//        if(column >= columns) {
//            y+= (item.view.frame.size.height + ySpacing);
//            itemsTotalHeight += (item.view.frame.size.height + ySpacing);
//        }
//    }
//    
//    [_contentScrollView setContentSize:CGSizeMake(_contentScrollView.contentSize.width, (_contentScrollView.contentSize.height+itemsTotalHeight))];
//    NSLog(@"content size is %.2f x %.2f", _contentScrollView.contentSize.width, _contentScrollView.contentSize.height);
}

- (void)loadFriendsItems {
    
    // Check if a user is cached and if user is linked to Facebook
    LogInViewController *logInViewController;
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]])
    {
        [itemDataSource getItemsAndReturnTo:self];
    } else {
        logInViewController = [[LogInViewController alloc] initWithNibName:@"LogInViewController" bundle:nil];
        [self.view.window.rootViewController presentViewController:logInViewController animated:YES completion:nil];
    }

    
}

- (void)populateCollectionView {
    
    NSLog(@"Populating list with %d items", itemDataSource.items.count);

    [_contentDisplayCollectionView reloadData];

}

//#pragma mark UIScrollViewDelegate methods

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    
////    NSLog(@"_menuBarView.frame.origin.y=%.1f and contentOffset.y=%.1f", _menuBarView.frame.origin.y, _contentScrollView.contentOffset.y);
////    if(_menuBarView.frame.origin.y<0) {
////        [_menuBarView setFrame:CGRectMake(_menuBarView.frame.origin.x, 0, _menuBarView.frame.size.width, _menuBarView.frame.size.height)];
////    }
//    
//    if(_contentScrollView.contentOffset.y > 101.0) {
//
//        [_menuBarView setFrame:CGRectMake(_menuBarView.frame.origin.x,
//                                          _contentScrollView.contentOffset.y,
//                                          _menuBarView.frame.size.width, _menuBarView.frame.size.height)];
//        NSLog(@"_menuBarView.frame.origin.y=%.1f", _menuBarView.frame.origin.y);
//
//    }
//    
//}

#pragma mark - UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return itemDataSource.items.count;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    ItemViewCell *itemViewCell = (ItemViewCell *)[self.contentDisplayCollectionView dequeueReusableCellWithReuseIdentifier:CELL_REUSE_IDENTIFIER forIndexPath:indexPath];
    
//    NSMutableArray *data = [self.dataArray objectAtIndex:indexPath.section];
//    NSString *cellData = [data objectAtIndex:indexPath.row];
//    [cell.titleLabel setText:cellData];
    
    return itemViewCell;
    
    
    
//    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:CELL_REUSE_IDENTIFIER forIndexPath:indexPath];
//    cell.backgroundColor = [UIColor whiteColor];
//    return cell;
}
// 4
/*- (UICollectionReusableView *)collectionView:
 (UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
 {
 return [[UICollectionReusableView alloc] init];
 }*/

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: Select Item
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
}


#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(147, 205);
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(5, 10, 5, 10);
}

@end
