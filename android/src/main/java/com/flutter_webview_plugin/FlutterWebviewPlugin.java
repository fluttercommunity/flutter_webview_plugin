package com.flutter_webview_plugin;


import android.app.Activity;
import android.content.Context;
import android.content.Intent;
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
    private final int WEBVIEW_ACTIVITY_CODE = 1;

    private Activity activity;
    private WebviewManager webViewManager;
    public static MethodChannel channel;
    private static final String CHANNEL_NAME = "flutter_webview_plugin";

    public static void registerWith(PluginRegistry.Registrar registrar) {
        channel = new MethodChannel(registrar.messenger(), CHANNEL_NAME);
        FlutterWebviewPlugin instance = new FlutterWebviewPlugin((Activity) registrar.activity());
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
            default:
                result.notImplemented();
                break;
        }
    }

    private void openUrl(MethodCall call, MethodChannel.Result result) {
        if ((boolean) call.argument("fullScreen") && !(boolean) call.argument("hidden")) {
            Intent intent = new Intent(activity, WebviewActivity.class);
            intent.putExtra(WebviewActivity.URL_KEY, (String) call.argument("url"));
            intent.putExtra(WebviewActivity.WITH_JAVASCRIPT_KEY, (boolean) call.argument("withJavascript"));
            intent.putExtra(WebviewActivity.CLEAR_CACHE_KEY, (boolean) call.argument("clearCache"));
            intent.putExtra(WebviewActivity.CLEAR_COOKIES_KEY, (boolean) call.argument("clearCookies"));
            activity.startActivityForResult(intent, WEBVIEW_ACTIVITY_CODE);
        } else {
            if (webViewManager == null) {
                webViewManager = new WebviewManager(activity);
            }

            Map<String, Number> rc = call.argument("rect");
            if (rc != null) {
                FrameLayout.LayoutParams params = new FrameLayout.LayoutParams(
                        dp2px(activity, rc.get("width").intValue()), dp2px(activity, rc.get("height").intValue()));
                params.setMargins(dp2px(activity, rc.get("left").intValue()), dp2px(activity, rc.get("top").intValue()),
                        0, 0);
                activity.addContentView(webViewManager.webView, params);
            } else if (!(boolean) call.argument("hidden")) {
                activity.setContentView(webViewManager.webView);
            }

            webViewManager.openUrl((boolean) call.argument("withJavascript"),
                    (boolean) call.argument("clearCache"),
                    (boolean) call.argument("hidden"),
                    (boolean) call.argument("clearCookies"),
                    (String) call.argument("userAgent"),
                    (String) call.argument("url")
            );
        }
        result.success(null);
    }

    private void close(MethodCall call, MethodChannel.Result result) {
        if (webViewManager != null) {
            webViewManager.close(call, result);
            webViewManager = null;
        }
    }

    private void eval(MethodCall call, final MethodChannel.Result result) {
        if (webViewManager != null) {
            webViewManager.eval(call, result);
        }
    }

    private static int dp2px(Context context, float dp) {
        final float scale = context.getResources().getDisplayMetrics().density;
        return (int) (dp * scale + 0.5f);
    }
}
