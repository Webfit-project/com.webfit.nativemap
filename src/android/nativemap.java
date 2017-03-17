package com.webfit.nativemap;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.PluginResult;
import org.apache.cordova.PluginResult.Status;
import org.json.JSONArray;


import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;

import android.preference.PreferenceManager;
import android.util.Log;

import com.google.android.gms.phenotype.Configuration;
import com.ionicframework.camptocamp893008.R;

import org.json.JSONException;
import org.json.JSONObject;
import org.osmdroid.tileprovider.tilesource.TileSourceFactory;
import org.osmdroid.views.MapView;

public class nativemap extends CordovaPlugin {

  CallbackContext cbContext;


  public boolean execute(String action, final JSONArray args, CallbackContext callbackContext) {
    final CordovaPlugin that = this;
    this.cbContext = callbackContext;

    PluginResult result = new PluginResult(PluginResult.Status.NO_RESULT);;
    result.setKeepCallback(true);

    if(action.equals("startMap"))
    {
      Log.d("STATE","onstart la map");

      cordova.getThreadPool().execute(new Runnable() {
        @Override
        public void run() {
          String center= "";
          String iconList = "";
          String route = "";
          try {
            center =  args.getString(0);
            iconList =  args.getString(1);
            route = args.getString(2);
          } catch (JSONException e) {
            e.printStackTrace();
          }

          Intent intentMap = new Intent(that.cordova.getActivity().getBaseContext(), MapActivity.class);
          intentMap.putExtra("center",center);
          intentMap.putExtra("iconList",iconList);
          intentMap.putExtra("route",route);

          intentMap.setPackage(that.cordova.getActivity().getApplicationContext().getPackageName());


          that.cordova.startActivityForResult(that, intentMap, 0);
        }
      });

      callbackContext.sendPluginResult(result);

    }
    else {
      result = new PluginResult(Status.INVALID_ACTION);
      callbackContext.sendPluginResult(result);

    }



    return true;
  }




  public void startMap() {




  }


}
