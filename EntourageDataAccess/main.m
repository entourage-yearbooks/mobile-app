//
//  main.m
//  EntourageDataAccess
//
//  Created by Elias Jo on 6/19/14.
//  Copyright (c) 2014 Entourage Yearbooks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ENTObject.h"
#import "EntourageDAO.h"

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        // insert code here...
        NSLog(@"Hello, World!");
        ENTObject *eObj = [[ENTObject alloc] init];
        [eObj entLog:@"main" msg:@"Start of the program"];
        EntourageDAO * dao = [[EntourageDAO alloc] init];
        
        NSDictionary* ybData = [dao getYearbookInformation: 8541];
        NSLog(@"REturn the yearbook information %@) %@", ybData[@"yearbook_id"], ybData[@"yearbook_title"]);
    }
    return 0;
}

