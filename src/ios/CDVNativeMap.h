//
//  CDVNativeMap.h
//
//  Created by Webfit on 29/05/2017.
//

#import <Foundation/Foundation.h>
#import <Cordova/CDV.h>

@interface CDVNativeMap : CDVPlugin
- (void)startMap:(CDVInvokedUrlCommand*)command;
- (void)getCacheSize:(CDVInvokedUrlCommand*)command;
- (void)clearCache:(CDVInvokedUrlCommand*)command;
- (void)requestWES:(CDVInvokedUrlCommand*)command;
@end


#ifndef CDVNativeMap_h

#define CDVNativeMap_h


#endif /* CDVNativeMap_h */