import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;

final class WebSocketManager {
  //I want init one time connection so I using singleton pattern
  static final WebSocketManager instance = WebSocketManager();
  // ignore: non_constant_identifier_names
  String API_KEY = dotenv.env['API_KEY']!;
  String _fetchBaseUrl() {
    try {
      switch (kDebugMode) {
        case true:
          if (!kIsWeb) {
            // return "http://10.0.2.2:3000";
            return "wss://s13498.sgp1.piesocket.com/v3/1?api_key=jxPrafIAaT4CfeZtrLrrgVimpGeEhNfZ19wlLHLO&notify_self=1";
          }
          return "wss://rad-croquembouche-7794bb.netlify.app";

        default:
          //Product host url
          return "wss://splendorous-halva-0d648a.netlify.app";
      }
    } catch (e) {
      debugPrint(e.toString());
      return "";
    }
  }

  //Our socket object
  IO.Socket get socket => IO.io(
      _fetchBaseUrl(), IO.OptionBuilder().setTransports(['websocket']).build());

  initializeSocketConnection() {
    try {
      socket.connect();
      socket.onConnectError(
        (data) => debugPrint('websocket error $data'),
      );
      socket.onConnect((_) {
        debugPrint("Websocket connection success");
      });
    } catch (e) {
      debugPrint('websocket $e');
    }
  }

  disconnectFromSocket() {
    socket.disconnect();
    socket.onDisconnect((data) => debugPrint("Websocket disconnected"));
  }

  //Getting data from subscribed messages and calling onEvent callback
  void webSocketReceiver(String eventName, Function(dynamic) onEvent) {
    socket.on(eventName, (data) {
      onEvent(data);
    });
  }

  //Sending data to any channel
  void webSocketSender(String eventName, dynamic body) {
    socket.emit(eventName, body);
  }
}
