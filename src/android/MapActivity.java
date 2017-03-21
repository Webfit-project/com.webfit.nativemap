package com.webfit.nativemap;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.os.Build;
import android.os.Bundle;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.View;

import com.ionicframework.camptocamp893008.R;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.osmdroid.api.IMapController;
import org.osmdroid.tileprovider.tilesource.TileSourceFactory;
import org.osmdroid.util.GeoPoint;
import org.osmdroid.views.MapView;
import org.osmdroid.views.overlay.ItemizedOverlay;
import org.osmdroid.views.overlay.Marker;
import org.osmdroid.views.overlay.OverlayItem;
import org.osmdroid.views.overlay.Polyline;
import org.osmdroid.views.overlay.ScaleBarOverlay;
import org.osmdroid.views.overlay.compass.CompassOverlay;
import org.osmdroid.views.overlay.compass.InternalCompassOrientationProvider;
import org.osmdroid.views.overlay.infowindow.MarkerInfoWindow;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Nicolas on 15/03/2017.
 */

public class MapActivity extends Activity implements View.OnClickListener {
  protected MapView mapView;
  private ScaleBarOverlay mScaleBarOverlay;
  private CompassOverlay mCompassOverlay=null;

  private ItemizedOverlay<OverlayItem>itemOverlay;

  @Override public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    Context ctx = getApplicationContext();

    Log.d("STATE","on est dans map activity");
    setContentView(R.layout.map);
    Intent intent = getIntent();
    String center = intent.getStringExtra("center");
    String iconList = intent.getStringExtra("iconList");
    String route =  intent.getStringExtra("route");



    mapView = (MapView) findViewById(R.id.map);
    mapView.setTileSource(TileSourceFactory.MAPNIK);
    //mapView.setLayerType(View.LAYER_TYPE_SOFTWARE,null);
    IMapController mapController = mapView.getController();
    try {
      JSONObject centerObject = new JSONObject(center);
      GeoPoint point2 = new GeoPoint(centerObject.getDouble("lat"), centerObject.getDouble("lon"));
      mapController.setCenter(point2);
    } catch (JSONException e) {
      e.printStackTrace();
      GeoPoint point2 = new GeoPoint(44.923001,  6.359711);
      mapController.setCenter(point2);
    }

    mapController.setZoom(15);
    mapView.setMaxZoomLevel(25);

    mapView.setMultiTouchControls(true);
    mapView.setTilesScaledToDpi(true);
    final DisplayMetrics dm = ctx.getResources().getDisplayMetrics();
/*
    mapView.setMapListener(new MapListener() {
      @Override
      public boolean onScroll(ScrollEvent event) {
        return false;
      }

      @Override
      public boolean onZoom(ZoomEvent event) {
        if(mapView.getZoomLevel() < 13)
        {
          mapView.setLayerType(View.LAYER_TYPE_HARDWARE,null);

        }
        else
        {
          // mapView.setLayerType(View.LAYER_TYPE_SOFTWARE,null);

        }
        return false;
      }

    } );
*/


    mScaleBarOverlay = new ScaleBarOverlay(mapView);
    mScaleBarOverlay.setCentred(true);
    mScaleBarOverlay.setScaleBarOffset(dm.widthPixels / 2, 10);

    if (Build.VERSION.SDK_INT > Build.VERSION_CODES.FROYO) {
      mCompassOverlay = new CompassOverlay(ctx, new InternalCompassOrientationProvider(ctx),
        mapView);
      mCompassOverlay.enableCompass();
      mapView.getOverlays().add(this.mCompassOverlay);
    }


