package com.webfit.nativemap;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.PluginResult;
import org.apache.cordova.PluginResult.Status;
import org.json.JSONArray;




import android.annotation.SuppressLint;
import android.content.Context;
import android.content.Intent;
import android.location.LocationManager;
import android.provider.Settings;
import android.support.v4.view.MotionEventCompat;
import android.view.MotionEvent;
import android.view.View;

public class nativemap extends CordovaPlugin {
    
    CallbackContext cbContext;


public boolean execute(String action, final JSONArray args, CallbackContext callbackContext) {

		this.cbContext = callbackContext;

		PluginResult result = new PluginResult(PluginResult.Status.NO_RESULT);;
    	result.setKeepCallback(true);

        if (action.equals("test")) {

        }
        else if(action.equals("startMap"))
        {
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
