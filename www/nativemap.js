//cordova.define('com.webfit.nativemap.nativemap', function(require, exports, module) {

var exec = require('cordova/exec');

var nativemap = {

    startMap : function(successCallback, failureCallback) {

        exec(successCallback, failureCallback, 'nativemap', 'startListen', []);
    }
}


module.exports = nativemap;
//cordova.define("cordova/plugin/gpsDetectionPlugin", gpsDetect);

//});