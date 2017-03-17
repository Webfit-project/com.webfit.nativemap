var exec = require('cordova/exec');

var nativemap = {

    startMap : function(center,iconList,route,successCallback, failureCallback) {

        exec(successCallback, failureCallback, 'nativemap', 'startMap', [center,iconList,route]);
    }
}


module.exports = nativemap;