/// A message that was sent by JavaScript code running in a [WebView].

class JavascriptMessage {
  /// Constructs a JavaScript message object.
  ///
  /// The `channel` parameter must not be null.
  /// The `message` parameter must not be null.
  const JavascriptMessage(this.channel, this.message)
      : assert(message != null, channel != null);

  /// The contents of the channel that was sent by the JavaScript code.
  final String channel;

  /// The contents of the message that was sent by the JavaScript code.
  final String message;
}
