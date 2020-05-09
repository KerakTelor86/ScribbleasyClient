import 'dart:io';
import 'dart:async';
import 'dart:ui' as Ui;
import 'package:web_socket_channel/io.dart';
import 'package:Scribbleasy/board.dart';
import 'package:Scribbleasy/misc.dart';

class Connection {
  String _name = 'test2';
  final BoardState _boardState;
  var channel;
  int type = 1;

  Connection(String ip, int port, this._boardState) {
    channel = IOWebSocketChannel.connect(
        'ws://${ip}:${port}/connect?username=${_name}');
    channel.stream.listen((data) => _handleMsg(data));
    if (type == 0) {
      create('test', 123, 2);
    } else {
      connect(0, 123);
    }
  }

  void _handleMsg(String data) {
    Data received = Data.fromString(data);
    if (received['type'] == 'sessionData') {
      Ui.Offset offset = Ui.Offset(received['dx'], received['dy']);
      Ui.Size size = Ui.Size(received['width'], received['height']);
      _boardState.addPoint(offset, size, received['scale'], true);
    }
  }

  void sendData(String data) {
    channel.sink.add(data);
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
