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
#import "RMShape.h"
#import "RMCoordinateGridSource.h"
#import "RMOpenCycleMapSource.h"

@implementation CDVNativeMap {
    CLLocationCoordinate2D center;
    BOOL tapped;
    NSUInteger tapCount;
}
@synthesize mapView;
@synthesize infoTextView;
#define kCircleAnnotationType @"circleAnnotation"
#define kDraggableAnnotationType @"draggableAnnotation"


#define    TOOLBAR_HEIGHT 56.0
#define    STATUSBAR_HEIGHT 20.0
#define    LOCATIONBAR_HEIGHT 21.0
#define    FOOTER_HEIGHT ((TOOLBAR_HEIGHT) + (LOCATIONBAR_HEIGHT))

- (void)pluginInitialize
{
    NSLog(@"on init le plugin");
    
}
- (void)createView:(CDVInvokedUrlCommand*)command
{
    NSError *error;
    NSMutableArray *centerCoord = [NSJSONSerialization JSONObjectWithData:[[command argumentAtIndex:0] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    
    double zoomLevel = [[command argumentAtIndex:4] doubleValue];

    NSMutableArray *iconList = [NSJSONSerialization JSONObjectWithData:[[command argumentAtIndex:1] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    
    NSLog(@"test iconlist: %@",[iconList valueForKey:@"list"]);
    
    center.latitude = [[centerCoord valueForKey:@"lat"] doubleValue];
    center.longitude = [[centerCoord valueForKey:@"lon"] doubleValue];
    
    CGRect bounds = [[UIScreen mainScreen] bounds];
    mapView.maxZoom = 12.5f;
    mapView.minZoom = 6.0f;
    mapView = [[RMMapView alloc] initWithFrame:CGRectMake(0, 0, bounds.size.width, bounds.size.height)];
    [mapView setDelegate:self];
    NSLog(@"apres set delegate");
    mapView.adjustTilesForRetinaDisplay = YES;
    mapView.enableClustering = YES;
    mapView.positionClusterMarkersAtTheGravityCenter = YES;
    
    NSLog(@"test zoom: %f",zoomLevel);
    [mapView setZoom:zoomLevel];
    [mapView setCenterCoordinate:center animated:NO];
    mapView.adjustTilesForRetinaDisplay = YES;
    //   mapView.decelerationMode = RMMapDecelerationOff;
    mapView.decelerationMode = RMMapDecelerationNormal;
    
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
    
    
    [self updateInfo];
    [self performSelector:@selector(addMarkers) withObject:nil afterDelay:1];
    
}

//-(IBAction)doneButton:(id)sender
- (RMMapLayer *)mapView:(RMMapView *)aMapView layerForAnnotation:(RMAnnotation *)annotation
{
    RMMapLayer *marker = nil;
    
    if ([annotation.annotationType isEqualToString:kRMClusterAnnotationTypeName])
    {
        marker = [[RMMarker alloc] initWithUIImage:[UIImage imageNamed:@"marker-blue.png"] anchorPoint:CGPointMake(0.5, 1.0)];
        
        if (annotation.title)
            [(RMMarker *)marker changeLabelUsingText:annotation.title];
    }
    else if ([annotation.annotationType isEqualToString:kCircleAnnotationType])
    {
        marker = [[RMCircle alloc] initWithView:aMapView radiusInMeters:10000.0];
        [(RMCircle *)marker setLineWidthInPixels:5.0];
    }
    else
    {
        marker = [[RMMarker alloc] initWithUIImage:annotation.annotationIcon anchorPoint:annotation.anchorPoint];
        
        if (annotation.title)
            [(RMMarker *)marker changeLabelUsingText:annotation.title];
        
        if ([annotation.userInfo objectForKey:@"foregroundColor"])
            [(RMMarker *)marker setTextForegroundColor:[annotation.userInfo objectForKey:@"foregroundColor"]];
        
        if ([annotation.annotationType isEqualToString:kDraggableAnnotationType])
            marker.enableDragging = YES;
    }
    
    return marker;
}


- (void)addMarkers
{
    NSLog(@"on ajoute un marker");
   
    UIImage *redMarkerImage = [UIImage imageNamed:@"marker-red.png"];
    
    CLLocationCoordinate2D markerPosition;
    markerPosition.latitude = center.latitude;
    markerPosition.longitude = center.longitude;
    
    RMAnnotation *annotation = [RMAnnotation annotationWithMapView:mapView coordinate:markerPosition andTitle:[NSString stringWithFormat:@"%4.1f", markerPosition.longitude]];
    
    annotation.annotationIcon = redMarkerImage;
    annotation.anchorPoint = CGPointMake(0.5, 1.0);

    [mapView addAnnotation:annotation];
    
    
    NSLog(@"fin ajout marker");
    /*
    UIImage *redMarkerImage = [UIImage imageNamed:@"marker-red.png"];
    UIImage *blueMarkerImage = [UIImage imageNamed:@"marker-blue.png"];
    
    markerPosition.latitude = center.latitude;
    markerPosition.longitude = center.longitude;
    
    
    NSLog(@"Add marker @ {%f,%f} = {%f,%f}", markerPosition.longitude, markerPosition.latitude, [mapView coordinateToProjectedPoint:markerPosition].x, [mapView coordinateToProjectedPoint:markerPosition].y);
    
    RMAnnotation *annotation = [RMAnnotation annotationWithMapView:mapView coordinate:markerPosition andTitle:[NSString stringWithFormat:@"%4.1f", markerPosition.longitude]];
    
    if ((markerPosition.longitude < -180) || (markerPosition.longitude > 0))
    {
        annotation.annotationIcon = redMarkerImage;
        annotation.anchorPoint = CGPointMake(0.5, 1.0);
    }
    else
    {
        annotation.annotationIcon = blueMarkerImage;
        annotation.anchorPoint = CGPointMake(0.5, 1.0);
    }
    
    [mapView addAnnotation:annotation];
    */
    
    /*
    RMAnnotation *circleAnnotation = [RMAnnotation annotationWithMapView:mapView coordinate:CLLocationCoordinate2DMake(47.4, 10.0) andTitle:@"A Circle"];
    circleAnnotation.annotationType = kCircleAnnotationType;
    [mapView addAnnotation:circleAnnotation];
    
    RMAnnotation *draggableAnnotation = [RMAnnotation annotationWithMapView:mapView coordinate:CLLocationCoordinate2DMake(47.72, 10.2) andTitle:@"Drag me! Tap me!"];
    draggableAnnotation.annotationType = kDraggableAnnotationType;
    draggableAnnotation.annotationIcon = [UIImage imageNamed:@"marker-blue.png"];
    draggableAnnotation.anchorPoint = CGPointMake(0.5, 1.0);
    draggableAnnotation.clusteringEnabled = NO;
    draggableAnnotation.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIColor blueColor],@"foregroundColor",
                                    nil];
    [mapView addAnnotation:draggableAnnotation];
     */
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

- (void)updateInfo
{
    
     CLLocationCoordinate2D mapCenter = [mapView centerCoordinate];
     
     [infoTextView setText:[NSString stringWithFormat:@"Longitude : %f\nLatitude : %f\nZoom level : %.2f\nScale : 1:%.0f\n%@",
     mapCenter.longitude,
     mapCenter.latitude,
     mapView.zoom,
     mapView.scaleDenominator,
     [[mapView tileSource] shortAttribution]
     ]];
     /*
     [mppLabel setText:[NSString stringWithFormat:@"%.0f m", mapView.metersPerPixel * mppImage.bounds.size.width]];
     */
}



-(IBAction)doneButton:(id)sender
{
    CDVPluginResult* pluginResult = nil;
    
    
    
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    
    
    //	 [self.commandDelegate sendPluginResult:pluginResult callbackId:self.cmddone.callbackId];
    [ self.mapView removeFromSuperview];
    [ self.bgToolbar removeFromSuperview];
    [ self.toolbar removeFromSuperview];
    
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
    [self createView:command];
    
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

#pragma mark -
#pragma mark Delegate methods

- (void)afterMapMove:(RMMapView *)map
{
    [self updateInfo];
}

- (void)afterMapZoom:(RMMapView *)map
{
    [self updateInfo];
}

// Don't use this delegate method for long running tasks since it blocks the main thread - use #afterMapMove or #afterMapZoom instead
- (void)mapViewRegionDidChange:(RMMapView *)mapView
{
    [self updateInfo];
}

- (BOOL)mapView:(RMMapView *)map shouldDragAnnotation:(RMAnnotation *)annotation
{
    if ([annotation.annotationType isEqualToString:kDraggableAnnotationType])
    {
        NSLog(@"Start dragging marker");
        return YES;
    }
    
    return NO;
}

- (void)mapView:(RMMapView *)map didDragAnnotation:(RMAnnotation *)annotation withDelta:(CGPoint)delta
{
    CGPoint screenPosition = CGPointMake(annotation.position.x - delta.x, annotation.position.y - delta.y);
    
    annotation.coordinate = [mapView pixelToCoordinate:screenPosition];
    annotation.position = screenPosition;
}

- (void)mapView:(RMMapView *)map didEndDragAnnotation:(RMAnnotation *)annotation
{
    RMProjectedPoint projectedPoint = annotation.projectedLocation;
    CGPoint screenPoint = annotation.position;
    
    NSLog(@"Did end dragging marker, screen: {%.0f,%.0f}, projected: {%f,%f}, coordinate: {%f,%f}", screenPoint.x, screenPoint.y, projectedPoint.x, projectedPoint.y, annotation.coordinate.latitude, annotation.coordinate.longitude);
}

- (void)tapOnLabelForAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map
{
    if ([annotation.annotationType isEqualToString:kDraggableAnnotationType])
    {
        NSLog(@"Label <%@> tapped for marker <%@>",  ((RMMarker *)annotation.layer).label, (RMMarker *)annotation.layer);
        [(RMMarker *)annotation.layer changeLabelUsingText:[NSString stringWithFormat:@"Drag me! Tap me! (%d)", ++tapCount]];
    }
}

- (void)singleTapOnMap:(RMMapView *)map at:(CGPoint)point
{
    RMProjectedPoint projectedPoint = [map pixelToProjectedPoint:point];
    CLLocationCoordinate2D coordinates =  [map pixelToCoordinate:point];
    
    NSLog(@"Clicked on Map - Location: x:%lf y:%lf, Projected east:%f north:%f, Coordinate lat:%f lon:%f", point.x, point.y, projectedPoint.x, projectedPoint.y, coordinates.latitude, coordinates.longitude);
}

- (void)tapOnAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map
{
    if ([annotation.annotationType isEqualToString:kRMClusterAnnotationTypeName])
    {
        [map zoomInToNextNativeZoomAt:[map coordinateToPixel:annotation.coordinate] animated:YES];
    }
    else if ([annotation.annotationType isEqualToString:kDraggableAnnotationType])
    {
        NSLog(@"MARKER TAPPED!");
        
        if (!tapped)
        {
            annotation.annotationIcon = [UIImage imageNamed:@"marker-red.png"];
            [(RMMarker *)annotation.layer replaceUIImage:annotation.annotationIcon anchorPoint:annotation.anchorPoint];
            [(RMMarker *)annotation.layer changeLabelUsingText:@"Hello"];
            tapped = YES;
        }
        else
        {
            annotation.annotationIcon = [UIImage imageNamed:@"marker-blue.png"];
            [(RMMarker *)annotation.layer replaceUIImage:annotation.annotationIcon anchorPoint:annotation.anchorPoint];
            [(RMMarker *)annotation.layer changeLabelUsingText:@"World"];
            tapped = NO;
        }
    }
}
@end
