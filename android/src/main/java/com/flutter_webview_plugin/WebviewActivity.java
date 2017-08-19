package com.flutter_webview_plugin;

import android.app.Activity;
import android.os.Bundle;
import android.webkit.CookieManager;
import android.webkit.ValueCallback;
import android.webkit.WebView;
import android.webkit.WebViewClient;

/**
 * Created by lejard_h on 23/04/2017.
 */

public class WebviewActivity extends Activity {

    static public final String URL_KEY = "URL";
    static public final String CLEAR_CACHE_KEY = "CLEAR_CACHE";
    static public final String CLEAR_COOKIES_KEY = "CLEAR_COOKIES";
    static public final String WITH_JAVASCRIPT_KEY = "WITH_JAVASCRIPT";

    private WebView webView;

    public WebviewActivity() {
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        webView = initWebview();
        setContentView(webView);
        clearCookies();
        clearCache();
        setWebViewClient();
        loadUrl();
    }

    protected WebView initWebview() {
        return new WebView(this);
    }

    protected void clearCookies() {
        if (getIntent().getBooleanExtra(CLEAR_COOKIES_KEY, false)) {
            CookieManager.getInstance().removeAllCookies(new ValueCallback<Boolean>() {
                @Override
                public void onReceiveValue(Boolean aBoolean) {

                }
            });
        }
    }

    protected void clearCache() {
        if (getIntent().getBooleanExtra(CLEAR_CACHE_KEY, false)) {
            webView.clearCache(false);
            webView.clearFormData();
        }
    }

    protected WebViewClient setWebViewClient() {
        WebViewClient webViewClient = new WebViewClient();
        webView.setWebViewClient(webViewClient);
        return webViewClient;
    }

    protected void loadUrl() {
        webView.getSettings().setJavaScriptEnabled(getIntent().getBooleanExtra(WITH_JAVASCRIPT_KEY, true));
        webView.loadUrl(getIntent().getStringExtra(URL_KEY));
    }

    @Override
    protected void onDestroy() {
        FlutterWebviewPlugin.channel.invokeMethod("onDestroy", null);
        super.onDestroy();
    }

    @Override
    public void onBackPressed() {
        if(webView.canGoBack()){
            webView.goBack();
            return;
        }
        FlutterWebviewPlugin.channel.invokeMethod("onBackPressed", null);
        super.onBackPressed();
    }
}