import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:mocktail/mocktail.dart';

class MockMethodChannel extends Mock implements MethodChannel {}

void main() {
  group('Method channel invoke', () {
    group('returns null', () {
      late MockMethodChannel methodChannel;
      late FlutterWebviewPlugin webview;

      setUp(() {
        methodChannel = MockMethodChannel();
        webview = new FlutterWebviewPlugin.private(methodChannel);
        when(() => methodChannel.invokeMethod(any(), any()))
            .thenAnswer((_) => Future.value(null));
      });

      test('Should invoke close', () async {
        webview.close();
        verify(() => methodChannel.invokeMethod('close')).called(1);
      });
      test('Should invoke reload', () async {
        when(() => methodChannel.invokeMethod(any()))
            .thenAnswer((_) => Future.value(null));

        webview.reload();
        verify(() => methodChannel.invokeMethod('reload')).called(1);
      });
      test('Should invoke goBack', () async {
        webview.goBack();
        verify(() => methodChannel.invokeMethod('back')).called(1);
      });
      test('Should invoke goForward', () async {
        webview.goForward();
        verify(() => methodChannel.invokeMethod('forward')).called(1);
      });
      test('Should invoke hide', () async {
        webview.hide();
        verify(() => methodChannel.invokeMethod('hide')).called(1);
      });
      test('Should invoke show', () async {
        webview.show();
        verify(() => methodChannel.invokeMethod('show')).called(1);
      });
    });

    group('returns bool', () {
      late MockMethodChannel methodChannel;
      late FlutterWebviewPlugin webview;

      setUp(() {
        methodChannel = MockMethodChannel();
        webview = new FlutterWebviewPlugin.private(methodChannel);
        when(() => methodChannel.invokeMethod(any(), any()))
            .thenAnswer((_) => Future.value(true));
      });

      test('Should invoke canGoBack', () async {
        webview.canGoBack();
        verify(() => methodChannel.invokeMethod('canGoBack')).called(1);
      });
      test('Should invoke canGoForward', () async {
        webview.canGoForward();
        verify(() => methodChannel.invokeMethod('canGoForward')).called(1);
      });
    });
  });
}
