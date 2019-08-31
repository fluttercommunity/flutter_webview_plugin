package com.flutter_webview_plugin;

import android.os.Handler;
import android.os.Message;
import android.webkit.JavascriptInterface;

import java.util.HashMap;
import java.util.Map;


public final class InJavaScriptLocalObj {
    @JavascriptInterface
    public void showSource(String html) {
        Message message = new Message();
        message.obj = html;
        handler.sendMessage(message);
    }

    private Handler handler = new Handler() {
        @Override
        public void handleMessage(Message msg) {
            super.handleMessage(msg);
            String html = (String) msg.obj;
            Map<String, Object> data = new HashMap<>();
            data.put("html", html);
            FlutterWebviewPlugin.channel.invokeMethod("onHtmlCallback", data);
        }
    };
}
