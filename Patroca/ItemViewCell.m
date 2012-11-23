//
//  ItemViewCell.m
//  Patroca
//
//  Created by Rafael Gaino on 11/22/12.
//  Copyright (c) 2012 Punk Opera. All rights reserved.
//

#import "ItemViewCell.h"

@implementation ItemViewCell


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame]; if (self) {
        // Initialization code
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"ItemViewCell" owner:self options:nil];
        
        if ([arrayOfViews count] > 1) { return nil; }
        
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UICollectionViewCell class]]) { return nil; }
        
        self = [arrayOfViews objectAtIndex:0];
        
    }
    
    return self;
    
}


@end
