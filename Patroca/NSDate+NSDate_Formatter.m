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
    
//    if(self)
    
    NSDate *todayDate = [NSDate date];
    double timeInterval = [self timeIntervalSinceDate:todayDate] * -1;
        
    if(timeInterval < 1) {
    	return @"agora mesmo";
    } else 	if (timeInterval < 60) {
    	return @"agora mesmo";
    } else if (timeInterval < 3600) {
    	int diff = round(timeInterval / 60);
    	return [NSString stringWithFormat:@"%d min atrás", diff];
    } else if (timeInterval < 86400) {
    	int diff = round(timeInterval / 60 / 60);
    	return[NSString stringWithFormat:@"%d horas atrás", diff];
    } else if (timeInterval < 2629743) {
    	int diff = round(timeInterval / 60 / 60 / 24);
    	return[NSString stringWithFormat:@"%d dias atrás", diff];
    } else {
    	return @"nunca";
    }
}

@end
