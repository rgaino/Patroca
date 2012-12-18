//
//  UILabel+UILabel_Resize.m
//  Patroca
//
//  Created by Rafael Gaino on 12/18/12.
//  Copyright (c) 2012 Punk Opera. All rights reserved.
//

#import "UILabel+UILabel_Resize.h"

@implementation UILabel (UILabel_Resize)

- (void)adjustHeight {
    
    if (self.text == nil) {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.bounds.size.width, 0);
        return;
    }
    
    CGSize aSize = self.bounds.size;
    CGSize tmpSize = CGRectInfinite.size;
    tmpSize.width = aSize.width;
    
    tmpSize = [self.text sizeWithFont:self.font constrainedToSize:tmpSize];
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, aSize.width, tmpSize.height);
}

@end
