import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter WebView Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Flutter WebView Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Instance of WebView plugin
  final FlutterWebViewPlugin flutterWebviewPlugin = new FlutterWebViewPlugin();

  // On destroy stream
  StreamSubscription _onDestroy;

  // On urlChanged stream
  StreamSubscription<String> _onUrlChanged;

  StreamSubscription<String> _onStateChanged;

  TextEditingController _urlCtrl =
      new TextEditingController(text: "http://github.com");

  TextEditingController _codeCtrl =
      new TextEditingController(text: "window.location.href");

  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  final _history = [];

  @override
  initState() {
    super.initState();

    _onStateChanged = flutterWebviewPlugin.stateChanged.listen((dynamic state) {
      if (mounted) {
        setState(() {
          _history.add("stateChanged: $state");
        });
      }
    });

    // Add a listener to on destroy WebView, so you can make came actions.
    _onDestroy = flutterWebviewPlugin.onDestroy.listen((_) {
      if (mounted) {
        // Actions like show a info toast.
        _scaffoldKey.currentState
            .showSnackBar(new SnackBar(content: new Text("Webview Destroyed")));
      }
    });

    // Add a listener to on url changed
    _onUrlChanged = flutterWebviewPlugin.onUrlChanged.listen((String url) {
      if (mounted) {
        setState(() {
          _history.add("onUrlChanged: $url");
        });
      }
    });
  }

  @override
  void dispose() {
    // Every listener should be canceled, the same should be done with this stream.
    _onDestroy?.cancel();
    _onUrlChanged?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text('Plugin example app'),
      ),
      body: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          new Container(
            padding: const EdgeInsets.all(24.0),
            child: new TextField(controller: _urlCtrl),
          ),
          new RaisedButton(
            onPressed: () {
              flutterWebviewPlugin.launch(_urlCtrl.text,
                  fullScreen: false,
                  rect: new Rect.fromLTWH(
                      0.0, 0.0, MediaQuery.of(context).size.width, 300.0));
            },
            child: new Text("Open Webview (rect)"),
          ),
          new RaisedButton(
            onPressed: () {
              flutterWebviewPlugin.launch(_urlCtrl.text, hidden: true);
            },
            child: new Text("Open 'hidden' Webview"),
          ),
          new RaisedButton(
            onPressed: () {
              flutterWebviewPlugin.launch(_urlCtrl.text, fullScreen: true);
            },
            child: new Text("Open Fullscreen Webview"),
          ),
          new Container(
            padding: const EdgeInsets.all(24.0),
            child: new TextField(controller: _codeCtrl),
          ),
          new RaisedButton(
            onPressed: () {
              Future<String> future =
                  flutterWebviewPlugin.evalJavascript(_codeCtrl.text);
              future.then((String result) {
                setState(() {
                  _history.add("eval: $result");
                });
              });
            },
            child: new Text("Eval some javascript"),
          ),
          new RaisedButton(
            onPressed: () {
              _history.clear();
              flutterWebviewPlugin.close();
            },
            child: new Text("Close"),
          ),
          new Text(_history.join("\n"))
        ],
      ),
    );
  }
}
