/// A message that was sent by JavaScript code running in a [WebView].

class JavascriptMessage {
  /// Constructs a JavaScript message object.
  ///
  /// The `message` parameter must not be null.
  const JavascriptMessage(this.message);

  /// The contents of the message that was sent by the JavaScript code.
  final String message;
}
