//
//  ENTObject.m
//  EntourageDataAccess
//
//  Created by Elias Jo on 6/19/14.
//  Copyright (c) 2014 Entourage Yearbooks. All rights reserved.
//

#import "ENTObject.h"

@implementation ENTObject

-(void) entLog: (NSString *) m msg: (NSString *) mess {
    NSString *logMessage;
    logMessage = [NSString stringWithFormat: @"%@ : %@ : %@", _className, m, mess];
    NSLog(@"%@", logMessage);
}

@end

