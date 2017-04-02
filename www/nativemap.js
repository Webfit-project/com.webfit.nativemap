var exec = require('cordova/exec');

var nativemap = {

    startMap : function(center,iconList,route,zoom,successCallback, failureCallback) {
        exec(successCallback, failureCallback, 'nativemap', 'startMap', [center,iconList,route,zoom]);
    },
    
    getCacheSize: function(successCallback, failureCallback) {
        exec(successCallback, failureCallback, 'nativemap', 'getCacheSize', []);
    },

    clearCache: function(successCallback, failureCallback) {
        exec(successCallback, failureCallback, 'nativemap', 'clearCache', []);
    }
}


module.exports = nativemap;