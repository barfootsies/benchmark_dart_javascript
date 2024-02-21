import 'dart:convert';
import 'dart:io';

void main() async {
  const host = '127.0.0.1';
  const port = 3000;

  print('Starting server at $host:$port');

  final server = await HttpServer.bind(host, port);
  await server.forEach((HttpRequest request) async {
    switch (request.method) {
      case 'GET':
        request.response.write('Hello World');
        request.response.close();
        break;
      case 'POST':
        request.response
            .addStream(encoder.bind(jsonDecoder.bind(decoder.bind(request))))
            .then((_) => request.response.close());
        break;
      default:
        request.response.close();
        break;
    }
  });
}

final encoder = JsonUtf8Encoder();
final jsonDecoder = JsonDecoder();
final decoder = Utf8Decoder();
