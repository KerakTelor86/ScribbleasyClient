import 'dart:io';
import 'dart:ui' as Ui;
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:Scribbleasy/network.dart';
import 'package:Scribbleasy/misc.dart';

class Board extends StatefulWidget {
  final Connection connection;

  Board({Key key, @required this.connection}) : super(key: key);

  @override
  BoardState createState() => BoardState(connection);
}

class BoardState extends State<Board> {
  Ui.Image image;
  List<Offset> points = [];
  bool baking = false;
  final Connection connection;
  StreamSubscription subscription;
  Size curSize;

  BoardState(this.connection) {
    subscription =
        connection.incoming.stream.listen((data) => _handleMsg(data));
  }

  void _handleMsg(Data received) async {
    if (received['type'] != 'sessionData') {
      return;
    }
    switch (received['reqType']) {
      case 'draw':
        Ui.Offset offset = Ui.Offset(received['dx'], received['dy']);
        addPoint(offset, true);
        break;
      case 'sync':
        points = List();
        int len = received['pointsX'].length;
        for (int i = 0; i < len; ++i) {
          points.add(Ui.Offset(received['pointsX'][i], received['pointsY'][i]));
        }
        len = received['image'].length;
        Uint8List temp = Uint8List(len);
        for (int i = 0; i < len; ++i) {
          temp[i] = received['image'][i];
        }
        var codec = await Ui.instantiateImageCodec(temp,
            targetWidth: curSize.width.ceil(),
            targetHeight: curSize.height.ceil());
        var frame = await codec.getNextFrame();
        image = frame.image;
        setState(() {});
        break;
    }
  }

  void addPoint(Offset offset, bool fromNetwork) async {
    if (!fromNetwork) {
      offset = Ui.Offset(offset.dx / curSize.width, offset.dy / curSize.height);
      Data update = Data();
      update['type'] = 'sessionData';
      update['reqType'] = 'draw';
      update['dx'] = offset.dx;
      update['dy'] = offset.dy;
      connection.sendData(update);
    }
    points.add(offset);

    if (points.length > 50 && !baking) {
      baking = true;
      var recorder = Ui.PictureRecorder();
      var canvas = Ui.Canvas(recorder);
      var numPoints = points.length;
      BoardPainter(image, points).paint(canvas, curSize);
      var picture = recorder.endRecording();
      var newImage = await picture.toImage(
        curSize.width.ceil(),
        curSize.height.ceil(),
      );
      if (baking) {
        image = newImage;
        points.removeRange(0, numPoints);
        baking = false;
        setState(() {});
      }
    } else {
      setState(() {});
    }
  }

  void clear() {
    setState(() {
      baking = false;
      image = null;
      points.clear();
    });
  }

  void _leaveSession() {
    Data data = Data();
    data['type'] = 'quitSession';
    connection.sendData(data);
  }

  void _syncBoard() {
    Data data = Data();
    data['type'] = 'sessionData';
    data['reqType'] = 'sync';
    connection.sendData(data);
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context);
        _leaveSession();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Board'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                _syncBoard();
              },
            ),
          ],
        ),
        body: LayoutBuilder(builder: (context, constraints) {
          curSize = constraints.constrain(Size.infinite);
          return GestureDetector(
              child: CustomPaint(
                painter: BoardPainter(image, points),
                size: curSize,
                willChange: true,
              ),
              onPanUpdate: (drag) {
                addPoint(drag.localPosition, false);
              });
        }),
      ),
    );
  }
}

class BoardPainter extends CustomPainter {
  final Ui.Image image;
  final List<Offset> points;

  BoardPainter(this.image, this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (image != null) {
      canvas.drawImageRect(
        image,
        Offset.zero & Size(image.width.toDouble(), image.height.toDouble()),
        Offset.zero & size,
        Paint(),
      );
    }
    for (var i in points) {
      var temp = Offset(i.dx * size.width, i.dy * size.height);
      canvas.drawCircle(temp, 8, Paint()..color = Colors.black);
    }
  }

  @override
  bool shouldRepaint(BoardPainter old) => true;
}
