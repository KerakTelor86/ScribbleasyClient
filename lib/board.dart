import 'dart:io';
import 'dart:ui' as Ui;
import 'package:flutter/material.dart';
import 'package:Scribbleasy/network.dart';
import 'package:Scribbleasy/misc.dart';

class Board extends StatefulWidget {
  @override
  BoardState createState() {
    var state = BoardState();
    var connection = Connection('keraktelor.ddns.net', 6969, state);
    state.connection = connection;
    return state;
  }
}

class BoardState extends State<Board> {
  Ui.Image image;
  List<Offset> points = [];
  bool baking = false;
  Connection connection;

  void addPoint(
      Offset offset, Size size, double scale, bool fromNetwork) async {
    points.add(offset);

    if (!fromNetwork) {
      Data update = Data();
      update['type'] = 'sessionData';
      update['dx'] = offset.dx;
      update['dy'] = offset.dy;
      update['width'] = size.width;
      update['height'] = size.height;
      update['scale'] = scale;
      connection.sendData(update.toString());
    }

    if (points.length > 50 && !baking) {
      baking = true;
      var recorder = Ui.PictureRecorder();
      var canvas = Ui.Canvas(recorder);
      var numPoints = points.length;
      canvas.scale(scale);
      BoardPainter(image, points).paint(canvas, size);
      var picture = recorder.endRecording();
      var newImage = await picture.toImage(
        (size.width * scale).ceil(),
        (size.height * scale).ceil(),
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

  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(builder: (context, constraints) {
        var size = constraints.constrain(Size.infinite);
        return GestureDetector(
            child: CustomPaint(
              painter: BoardPainter(image, points),
              size: size,
              willChange: true,
            ),
            onPanUpdate: (drag) {
              addPoint(drag.localPosition, size,
                  MediaQuery.of(context).devicePixelRatio, false);
            });
      }),
    );
  }
}

class BoardPainter extends CustomPainter {
  final Ui.Image image;
  final List<Offset> points;

  BoardPainter(this.image, this.points);

  @override
  void paint(Canvas canvas, Size size) {
    // print(points.length);
    if (image != null) {
      canvas.drawImageRect(
        image,
        Offset.zero & Size(image.width.toDouble(), image.height.toDouble()),
        Offset.zero & size,
        Paint(),
      );
    }
    for (var i in points) {
      canvas.drawCircle(i, 8, Paint()..color = Colors.black);
    }
  }

  @override
  bool shouldRepaint(BoardPainter old) => true;
}
