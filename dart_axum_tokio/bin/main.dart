import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dart_axum_tokio_sever/dart_axum_tokio_sever.dart';

Future<void> main(List<String> arguments) async {
  if (arguments.isNotEmpty && arguments.first == 'build') {
    print('build only');
    return;
  }

  await RustLib.init();

  final success = await startServer(
    dartGetCallback: () => utf8.encode('Hello Dart!'),
    // dartPostCallback: (Uint8List body) =>
    //     utf8.encode(jsonEncode(jsonDecode(utf8.decode(body)))),
    dartPostCallback: (Uint8List body) async =>
      await rustJsonEncode(v: await rustJsonDecode(s: body)),
  );
  if (success) {
    print('Dart: server running...');
    Timer(Duration(hours: 1), () {});
  }
}
