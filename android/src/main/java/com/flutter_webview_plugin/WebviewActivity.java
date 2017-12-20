package com.flutter_webview_plugin;

import android.app.Activity;
import android.os.Bundle;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

/**
 * Created by lejard_h on 23/04/2017.
 */

public class WebviewActivity extends Activity implements MethodChannel.MethodCallHandler {

    static public final String URL_KEY = "URL";
    static public final String CLEAR_CACHE_KEY = "CLEAR_CACHE";
    static public final String CLEAR_COOKIES_KEY = "CLEAR_COOKIES";
    static public final String WITH_JAVASCRIPT_KEY = "WITH_JAVASCRIPT";
    static public final String USER_AGENT_KEY = "USER_AGENT";

    static WebviewManager webViewManager;

    public WebviewActivity() {
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        webViewManager = new WebviewManager(this);
        setContentView(webViewManager.webView);
        webViewManager.openUrl(getIntent().getBooleanExtra(WITH_JAVASCRIPT_KEY, true),
                getIntent().getBooleanExtra(CLEAR_CACHE_KEY, false),
                false,
                getIntent().getBooleanExtra(CLEAR_COOKIES_KEY, false),
                getIntent().getStringExtra(USER_AGENT_KEY),
                getIntent().getStringExtra(URL_KEY)
                );
    }

    @Override
    protected void onDestroy() {
        FlutterWebviewPlugin.channel.invokeMethod("onDestroy", null);
        super.onDestroy();
    }

    @Override
    public void onBackPressed() {
        if(webViewManager.webView.canGoBack()){
            webViewManager.webView.goBack();
            return;
        }
        FlutterWebviewPlugin.channel.invokeMethod("onBackPressed", null);
        super.onBackPressed();
    }

    @Override
    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        switch (call.method) {
            case "eval":
                webViewManager.eval(call, result);
                break;
            default:
                result.notImplemented();
                break;
        }
    }
}