//
//  LogInViewController.h
//  Patroca
//
//  Created by Rafael Gaino on 8/23/12.
//  Copyright (c) 2012 Punk Opera. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface LogInViewController : BaseViewController {
    
}

-(void) userLoggedInSuccessfully;

@property (weak, nonatomic) IBOutlet UILabel *connectMessage;
@property (weak, nonatomic) IBOutlet UIButton *connectWithFacebookButton;

@end
