/*
* Author : LiJiqqi
* Date : 2020/8/19
*/


import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:flutter_webview_plugin_example/main.dart';

class PageTransitionDemo extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return PageTransitionDemoState();
  }

}

class PageTransitionDemoState extends State<PageTransitionDemo> {

  final selectedUrl = 'https://www.jd.com';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      color: Colors.lightBlueAccent,
      width: size.width,height: size.height,
      child: WebviewScaffold(
        /// in Debug mode,the first init webview page at slide/scale transition,will display misalignment
        /// after that will be display properly.
        ///
        /// in Profile/Release mode, will always display properly.
        transitionType: switcher ? TransitionType.Scale : TransitionType.Slide,
        url: selectedUrl,
        withJavascript: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
    );
  }
}


const bool switcher = false;

class DemoPageRouteBuilder extends PageRouteBuilder{
  final Widget page;

  DemoPageRouteBuilder(this.page)
      :super(
      pageBuilder:(ctx,animation,secondaryAnimation)=>page,
      opaque:false,
      transitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder:(ctx,animation,secondaryAnimation,child)
      => switcher ?
      ScaleTransition(
        scale: Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
            parent: animation,curve: Curves.fastOutSlowIn
        )),
        child: child,
      )
          :
      SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1.0,0.0),
          end: const Offset(0.0,0.0),
        ).animate(CurvedAnimation(
            parent: animation,curve: Curves.fastOutSlowIn
        )),
        child: child,
      )
  );
}