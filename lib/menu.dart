import 'package:flutter/material.dart';
import 'package:Scribbleasy/network.dart';
import 'package:Scribbleasy/misc.dart';

class Login extends StatefulWidget {
  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  String _nickname = null;
  String _ip = null;
  int _port = null;
  Connection _connection = null;

  void _setNickname(String name) {
    _nickname = name;
  }

  void _setIp(String ip) {
    _ip = ip;
  }

  void _setPort(String port) {
    _port = int.parse(port);
  }

  void _connect() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) =>
            SessionList(_ip = ip, _port = port, _nickname = _nickname),
      ),
    );
  }

  Widget build(BuildContext context) {
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
      onPressed: () => _connect(),
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
