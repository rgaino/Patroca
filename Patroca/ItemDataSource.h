//
//  ItemDataSource.h
//  Patroca
//
//  Created by Rafael Gaino on 11/22/12.
//  Copyright (c) 2012 Punk Opera. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MasterViewController;

@interface ItemDataSource : NSObject {
    
}

- (void)getItemsAndReturnTo:(MasterViewController*)masterViewController;

@end