    mapView.getOverlays().add(this.mScaleBarOverlay);
    Log.d("STATE","iconlist in activity = "+ iconList);
    this.addItem(iconList);
    this.addRoute(route);

  }

  public void addRoute(String route) {

    Polyline polyline;
    List<GeoPoint> polylines = new ArrayList<GeoPoint>();
    try {
      JSONObject iconObject = new JSONObject(route);
      JSONArray jArray = iconObject.getJSONArray("list");

      for (int i = 0; i < jArray.length(); i++) {
        JSONObject json_data = jArray.getJSONObject(i);
        GeoPoint gpt = new GeoPoint(json_data.getDouble("lat"), json_data.getDouble("lon"));
        polylines.add(gpt);


      }

    } catch (JSONException e) {
      e.printStackTrace();
    }

    polyline = new Polyline(MapActivity.this);
    polyline.setPoints (polylines);
    polyline.setColor(Color.argb(95, 39, 185, 0));
    polyline.setWidth(10);
/*
    polyline.setInfoWindow(new BasicInfoWindow(R.layout.bonuspack_bubble, mapView));
    polyline.setTitle("Polyline tapped!");
    */
    mapView.getOverlays().add(polyline);


    /*
    PathOverlay myPath = new PathOverlay(Color.argb(95, 39, 185, 0), this);


    try {
      JSONObject iconObject = new JSONObject(route);
      JSONArray jArray = iconObject.getJSONArray("list");

      for (int i = 0; i < jArray.length(); i++) {
        JSONObject json_data = jArray.getJSONObject(i);
        GeoPoint gpt = new GeoPoint(json_data.getDouble("lat"), json_data.getDouble("lon"));
        myPath.addPoint(gpt);
      }
    } catch (JSONException e) {
      e.printStackTrace();
    }


    Paint pPaint = myPath.getPaint();
    pPaint.setStyle(Paint.Style.STROKE);
    pPaint.setStrokeWidth(10);
    myPath.setPaint(pPaint);


    mapView.getOverlays().add(myPath);*/
  }


  public void addItem(String iconList)
  {
    Log.d("STATE","iconlist = " + iconList);
    final ArrayList<OverlayItem> items = new ArrayList<>();

    try {
      JSONObject iconObject = new JSONObject(iconList);
      JSONArray jArray = iconObject.getJSONArray("list");

      for(int i=0; i<jArray.length(); i++){
        JSONObject json_data = jArray.getJSONObject(i);
        Log.i("log_tag", "title=" + json_data.getString("title") +
          ", description" + json_data.getString("description") +
          ", id" + json_data.getString("id") +
          ", lat" + json_data.getDouble("lat") +
          ", lon" + json_data.getDouble("lon") +
          ", icon" + json_data.getString("icon")  );

        Marker startMarker = new Marker(mapView);
        startMarker.setPosition(new GeoPoint(json_data.getDouble("lat") ,json_data.getDouble("lon") ));
        startMarker.setIcon(getResources().getDrawable(R.drawable.icon_sommet));
        startMarker.setTitle("jkdfghspdifj");
        startMarker.setAnchor(Marker.ANCHOR_CENTER, 1.0f);
        MarkerInfoWindow infoWindow = new MarkerInfoWindow(org.osmdroid.bonuspack.R.layout.bonuspack_bubble, mapView);
        startMarker.setInfoWindow(infoWindow);

        switch(json_data.getString("icon"))
        {
          case "ic_sommet":
            startMarker.setIcon(getResources().getDrawable(R.drawable.icon_sommet));

            break;
          case "icon_abri":
            startMarker.setIcon(getResources().getDrawable(R.drawable.icon_abri));


            break;

          case "icon_acces":
            startMarker.setIcon(getResources().getDrawable(R.drawable.icon_acces));

            break;

          case "icon_atterrissage":
            startMarker.setIcon(getResources().getDrawable(R.drawable.icon_atterrissage));

            break;

          case "icon_bisse":
            startMarker.setIcon(getResources().getDrawable(R.drawable.icon_bisse));

            break;

          case "icon_bivouac":
            startMarker.setIcon(getResources().getDrawable(R.drawable.icon_bivouac));

            break;

          case "icon_camp":
            startMarker.setIcon(getResources().getDrawable(R.drawable.icon_camp));

            break;

          case "icon_camping":
            startMarker.setIcon(getResources().getDrawable(R.drawable.icon_camping));

            break;

          case "icon_canyon":
            startMarker.setIcon(getResources().getDrawable(R.drawable.icon_canyon));

            break;

          case "icon_cascade":
            startMarker.setIcon(getResources().getDrawable(R.drawable.icon_cascade));

            break;

          case "icon_col":
            startMarker.setIcon(getResources().getDrawable(R.drawable.icon_col));

            break;

          case "icon_decollage":
            startMarker.setIcon(getResources().getDrawable(R.drawable.icon_decollage));

            break;

          case "icon_escalade":
            startMarker.setIcon(getResources().getDrawable(R.drawable.icon_escalade));

            break;

          case "icon_gite":
            startMarker.setIcon(getResources().getDrawable(R.drawable.icon_gite));

            break;

          case "icon_grotte":
            startMarker.setIcon(getResources().getDrawable(R.drawable.icon_grotte));

            break;

          case "icon_lac":
            startMarker.setIcon(getResources().getDrawable(R.drawable.icon_lac));

            break;

          case "icon_lieu":
            startMarker.setIcon(getResources().getDrawable(R.drawable.icon_lieu));

            break;

          case "icon_meteo":
            startMarker.setIcon(getResources().getDrawable(R.drawable.icon_meteo));

            break;

          case "icon_produit":
            startMarker.setIcon(getResources().getDrawable(R.drawable.icon_produit));

            break;

          case "icon_refuge":
            startMarker.setIcon(getResources().getDrawable(R.drawable.icon_refuge));

            break;

          case "icon_sae":
            startMarker.setIcon(getResources().getDrawable(R.drawable.icon_sae));

            break;

          case "icon_source":
            startMarker.setIcon(getResources().getDrawable(R.drawable.icon_source));

            break;

          case "icon_virtuel":
            startMarker.setIcon(getResources().getDrawable(R.drawable.icon_virtuel));

            break;

          case "icon_webcam":
            startMarker.setIcon(getResources().getDrawable(R.drawable.icon_webcam));

            break;

          default:
            break;


        }

        mapView.getOverlays().add(startMarker);
/*
        OverlayItem olItem;


        olItem = new OverlayItem(json_data.getString("title"), json_data.getString("description"),new GeoPoint(json_data.getDouble("lat"), json_data.getDouble("lon")));
        Drawable newMarker= null;

        switch(json_data.getString("icon"))
        {
          case "ic_sommet":
            newMarker = this.getResources().getDrawable(R.drawable.icon_sommet);
            olItem.setMarker(newMarker);
            break;
          case "icon_abri":
            newMarker = this.getResources().getDrawable(R.drawable.icon_abri);

            olItem.setMarker(newMarker);
            break;

          case "icon_acces":
            newMarker = this.getResources().getDrawable(R.drawable.icon_acces);
            olItem.setMarker(newMarker);
            break;

          case "icon_atterrissage":
            newMarker = this.getResources().getDrawable(R.drawable.icon_atterrissage);
            olItem.setMarker(newMarker);
            break;

          case "icon_bisse":
            newMarker = this.getResources().getDrawable(R.drawable.icon_bisse);
            olItem.setMarker(newMarker);
            break;

          case "icon_bivouac":
            newMarker = this.getResources().getDrawable(R.drawable.icon_bivouac);
            olItem.setMarker(newMarker);
            break;

          case "icon_camp":
            newMarker = this.getResources().getDrawable(R.drawable.icon_camp);
            olItem.setMarker(newMarker);
            break;

          case "icon_camping":
            newMarker = this.getResources().getDrawable(R.drawable.icon_camping);
            olItem.setMarker(newMarker);
            break;

          case "icon_canyon":
            newMarker = this.getResources().getDrawable(R.drawable.icon_canyon);
            olItem.setMarker(newMarker);
            break;

          case "icon_cascade":
            newMarker = this.getResources().getDrawable(R.drawable.icon_cascade);
            olItem.setMarker(newMarker);
            break;

          case "icon_col":
            newMarker = this.getResources().getDrawable(R.drawable.icon_col);
            olItem.setMarker(newMarker);
            break;

          case "icon_decollage":
            newMarker = this.getResources().getDrawable(R.drawable.icon_decollage);
            olItem.setMarker(newMarker);
            break;

          case "icon_escalade":
            newMarker = this.getResources().getDrawable(R.drawable.icon_escalade);
            olItem.setMarker(newMarker);
            break;

          case "icon_gite":
            newMarker = this.getResources().getDrawable(R.drawable.icon_gite);
            olItem.setMarker(newMarker);
            break;

          case "icon_grotte":
            newMarker = this.getResources().getDrawable(R.drawable.icon_grotte);
            olItem.setMarker(newMarker);
            break;

          case "icon_lac":
            newMarker = this.getResources().getDrawable(R.drawable.icon_lac);
            olItem.setMarker(newMarker);
            break;

          case "icon_lieu":
            newMarker = this.getResources().getDrawable(R.drawable.icon_lieu);
            olItem.setMarker(newMarker);
            break;

          case "icon_meteo":
            newMarker = this.getResources().getDrawable(R.drawable.icon_meteo);
            olItem.setMarker(newMarker);
            break;

          case "icon_produit":
            newMarker = this.getResources().getDrawable(R.drawable.icon_produit);
            olItem.setMarker(newMarker);
            break;

          case "icon_refuge":
            newMarker = this.getResources().getDrawable(R.drawable.icon_refuge);
            olItem.setMarker(newMarker);
            break;

          case "icon_sae":
            newMarker = this.getResources().getDrawable(R.drawable.icon_sae);
            olItem.setMarker(newMarker);
            break;

          case "icon_source":
            newMarker = this.getResources().getDrawable(R.drawable.icon_source);
            olItem.setMarker(newMarker);
            break;

          case "icon_virtuel":
            newMarker = this.getResources().getDrawable(R.drawable.icon_virtuel);
            olItem.setMarker(newMarker);
            break;

          case "icon_webcam":
            newMarker = this.getResources().getDrawable(R.drawable.icon_webcam);
            olItem.setMarker(newMarker);
            break;

          default:
            break;


        }

        items.add(olItem);
*/



      }

    } catch (JSONException e) {
      e.printStackTrace();
    }


/*
    this.itemOverlay = new ItemizedIconOverlay<>(getApplicationContext(),items,
      new ItemizedIconOverlay.OnItemGestureListener<OverlayItem>() {

        @Override
        public boolean onItemSingleTapUp(final int index, final OverlayItem item) {



          Toast.makeText(
            MapActivity.this,
            "Item '" + item.getTitle() + "' (index=" + index
              + ") got single tapped up", Toast.LENGTH_LONG).show();

          return true; // We 'handled' this event.
        }

        @Override
        public boolean onItemLongPress(final int index, final OverlayItem item) {

          Toast.makeText(
            MapActivity.this,
            "Item '" + item.getTitle() + "' (index=" + index
              + ") got long pressed", Toast.LENGTH_LONG).show();

          return false;
        }
      });

    mapView.getOverlays().add(this.itemOverlay);
*/

  }

  public void onResume(){
    super.onResume();

  }


  @Override
  public void onClick(View v) {

  }
}
