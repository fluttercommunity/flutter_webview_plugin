package com.flutter_webview_plugin;

import android.content.Intent;
import android.app.Activity;
import android.content.Context;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.PluginRegistry;

/**
 * FlutterWebviewPlugin
 */
public class FlutterWebviewPlugin implements MethodCallHandler {
  private FlutterActivity activity;
  public static MethodChannel channel;
  private final int WEBVIEW_ACTIVITY_CODE = 1;
  private static final String CHANNEL_NAME = "flutter_webview_plugin";

  public static void registerWith(PluginRegistry.Registrar registrar) {
    channel = new MethodChannel(registrar.messenger(), CHANNEL_NAME);
    FlutterWebviewPlugin instance = new FlutterWebviewPlugin((FlutterActivity) registrar.activity());
    channel.setMethodCallHandler(instance);
  }

  private FlutterWebviewPlugin(FlutterActivity activity) {
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
      default:
        result.notImplemented();
        break;
    }
  }

  private void openUrl(MethodCall call, MethodChannel.Result result) {
    Intent intent = new Intent(activity, WebviewActivity.class);

    intent.putExtra(WebviewActivity.URL_KEY, (String) call.argument("url"));
    intent.putExtra(WebviewActivity.WITH_JAVASCRIPT_KEY, (boolean) call.argument("withJavascript"));
    intent.putExtra(WebviewActivity.CLEAR_CACHE_KEY, (boolean) call.argument("clearCache"));
    intent.putExtra(WebviewActivity.CLEAR_COOKIES_KEY, (boolean) call.argument("clearCookies"));

    activity.startActivityForResult(intent, WEBVIEW_ACTIVITY_CODE);

    result.success(null);
  }

  private void close(MethodCall call, MethodChannel.Result result) {
    activity.finishActivity(WEBVIEW_ACTIVITY_CODE);
    result.success(null);
  }
}

