package com.flutter_webview_plugin;


import android.app.Activity;
import android.content.Context;
import android.graphics.Bitmap;
import android.os.Build;
import android.view.ViewGroup;
import android.view.View;
import android.webkit.CookieManager;
import android.webkit.ValueCallback;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.FrameLayout;

import java.util.HashMap;
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
  private WebView webView;
  public static MethodChannel channel;
  private static final String CHANNEL_NAME = "flutter_webview_plugin";

  public static void registerWith(PluginRegistry.Registrar registrar) {
    channel = new MethodChannel(registrar.messenger(), CHANNEL_NAME);
    FlutterWebviewPlugin instance = new FlutterWebviewPlugin((Activity)registrar.activity());
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

  private WebViewClient setWebViewClient() {
    WebViewClient webViewClient = new BrowserClient();
    webView.setWebViewClient(webViewClient);
    return webViewClient;
  }

  private void eval(String code, final MethodChannel.Result result) {
    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.KITKAT) {
      webView.evaluateJavascript(code, new ValueCallback<String>() {
        @Override
        public void onReceiveValue(String value) {
          result.success(value);
        }
      });
    } else {
      webView.loadUrl(code);
    }
  }

  // @Override
  protected void onDestroy() {
    FlutterWebviewPlugin.channel.invokeMethod("onDestroy", null);
  }

  // @Override
  public void onBackPressed() {
    if(webView.canGoBack()){
      webView.goBack();
      return;
    }
    FlutterWebviewPlugin.channel.invokeMethod("onBackPressed", null);
  }

  private static int dp2px(Context context, float dp) {
    final float scale = context.getResources().getDisplayMetrics().density;
    return (int) (dp * scale +0.5f);
  }

  private void openUrl(MethodCall call, MethodChannel.Result result) {
    if (webView == null) {
      webView = new WebView(activity);

      Map<String, Number> rc = call.argument("rect");
      if (rc != null) {
        FrameLayout.LayoutParams params = new FrameLayout.LayoutParams(
                dp2px(activity, rc.get("width").intValue()), dp2px(activity, rc.get("height").intValue()));
        params.setMargins(dp2px(activity, rc.get("left").intValue()), dp2px(activity, rc.get("top").intValue()),
                0, 0);
        activity.addContentView(webView, params);
      }
      else if (!(boolean) call.argument("hidden")) {
        activity.setContentView(webView);
      }

      setWebViewClient();
    }

    webView.getSettings().setJavaScriptEnabled((boolean) call.argument("withJavascript"));

    if ((boolean) call.argument("clearCache")) {
      clearCache();
    }

    if ((boolean) call.argument("hidden")) {
      webView.setVisibility(View.INVISIBLE);
    }

    if ((boolean) call.argument("clearCookies")) {
      clearCookies();
    }

    String userAgent = call.argument("userAgent");
    if (userAgent != null) {
      webView.getSettings().setUserAgentString(userAgent);
    }

    String url = (String) call.argument("url");
    webView.loadUrl(url);
    result.success(null);
  }

  private void close(MethodCall call, MethodChannel.Result result) {
    if (View.VISIBLE == webView.getVisibility()) {
      ViewGroup vg = (ViewGroup) (webView.getParent());
      vg.removeView(webView);
    }
    webView = null;
    result.success(null);

    FlutterWebviewPlugin.channel.invokeMethod("onDestroy", null);
  }

  private void eval(MethodCall call, final MethodChannel.Result result) {
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


  private class BrowserClient extends WebViewClient {
    private BrowserClient() {
      super();
    }

    @Override
    public void onPageStarted(WebView view, String url, Bitmap favicon) {
      super.onPageStarted(view, url, favicon);
      Map<String, Object> data = new HashMap<>();
      data.put("url", url);
      FlutterWebviewPlugin.channel.invokeMethod("onUrlChanged", data);

      data.put("type", "startLoad");
      FlutterWebviewPlugin.channel.invokeMethod("onState", data);
    }

    @Override
    public void onPageFinished(WebView view, String url) {
      super.onPageFinished(view, url);
      Map<String, Object> data = new HashMap<>();
      data.put("url", url);
      data.put("type", "finishLoad");
      FlutterWebviewPlugin.channel.invokeMethod("onState", data);
    }
  }
}
