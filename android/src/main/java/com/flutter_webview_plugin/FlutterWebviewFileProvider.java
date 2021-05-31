package com.flutter_webview_plugin;

import androidx.core.content.FileProvider;

/**
 * Created by Konoha on 15/08/2020
 *
 * Providing a custom {@code FileProvider} prevents manifest {@code <provider>} name collisions.
 *
 * <p>See https://developer.android.com/guide/topics/manifest/provider-element.html for details.
 */
public class FlutterWebviewFileProvider extends FileProvider {
}
