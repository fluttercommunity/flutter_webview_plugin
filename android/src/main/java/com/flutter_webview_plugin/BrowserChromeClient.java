package com.flutter_webview_plugin;
import com.flutter_webview_plugin.OpenFileChooser;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Uri;
import android.webkit.ValueCallback;
import android.webkit.WebChromeClient;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by lejard_h on 20/12/2017.
 */

public class BrowserChromeClient extends WebChromeClient {

    public final static int FILE_CHOOSER_RESULT_CODE = 10000;
      OpenFileChooser activity;

    public BrowserChromeClient(Activity activity) {
        super();
        this.activity = ((OpenFileChooser)activity);
    }
   // For Android < 3.0
    public void openFileChooser(ValueCallback<Uri> valueCallback) {
        activity.setUploadMessage(valueCallback);
        openImageChooserActivity();
    }

    // For Android  >= 3.0
    public void openFileChooser(ValueCallback valueCallback, String acceptType) {
        activity.setUploadMessage(valueCallback);
        openImageChooserActivity();
    }

    //For Android  >= 4.1
    public void openFileChooser(ValueCallback<Uri> valueCallback, String acceptType, String capture) {
        activity.setUploadMessage(valueCallback);
        openImageChooserActivity();
    }

    // For Android >= 5.0
    @Override
    public boolean onShowFileChooser(WebView webView, ValueCallback<Uri[]> filePathCallback, WebChromeClient.FileChooserParams fileChooserParams) {
        activity.setUploadMessageAboveL(filePathCallback);
        openImageChooserActivity();
        return true;
    }
    private void openImageChooserActivity() {
        Intent i = new Intent(Intent.ACTION_GET_CONTENT);
        i.addCategory(Intent.CATEGORY_OPENABLE);
        i.setType("image/*");
        ((Activity)activity).startActivityForResult(Intent.createChooser(i, "Image Chooser"), FILE_CHOOSER_RESULT_CODE);
    }
}