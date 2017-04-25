package com.flutter_webview_plugin;

import android.content.Intent;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * FlutterWebviewPlugin
 */
public class FlutterWebviewPlugin implements MethodCallHandler {
  private FlutterActivity activity;
  public static MethodChannel channel;
  private final int WEBVIEW_ACTIVITY_CODE = 1;
  private final String CHANNEL = "flutter_webview_plugin";

  public static FlutterWebviewPlugin register(FlutterActivity activity) {
    return new FlutterWebviewPlugin(activity);
  }

  private FlutterWebviewPlugin(FlutterActivity activity) {
    this.activity = activity;
    channel = new MethodChannel(activity.getFlutterView(), CHANNEL);
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    switch (call.method) {
      case "launch":
        openUrl(call, result);
        break;
      case "close":
        close(call, result);
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  private void openUrl(MethodCall call, Result result) {
    Intent intent = new Intent(activity, WebviewActivity.class);

    intent.putExtra(WebviewActivity.URL_KEY, (String) call.argument("url"));
    intent.putExtra(WebviewActivity.WITH_JAVASCRIPT_KEY, (boolean) call.argument("withJavascript"));
    intent.putExtra(WebviewActivity.CLEAR_CACHE_KEY, (boolean) call.argument("clearCache"));
    intent.putExtra(WebviewActivity.CLEAR_COOKIES_KEY, (boolean) call.argument("clearCookies"));

    activity.startActivityForResult(intent, WEBVIEW_ACTIVITY_CODE);

    result.success(null);
  }

  private void close(MethodCall call, Result result) {
    activity.finishActivity(WEBVIEW_ACTIVITY_CODE);
    result.success(null);
  }
}

