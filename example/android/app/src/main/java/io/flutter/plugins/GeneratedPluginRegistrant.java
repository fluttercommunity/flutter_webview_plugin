package io.flutter.plugins;

// import io.flutter.plugin.common.PluginRegistry;
import androidx.annotation.NonNull;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.shim.ShimPluginRegistry;
import com.flutter_webview_plugin.FlutterWebviewPlugin;

/**
 * Generated file. Do not edit.
 */
// public final class GeneratedPluginRegistrant {
//   public static void registerWith(PluginRegistry registry) {
//     if (alreadyRegisteredWith(registry)) {
//       return;
//     }
//     FlutterWebviewPlugin.registerWith(registry.registrarFor("com.flutter_webview_plugin.FlutterWebviewPlugin"));
//   }

//   private static boolean alreadyRegisteredWith(PluginRegistry registry) {
//     final String key = GeneratedPluginRegistrant.class.getCanonicalName();
//     if (registry.hasPlugin(key)) {
//       return true;
//     }
//     registry.registrarFor(key);
//     return false;
//   }
// }

public final class GeneratedPluginRegistrant {
  public static void registerWith(@NonNull FlutterEngine flutterEngine) {
      ShimPluginRegistry shimPluginRegistry = new ShimPluginRegistry(flutterEngine);
      FlutterWebviewPlugin.registerWith(shimPluginRegistry.registrarFor("com.flutter_webview_plugin.FlutterWebviewPlugin"));
  }
}
