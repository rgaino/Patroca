//
//  UILabel+Extensions.h
//  Patroca
//
//  Created by Rafael Gaino on 12/26/12.
//  Copyright (c) 2012 Punk Opera. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (Extensions)

- (void)sizeToFitFixedWidth:(CGFloat)fixedWidth;
- (void)sizeToFitFrameWidth;
- (void)autoShrinkWithMultipleLinesConstraindToSize;

@end
