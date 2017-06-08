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
@property (nonatomic, assign) BOOL infollow;
@property (nonatomic, strong) IBOutlet UIToolbar* toolbar;
@property (nonatomic, strong) IBOutlet UIToolbar* bgToolbar;
@property (nonatomic, retain) IBOutlet RMMapView *mapView;
@property (nonatomic, retain) IBOutlet UITextView *infoTextView;
@property (nonatomic, retain) IBOutlet NSString *callbackId;
@property (nonatomic,retain) IBOutlet RMMapLayer *route;
@property (nonatomic, retain) IBOutlet NSMutableArray *routeCoord;
@property (nonatomic, retain) IBOutlet RMMapLayer *myroute;
@property (nonatomic, retain) IBOutlet NSMutableArray *myrouteCoord;
@property (nonatomic, retain) IBOutlet RMAnnotation *myposition;
@property (nonatomic, retain) IBOutlet RMAnnotation *pathmyroute;
@property (nonatomic, retain) IBOutlet UIButton *buttoncenter;
@property (nonatomic, retain) IBOutlet UIButton *buttongeoloc;
@property (nonatomic, retain) IBOutlet CLLocationManager *locationManager;

- (IBAction)centerButton:(id)sender;
- (IBAction)geolocButton:(id)sender;
- (IBAction)doneButton:(id)sender;
- (void)createRoute;
+ (void)drawRoute;
- (void)startMap:(CDVInvokedUrlCommand*)command;
- (void)getCacheSize:(CDVInvokedUrlCommand*)command;
- (void)clearCache:(CDVInvokedUrlCommand*)command;
- (void)requestWES:(CDVInvokedUrlCommand*)command;
- (void)createView:(CDVInvokedUrlCommand*)command;
- (void)updateInfo;
- (void)addMarkers:(double)lat :(double)lon :(NSString*)title :(NSString*)description :(NSString*)ido :(NSString*)icon;
- (UIImage *)imageResize :(UIImage*)img andResizeTo:(CGSize)newSize;

@end



