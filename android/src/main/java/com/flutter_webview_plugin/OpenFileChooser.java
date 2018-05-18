package com.flutter_webview_plugin;

import android.webkit.ValueCallback;

/**
 * Created by lejard_h on 20/12/2017.
 */
public interface OpenFileChooser {
    void setUploadMessage(ValueCallback valueCallback);
    void setUploadMessageAboveL(ValueCallback valueCallback);
}