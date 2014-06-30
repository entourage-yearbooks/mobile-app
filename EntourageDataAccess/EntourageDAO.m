//
//  EntourageDAO.m
//  EntourageDataAccess
//  This object is to access data from the Entourage system.
//
//  Created by Elias Jo on 6/20/14.
//  Copyright (c) 2014 Entourage Yearbooks. All rights reserved.
//

#import "EntourageDAO.h"
#include <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonHMAC.h>

@implementation EntourageDAO

- (id) init {
    self = [super init];
    _className = @"EntourageDAO";
    _publicKey = @"ENTOURAGE_06202014_1";
    _privateKey = @"E70C6F50-D161-49F8-A53B-0D57F00EC993";
    _entourageAPIService = @"http://dev.www.entourageyearbooks.com/services/EntourageServiceManager.asp";
    
    return (self);
}

- (NSDictionary *) getYearbookInformation: (int) yearbookId {
    NSString * ybParams = [NSString stringWithFormat: @"yearbook_id=%i", yearbookId];
    
    [self entLog:@"getYearbookInformation" msg: [NSString stringWithFormat: @"yearbook id: %i", yearbookId]];
     
    NSArray* resultsArray = [self executeEntourageServiceRequest: @"getYearbookInformation" params: ybParams];
    NSDictionary* retVal = [resultsArray objectAtIndex:0];
    
    return (retVal);
}

- (NSArray *) executeYBQuery: (NSString *) sql {
    return (nil);
}

- (NSArray*) executeEntourageServiceRequest: (NSString *) apiService params: (NSString *) p {
    
    [self entLog:@"executeEntourageServiceRequest" msg: [NSString stringWithFormat: @"API Service %@ params %@", apiService, p]];
    
    // Prepare the link that is going to be used on the GET request
    NSURL * url = [[NSURL alloc] initWithString: _entourageAPIService];
    
    // Prepare the request object
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url
                                        cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                        timeoutInterval:30];
    
    [urlRequest setHTTPMethod:@"POST"];
    
    [self entLog:@"executeEntourageServiceRequest" msg: [NSString stringWithFormat: @"Set the api service name header to: %@", apiService]];
    
    // Prepare the post data
    NSString *post = [NSString stringWithFormat:@"%@&debug=", p];
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];

    NSString * ts = [self getGMTTimestamp];
    NSString * authCode = [self getEntourageAuthorizationCode: apiService timestamp: ts];
    
    // Set the headers
    [urlRequest setValue: postLength forHTTPHeaderField:@"Content-Length"];
    [urlRequest setValue: @"application/x-www-form-urlencoded" forHTTPHeaderField:@"Current-Type"];
    [urlRequest addValue: apiService forHTTPHeaderField:@"ent-service"];
    [urlRequest addValue: _publicKey forHTTPHeaderField:@"ent-access-key"];
    [urlRequest addValue: authCode forHTTPHeaderField:@"ent-authorization"];
    [urlRequest addValue: ts forHTTPHeaderField:@"ent-timestamp"];
    
    [urlRequest setHTTPBody:postData];
    
    [self entLog:@"executeEntourageServiceRequest" msg: [NSString stringWithFormat: @"Construct the service request with url: %@", _entourageAPIService]];
    
    // Prepare the variables for the JSON response
    NSData *urlData;
    NSURLResponse *response;
    NSError *error;
    
    // Make synchronous request
    urlData = [NSURLConnection sendSynchronousRequest:urlRequest
                                    returningResponse:&response
                                                error:&error];
    [self entLog:@"executeEntourageServiceRequest" msg: @"Sent the synchronous url request"];
    NSString* result = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
    //NSString* result = [[[[NSString alloc] initWithData:urlData encoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"\t" withString:@""] stringByReplacingOccurrencesOfString:@"\0" withString:@""];
    
    [self entLog:@"executeEntourageServiceRequest" msg: [NSString stringWithFormat: @"Response from Entourage API server: %@", result]];

    //NSData *data = [result dataUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [result dataUsingEncoding: NSASCIIStringEncoding];
    
    NSString* myString;
    myString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"WHAT IS GOING ON HERE: %@", result);
    
    NSError *e = nil;
    
    NSArray * jsonArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&e];
    
    return (jsonArray);
}

- (NSString *) getGMTTimestamp {
    [self entLog:@"getGMTTimestamp" msg: @"Get the current timestamp"];
    NSDate *myDate = [[NSDate alloc] init];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [dateFormat setTimeZone: gmt];
    [dateFormat setDateFormat:@"ccc, dd MMM yyyy hh:mm:ss +0000"];
    NSString *formattedString = [dateFormat stringFromDate:myDate];
    [self entLog:@"getGMTTimestamp" msg: [NSString stringWithFormat: @"Formatted timestamp GMT: %@", formattedString]];
    return (formattedString);
}

- (NSString *) getEntourageAuthorizationCode: (NSString *) api timestamp: (NSString *) ts {
    [self entLog:@"getEntourageAuthorizationCode" msg: [NSString stringWithFormat: @"Api Service %@ timestampe %@", api, ts]];
    NSString * signMe;
    NSString * authCode;
    signMe = [NSString stringWithFormat: @"Time: %@ Key: %@ Service: %@", ts, _publicKey, api];
    [self entLog:@"getEntourageAuthorizationCode" msg: [NSString stringWithFormat: @"Sting to sign %@", signMe]];
    
    const char *cKey  = [_privateKey cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [signMe cStringUsingEncoding:NSASCIIStringEncoding];
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData *HMACData = [NSData dataWithBytes:cHMAC length:sizeof(cHMAC)];
    const unsigned char *buffer = (const unsigned char *)[HMACData bytes];
    NSMutableString *HMAC = [NSMutableString stringWithCapacity:HMACData.length * 2];
    for (int i = 0; i < HMACData.length; ++i){
        [HMAC appendFormat:@"%02x", buffer[i]];
    }
    authCode = HMAC;
    [self entLog:@"getEntourageAuthorizationCode" msg: [NSString stringWithFormat: @"Generated authcode %@", authCode]];
    return (authCode);
}

@end
