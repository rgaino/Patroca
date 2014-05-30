//
//  NSDate+NSDate_Formatter.m
//  Patroca
//
//  Created by Rafael Gaino on 12/23/12.
//  Copyright (c) 2012 Punk Opera. All rights reserved.
//

#import "NSDate+NSDate_Formatter.h"

@implementation NSDate (NSDate_Formatter)

- (NSString*)prettyDateDiffFormat {
    
    NSDate *todayDate = [NSDate date];
    double timeInterval = [self timeIntervalSinceDate:todayDate] * -1;

    if (timeInterval < 60) {
    	return NSLocalizedString(@"right now", nil);
    } else if (timeInterval < 3600) {
    	int diff = round(timeInterval / 60);
        if(diff==1) {
            return [NSString stringWithFormat:NSLocalizedString(@"%d minute ago", nil), diff];
        } else {
            return [NSString stringWithFormat:NSLocalizedString(@"%d minutes ago", nil), diff];
        }
    } else if (timeInterval < 86400) {
    	int diff = round(timeInterval / 60 / 60);
        if(diff==1) {
            return[NSString stringWithFormat:NSLocalizedString(@"%d hour ago", nil), diff];
        } else {
            return[NSString stringWithFormat:NSLocalizedString(@"%d hours ago", nil), diff];
        }
    } else if (timeInterval < 2716143) {
    	int diff = round(timeInterval / 60 / 60 / 24);
        if(diff==1) {
            return[NSString stringWithFormat:NSLocalizedString(@"%d day ago", nil), diff];
        } else {
            return[NSString stringWithFormat:NSLocalizedString(@"%d days ago", nil), diff];
        }
    } else {
    	int diff = round(timeInterval / 60 / 60 / 24 / 30);
        if(diff==1) {
            return[NSString stringWithFormat:NSLocalizedString(@"%d month ago", nil), diff];
        } else {
            return[NSString stringWithFormat:NSLocalizedString(@"%d months ago", nil), diff];
        }
    }
}
 
@end