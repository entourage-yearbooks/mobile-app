//
//  EntourageDAO.h
//  EntourageDataAccess
//
//  Created by Elias Jo on 6/20/14.
//  Copyright (c) 2014 Entourage Yearbooks. All rights reserved.
//

#import "ENTObject.h"

@interface EntourageDAO : ENTObject {
    NSString * _entourageServer;
    NSString * _accessCode;
    NSString * _publicKey;
    NSString * _privateKey;
    NSString * _entourageAPIService;
    int _memberId;
    
}

- (NSDictionary *) getYearbookInformation: (int) yearbookId;

- (NSArray *) executeYBQuery: (NSString *) sql;

- (NSArray *) executeEntourageServiceRequest: (NSString *) apiService params: (NSString *) p;

- (NSString *) getGMTTimestamp;

- (NSString *) getEntourageAuthorizationCode: (NSString *) api timestamp: (NSString *) ts;

@end
