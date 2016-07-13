var browser = require('cordova/platform');
var cordova = require('cordova');

module.exports = {
    compose: function (onSuccess, onError, args) {
        setTimeout(function () {
			var videoFile = args[0];
			var opt = args[1];
            onSuccess(videoFile);
        }, 0);
    }
};

require("cordova/exec/proxy").add("VideoProc", module.exports);