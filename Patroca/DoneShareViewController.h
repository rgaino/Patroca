//
//  DoneShareViewController.h
//  Patroca
//
//  Created by Rafael Gaino on 2/28/13.
//  Copyright (c) 2013 Punk Opera. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@class PFObject;

@interface DoneShareViewController : BaseViewController {

}

@property (nonatomic, readwrite) PFObject *itemObject;
@property (weak, nonatomic) IBOutlet UILabel *itemTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;

- (IBAction)shareButtonPressed:(id)sender;
    
@end
