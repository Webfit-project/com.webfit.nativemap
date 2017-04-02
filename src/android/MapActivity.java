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
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.ionicframework.camptocamp893008.R;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.osmdroid.api.IMapController;
import org.osmdroid.bonuspack.utils.BonusPackHelper;
import org.osmdroid.tileprovider.tilesource.TileSourceFactory;
import org.osmdroid.util.GeoPoint;
import org.osmdroid.views.MapView;
import org.osmdroid.views.overlay.Marker;
import org.osmdroid.views.overlay.OverlayItem;
import org.osmdroid.views.overlay.OverlayWithIW;
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

final public class MapActivity extends Activity implements View.OnClickListener {
  protected MapView mapView;
  private ScaleBarOverlay mScaleBarOverlay;
  private CompassOverlay mCompassOverlay=null;


  @Override public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    Context ctx = getApplicationContext();

    Log.d("STATE","on est dans map activity");
    setContentView(R.layout.map);
    Intent intent = getIntent();
    String center = intent.getStringExtra("center");
    String iconList = intent.getStringExtra("iconList");
    String route =  intent.getStringExtra("route");
    String zoom =  intent.getStringExtra("zoom");


    mapView = (MapView) findViewById(R.id.map);
    mapView.setTileSource(TileSourceFactory.MAPNIK);

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
  int zoomLevel = Integer.parseInt(zoom);
    mapController.setZoom(zoomLevel);
    mapView.setMaxZoomLevel(zoomLevel);

    mapView.setMultiTouchControls(true);
    mapView.setTilesScaledToDpi(true);
    final DisplayMetrics dm = ctx.getResources().getDisplayMetrics();



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

    mapView.getOverlays().add(polyline);



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
        startMarker.setTitle(json_data.getString("title"));
        if(json_data.getString("description") != "null")
          startMarker.setSubDescription(json_data.getString("description"));
        startMarker.setAnchor(Marker.ANCHOR_CENTER, 1.0f);

        CustomInfoWindow infoWindow = new CustomInfoWindow(R.layout.bubble,mapView,this,json_data.getString("id"));
        startMarker.setInfoWindow(infoWindow);

        switch(json_data.getString("icon"))
        {
          case "summit":
            startMarker.setIcon(getResources().getDrawable(R.drawable.icon_sommet));

            break;
          case "shelter":
            startMarker.setIcon(getResources().getDrawable(R.drawable.icon_abri));


            break;

          case "access":
            startMarker.setIcon(getResources().getDrawable(R.drawable.icon_acces));

            break;

          case "paragliding_landing":
            startMarker.setIcon(getResources().getDrawable(R.drawable.icon_atterrissage));

            break;

          case "bisse":
            startMarker.setIcon(getResources().getDrawable(R.drawable.icon_bisse));

            break;

          case "bivouac":
            startMarker.setIcon(getResources().getDrawable(R.drawable.icon_bivouac));

            break;

          case "base_camp":
            startMarker.setIcon(getResources().getDrawable(R.drawable.icon_camp));

            break;

          case "camp_site":
            startMarker.setIcon(getResources().getDrawable(R.drawable.icon_camping));

            break;

          case "canyon":
            startMarker.setIcon(getResources().getDrawable(R.drawable.icon_canyon));

            break;

          case "waterfall":
            startMarker.setIcon(getResources().getDrawable(R.drawable.icon_cascade));

            break;

          case "pass":
            startMarker.setIcon(getResources().getDrawable(R.drawable.icon_col));

            break;

          case "paragliding_takeoff":
            startMarker.setIcon(getResources().getDrawable(R.drawable.icon_decollage));

            break;

          case "climbing_outdoor":
            startMarker.setIcon(getResources().getDrawable(R.drawable.icon_escalade));

            break;

          case "gite":
            startMarker.setIcon(getResources().getDrawable(R.drawable.icon_gite));

            break;

          case "cave":
            startMarker.setIcon(getResources().getDrawable(R.drawable.icon_grotte));

            break;

          case "lake":
            startMarker.setIcon(getResources().getDrawable(R.drawable.icon_lac));

            break;

          case "locality":
            startMarker.setIcon(getResources().getDrawable(R.drawable.icon_lieu));

            break;

          case "weather_station":
            startMarker.setIcon(getResources().getDrawable(R.drawable.icon_meteo));

            break;

          case "local_product":
            startMarker.setIcon(getResources().getDrawable(R.drawable.icon_produit));

            break;

          case "hut":
            startMarker.setIcon(getResources().getDrawable(R.drawable.icon_refuge));

            break;

          case "climbing_indoor":
            startMarker.setIcon(getResources().getDrawable(R.drawable.icon_sae));

            break;

          case "waterpoint":
            startMarker.setIcon(getResources().getDrawable(R.drawable.icon_source));

            break;

          case "virtual":
            startMarker.setIcon(getResources().getDrawable(R.drawable.icon_virtuel));

            break;

          case "webcam":
            startMarker.setIcon(getResources().getDrawable(R.drawable.icon_webcam));

            break;
          case "icon_itineraire":
            startMarker.setIcon(getResources().getDrawable(R.drawable.icon_itineraire));

            break;
          default:
            break;


        }

