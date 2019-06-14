package com.flutter_webview_plugin;

import android.app.Activity;

import org.junit.Before;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.mockito.Spy;

import io.flutter.plugin.common.ErrorLogResult;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

import static org.mockito.Mockito.verify;

public class FlutterWebviewPluginTest {

    @Mock
    Activity mockActivity;

    MethodCall mockMethodCall;
    MethodChannel.Result mockResult;

    @Spy
    FlutterWebviewPlugin flutterWebviewPlugin = new FlutterWebviewPlugin(mockActivity, mockActivity);

    @Before
    public void setUp() {
        MockitoAnnotations.initMocks(this);
    }

    @Test
    public void shouldInvokeClose() {
        mockMethodCall = new MethodCall("close", null);
        mockResult = new ErrorLogResult("");
        flutterWebviewPlugin.onMethodCall(mockMethodCall, mockResult);
        verify(flutterWebviewPlugin).close(mockMethodCall, mockResult);

    }
}