import 'package:flutter/material.dart';
import 'package:Scribbleasy/list.dart';
import 'package:Scribbleasy/network.dart';
import 'package:Scribbleasy/misc.dart';
import 'package:Scribbleasy/exceptions.dart';

class Login extends StatefulWidget {
  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  String _nickname = null;
  String _ip = null;
  int _port = null;
  Connection _connection = null;
  BuildContext currentContext;

  void _setNickname(String name) {
    _nickname = name;
  }

  void _setIp(String ip) {
    _ip = ip;
  }

  void _setPort(String port) {
    _port = int.parse(port);
  }

  void _handleMsg(Data data) {
    if (data['type'] != 'auth') {
      return;
    }
    if (data['auth'] == 1) {
      Navigator.push(
        currentContext,
        MaterialPageRoute(
          builder: (BuildContext context) =>
              SessionList(connection: _connection),
        ),
      );
    } else {
      showDialog(
        context: currentContext,
        builder: (context) {
          return AlertDialog(
            title: Text('Connection failure'),
            content: Text('Server full.'),
            actions: <Widget>[
              FlatButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _connect(BuildContext context) {
    try {
      _connection = Connection(_ip, _port, _nickname);
      _connection.incoming.stream.listen((data) => _handleMsg(data));
    } on ConnectionFailureException catch (e) {
      showDialog(
        context: currentContext,
        builder: (context) {
          return AlertDialog(
            title: Text('Connection failure'),
            content: Text('Recheck server IP and port.'),
            actions: <Widget>[
              FlatButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    currentContext = context;
    final nameField = TextField(
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Nickname',
      ),
      onChanged: _setNickname,
    );
    final ipField = TextField(
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Server IP',
      ),
      onChanged: _setIp,
    );
    final portField = TextField(
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Server Port',
      ),
      keyboardType: TextInputType.number,
      onChanged: _setPort,
    );
    final connectButton = RaisedButton(
      onPressed: () => _connect(context),
      child: Text('Connect'),
    );
    return Row(
      children: <Widget>[
        Expanded(
          flex: 2,
          child: Container(),
        ),
        Expanded(
          flex: 6,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              nameField,
              SizedBox(height: 10),
              ipField,
              SizedBox(height: 10),
              portField,
              SizedBox(height: 10),
              connectButton,
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(),
        ),
      ],
    );
  }
}
