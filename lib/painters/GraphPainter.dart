import 'package:flutter/material.dart';
import 'package:thermostat/data/THR.dart';

class GraphPainter extends CustomPainter{
  GraphPainter({required this.data, required  this.propValue, required  this.yMin, required  this.yMax, required  this.step, required this.majorStep});

  Map data;
  String propValue;
  int yMin;
  int yMax;
  int step;
  int majorStep;


  @override
  void paint(Canvas canvas, Size size){
    var yLimits = {'max': this.yMax, 'min':this.yMin};
    if(data == null){
      return;
    }
    this.paintBackground(data['CHAMBRE'], yLimits, canvas, size);
    this.paintGraph(data['CHAMBRE'], Colors.blue, yLimits, canvas, size);
    this.paintGraph(data['SALON'], Colors.teal, yLimits, canvas, size);
  }

  void paintBackground(List<THR> source, Map yLimits, Canvas canvas, Size size){
    if(source.length == 0)
      return;
    Paint minorPaint = new Paint();
    minorPaint.style = PaintingStyle.stroke;
    minorPaint.color = const Color(0xffdddddd);
    Paint majorPaint = new Paint();
    majorPaint.style = PaintingStyle.stroke;
    majorPaint.color = const Color(0xff999999);
    Path minorPath = new Path();
    Path majorPath = new Path();
    double yDist = size.height / (yLimits['max'] - yLimits['min']);
    int y = 0;
    Path currentPath;
    for(int i = yLimits['min'], max = yLimits['max']; i<=max; i += this.step){
      if(i%this.majorStep == 0){
        currentPath = majorPath;
      }
      else{
        currentPath = minorPath;
      }
      currentPath.moveTo(0.0, size.height - (y * yDist));
      currentPath.lineTo(size.width, size.height - (y * yDist));
      y += this.step;
    }
    canvas.drawPath(minorPath, minorPaint);
    canvas.drawPath(majorPath, majorPaint);

    Paint nightPaint = new Paint();
    nightPaint.color = const Color(0x220000FF);
    Path nightPath = new Path();
    var xSteps = size.width / source.length;
    var x = 0.0;
    var open = false;
    source.forEach((THR thr){
      if(thr.date.hour == 23 && thr.date.minute == 0){
        nightPath.moveTo(x, 0.0);
        nightPath.lineTo(x, size.height);
        open = true;
      }
      if(thr.date.hour == 7 && thr.date.minute == 0){
        if(open == false){
          nightPath.moveTo(0.0, 0.0);
          nightPath.lineTo(0.0, size.height);
        }

        nightPath.lineTo(x, size.height);
        nightPath.lineTo(x, 0.0);
        open = false;
      }
      x += xSteps;
    });

    if(open == true){
      nightPath.lineTo(size.width, size.height);
      nightPath.lineTo(size.width, 0.0);
    }

    canvas.drawPath(nightPath, nightPaint);
  }

  void paintGraph(List<THR> source, Color color, Map yLimits, Canvas canvas, Size size){
    if(source == null || source.length == 0)
      return;

    var xSteps = size.width/ source.length;

    var yDiff = yLimits['max'] - yLimits['min'];

    Paint paint = new Paint();
    paint.color = color;
    paint.strokeWidth = 2.0;
    paint.strokeJoin = StrokeJoin.round;
    paint.strokeCap = StrokeCap.round;
    paint.style = PaintingStyle.stroke;
    Path path = new Path();

    bool init = false;
    double x = 0.0;
    source.forEach((THR thr){
      double diff = thr.get(this.propValue) - yLimits['min'];
      double y = size.height - ((size.height/yDiff) * diff);
      if(init == false){
        init = true;
        path.moveTo(x, y);
      }
      else{
        path.lineTo(x, y);
      }

      x += xSteps;
    });

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(GraphPainter painter){
    return painter.data != this.data;
  }
}