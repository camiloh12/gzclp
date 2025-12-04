import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_static/shelf_static.dart';

/// Custom web server with CORS headers for SharedArrayBuffer support
///
/// Run this with: dart run web_server.dart
/// Then access the app at: http://localhost:8080
void main() async {
  // Middleware to add security headers for SharedArrayBuffer support
  Middleware addHeaders() {
    return createMiddleware(
      responseHandler: (Response response) {
        return response.change(headers: {
          'Cross-Origin-Opener-Policy': 'same-origin',
          'Cross-Origin-Embedder-Policy': 'require-corp',
          // Allow the app to load resources
          'Cross-Origin-Resource-Policy': 'cross-origin',
        });
      },
    );
  }

  final handler = Pipeline()
      .addMiddleware(addHeaders())
      .addMiddleware(logRequests())
      .addHandler(createStaticHandler(
        'build/web',
        defaultDocument: 'index.html',
      ));

  final server = await shelf_io.serve(handler, 'localhost', 8080);
  print('Serving at http://${server.address.host}:${server.port}');
  print('');
  print('📌 IMPORTANT: SharedArrayBuffers are now enabled!');
  print('   This should fix the database persistence issue.');
  print('');
  print('Press Ctrl+C to stop the server.');
}
