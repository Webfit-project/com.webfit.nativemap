cordova.define('com.webfit.nativemap', function(require, exports, module) {
    
    var exec = require('cordova/exec');

    var nativemap = function() {   };

    nativemap.prototype.startMap = function(successCallback, failureCallback) {
        
    	exec(successCallback, failureCallback, 'nativemap', 'startListen', []);
    };
	

    
	if(!window.plugins) {
    window.plugins = {};
}
    
 
if (!window.plugins.nativemap) {
    window.plugins.nativemap = new nativemap();
}
 module.exports = nativemap;
	//cordova.define("cordova/plugin/gpsDetectionPlugin", gpsDetect);
	
});