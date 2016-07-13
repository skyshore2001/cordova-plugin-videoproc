var argscheck = require('cordova/argscheck'),
    channel = require('cordova/channel'),
    utils = require('cordova/utils'),
    exec = require('cordova/exec'),
    cordova = require('cordova');

var VideoProc = {
	compose: function(videoFile, opt, onSuccess, onError) {
		argscheck.checkArgs('SOFF', 'VideoProc.compose', arguments);
		exec(onSuccess, onError, "VideoProc", "compose", [ videoFile, opt ]);
	}
};

module.exports = VideoProc;