package com.webfit.nativemap;
import android.app.Activity;
import android.content.Context;
import android.os.Bundle;
import android.util.Log;

import com.ionicframework.camptocamp893008.R;

import org.osmdroid.api.IMapController;
import org.osmdroid.tileprovider.tilesource.TileSourceFactory;
import org.osmdroid.util.GeoPoint;
import org.osmdroid.views.MapView;

/**
 * Created by Nicolas on 15/03/2017.
 */

public class MapActivity extends Activity {
  @Override public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    Context ctx = getApplicationContext();
    Log.d("STATE","on est dans map activity");
    setContentView(R.layout.map);


    MapView mapView = (MapView) findViewById(R.id.map);
    mapView.setTileSource(TileSourceFactory.MAPNIK);
    mapView.setBuiltInZoomControls(true);
    IMapController mapController = mapView.getController();
    mapController.setZoom(15);
    GeoPoint point2 = new GeoPoint(51496994, -134733);
    mapController.setCenter(point2);

  }

  public void onResume(){
    super.onResume();

  }
}
