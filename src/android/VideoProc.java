package com.oliveche.videoproc;

import org.apache.cordova.CordovaWebView;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaInterface;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class VideoProc extends CordovaPlugin {
    public static final String TAG = "VideoProc";

    /**
     * Sets the context of the Command. This can then be used to do things like
     * get file paths associated with the Activity.
     *
     * @param cordova The context of the main Activity.
     * @param webView The CordovaWebView Cordova is running in.
     */
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
    }

    /**
     * Executes the request and returns PluginResult.
     *
     * @param action            The action to execute.
     * @param args              JSONArry of arguments for the plugin.
     * @param callbackContext   The callback id used when calling back into JavaScript.
     * @return                  True if the action was valid, false if not.
     */
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if ("compose".equals(action)) {
            final String videoFile = args.getString(0);
            final JSONObject opt = args.getJSONObject(1);
            final CallbackContext cb = callbackContext;

            cordova.getThreadPool().execute(new Runnable() {
                @Override
                public void run() {
                    try {
                        String file = compose(videoFile, opt);
                        cb.success(file);
                    } catch (Exception e) {
                        cb.error(e.getMessage());
                    }
                }
            });
        }
        else {
            return false;
        }
        return true;
    }

    protected String compose(String videoFile, JSONObject opt) throws Exception {
        // TODO: compose video, audio, image, text
        if (videoFile.isEmpty()) {
            throw new Exception("fail to find videoFile: " + videoFile);
        }
        Thread.sleep(2000);
        return videoFile;
    }
}
