#import "CDVNativeMap.h"
#import <Cordova/CDV.h>
#import "RMOpenStreetMapSource.h"
#import "RMOpenSeaMapLayer.h"
#import "RMMapView.h"
#import "RMMarker.h"
#import "RMCircle.h"
#import "RMProjection.h"
#import "RMAnnotation.h"
#import "RMQuadTree.h"
#import "RMCoordinateGridSource.h"
#import "RMOpenCycleMapSource.h"

@implementation CDVNativeMap {
    CLLocationCoordinate2D center;
}
@synthesize mapView;
#define kCircleAnnotationType @"circleAnnotation"
#define kDraggableAnnotationType @"draggableAnnotation"
#define kNumberRows 2
#define kNumberColumns 9
#define kSpacing 0.1

#define    TOOLBAR_HEIGHT 46.0
#define    STATUSBAR_HEIGHT 20.0
#define    LOCATIONBAR_HEIGHT 21.0
#define    FOOTER_HEIGHT ((TOOLBAR_HEIGHT) + (LOCATIONBAR_HEIGHT))

- (void)pluginInitialize
{

}
- (void)createView
{
//self.childView = [[UIView alloc] initWithFrame:CGRectMake(x,y,width,height)];
    
    CLLocationCoordinate2D firstLocation;
    firstLocation.latitude = 51.2795;
    firstLocation.longitude = 1.082;
    
    CGRect bounds = [[UIScreen mainScreen] bounds];
    
    mapView = [[RMMapView alloc] initWithFrame:CGRectMake(0, 0, bounds.size.width, bounds.size.height)];
    mapView.adjustTilesForRetinaDisplay = YES;
    mapView.enableClustering = YES;
    mapView.positionClusterMarkersAtTheGravityCenter = YES;
    
    mapView.adjustTilesForRetinaDisplay = YES;
    //   mapView.decelerationMode = RMMapDecelerationOff;
    mapView.enableBouncing = NO;
    mapView.enableDragging = YES;
    
    UIImage *clusterMarkerImage = [UIImage imageNamed:@"marker-blue.png"];
    mapView.clusterMarkerSize = clusterMarkerImage.size;
    mapView.clusterAreaSize = CGSizeMake(clusterMarkerImage.size.width * 1.25, clusterMarkerImage.size.height * 1.25);
    
    //  mapView.debugTiles = YES;

    CGRect toolbarFrame = CGRectMake(0.0, 20.0, self.webView.bounds.size.width, TOOLBAR_HEIGHT);
    
    self.toolbar = [[UIToolbar alloc] initWithFrame:toolbarFrame];
    self.toolbar.alpha = 1.000;
    self.toolbar.autoresizesSubviews = YES;
    self.toolbar.autoresizingMask =  UIViewAutoresizingFlexibleWidth;
   self.toolbar.barStyle = UIBarStyleDefault;
    self.toolbar.translucent = YES;
    [self.toolbar setBackgroundImage:[UIImage new]
                  forToolbarPosition:UIToolbarPositionAny
                          barMetrics:UIBarMetricsDefault];

   self.toolbar.backgroundColor = [UIColor colorWithRed:1 green:170.0/255 blue:69.0/255 alpha:0.95];
    self.toolbar.barTintColor = [UIColor colorWithRed:1 green:170.0/255 blue:69.0/255 alpha:0.95];
    self.toolbar.clearsContextBeforeDrawing = NO;
    self.toolbar.clipsToBounds = YES;
    self.toolbar.contentMode = UIViewContentModeScaleToFill;
    self.toolbar.hidden = NO;
    self.toolbar.multipleTouchEnabled = NO;
    self.toolbar.opaque = NO;
    self.toolbar.userInteractionEnabled = YES;
    
    
    UIBarButtonItem *flexibleSpace =  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIImage *logoimg = [[UIImage imageNamed:@("logo.png")] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIBarItem *logo= [[UIBarButtonItem alloc] initWithImage:logoimg style:nil target:self action:nil];
    
    UIImage *backbuttonimg = [[UIImage imageNamed:@("backbutton.png")] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
   
    UIBarButtonItem *backbutton= [[UIBarButtonItem alloc] initWithImage:backbuttonimg style:UIBarButtonItemStylePlain target:self action:@selector(doneButton:)];
    

    
    NSArray *toolbarItems = [NSArray arrayWithObjects:backbutton,logo,flexibleSpace, flexibleSpace, flexibleSpace, nil];
    
    [self.toolbar setItems:toolbarItems animated:NO];
    
    

    [mapView setTileSources:@[[[RMOpenStreetMapSource alloc] init]]];
    [self.mapView setBackgroundColor:[UIColor greenColor]];
   // [[self view] addSubview:mapView];
   //
    
  //  [self updateInfo];

 
   // [self.childView addSubview:self.mapView];
    

				
    
    CGRect statusBarFrame = [self invertFrameIfNeeded:[UIApplication sharedApplication].statusBarFrame];
    statusBarFrame.size.height = 20;
    // simplified from: http://stackoverflow.com/a/25669695/219684
    
    self.bgToolbar = [[UIToolbar alloc] initWithFrame:statusBarFrame];
    self.bgToolbar.barStyle = UIBarStyleDefault;
    self.bgToolbar.translucent = YES;
    [self.bgToolbar setBackgroundImage:[UIImage new]
                  forToolbarPosition:UIToolbarPositionAny
                          barMetrics:UIBarMetricsDefault];
    self.bgToolbar.barTintColor =[UIColor colorWithRed:1 green:170.0/255 blue:69.0/255 alpha:0.95];
    self.bgToolbar.clipsToBounds = YES;
    self.bgToolbar.backgroundColor = [UIColor colorWithRed:1 green:170.0/255 blue:69.0/255 alpha:0.95];
    [self.bgToolbar setAutoresizingMask:UIViewAutoresizingFlexibleWidth];

    
    
    [self.webView addSubview:self.mapView];
    [self.webView addSubview:self.bgToolbar];
    [self.webView addSubview:self.toolbar];
    
}

- (CGRect) invertFrameIfNeeded:(CGRect)rect {
    // We need to invert since on iOS 7 frames are always in Portrait context
    if (!IsAtLeastiOSVersion(@"8.0")) {
        if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
            CGFloat temp = rect.size.width;
            rect.size.width = rect.size.height;
            rect.size.height = temp;
        }
        rect.origin = CGPointZero;
    }
    return rect;
}



-(IBAction)doneButton:(id)sender
{
    CDVPluginResult* pluginResult = nil;

    
  
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];

    
   //	 [self.commandDelegate sendPluginResult:pluginResult callbackId:self.cmddone.callbackId];
    [ self.mapView removeFromSuperview];


}
- (void)startMap:(CDVInvokedUrlCommand*)command
{
    /*
    CDVPluginResult* pluginResult = nil;
    NSString* cmd = [command.arguments objectAtIndex:0];

    if (cmd != nil && [cmd length] > 0) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:cmd];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
     */
    self.cmddone = command;
    [self createView];
    
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
- (void)dealloc
{
    if (self.mapView)
    {
       
        [ self.mapView removeFromSuperview];
        
        self.mapView = nil;
    }
    if(self.toolbar) {
        [ self.toolbar removeFromSuperview];
        
        self.toolbar = nil;
    }
    if(self.bgToolbar) {
        [ self.bgToolbar removeFromSuperview];
        
        self.bgToolbar = nil;
    }
}
@end
