import 'dart:io';
import 'dart:async';
import 'dart:ui' as Ui;
import 'package:web_socket_channel/io.dart';
import 'package:Scribbleasy/board.dart';
import 'package:Scribbleasy/misc.dart';
import 'package:Scribbleasy/exceptions.dart';

class Connection {
  String _name;
  StreamController<Data> incoming = StreamController.broadcast();
  var channel;

  Connection(String ip, int port, this._name) {
    try {
      channel = IOWebSocketChannel.connect(
          'ws://${ip}:${port}/connect?username=${_name}');
      channel.stream.listen((data) => _handleMsg(data));
    } catch (e) {
      throw ConnectionFailureException();
    }
  }

  void _handleMsg(String data) {
    Data received = Data.fromString(data);
    incoming.add(received);
  }

  void sendData(Data data) {
    channel.sink.add(data.toString());
  }
}
