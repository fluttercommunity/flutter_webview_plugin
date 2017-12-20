package com.flutter_webview_plugin;

import android.app.Activity;
import android.os.Build;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.CookieManager;
import android.webkit.ValueCallback;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

/**
 * Created by lejard_h on 20/12/2017.
 */

class WebviewManager {

    Activity activity;
    WebView webView;

    WebviewManager(Activity activity) {
        this.activity = activity;
        this.webView = new WebView(activity);
        WebViewClient webViewClient = new BrowserClient();
        webView.setWebViewClient(webViewClient);
    }



    private void clearCookies() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            CookieManager.getInstance().removeAllCookies(new ValueCallback<Boolean>() {
                @Override
                public void onReceiveValue(Boolean aBoolean) {

                }
            });
        } else {
            CookieManager.getInstance().removeAllCookie();
        }
    }

    private void clearCache() {
        webView.clearCache(true);
        webView.clearFormData();
    }

    void openUrl(boolean withJavascript, boolean clearCache, boolean hidden, boolean clearCookies, String userAgent, String url) {
        webView.getSettings().setJavaScriptEnabled(withJavascript);

        if (clearCache) {
            clearCache();
        }

        if (hidden) {
            webView.setVisibility(View.INVISIBLE);
        }

        if (clearCookies) {
            clearCookies();
        }

        if (userAgent != null) {
            webView.getSettings().setUserAgentString(userAgent);
        }

        webView.loadUrl(url);
    }

    void close(MethodCall call, MethodChannel.Result result) {
        if (View.VISIBLE == webView.getVisibility()) {
            ViewGroup vg = (ViewGroup) (webView.getParent());
            vg.removeView(webView);
        }
        webView = null;
        result.success(null);

        FlutterWebviewPlugin.channel.invokeMethod("onDestroy", null);
    }

    void eval(MethodCall call, final MethodChannel.Result result) {
        String code = call.argument("code");

        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.KITKAT) {
            webView.evaluateJavascript(code, new ValueCallback<String>() {
                @Override
                public void onReceiveValue(String value) {
                    result.success(value);
                }
            });
        } else {
            // TODO:
            webView.loadUrl(code);
        }
    }

}