        mapView.getOverlays().add(startMarker);

      }

    } catch (JSONException e) {
      e.printStackTrace();
    }

  }

  public void onResume(){
    super.onResume();

  }


  @Override
  public void onClick(View v) {

  }
}



class CustomInfoWindow extends  MarkerInfoWindow {

  MapActivity mapactivity;

  static int mTitleId=BonusPackHelper.UNDEFINED_RES_ID,
    mDescriptionId=BonusPackHelper.UNDEFINED_RES_ID,
    mSubDescriptionId=BonusPackHelper.UNDEFINED_RES_ID,
    mImageId=BonusPackHelper.UNDEFINED_RES_ID; //resource ids
  String id;
  private static void setResIds(Context context){
    String packageName = context.getPackageName(); //get application package name
    mTitleId = context.getResources().getIdentifier("id/bubble_title", null, packageName);
    mDescriptionId = context.getResources().getIdentifier("id/bubble_description", null, packageName);
    mSubDescriptionId = context.getResources().getIdentifier("id/bubble_subdescription", null, packageName);
    mImageId = context.getResources().getIdentifier("id/bubble_image", null, packageName);
    if (mTitleId == BonusPackHelper.UNDEFINED_RES_ID || mDescriptionId == BonusPackHelper.UNDEFINED_RES_ID
      || mSubDescriptionId == BonusPackHelper.UNDEFINED_RES_ID || mImageId == BonusPackHelper.UNDEFINED_RES_ID) {
      Log.e(BonusPackHelper.LOG_TAG, "BasicInfoWindow: unable to get res ids in "+packageName);
    }
  }

  public CustomInfoWindow(int layoutResId, MapView mapView, MapActivity mapactivity, String id) {
    super(layoutResId, mapView);
    this.id = id;
    this.mapactivity = mapactivity;

    if (mTitleId == BonusPackHelper.UNDEFINED_RES_ID)
      setResIds(mapView.getContext());

  }


  public void onClose() {
  }

  public void onOpen(Object arg0) {

    OverlayWithIW overlay = (OverlayWithIW)arg0;
    String title = overlay.getTitle();
    String subDesc = overlay.getSubDescription();

    LinearLayout layout = (LinearLayout) mView.findViewById(R.id.bubble);
    Button btnMoreInfo = (Button) mView.findViewById(R.id.bubble_moreinfo);
    final Button btnShow = (Button) mView.findViewById(R.id.bubble_show);
    TextView txtTitle = (TextView) mView.findViewById(R.id.bubble_title);
    TextView txtDescription = (TextView) mView.findViewById(R.id.bubble_description);


    txtTitle.setText(title);
    txtDescription.setText(subDesc);

    layout.setOnClickListener(new View.OnClickListener() {
      public void onClick(View v) {

      }
    });


    btnShow.setOnClickListener(new View.OnClickListener() {

      public void onClick(View view) {

        Intent returnIntent = new Intent();
        returnIntent.putExtra("id_obj",id);
        mapactivity.setResult(Activity.RESULT_OK,returnIntent);
        mapactivity.finish();
      }
    });

  }
}