//
//  ItemDataSourceDelegate.h
//  Patroca
//
//  Created by Rafael Gaino on 2/6/13.
//  Copyright (c) 2013 Punk Opera. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ItemViewCell;

@protocol ItemDataSourceDelegate <NSObject>

@required
- (void)populateCollectionView;
- (void)addItemsToColletionView;
- (void)populateTotalLikesWithDictionary:(NSDictionary*)tempTotalCommentsForItemsDictionary;
- (void)updateTotalLikesForItemViewCell:(ItemViewCell*)itemViewCell;

@end
