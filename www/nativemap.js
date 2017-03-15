//cordova.define('com.webfit.nativemap.nativemap', function(require, exports, module) {
if (typeof cordova !== 'undefined') {
    var exec = require('cordova/exec');

    var nativemap = {

        startMap : function(successCallback, failureCallback) {

            exec(successCallback, failureCallback, 'nativemap', 'startListen', []);
        }
    }


    module.exports = nativemap;
}
else
{
var nativemap = {

        startMap : function(successCallback, failureCallback) {

            console.log("not work on navigator");
        }
    }


    module.exports = nativemap;
}
}
//cordova.define("cordova/plugin/gpsDetectionPlugin", gpsDetect);

//});