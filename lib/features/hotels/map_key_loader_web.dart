// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:async';
import 'dart:html' as html;

bool hasWebMapKey() {
  final meta = html.document.querySelector('meta[name="google-maps-api-key"]') as html.MetaElement?;
  final content = meta?.content ?? '';
  return content.trim().isNotEmpty;
}

bool _isLoaded() {
  final google = (html.window as dynamic).google;
  if (google == null) return false;
  return google.maps != null;
}

Future<bool> ensureGoogleMapsLoaded({required String apiKey}) async {
  if (_isLoaded()) return true;
  final hasMeta = hasWebMapKey();
  // If meta key exists, index.html loader will inject. Wait briefly for it.
  if (hasMeta) {
    for (var i = 0; i < 10; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 150));
      if (_isLoaded()) return true;
    }
  }

  // Otherwise, inject using the dart-define key.
  if (apiKey.isEmpty) return false;

  final completer = Completer<bool>();
  final script = html.ScriptElement()
    ..src = 'https://maps.googleapis.com/maps/api/js?key=$apiKey'
    ..async = true;
  script.onError.listen((_) {
    if (!completer.isCompleted) completer.complete(false);
  });
  script.onLoad.listen((_) {
    completer.complete(_isLoaded());
  });
  html.document.head?.append(script);

  // Fallback timeout
  unawaited(Future<void>.delayed(const Duration(seconds: 5)).then((_) {
    if (!completer.isCompleted) completer.complete(_isLoaded());
  }));

  return completer.future;
}
