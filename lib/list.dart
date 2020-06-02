import 'package:flutter/material.dart';
import 'package:Scribbleasy/network.dart';
import 'package:Scribbleasy/misc.dart';

class SessionList extends StatefulWidget {
  final String nickname;
  final String ip;
  final int port;

  SessionList(
      {Key key,
      @required this.nickname,
      @required this.ip,
      @required this.port})
      : super(key: key);

  @override
  SessionListState createState() => SessionListState(ip, port, nickname);
}

class SessionListState extends State<SessionList> {
  final String nickname;
  final String ip;
  final int port;
  Connection _connection;
  List<Pair<int, String>> sessionList = List();

  SessionListState(this.ip, this.port, this.nickname) {
    _connection = Connection(ip, port, nickname);
    _connection.incoming.stream.listen((data) => _handleMsg(data));
    refreshList();
  }

  void _handleMsg(Data data) {
    if (data['type'] != 'sessionList') {
      return;
    }
    sessionList = List();
    for (int i = 0; i < data['sessions'].length; ++i) {
      if (data['sessions'][i] != null) {
        sessionList.add(Pair<int, String>(i, data['sessions'][i]));
      }
    }
    setState(() {});
  }

  void refreshList() {
    Data request = Data();
    request['type'] = 'getSessions';
    _connection.sendData(request);
  }

  void newSession(BuildContext context) {
    String sessionName;
    int password;
    int maxUsers;
    final nameField = TextField(
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Session name',
      ),
      onChanged: (str) {
        sessionName = str;
      },
    );
    final passwordField = TextField(
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Password',
      ),
      onChanged: (str) {
        password = str.hashCode;
      },
    );
    final maxUsersField = TextField(
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Max users',
      ),
      onChanged: (str) {
        maxUsers = int.parse(str);
      },
    );
    final okButton = RaisedButton(
      onPressed: () {
        Navigator.pop(context);
        _connection.create(sessionName, password, maxUsers);
      },
      child: Text('OK'),
    );
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Row(
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
                    passwordField,
                    SizedBox(height: 10),
                    maxUsersField,
                    SizedBox(height: 10),
                    okButton,
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sessions'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add_circle),
            onPressed: () {
              newSession(context);
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              refreshList();
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: sessionList.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(sessionList[index].second),
            onTap: () {
              print('Attempting to connect');
              print(sessionList[index].first);
              print(sessionList[index].second);
            },
          );
        },
      ),
    );
  }
}
