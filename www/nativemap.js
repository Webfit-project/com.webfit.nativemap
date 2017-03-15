//cordova.define('com.webfit.nativemap.nativemap', function(require, exports, module) {
    console.log("create nativemap");
    var exec = require('cordova/exec');

    var nativemap = {

        startMap : function(successCallback, failureCallback) {

            exec(successCallback, failureCallback, 'nativemap', 'startMap', []);
        }
    }


    module.exports = nativemap;

//cordova.define("cordova/plugin/gpsDetectionPlugin", gpsDetect);

//});