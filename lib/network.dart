import 'dart:io';
import 'dart:async';
import 'dart:ui' as Ui;
import 'package:web_socket_channel/io.dart';
import 'package:Scribbleasy/board.dart';
import 'package:Scribbleasy/misc.dart';

class Connection {
  String _name;
  StreamController<Data> incoming = StreamController.broadcast();
  var channel;

  Connection(String ip, int port, this._name) {
    channel = IOWebSocketChannel.connect(
        'ws://${ip}:${port}/connect?username=${_name}');
    channel.stream.listen((data) => _handleMsg(data));
  }

  void _handleMsg(String data) {
    Data received = Data.fromString(data);
    incoming.add(received);
  }

  void sendData(Data data) {
    channel.sink.add(data.toString());
  }

  void create(String name, int pw, int usr) {
    Data data = Data();
    data['name'] = name;
    data['pwHash'] = pw;
    data['maxUsers'] = usr;
    data['type'] = 'createSession';
    channel.sink.add(data.toString());
  }

  void connect(int id, int pw) {
    Data data = Data();
    data['id'] = id;
    data['pwHash'] = pw;
    data['type'] = 'joinSession';
    channel.sink.add(data.toString());
  }
}
