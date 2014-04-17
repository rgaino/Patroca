//
//  HelpView.h
//  Patroca
//
//  Created by Rafael Gaino on 4/16/14.
//  Copyright (c) 2014 Punk Opera. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HelpView : UIButton

//the current data mode
typedef enum {
    HelpViewTypeLogin,
    HelpViewTypeAddItem
} HelpViewType;

- (id)initWithStyle:(HelpViewType)helpViewType;

@end
