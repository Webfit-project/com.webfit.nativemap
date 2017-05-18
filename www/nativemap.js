var exec = require('cordova/exec');

var nativemap = {

    startMap : function(center,iconList,route,myroute,zoom,btfollow,btcenter,successCallback, failureCallback) {

        exec(successCallback, failureCallback, 'nativemap', 'startMap', [center,iconList,route,myroute,zoom,btfollow,btcenter]);
    },

    getCacheSize: function(successCallback, failureCallback) {
        exec(successCallback, failureCallback, 'nativemap', 'getCacheSize', []);
    },

    clearCache: function(successCallback, failureCallback) {
        exec(successCallback, failureCallback, 'nativemap', 'clearCache', []);
    }
}


module.exports = nativemap;