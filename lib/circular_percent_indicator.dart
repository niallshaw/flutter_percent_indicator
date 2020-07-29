//import 'dart:math';

import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:math' as math;

enum CircularStrokeCap { butt, round, square }

enum ArcType {
  HALF,
  FULL,
}

// ignore: must_be_immutable
class CircularPercentIndicator extends StatefulWidget {
  ///Percent value between 0.0 and 1.0
  final double percent;
  final double radius;

  ///Width of the progress bar of the circle
  final double lineWidth;

  ///Width of the unfilled background of the progress bar
  final double backgroundWidth;

  ///Color of the background of the circle , default = transparent
  final Color fillColor;

  ///First color applied to the complete circle
  final Color backgroundColor;

  Color get progressColor => _progressColor;

  Color _progressColor;

  ///true if you want the circle to have animation
  final bool animation;

  ///duration of the animation in milliseconds, It only applies if animation attribute is true
  final int animationDuration;

  ///widget at the top of the circle
  final Widget header;

  ///widget at the bottom of the circle
  final Widget footer;

  ///widget inside the circle
  final Widget center;

  final LinearGradient linearGradient;

  ///The kind of finish to place on the end of lines drawn, values supported: butt, round, square
  final CircularStrokeCap circularStrokeCap;

  //The gap to leave between the progress bar and background.
  final double gap;

  ///the angle which the circle will start the progress (in degrees, eg: 0.0, 45.0, 90.0)
  final double startAngle;

  //the angle which the indicator will stop (rest will be drawn transparent)
  final double endAngle;

  /// set true if you want to animate the linear from the last percent value you set
  final bool animateFromLastPercent;

  /// set false if you don't want to preserve the state of the widget
  final bool addAutomaticKeepAlive;

  /// set the arc type
  final ArcType arcType;

  /// set a circular background color when use the arcType property
  final Color arcBackgroundColor;

  /// set true when you want to display the progress in reverse mode
  final bool reverse;

  /// Creates a mask filter that takes the progress shape being drawn and blurs it.
  final MaskFilter maskFilter;

  /// set a circular curve animation type
  final Curve curve;

  /// set true when you want to restart the animation, it restarts only when reaches 1.0 as a value
  /// defaults to false
  final bool restartAnimation;

  CircularPercentIndicator(
      {Key key,
      this.percent = 0.0,
      this.lineWidth = 5.0,
      this.gap = 0.0,
      this.startAngle = 0.0,
      this.endAngle = 360.0,
      @required this.radius,
      this.fillColor = Colors.transparent,
      this.backgroundColor = const Color(0xFFB8C7CB),
      Color progressColor,
      this.backgroundWidth =
          -1, //negative values ignored, replaced with lineWidth
      this.linearGradient,
      this.animation = false,
      this.animationDuration = 500,
      this.header,
      this.footer,
      this.center,
      this.addAutomaticKeepAlive = true,
      this.circularStrokeCap,
      this.arcBackgroundColor,
      this.arcType,
      this.animateFromLastPercent = false,
      this.reverse = false,
      this.curve = Curves.linear,
      this.maskFilter,
      this.restartAnimation = false})
      : super(key: key) {
    if (linearGradient != null && progressColor != null) {
      throw ArgumentError(
          'Cannot provide both linearGradient and progressColor');
    }
    _progressColor = progressColor ?? Colors.red;

    assert(startAngle >= 0.0 || endAngle <= 360);
    assert(endAngle <= 360 && startAngle < endAngle);
    assert(gap >= 0.0);
    assert(curve != null);
    if (percent < 0.0 || percent > 1.0) {
      throw Exception("Percent value must be a double between 0.0 and 1.0");
    }

    if (arcType == null && arcBackgroundColor != null) {
      throw ArgumentError('arcType is required when you arcBackgroundColor');
    }
  }

  @override
  _CircularPercentIndicatorState createState() =>
      _CircularPercentIndicatorState();
}

