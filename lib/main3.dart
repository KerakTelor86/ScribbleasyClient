import 'package:flutter/material.dart';
import 'dart:ui' as ui;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ui.Image image;
  var points = <Offset>[];
  var baking = false;

  void addPoint(Offset offset, Size size, double scale) async {
    points.add(offset);
    if (points.length > 50 && !baking) {
      baking = true;
      var recorder = ui.PictureRecorder();
      var canvas = ui.Canvas(recorder);
      var numPoints = points.length;
      canvas.scale(scale);
      DrawingPainter(image, points).paint(canvas, size);
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

  build(context) => Scaffold(
        appBar: AppBar(
          title: Text("Painter"),
          actions: [
            IconButton(
              icon: Icon(Icons.clear),
              onPressed: clear,
            ),
          ],
        ),
        body: LayoutBuilder(builder: (context, constraints) {
          return GestureDetector(
              child: CustomPaint(
                painter: DrawingPainter(image, points),
                size: Size.infinite,
                willChange: true,
              ),
              onPanUpdate: (drag) {
                addPoint(drag.localPosition, size,
                    MediaQuery.of(context).devicePixelRatio);
              });
        }),
      );
}

class DrawingPainter extends CustomPainter {
  final ui.Image image;
  final List<Offset> points;

  DrawingPainter(this.image, this.points);

  paint(canvas, size) {
    if (image != null) {
      canvas.drawImageRect(
        image,
        Offset.zero & Size(image.width.toDouble(), image.height.toDouble()),
        Offset.zero & size,
        Paint(),
      );
    }
    for (var pt in points) {
      canvas.drawCircle(pt, 8, Paint()..color = Colors.blue);
    }
  }

  shouldRepaint(DrawingPainter old) => true;
}
