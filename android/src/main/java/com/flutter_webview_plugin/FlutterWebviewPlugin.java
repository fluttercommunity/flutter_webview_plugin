package com.flutter_webview_plugin;


import android.app.Activity;
import android.content.Context;
import android.graphics.Point;
import android.view.Display;
import android.widget.FrameLayout;

import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.PluginRegistry;

/**
 * FlutterWebviewPlugin
 */
public class FlutterWebviewPlugin implements MethodCallHandler {
    private Activity activity;
    private WebviewManager webViewManager;
    static MethodChannel channel;
    private static final String CHANNEL_NAME = "flutter_webview_plugin";

    public static void registerWith(PluginRegistry.Registrar registrar) {
        channel = new MethodChannel(registrar.messenger(), CHANNEL_NAME);
        FlutterWebviewPlugin instance = new FlutterWebviewPlugin(registrar.activity());
        channel.setMethodCallHandler(instance);
    }

    private FlutterWebviewPlugin(Activity activity) {
        this.activity = activity;
    }

    @Override
    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        switch (call.method) {
            case "launch":
                openUrl(call, result);
                break;
            case "close":
                close(call, result);
                break;
            case "eval":
                eval(call, result);
                break;
            case "resize":
                resize(call, result);
                break;
            case "reload":
                reload(call, result);
                break;
            case "back":
                back(call, result);
                break;
            case "forward":
                forward(call, result);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    private void openUrl(MethodCall call, MethodChannel.Result result) {
        boolean hidden = call.argument("hidden");
        String url = call.argument("url");
        String userAgent = call.argument("userAgent");
        boolean withJavascript = call.argument("withJavascript");
        boolean clearCache = call.argument("clearCache");
        boolean clearCookies = call.argument("clearCookies");
        boolean withZoom = call.argument("withZoom");
        boolean withLocalStorage = call.argument("withLocalStorage");

        if (webViewManager == null || webViewManager.closed == true) {
            webViewManager = new WebviewManager(activity);
        }

        FrameLayout.LayoutParams params = buildLayoutParams(call);

        activity.addContentView(webViewManager.webView, params);

        webViewManager.openUrl(withJavascript,
                clearCache,
                hidden,
                clearCookies,
                userAgent,
                url,
                withZoom,
                withLocalStorage
        );
        result.success(null);
    }

    private FrameLayout.LayoutParams buildLayoutParams(MethodCall call) {
        Map<String, Number> rc = call.argument("rect");
        FrameLayout.LayoutParams params;
        if (rc != null) {
            params = new FrameLayout.LayoutParams(
                    dp2px(activity, rc.get("width").intValue()), dp2px(activity, rc.get("height").intValue()));
            params.setMargins(dp2px(activity, rc.get("left").intValue()), dp2px(activity, rc.get("top").intValue()),
                    0, 0);
        } else {
            Display display = activity.getWindowManager().getDefaultDisplay();
            Point size = new Point();
            display.getSize(size);
            int width = size.x;
            int height = size.y;
            params = new FrameLayout.LayoutParams(width, height);
        }

        return params;
    }

    private void close(MethodCall call, MethodChannel.Result result) {
        if (webViewManager != null) {
            webViewManager.close(call, result);
            webViewManager = null;
        }
    }

    /** 
    * Navigates back on the Webview.
    */
    private void back(MethodCall call, MethodChannel.Result result) {
        if (webViewManager != null) {
            webViewManager.back(call, result);
        }
    }
    /** 
    * Navigates forward on the Webview.
    */
    private void forward(MethodCall call, MethodChannel.Result result) {
        if (webViewManager != null) {
            webViewManager.forward(call, result);
        }
    }

    /** 
    * Reloads the Webview.
    */
    private void reload(MethodCall call, MethodChannel.Result result) {
        if (webViewManager != null) {
            webViewManager.reload(call, result);
        }
    }
    private void eval(MethodCall call, final MethodChannel.Result result) {
        if (webViewManager != null) {
            webViewManager.eval(call, result);
        }
    }

    private void resize(MethodCall call, final MethodChannel.Result result) {
        if (webViewManager != null) {
            FrameLayout.LayoutParams params = buildLayoutParams(call);
            webViewManager.resize(params);
        }
        result.success(null);
    }

    private int dp2px(Context context, float dp) {
        final float scale = context.getResources().getDisplayMetrics().density;
        return (int) (dp * scale + 0.5f);
    }
}