class _CircularPercentIndicatorState extends State<CircularPercentIndicator>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  AnimationController _animationController;
  Animation _animation;
  double _percent = 0.0;

  @override
  void dispose() {
    if (_animationController != null) {
      _animationController.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    if (widget.animation) {
      _animationController = AnimationController(
          vsync: this,
          duration: Duration(milliseconds: widget.animationDuration));
      _animation = Tween(begin: 0.0, end: widget.percent).animate(
        CurvedAnimation(parent: _animationController, curve: widget.curve),
      )..addListener(() {
          setState(() {
            _percent = _animation.value;
          });
          if (widget.restartAnimation && _percent == 1.0) {
            _animationController.repeat(min: 0, max: 1.0);
          }
        });
      _animationController.forward();
    } else {
      _updateProgress();
    }
    super.initState();
  }

  @override
  void didUpdateWidget(CircularPercentIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.percent != widget.percent ||
        oldWidget.startAngle != widget.startAngle) {
      if (_animationController != null) {
        _animationController.duration =
            Duration(milliseconds: widget.animationDuration);
        _animation = Tween(
                begin: widget.animateFromLastPercent ? oldWidget.percent : 0.0,
                end: widget.percent)
            .animate(
          CurvedAnimation(parent: _animationController, curve: widget.curve),
        );
        _animationController.forward(from: 0.0);
      } else {
        _updateProgress();
      }
    }
  }

  _updateProgress() {
    setState(() {
      _percent = widget.percent;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var items = List<Widget>();
    if (widget.header != null) {
      items.add(widget.header);
    }
    items.add(Container(
        height: widget.radius + widget.lineWidth,
        width: widget.radius,
        child: CustomPaint(
          painter: CirclePainter(
              progress: _percent * (widget.endAngle - widget.startAngle),
              progressColor: widget.progressColor,
              backgroundColor: widget.backgroundColor,
              startAngle: widget.startAngle,
              endAngle: widget.endAngle,
              circularStrokeCap: widget.circularStrokeCap,
              radius: (widget.radius / 2) - widget.lineWidth / 2,
              gap: widget.gap,
              lineWidth: widget.lineWidth,
              backgroundWidth: //negative values ignored, replaced with lineWidth
                  widget.backgroundWidth >= 0.0
                      ? (widget.backgroundWidth)
                      : widget.lineWidth,
              arcBackgroundColor: widget.arcBackgroundColor,
              arcType: widget.arcType,
              reverse: widget.reverse,
              linearGradient: widget.linearGradient,
              maskFilter: widget.maskFilter),
          child: (widget.center != null)
              ? Center(child: widget.center)
              : Container(),
        )));

    if (widget.footer != null) {
      items.add(widget.footer);
    }

    return Material(
      color: widget.fillColor,
      child: Container(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: items,
      )),
    );
  }

  @override
  bool get wantKeepAlive => widget.addAutomaticKeepAlive;
}

class CirclePainter extends CustomPainter {
  final Paint _paintBackground = Paint();
  final Paint _paintLine = Paint();
  final Paint _paintBackgroundStartAngle = Paint();
  final double lineWidth;
  final double backgroundWidth;
  final double progress;
  final double radius;
  final double gap;
  final Color progressColor;
  final Color backgroundColor;
  final CircularStrokeCap circularStrokeCap;
  final double startAngle;
  final double endAngle;
  final LinearGradient linearGradient;
  final Color arcBackgroundColor;
  final ArcType arcType;
  final bool reverse;
  final MaskFilter maskFilter;

  CirclePainter(
      {this.lineWidth,
      this.backgroundWidth,
      this.progress,
      this.gap,
      @required this.radius,
      this.progressColor,
      this.backgroundColor,
      this.startAngle = 0.0,
      this.endAngle = 360.0,
      this.circularStrokeCap = CircularStrokeCap.round,
      this.linearGradient,
      this.reverse,
      this.arcBackgroundColor,
      this.arcType,
      this.maskFilter}) {
    _paintBackground.color = backgroundColor;
    _paintBackground.style = PaintingStyle.stroke;
    _paintBackground.strokeWidth = backgroundWidth;

    if (arcBackgroundColor != null) {
      _paintBackgroundStartAngle.color = arcBackgroundColor;
      _paintBackgroundStartAngle.style = PaintingStyle.stroke;
      _paintBackgroundStartAngle.strokeWidth = lineWidth;
      if (circularStrokeCap == CircularStrokeCap.round) {
        _paintBackgroundStartAngle.strokeCap = StrokeCap.round;
      } else if (circularStrokeCap == CircularStrokeCap.butt) {
        _paintBackgroundStartAngle.strokeCap = StrokeCap.butt;
      } else {
        _paintBackgroundStartAngle.strokeCap = StrokeCap.square;
      }
    }

    _paintLine.color = progressColor;
    _paintLine.style = PaintingStyle.stroke;
    _paintLine.strokeWidth = lineWidth;
    if (circularStrokeCap == CircularStrokeCap.round) {
      _paintLine.strokeCap = StrokeCap.round;
    } else if (circularStrokeCap == CircularStrokeCap.butt) {
      _paintLine.strokeCap = StrokeCap.butt;
    } else {
      _paintLine.strokeCap = StrokeCap.square;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Offset.zero & size, Paint());
    final center = Offset(size.width / 2, size.height / 2);

    if (maskFilter != null) {
      _paintLine.maskFilter = maskFilter;
    }
    if (linearGradient != null) {
      /*
      _paintLine.shader = SweepGradient(
              center: FractionalOffset.center,
              startAngle: math.radians(-90.0 + startAngle),
              endAngle: math.radians(progress),
              //tileMode: TileMode.mirror,
              colors: linearGradient.colors)
          .createShader(
        Rect.fromCircle(
          center: center,
          radius: radius,
        ),
      );*/
      _paintLine.shader = linearGradient.createShader(
        Rect.fromCircle(
          center: center,
          radius: radius,
        ),
      );
    }

    double fixedStartAngle = startAngle;

    double startAngleFixedMargin = 1.0;
    if (arcType != null) {
      if (arcType == ArcType.FULL) {
        fixedStartAngle = 220;
        startAngleFixedMargin = 172 / fixedStartAngle;
      } else {
        fixedStartAngle = 270;
        startAngleFixedMargin = 135 / fixedStartAngle;
      }
    }

    if (endAngle < 360) {
      canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          radians(-90.0 + endAngle),
          radians(-((startAngle.abs() + endAngle.abs()) - progress)),
          false,
          _paintBackground..strokeCap = StrokeCap.round);
    } else {
      canvas.drawCircle(center, radius, _paintBackground);
    }

