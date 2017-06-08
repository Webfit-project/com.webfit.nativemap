#import "CDVNativeMap.h"
#import <Cordova/CDV.h>
#import "RMOpenStreetMapSource.h"
#import "RMESRIWorldTopoMap.h"
#import "RMMapView.h"
#import "RMMarker.h"
#import "RMCircle.h"
#import "RMPath.h"
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
    NSString *callbackId;
}
@synthesize mapView;
@synthesize infoTextView;
@synthesize callbackId;
@synthesize myroute;
@synthesize myrouteCoord;
@synthesize route;
@synthesize routeCoord;
@synthesize myposition;
@synthesize pathmyroute;
@synthesize infollow;

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
    
    [[NSNotificationCenter 	defaultCenter] addObserver:self selector:@selector(getNewLocation:) name:@"getnewlocation" object:nil];
    
    NSError *error;
    NSMutableArray *centerCoord = [NSJSONSerialization JSONObjectWithData:[[command argumentAtIndex:0] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    
    center.latitude = [[centerCoord valueForKey:@"lat"] doubleValue];
    center.longitude = [[centerCoord valueForKey:@"lon"] doubleValue];
    
    routeCoord = [[NSMutableArray alloc] init];
    
    if ([[command argumentAtIndex:2] isKindOfClass:[NSDictionary class]])
    {
        NSArray *routeList = [[command argumentAtIndex:2] valueForKey:@"list"];
        for(int n = 0;n < [routeList count];n++) {
            
            double lat = [[routeList[n] valueForKey:@"lat"] doubleValue];
            double lon = [[routeList[n] valueForKey:@"lon"] doubleValue];
            NSLog(@"on rajoute à la route les coordonnées: %@,%@",[routeList[n] valueForKey:@"lat"],[routeList[n] valueForKey:@"lon"]);
            [routeCoord addObject:[[CLLocation alloc] initWithLatitude:lat longitude:lon]];
            
        }
    }
    
    infollow = false;
    myrouteCoord = [[NSMutableArray alloc] init];
    
    if ([[command argumentAtIndex:3] isKindOfClass:[NSDictionary class]])
    {
        NSArray *myrouteList = [[command argumentAtIndex:3] valueForKey:@"list"];
        for(int n = 0;n < [myrouteList count];n++) {
            
            double lat = [[myrouteList[n] valueForKey:@"lat"] doubleValue];
            double lon = [[myrouteList[n] valueForKey:@"lon"] doubleValue];
            NSLog(@"on rajoute les coordonnées: %@,%@",[myrouteList[n] valueForKey:@"lat"],[myrouteList[n] valueForKey:@"lon"]);
            [myrouteCoord addObject:[[CLLocation alloc] initWithLatitude:lat longitude:lon]];
            
        }
    }
    
    //}
    double zoomLevel = [[command argumentAtIndex:4] doubleValue];
    
    
    CGRect bounds = [[UIScreen mainScreen] bounds];
    mapView.maxZoom = 12.5f;
    mapView.minZoom = 6.0f;
    mapView = [[RMMapView alloc] initWithFrame:CGRectMake(0, 0, bounds.size.width, bounds.size.height)];
    [mapView setDelegate:self];
    mapView.adjustTilesForRetinaDisplay = YES;
    mapView.enableClustering = NO;
    mapView.positionClusterMarkersAtTheGravityCenter = YES;
    
    [mapView setZoom:zoomLevel];
    [mapView setCenterCoordinate:center animated:NO];
    mapView.adjustTilesForRetinaDisplay = YES;
    //mapView.decelerationMode = RMMapDecelerationOff;
    mapView.decelerationMode = RMMapDecelerationNormal;
    
    mapView.enableBouncing = NO;
    mapView.enableDragging = YES;
    
    
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
    UIBarItem *logo = [[UIBarButtonItem alloc] initWithImage:logoimg style:UIBarButtonItemStyleDone target:self action:nil];
    
    
    
    
    UIImage *backbuttonimg = [[UIImage imageNamed:@("backbutton.png")] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *backbutton = [[UIBarButtonItem alloc] initWithImage:backbuttonimg style:UIBarButtonItemStylePlain target:self action:@selector(doneButton:)];
    UIBarButtonItem *separator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    separator.width = 15;
    
    [backbutton setWidth: 30];
    
    NSArray *toolbarItems = [NSArray arrayWithObjects:backbutton,separator,logo,flexibleSpace, nil];
    [self.toolbar setItems:toolbarItems animated:NO];
    
    if([[command argumentAtIndex:5] isEqualToString:@"1"])
    {
        UIImage *buttongeolocimg = [[UIImage imageNamed:@("ic_follow_me.png")] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        self.buttongeoloc = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.buttongeoloc.frame = CGRectMake(self.webView.bounds.size.width - 88, 188, 68, 68);
        [self.buttongeoloc addTarget:self action:@selector(geolocButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttongeoloc setImage:buttongeolocimg forState:UIControlStateNormal];
    }
    
    
    if([[command argumentAtIndex:6] isEqualToString:@"1"])
    {
        UIImage *buttoncenterimg = [[UIImage imageNamed:@("ic_center_map.png")] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        self.buttoncenter = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.buttoncenter.frame = CGRectMake(self.webView.bounds.size.width - 88, 100, 68, 68);
        [self.buttoncenter addTarget:self action:@selector(centerButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttoncenter setImage:buttoncenterimg forState:UIControlStateNormal];
    }
    
 
    
    
    [mapView setTileSources:@[[[RMOESRIWorldTopoMap alloc] init]]];
    [self.mapView setBackgroundColor:[UIColor greenColor]];
    
    
    
				
    
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
    [self.webView addSubview:self.buttoncenter];
    [self.webView addSubview:self.buttongeoloc];
    
    [self updateInfo];
    [self performSelector:@selector(createRoute:) withObject:nil afterDelay:0.5f];
    
    if ([[command argumentAtIndex:1	] isKindOfClass:[NSDictionary class]])
    {
        
        [self performSelector:@selector(createWaypoints:) withObject:[command argumentAtIndex:1] afterDelay:0.7f];
    }
    
}

//-(IBAction)doneButton:(id)sender

- (RMMapLayer *)mapView:(RMMapView *)aMapView layerForAnnotation:(RMAnnotation *)annotation
{
    RMMapLayer *marker = nil;
    
    if ([annotation.annotationType isEqualToString:kCircleAnnotationType])
    {
        marker = [[RMCircle alloc] initWithView:aMapView radiusInMeters:10000.0];
        [(RMCircle *)marker setLineWidthInPixels:5.0];
    }
    else if([annotation.annotationType isEqualToString:@"path"])
    {
        marker = [[RMShape alloc] initWithView:aMapView];
        
        [(RMShape *)marker setLineWidth:4.0];
        [(RMShape *)marker setLineColor:[UIColor colorWithRed:246.0f/255.0f green:135.0f/255.0f blue:18.0f/255.0f alpha:200.0f/250.0f]];
        marker.zPosition = 1;
        myroute = marker;
        
        for(CLLocation* coord in myrouteCoord)
        {
            [(RMShape *)myroute addLineToCoordinate:CLLocationCoordinate2DMake(coord.coordinate.latitude,coord.coordinate.longitude)];
        }
        
    }
    else if([annotation.annotationType isEqualToString:@"path2"])
    {
        marker = [[RMShape alloc] initWithView:aMapView];
        
        [(RMShape *)marker setLineWidth:4.0];
        [(RMShape *)marker setLineColor:[UIColor colorWithRed:225.0f/255.0f green:72.0f/255.0f blue:79.0f/255.0f alpha:1]];
        
        route = marker;
        
        for(CLLocation* coord in routeCoord)
        {
            [(RMShape *)route addLineToCoordinate:CLLocationCoordinate2DMake(coord.coordinate.latitude,coord.coordinate.longitude)];
        }
        
        route.zPosition = 0.0f;
        
        //  [self drawRoute];
        
    }
    
    else if([annotation.annotationType isEqualToString:@"myposition"])
    {
        marker = [[RMMarker alloc] initWithUIImage:annotation.annotationIcon anchorPoint:annotation.anchorPoint];
        marker.zPosition = 2.0f;
        if(annotation.title)
            [(RMMarker *)marker setTitle:annotation.title];
        
    }
    
    else
    {
        marker = [[RMMarker alloc] initWithUIImage:annotation.annotationIcon anchorPoint:annotation.anchorPoint];
        marker.zPosition = 3.0f;
        if(annotation.title)
            [(RMMarker *)marker setTitle:annotation.title];
        
        if(annotation.desc)
            [(RMMarker *)marker setDesc:annotation.desc];
        
        if(annotation.ido)
            [(RMMarker *)marker setIdo:annotation.ido];
        
    }
    
    return marker;
}

- (void)createWaypoints:(NSDictionary *)iconList
{
    
    if([myrouteCoord count] > 0)
    {
        
        CLLocation *mylocation = [myrouteCoord lastObject];
        [self addMyPositionMarker:mylocation.coordinate.latitude :mylocation.coordinate.longitude];
    }
    NSArray *waypointList = [iconList objectForKey:@"list"];
    
    for(int n = 0;n < [waypointList count];n++) {
        
        NSLog(@"test iconlist objet n° %d: %@",n,waypointList[n] );
        double lat = [[waypointList[n] valueForKey:@"lat"] doubleValue];
        double lon = [[waypointList[n] valueForKey:@"lon"] doubleValue];
        NSString *title = [waypointList[n] valueForKey:@"title"];
        NSString *description = [waypointList[n] valueForKey:@"description"];
        NSString *ido = [[waypointList[n] valueForKey:@"id"] stringValue];
        NSString *icon = [waypointList[n] valueForKey:@"icon"];
        [self addMarkers:lat :lon :title :description :ido :icon];
    }
}

-(UIImage *)imageResize :(UIImage*)img andResizeTo:(CGSize)newSize
{
    CGFloat scale = [[UIScreen mainScreen]scale];
    /*You can remove the below comment if you dont want to scale the image in retina   device .Dont forget to comment UIGraphicsBeginImageContextWithOptions*/
    //UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, scale);
    [img drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)addMyPositionMarker:(double)lat :(double)lon
{
    UIImage *MarkerImage;
    MarkerImage = [self imageResize:[UIImage imageNamed:@"icon_myposition.png"] andResizeTo:CGSizeMake(40, 64) ];
    CLLocationCoordinate2D markerPosition;
    markerPosition.latitude = lat;
    markerPosition.longitude = lon;
    
    RMAnnotation *annotation = [RMAnnotation annotationWithMapView:mapView coordinate:markerPosition andTitle:nil];
    
    annotation.annotationIcon = MarkerImage;
    annotation.title = @"Ma position";
    annotation.anchorPoint = CGPointMake(0.5, 1.0);
    annotation.annotationType = @"myposition";
    
    myposition = annotation;
    [mapView addAnnotation:annotation];
    
    
}
- (void)addMarkers:(double)lat :(double)lon :(NSString*)title :(NSString*)description :(NSString *)ido :(NSString*)icon
{
    NSLog(@"on ajoute un marker");
    
    
    UIImage *MarkerImage;
    
    if([icon isEqualToString:@"summit"]) {
        MarkerImage = [self imageResize:[UIImage imageNamed:@"icon_sommet.png"] andResizeTo:CGSizeMake(40, 64) ];
    } else if([icon isEqualToString:@"shelter"]) {
        MarkerImage = [self imageResize:[UIImage imageNamed:@"icon_abri.png"] andResizeTo:CGSizeMake(40, 64) ];
        
    } else if([icon isEqualToString:@"access"]) {
        MarkerImage = [self imageResize:[UIImage imageNamed:@"icon_acces.png"] andResizeTo:CGSizeMake(40, 64) ];
        
    } else if([icon isEqualToString:@"paragliding_landing"]) {
        MarkerImage = [self imageResize:[UIImage imageNamed:@"icon_atterrissage.png"] andResizeTo:CGSizeMake(40, 64) ];
        
    } else if([icon isEqualToString:@"bisse"]) {
        MarkerImage = [self imageResize:[UIImage imageNamed:@"icon_bisse.png"] andResizeTo:CGSizeMake(40, 64) ];
        
    } else if([icon isEqualToString:@"bivouac"]) {
        MarkerImage = [self imageResize:[UIImage imageNamed:@"icon_bivouac.png"] andResizeTo:CGSizeMake(40, 64) ];
    } else if([icon isEqualToString:@"base_camp"]) {
        MarkerImage = [self imageResize:[UIImage imageNamed:@"icon_camp.png"] andResizeTo:CGSizeMake(40, 64) ];
        
    } else if([icon isEqualToString:@"camp_site"]) {
        MarkerImage = [self imageResize:[UIImage imageNamed:@"icon_camping.png"] andResizeTo:CGSizeMake(40, 64) ];
        
    } else if([icon isEqualToString:@"canyon"]) {
        MarkerImage = [self imageResize:[UIImage imageNamed:@"icon_canyon.png"] andResizeTo:CGSizeMake(40, 64) ];
        
    } else if([icon isEqualToString:@"waterfall"]) {
        MarkerImage = [self imageResize:[UIImage imageNamed:@"icon_cascade.png"] andResizeTo:CGSizeMake(40, 64) ];
        
    } else if([icon isEqualToString:@"pass"]) {
        MarkerImage = [self imageResize:[UIImage imageNamed:@"icon_col.png"] andResizeTo:CGSizeMake(40, 64) ];
        
    } else if([icon isEqualToString:@"paragliding_takeoff"]) {
        MarkerImage = [self imageResize:[UIImage imageNamed:@"icon_decollage.png"] andResizeTo:CGSizeMake(40, 64) ];
    } else if([icon isEqualToString:@"climbing_outdoor"]) {
        MarkerImage = [self imageResize:[UIImage imageNamed:@"icon_escalade.png"] andResizeTo:CGSizeMake(40, 64) ];
        
    } else if([icon isEqualToString:@"gite"]) {
        MarkerImage = [self imageResize:[UIImage imageNamed:@"icon_gite.png"] andResizeTo:CGSizeMake(40, 64) ];
        
    } else if([icon isEqualToString:@"cave"]) {
        MarkerImage = [self imageResize:[UIImage imageNamed:@"icon_grotte.png"] andResizeTo:CGSizeMake(40, 64) ];
        
    } else if([icon isEqualToString:@"lake"]) {
        MarkerImage = [self imageResize:[UIImage imageNamed:@"icon_lac.png"] andResizeTo:CGSizeMake(40, 64) ];
    } else if([icon isEqualToString:@"locality"]) {
        MarkerImage = [self imageResize:[UIImage imageNamed:@"icon_lieu.png"] andResizeTo:CGSizeMake(40, 64) ];
    } else if([icon isEqualToString:@"weather_station"]) {
        MarkerImage = [self imageResize:[UIImage imageNamed:@"icon_meteo.png"] andResizeTo:CGSizeMake(40, 64) ];
    } else if([icon isEqualToString:@"local_product"]) {
        MarkerImage = [self imageResize:[UIImage imageNamed:@"icon_produit.png"] andResizeTo:CGSizeMake(40, 64) ];
    } else if([icon isEqualToString:@"hut"]) {
        MarkerImage = [self imageResize:[UIImage imageNamed:@"icon_refuge.png"] andResizeTo:CGSizeMake(40, 64) ];
    } else if([icon isEqualToString:@"climbing_indoor"]) {
        MarkerImage = [self imageResize:[UIImage imageNamed:@"icon_sae.png"] andResizeTo:CGSizeMake(40, 64) ];
    } else if([icon isEqualToString:@"waterpoint"]) {
        MarkerImage = [self imageResize:[UIImage imageNamed:@"icon_source.png"] andResizeTo:CGSizeMake(40, 64) ];
    } else if([icon isEqualToString:@"virtual"]) {
        MarkerImage = [self imageResize:[UIImage imageNamed:@"icon_virtuel.png"] andResizeTo:CGSizeMake(40, 64) ];
    } else if([icon isEqualToString:@"webcam"]) {
        MarkerImage = [self imageResize:[UIImage imageNamed:@"icon_webcam.png"] andResizeTo:CGSizeMake(40, 64) ];
    } else if([icon isEqualToString:@"icon_itineraire"]) {
        MarkerImage = [self imageResize:[UIImage imageNamed:@"icon_itineraire.png"] andResizeTo:CGSizeMake(40, 64) ];
    } else if([icon isEqualToString:@"icon_misc"]) {
        MarkerImage = [self imageResize:[UIImage imageNamed:@"icon_misc.png"] andResizeTo:CGSizeMake(40, 64) ];
    } else {
        MarkerImage = [self imageResize:[UIImage imageNamed:@"icon_misc.png"] andResizeTo:CGSizeMake(40, 64) ];
    }
    
    
    
    
    CLLocationCoordinate2D markerPosition;
    markerPosition.latitude = lat;
    markerPosition.longitude = lon;
    
    RMAnnotation *annotation = [RMAnnotation annotationWithMapView:mapView coordinate:markerPosition andTitle:nil];
    
    annotation.annotationIcon = MarkerImage;
    annotation.title = title;
    annotation.desc = description;
    annotation.ido = ido;
    annotation.anchorPoint = CGPointMake(0.5, 1.0);
    
    [mapView addAnnotation:annotation];
    
    
    /*
     trace un cercle
     RMAnnotation *circleAnnotation = [RMAnnotation annotationWithMapView:mapView coordinate:CLLocationCoordinate2DMake(47.4, 10.0) andTitle:@"A Circle"];
     circleAnnotation.annotationType = kCircleAnnotationType;
     [mapView addAnnotation:circleAnnotation];
     */
    
    NSLog(@"fin ajout marker");
    
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

-(IBAction)geolocButton:(id)sender
{
    
    if(infollow) {
        UIImage *buttongeolocimg = [[UIImage imageNamed:@("ic_follow_me.png")] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        [self.buttongeoloc setImage:buttongeolocimg forState:UIControlStateNormal];
        infollow = false;
        [mapView setShowsUserLocation:false];
        
    }
    else {
        UIImage *buttongeolocimg = [[UIImage imageNamed:@("ic_follow_me_on.png")] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        [self.buttongeoloc setImage:buttongeolocimg forState:UIControlStateNormal];
        infollow = true;
        
        
        [mapView setUserTrackingMode:RMUserTrackingModeFollowWithHeading];
        
    }
    
    
}

-(IBAction)centerButton:(id)sender
{
    
    CLLocation *mrfc;
    mrfc = [myrouteCoord lastObject];
    if(mrfc != nil) {
        [mapView setCenterCoordinate:CLLocationCoordinate2DMake(mrfc.coordinate.latitude, mrfc.coordinate.longitude)];
        [mapView setZoom:16.0f];
    }
    
    
    
}

-(IBAction)doneButton:(id)sender
{
    CDVPluginResult* pluginResult = nil;
    
    
    
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
    
    [self closeMap];
}
- (void)closeMap {
    [ self.mapView removeFromSuperview];
    [ self.bgToolbar removeFromSuperview];
    [ self.toolbar removeFromSuperview];
    [ self.buttoncenter removeFromSuperview];
    [ self.buttongeoloc removeFromSuperview];
}
- (void)createRoute:(NSDictionary *)iconList {
    NSLog(@"on crée les annotations pour les routes");
    
    
    
    
    if([myrouteCoord count] > 0)
    {
        CLLocation *mrfc;
        mrfc = [myrouteCoord firstObject];
        pathmyroute = [RMAnnotation annotationWithMapView:mapView coordinate:CLLocationCoordinate2DMake(mrfc.coordinate.latitude, mrfc.coordinate.longitude) andTitle:@""];
        pathmyroute.annotationType = @"path";
        pathmyroute.title = @"my route";
        [pathmyroute setBoundingBoxFromLocations:myrouteCoord];
        
        
        [mapView addAnnotation:pathmyroute];
        
    }
    
    
    
    
    RMAnnotation *pathAnnotation2;
    
    
    CLLocation *rfc;
    rfc = [routeCoord firstObject];
    pathAnnotation2 = [RMAnnotation annotationWithMapView:mapView coordinate:CLLocationCoordinate2DMake(rfc.coordinate.latitude, rfc.coordinate.longitude) andTitle:@""];
    
    
    pathAnnotation2.annotationType = @"path2";
    
    [pathAnnotation2 setBoundingBoxFromLocations:routeCoord];
    pathAnnotation2.title = @"route";
    
    [mapView addAnnotation:pathAnnotation2];
}
- (void)getNewLocation:(NSNotification*)notification {
    NSDictionary* userInfo = notification.userInfo;
    
    NSString *latitude = (NSString*)userInfo[@"latitude"];
    NSString *longitude = (NSString*)userInfo[@"longitude"];
    [myrouteCoord addObject:[[CLLocation alloc] initWithLatitude:[latitude doubleValue] longitude:[longitude doubleValue]]];
    
    [(RMShape *)myroute addLineToCoordinate:CLLocationCoordinate2DMake([latitude doubleValue],[longitude doubleValue])];
    
    // myposition
    if(myposition != nil)
    {
        [myposition setCoordinate:CLLocationCoordinate2DMake([latitude doubleValue], [longitude doubleValue])];
    }
    else
    {
        //CLLocation *mylocation = [myrouteCoord lastObject];
        [self addMyPositionMarker:[latitude doubleValue] :[longitude doubleValue]];
    }
    
    if(pathmyroute == nil)
    {
        pathmyroute = [RMAnnotation annotationWithMapView:mapView coordinate:CLLocationCoordinate2DMake([latitude doubleValue], [longitude doubleValue]) andTitle:@""];
        pathmyroute.annotationType = @"path";
        pathmyroute.title = @"my route";
        [pathmyroute setBoundingBoxFromLocations:myrouteCoord];
        
        
        [mapView addAnnotation:pathmyroute];
    }
    NSLog (@"nouvelle coordonnée : (%@,%@)", latitude,longitude);
}


- (void)startMap:(CDVInvokedUrlCommand*)command
{
    
    callbackId = command.callbackId;
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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


- (void)tapOnButton:(NSString *)name
{
    CDVPluginResult* pluginResult = nil;
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:name];
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
    [self closeMap];
}


- (void)tapOnLabelForAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map
{
    [(RMMarker *)annotation.layer hideLabel];
}

- (void)singleTapOnMap:(RMMapView *)map at:(CGPoint)point
{
    /*
     RMProjectedPoint projectedPoint = [map pixelToProjectedPoint:point];
     CLLocationCoordinate2D coordinates =  [map pixelToCoordinate:point];
     
     NSLog(@"Clicked on Map - Location: x:%lf y:%lf, Projected east:%f north:%f, Coordinate lat:%f lon:%f", point.x, point.y, projectedPoint.x, projectedPoint.y, coordinates.latitude, coordinates.longitude);
     */
}

- (void)tapOnAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map
{
    NSLog(@"taponannotation");
    if(annotation.ido != nil)
        [(RMMarker *)annotation.layer createInfoWindow:annotation.title desc:annotation.desc ido:annotation.ido];
    /*
     
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
     */
}
@end
