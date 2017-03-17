package com.webfit.nativemap;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.View;
import android.widget.Toast;

import com.ionicframework.camptocamp893008.R;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.osmdroid.api.IMapController;
import org.osmdroid.events.MapListener;
import org.osmdroid.events.ScrollEvent;
import org.osmdroid.events.ZoomEvent;
import org.osmdroid.tileprovider.tilesource.TileSourceFactory;
import org.osmdroid.util.GeoPoint;
import org.osmdroid.views.MapView;
import org.osmdroid.views.overlay.ItemizedIconOverlay;
import org.osmdroid.views.overlay.ItemizedOverlay;
import org.osmdroid.views.overlay.OverlayItem;
import org.osmdroid.views.overlay.PathOverlay;
import org.osmdroid.views.overlay.ScaleBarOverlay;
import org.osmdroid.views.overlay.compass.CompassOverlay;
import org.osmdroid.views.overlay.compass.InternalCompassOrientationProvider;

import java.util.ArrayList;

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

    IMapController mapController = mapView.getController();
    mapController.setZoom(15);
    mapView.setLayerType(View.LAYER_TYPE_SOFTWARE, null);
    mapView.setMaxZoomLevel(25);
    GeoPoint point2 = new GeoPoint(44.923001,  6.359711);
    mapController.setCenter(point2);
    mapView.setMultiTouchControls(true);
    mapView.setTilesScaledToDpi(true);
    final DisplayMetrics dm = ctx.getResources().getDisplayMetrics();



    mScaleBarOverlay = new ScaleBarOverlay(ctx);
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
    mapView.setMapListener(new MapListener() {
      @Override
      public boolean onScroll(ScrollEvent event) {
        return false;
      }

      public boolean onZoom(ZoomEvent arg0) {
        Log.d("STATE","ZOOM="+mapView.getZoomLevel());
        if(mapView.getZoomLevel() > 13)
        {
          Log.d("STATE","SOFTWARE");
          mapView.setLayerType(View.LAYER_TYPE_SOFTWARE, null);
        }
        else
        {
          Log.d("STATE","HARDWARE");
          mapView.setLayerType(View.LAYER_TYPE_HARDWARE, null);
        }
        return false;
      }


    } );

    this.addItem(iconList);
    this.addRoute(route);


  }

  public void addRoute(String route)
  {
    PathOverlay myPath = new PathOverlay(Color.argb(95,39,185,0), this);
    try {
      JSONObject iconObject = new JSONObject(route);
      JSONArray jArray = iconObject.getJSONArray("list");

      for (int i = 0; i < jArray.length(); i++) {
        JSONObject json_data = jArray.getJSONObject(i);
        GeoPoint gpt= new GeoPoint(json_data.getDouble("lat"),  json_data.getDouble("lon"));
        myPath.addPoint(gpt);
      }
    }
    catch (JSONException e) {
      e.printStackTrace();
    }

    Paint pPaint = myPath.getPaint();
    pPaint.setStyle(Paint.Style.STROKE);
    pPaint.setStrokeWidth(8);
    myPath.setPaint(pPaint);


    mapView.getOverlays().add(myPath);
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

        OverlayItem olItem;


        olItem = new OverlayItem(json_data.getString("title"), json_data.getString("description"),new GeoPoint(json_data.getDouble("lat"), json_data.getDouble("lon")));
        switch(json_data.getString("icon"))
        {
          case "ic_sommet":
            Drawable newMarker = this.getResources().getDrawable(R.drawable.icon_sommet);
            olItem.setMarker(newMarker);
            break;

          default:
            break;


        }

        items.add(olItem);


      }

    } catch (JSONException e) {
      e.printStackTrace();
    }



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


  }

  public void onResume(){
    super.onResume();
  }


  @Override
  public void onClick(View v) {

  }
}
