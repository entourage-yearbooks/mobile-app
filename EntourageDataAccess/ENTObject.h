//
//  ENTObject.h
//  EntourageDataAccess
//
//  Created by Elias Jo on 6/19/14.
//  Copyright (c) 2014 Entourage Yearbooks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ENTObject : NSObject {
    NSString *_className;
    
}

// Interface definitions

-(void) entLog: (NSString *) m msg: (NSString *) mess;

@end
