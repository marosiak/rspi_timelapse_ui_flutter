import 'package:web_socket_channel/web_socket_channel.dart';

import 'platform/stub_ws.dart'
if (dart.library.io) 'platform/io_ws.dart'
if (dart.library.html) 'platform/html_ws.dart';

abstract class BaseWebsocket {
  final String url;

  BaseWebsocket(this.url);
  WebSocketChannel getWebSocketChannel();
}

class Websocket {
  final WebsocketImpl _websocket;
  final String url;
  Websocket(this.url) : _websocket = WebsocketImpl(url);

  WebSocketChannel getWebSocketChannel() {
    return _websocket.getWebSocketChannel();
  }
}
