
import 'package:test/test.dart';

void main() {
  test('Cookies parsed', () {
    Map<String, String> cookiesPrepared = {
    'username': 'John Doe',
    'expires': 'Thu, 18 Dec 2013 12:00:00 UTC',
    'path': '/usr/apache2/www/',
    'timestamp': '57246556',
    'cookieWithDoubleQuotes': 'fe23\"·dsd',
    'cookieWithSimpleQuotes': "rrer8974\'ve76\'",
    '..///\\\\**-++!\"··%&((': '/+-*()!"·?¿¿`+ç´.-',
    'empty': ''
  };
  
  String cookies = '';
  int i = 0;
  
  cookiesPrepared.forEach((k, v) {
    cookies += '$k=$v';
    i++;
    if (i < cookiesPrepared.length)
      cookies += '; ';
  });
  
  var cookiesString = '"$cookies"';
  final Map<String, String> cookiesParsed = {};

  final RegExp escapeInternalQuotes = RegExp(r'(?<=").+?(?=")');

  cookiesString = escapeInternalQuotes.allMatches(cookiesString).map((m) => m.group(0)).join('"');

  cookiesString
    .split('; ')
    .where((c) => c.isNotEmpty)
    .forEach((cookie) => 
              cookiesParsed[cookie.split('=').first] = cookie.split('=').last
            );

  expect(cookiesPrepared, cookiesParsed);
  });
}