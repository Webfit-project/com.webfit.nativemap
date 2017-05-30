#import "CDVNativeMap.h"
#import <Cordova/CDV.h>

@implementation CDVNativeMap

@synthesize childView;

- (void)pluginInitialize
{

}
- (void)createView
{

}


- (void)startMap:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSString* cmd = [command.arguments objectAtIndex:0];

    if (cmd != nil && [cmd length] > 0) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:cmd];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)requestWES:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
   
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
   
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)getCacheSize:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSString* cmd = [command.arguments objectAtIndex:0];

    if (cmd != nil && [cmd length] > 0) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:cmd];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)clearCache:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSString* cmd = [command.arguments objectAtIndex:0];
    if (cmd != nil && [cmd length] > 0) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:cmd];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end