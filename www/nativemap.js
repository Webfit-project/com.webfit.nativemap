var exec = require('cordova/exec');

var nativemap = {

    requestWS: function(successCallback,failureCallback) {
        exec(successCallback, failureCallback, 'nativemap', 'requestWES', []);
    },

    hasWESS: function(successCallback,failureCallback) {
        exec(successCallback, failureCallback, 'nativemap', 'hasWES', []);
    },

    startMap : function(center,iconList,route,myroute,zoom,btfollow,btcenter,tracking,successCallback, failureCallback) {

        exec(successCallback, failureCallback, 'nativemap', 'startMap', [center,iconList,route,myroute,zoom,btfollow,btcenter,tracking]);
    },

    getCacheSize: function(successCallback, failureCallback) {
        exec(successCallback, failureCallback, 'nativemap', 'getCacheSize', []);
    },

    clearCache: function(successCallback, failureCallback) {
        exec(successCallback, failureCallback, 'nativemap', 'clearCache', []);
    }
}


module.exports = nativemap;