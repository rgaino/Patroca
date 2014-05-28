//
//  AboutViewController.h
//  Patroca
//
//  Created by Rafael Gaino on 5/26/14.
//  Copyright (c) 2014 Punk Opera. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface AboutViewController : BaseViewController <UIWebViewDelegate> {

    UIScrollView *aboutScrollView;
    UIWebView *termsWebView;
    UIActivityIndicatorView *loadingTermsActivityIndicator;
}

@end
