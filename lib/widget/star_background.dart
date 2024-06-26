import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:star_background/widget/ufo_front.dart';

class StarBackground extends StatelessWidget {
  final double height;
  final double width;
  final int starCount;
  final double starSize;
  PointerExitEventListener? onExit;
  PointerHoverEventListener? onHover;
  final Widget? floatChild;

  @override
  StarBackground(
      {super.key,
      this.height = 200,
      this.width = 200,
      this.starCount = 200,
      this.starSize = 2,
      this.onExit,
      this.onHover,
      this.floatChild});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: LayoutBuilder(builder: (context, constraints) {
        return _StarBackgroundState(
          height: constraints.maxHeight,
          width: constraints.maxWidth,
          starCount: starCount,
          starSize: starSize,
          onExit: onExit,
          onHover: onHover,
          floatChild: floatChild,
        );
      }),
    );
  }
}

class _StarBackgroundState extends StatefulWidget {
  final double height;
  final double width;
  final int starCount;
  final double starSize;
  final Widget? floatChild;
  final PointerExitEventListener? onExit;
  final PointerHoverEventListener? onHover;

  const _StarBackgroundState(
      {super.key,
      this.height = 200,
      this.width = 200,
      this.starCount = 200,
      this.starSize = 1,
      this.onExit,
      this.floatChild,
      this.onHover});

  @override
  State<_StarBackgroundState> createState() => _StarBackgroundStateState();
}

class _StarBackgroundStateState extends State<_StarBackgroundState>
    with TickerProviderStateMixin {
  List<_StarData> starList = [];
  double tailLength = 0;
  double angle = 0;
  double recordTailLength = 0;
  double recordAngle = 0;
  double lastX = 0;
  double lastY = 0;
  double lastAngle = 0;
  late AnimationController animationController;
  double speed = 0;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    print("123");
    for (int i = 0; i < widget.starCount; i++) {
      starList.add(_StarData(
          x: Random().nextDouble() * widget.width,
          y: Random().nextDouble() * widget.height,
          radius: Random().nextDouble() * widget.starSize,
          initialHeight: widget.height,
          initialWidth: widget.width));
    }

    animationController = AnimationController(
        upperBound: 1,
        lowerBound: 0,
        vsync: this,
        duration: const Duration(milliseconds: 500))
      ..addListener(() {
        setState(() {
          tailLength =
              recordTailLength - recordTailLength * animationController.value;
        });
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            tailLength = 0;
            angle = 0;
            recordAngle = 0;
            recordTailLength = 0;
          });
          animationController.reset();
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomPaint(
          painter: _StarPainter(
              starList: starList,
              tailLength: tailLength > 100 ? 100 : tailLength,
              angle: angle),
          size: Size(widget.width, widget.height),
        ),
        if (widget.floatChild != null) widget.floatChild!,
        MouseRegion(
          onExit: (event) {
            recordAngle = angle;
            recordTailLength = tailLength;
            animationController.forward();
            if (widget.onExit != null) {
              widget.onExit!(event);
            }
          },
          onHover: (event) {
            double dx = event.localPosition.dx - lastX;
            double dy = event.localPosition.dy - lastY;
            double distance = sqrt(dx * dx + dy * dy);
            // 计算当前点和中心点旋转角
            double angle = atan2(dy, dx);
            setState(() {
              tailLength = distance*1.2;
              this.angle = angle;
            });
            lastX = event.localPosition.dx;
            lastY = event.localPosition.dy;
            lastAngle = angle;
            if (widget.onHover != null) {
              widget.onHover!(event);
            }
          },
        )
      ],
    );
  }
}

class _StarPainter extends CustomPainter {
  final List<_StarData> starList;
  final double tailLength;
  final double angle;

  _StarPainter(
      {required this.starList, required this.tailLength, required this.angle});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xfff5f5f5)
      ..style = PaintingStyle.fill;
    for (_StarData e in starList) {
      canvas.drawCircle(
          Offset(e.x * size.width / e.initialWidth,
              e.y * size.height / e.initialHeight),
          e.radius,
          paint);
      drawTail(e, size, canvas);
    }
  }

  final tailPaint = Paint()
    ..color = const Color(0xfff5f5f5)
    ..style = PaintingStyle.stroke;

  void drawTail(_StarData e, Size size, Canvas canvas) {
    if (tailLength > 0) {
      // 根据tailLength 和 angle 计算尾部终点坐标
      double dx = e.x - tailLength * cos(angle);
      double dy = e.y - tailLength * sin(angle);
      List<Color> colors = [
        const Color(0xfff5f5f5).withOpacity(0.2),
        const Color(0xfff5f5f5),
      ];
      if (dx > e.x) {
        colors = [
          const Color(0xfff5f5f5),
          const Color(0xfff5f5f5).withOpacity(0.2),
        ];
      }
      tailPaint
        ..strokeWidth = e.radius * 2
        ..shader = LinearGradient(colors: colors).createShader(Rect.fromPoints(
            Offset(e.x * size.width / e.initialWidth,
                e.y * size.height / e.initialHeight),
            Offset(dx*size.width/e.initialWidth, dy*size.height/e.initialHeight)));
      canvas.drawLine(
          Offset(e.x * size.width / e.initialWidth,
              e.y * size.height / e.initialHeight),
          Offset(dx * size.width / e.initialWidth,
              dy * size.height / e.initialHeight),
          tailPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarPainter oldDelegate) {
    return true;
  }
}

class _StarData {
  double x;
  double y;
  double initialWidth;
  double initialHeight;
  final double radius;

  _StarData(
      {required this.x,
      required this.y,
      required this.radius,
      required this.initialWidth,
      required this.initialHeight});

  @override
  String toString() {
    return 'StarData{x: $x, y: $y, radius: $radius}';
  }
}
