//
//  UILabel+Extensions.m
//  Patroca
//
//  Created by Rafael Gaino on 12/26/12.
//  Copyright (c) 2012 Punk Opera. All rights reserved.
//

#import "UILabel+Extensions.h"

@implementation UILabel (Extensions)


- (void)sizeToFitFixedWidth:(CGFloat)fixedWidth {

    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, fixedWidth, 0);
    self.lineBreakMode = NSLineBreakByWordWrapping;
    self.numberOfLines = 0;
    [self sizeToFit];
}

- (void)sizeToFitFrameWidth {
    [self sizeToFitFixedWidth:self.frame.size.width];
}

- (void)autoShrinkWithMultipleLinesConstraindToSize {

    CGSize size = CGSizeMake(self.frame.size.width, self.frame.size.height);
    CGFloat fontSize = self.font.pointSize;
    NSString *text = self.text;
    CGFloat height = [text sizeWithFont:self.font constrainedToSize:CGSizeMake(self.frame.size.width,FLT_MAX) lineBreakMode:NSLineBreakByWordWrapping].height;
    UIFont *newFont = self.font;
    
    //Reduce font size while too large, break if no height (empty string)
    while (height > size.height && height != 0) {
        fontSize--;
        newFont = [UIFont fontWithName:self.font.fontName size:fontSize];
        height = [text sizeWithFont:newFont constrainedToSize:CGSizeMake(size.width,FLT_MAX) lineBreakMode:NSLineBreakByWordWrapping].height;
    };
    
    // Loop through words in string and resize to fit
    for (NSString *word in [text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]) {
        CGFloat width = [word sizeWithFont:newFont].width;
        while (width > size.width && width != 0) {
            fontSize--;
            newFont = [UIFont fontWithName:self.font.fontName size:fontSize];
            width = [word sizeWithFont:newFont].width;
        }
    }
    
    [self setFont:[UIFont systemFontOfSize:fontSize]];
}

@end