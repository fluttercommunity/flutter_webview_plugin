package com.flutter_webview_plugin;

import android.app.Activity;
import android.content.Context;

import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.mockito.Spy;
import org.robolectric.RobolectricTestRunner;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

import static org.junit.Assert.assertEquals;

@RunWith(RobolectricTestRunner.class)
public class FlutterWebviewPluginTest {

    @Mock
    Activity mockActivity;
    @Mock
    MethodCall mockMethodCall;
    @Mock
    MethodChannel.Result mockResult;

    @Spy
    FlutterWebviewPlugin flutterWebviewPlugin = new FlutterWebviewPlugin(mockActivity, mockActivity);

    @Before
    public void setUp() {
        MockitoAnnotations.initMocks(this);
    }

    @Test
    public void sampleTest() {
        assertEquals(true, true);
    }

    @Test
    public void shouldDo() {
        flutterWebviewPlugin.onMethodCall(null, null);

    }
}