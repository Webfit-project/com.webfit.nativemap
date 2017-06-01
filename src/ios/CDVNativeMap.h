//
//  CDVNativeMap.h
//
//  Created by Webfit on 29/05/2017.
//

#import <Foundation/Foundation.h>
#import <Cordova/CDV.h>

#import "RMMapView.h"


@interface CDVNativeMap : CDVPlugin <RMMapViewDelegate> {
    RMMapView *mapView;
    
    // Your own code....
}
@property (nonatomic, assign) IBOutlet CDVInvokedUrlCommand* cmddone;
@property (nonatomic, strong) IBOutlet UIToolbar* toolbar;
@property (nonatomic, strong) IBOutlet UIToolbar* bgToolbar;
@property (nonatomic, retain) IBOutlet RMMapView *mapView;
@property (nonatomic, retain) IBOutlet UITextView *infoTextView;
- (IBAction)doneButton:(id)sender;
- (void)startMap:(CDVInvokedUrlCommand*)command;
- (void)getCacheSize:(CDVInvokedUrlCommand*)command;
- (void)clearCache:(CDVInvokedUrlCommand*)command;
- (void)requestWES:(CDVInvokedUrlCommand*)command;
- (void)createView:(CDVInvokedUrlCommand*)command;
- (void)updateInfo;

@end