    // if (startAngle) {
    //   fixedStartAngle = 360 + startAngle;
    // }

    if (arcBackgroundColor != null) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        radians(-90.0 + fixedStartAngle),
        radians(360 * startAngleFixedMargin),
        false,
        _paintBackgroundStartAngle,
      );
    }
    // canvas.saveLayer(Rect.fromCircle(center: center, radius: radius),
    //     _paintBackground..blendMode);

    if (reverse) {
      final start =
          radians(360 * startAngleFixedMargin - 90.0 + fixedStartAngle);
      print(start);

      final end = radians(-progress * startAngleFixedMargin);
      final startGap =
          radians(360 * startAngleFixedMargin - 90.0 + gap + fixedStartAngle);
      final endGap = radians(-(progress + gap * 2) * startAngleFixedMargin);
      Path path = Path();
      path.addArc(
          Rect.fromCircle(
            center: center,
            radius: radius,
          ),
          start,
          end);

      PathMetrics pm = path.computeMetrics();

      for (PathMetric pathMetric in pm) {
        Path extractPath = pathMetric.extractPath(0.0, pathMetric.length);
        // extractPath
        //     .computeMetrics()
        //     .
        Offset offset =
            pathMetric.getTangentForOffset(pathMetric.length).position;
        Offset offseta = pathMetric.getTangentForOffset(0).position;
        Path path = new Path();
        path.addOval(Rect.fromCircle(center: offset, radius: 15));
        path.addOval(Rect.fromCircle(center: offseta, radius: 15));
        canvas.drawPath(
            path,
            Paint()
              ..blendMode = BlendMode.clear
              ..style = PaintingStyle.fill
              ..color = Colors.black);
      }
      // path.arcTo(rect, startGap, endGap, true);

      // print(end);
      // path.close();
      // canvas.drawPath(
      //     path,
      //     new Paint()
      //       ..color = Colors.red
      //       ..style = PaintingStyle.stroke
      //       ..strokeWidth = lineWidth
      //       ..strokeCap = _paintLine.strokeCap);
      // canvas.drawArc(
      //     Rect.fromCircle(
      //       center: center,
      //       radius: radius,
      //     ),
      //     startGap,
      //     endGap,
      //     false,
      //     new Paint()
      //       ..color = Colors.red
      //       ..blendMode = BlendMode.clear
      //       ..style = PaintingStyle.stroke
      //       ..strokeWidth = lineWidth
      //       ..strokeCap = _paintLine.strokeCap);

      canvas.drawArc(
        Rect.fromCircle(
          center: center,
          radius: radius,
        ),
        start,
        end,
        false,
        _paintLine,
      );
    } else {
      final start = radians(-90.0 + fixedStartAngle);
      final end = radians(progress * startAngleFixedMargin);
      final startGap = radians(-90.0 - gap + fixedStartAngle);
      final endGap = radians((progress + gap * 2) * startAngleFixedMargin);

      Path path = Path();
      path.addArc(
          Rect.fromCircle(
            center: center,
            radius: radius,
          ),
          start,
          end);

      PathMetrics pm = path.computeMetrics();

      for (PathMetric pathMetric in pm) {
        Path extractPath = pathMetric.extractPath(0.0, pathMetric.length);
        // extractPath
        //     .computeMetrics()
        //     .
        Offset offset =
            pathMetric.getTangentForOffset(pathMetric.length).position;
        Offset offseta = pathMetric.getTangentForOffset(0).position;
        Path path = new Path();
        path.addOval(Rect.fromCircle(center: offset, radius: 15));
        path.addOval(Rect.fromCircle(center: offseta, radius: 15));
        canvas.drawPath(
            path,
            Paint()
              ..blendMode = BlendMode.clear
              ..style = PaintingStyle.fill
              ..color = Colors.black);
      }

      // canvas.saveLayer(
      //     Rect.fromCircle(
      //       center: center,
      //       radius: radius,
      //     ),
      //     new Paint()
      //       ..color = Colors.red
      //       ..blendMode = BlendMode.darken
      //       ..style = PaintingStyle.stroke
      //       ..strokeWidth = lineWidth
      //       ..strokeCap = _paintLine.strokeCap);

      canvas.drawArc(
        Rect.fromCircle(
          center: center,
          radius: radius,
        ),
        start,
        end,
        false,
        _paintLine,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  num radians(num deg) => deg * (math.pi / 180.0);
}
