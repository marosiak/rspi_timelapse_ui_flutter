import 'package:web_socket_channel/web_socket_channel.dart';

import '../ws.dart';

class WebsocketImpl extends BaseWebsocket {
  WebsocketImpl(super.url);

  @override
  WebSocketChannel getWebSocketChannel() {
    throw Exception("not implemented");
  }
}