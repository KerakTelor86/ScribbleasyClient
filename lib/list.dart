import 'package:flutter/material.dart';
import 'package:Scribbleasy/network.dart';
import 'package:Scribbleasy/misc.dart';
import 'package:Scribbleasy/board.dart';

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
  BuildContext currentContext;
  List<Pair<int, String>> sessionList = List();

  SessionListState(this.ip, this.port, this.nickname) {
    _connection = Connection(ip, port, nickname);
    _connection.incoming.stream.listen((data) => _handleMsg(data));
    refreshList();
  }

  void _handleMsg(Data data) {
    switch (data['type']) {
      case 'sessionList':
        return updateList(data['sessions']);
        break;
      case 'sessionAuth':
        return checkAuth(data['auth']);
        break;
      default:
        break;
    }
  }

  void updateList(List<dynamic> names) {
    sessionList = List();
    for (int i = 0; i < names.length; ++i) {
      if (names[i] != null) {
        sessionList.add(Pair<int, String>(i, names[i]));
      }
    }
    setState(() {});
  }

  void checkAuth(int auth) {
    if (auth == 0) {
      showDialog(
        context: currentContext,
        builder: (context) {
          return AlertDialog(
            title: Text('Authentication failure'),
            content: Text('Recheck your password.'),
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
    } else {
      Navigator.push(
        currentContext,
        MaterialPageRoute(
          builder: (BuildContext context) => Board(connection: _connection),
        ),
      );
    }
  }

  void refreshList() {
    Data request = Data();
    request['type'] = 'getSessions';
    _connection.sendData(request);
  }

  void newSession() {
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
        Data data = Data();
        data['name'] = sessionName;
        data['pwHash'] = password;
        data['maxUsers'] = maxUsers;
        data['type'] = 'createSession';
        _connection.sendData(data);
      },
      child: Text('OK'),
    );
    showDialog(
      context: currentContext,
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

  void joinSession(int id) {
    int password;
    final passwordField = TextField(
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Password',
      ),
      onChanged: (str) {
        password = str.hashCode;
      },
    );
    final okButton = RaisedButton(
      onPressed: () {
        Navigator.pop(context);
        Data request = Data();
        request['type'] = 'joinSession';
        request['id'] = id;
        request['pwHash'] = password.hashCode;
        _connection.sendData(request);
      },
      child: Text('OK'),
    );
    showDialog(
      context: currentContext,
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
                    passwordField,
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
    currentContext = context;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sessions'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add_circle),
            onPressed: () {
              newSession();
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
              joinSession(sessionList[index].first);
            },
          );
        },
      ),
    );
  }
}
