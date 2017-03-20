package com.webfit.nativemap;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.apache.cordova.PluginResult.Status;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;

public class nativemap extends CordovaPlugin {

  CallbackContext cbContext;


  public boolean execute(String action, final JSONArray args, final CallbackContext callbackContext) {
    final CordovaPlugin that = this;
    this.cbContext = callbackContext;

    PluginResult result = new PluginResult(PluginResult.Status.NO_RESULT);
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

    if(action.equals("getCacheSize")) {
      cordova.getThreadPool().execute(new Runnable() {
        @Override
        public void run() {
          JSONObject r = new JSONObject();
          try {

            r.put("size", this.initializeCache((that.cordova.getActivity().getBaseContext())));
            callbackContext.success(r);
          } catch (JSONException e) {
            e.printStackTrace();
            PluginResult result = new PluginResult(PluginResult.Status.NO_RESULT);
            result.setKeepCallback(true);
            result = new PluginResult(Status.INVALID_ACTION);
            callbackContext.sendPluginResult(result);
          }

        }

        private long initializeCache(Context context) {
          long size = 0;
          size += getDirSize(context.getCacheDir());
          size += getDirSize(context.getExternalCacheDir());
          return size;
        }

        public long getDirSize(File dir) {
          long size = 0;
          for (File file : dir.listFiles()) {
            if (file != null && file.isDirectory()) {
              size += getDirSize(file);
            } else if (file != null && file.isFile()) {
              size += file.length();
            }
          }
          return size;
        }


      });
    }
    if(action.equals("clearCache")) {
      cordova.getThreadPool().execute(new Runnable() {

        @Override
        public void run() {
          PluginResult result = new PluginResult(PluginResult.Status.NO_RESULT);
          result.setKeepCallback(true);
          if(this.deleteCache(that.cordova.getActivity().getBaseContext()))
          {
            result = new PluginResult(Status.OK);
            callbackContext.sendPluginResult(result);
          }
          else
          {
            result = new PluginResult(Status.INVALID_ACTION);
            callbackContext.sendPluginResult(result);
          }
        }


        public  boolean deleteCache(Context context) {
          try {
            File dir = context.getCacheDir();
            deleteDir(dir);
          } catch (Exception e) { return false;}

          try {
            File dir = context.getExternalCacheDir();
            deleteDir(dir);
          }
          catch(Exception e ){}
          return true;
        }

        public boolean deleteDir(File dir) {
          if (dir != null && dir.isDirectory()) {
            String[] children = dir.list();
            for (int i = 0; i < children.length; i++) {
              boolean success = deleteDir(new File(dir, children[i]));
              if (!success) {
                return false;
              }
            }
            return dir.delete();
          } else if(dir!= null && dir.isFile()) {
            return dir.delete();
          } else {
            return false;
          }
        }


      });

    }
    else {
      result = new PluginResult(Status.INVALID_ACTION);
      callbackContext.sendPluginResult(result);

    }



    return true;
  }





}
