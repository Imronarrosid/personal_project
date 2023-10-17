import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:personal_project/constant/color.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';

class CountDownTimer extends StatefulWidget {
  final AnimationController controller;
  const CountDownTimer({super.key, required this.controller});

  @override
  State<CountDownTimer> createState() => _CountDownTimerState();
}

class _CountDownTimerState extends State<CountDownTimer>
    with TickerProviderStateMixin {
  // late AnimationController controller;

  String get timerString {
    Duration duration = widget.controller.duration! * widget.controller.value;
    if (widget.controller.value == 0.0) {
      return LocaleKeys.label_60_second.tr();
    }
    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    // controller = widget.controller;
    // controller = AnimationController(
    //   vsync: this,
    //   duration: Duration(seconds: 5),
    // );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return AnimatedBuilder(
        animation: widget.controller,
        builder: (context, child) {
          return Stack(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Align(
                        alignment: FractionalOffset.center,
                        child: AspectRatio(
                          aspectRatio: 1.0,
                          child: Stack(
                            children: <Widget>[
                              // Positioned.fill(
                              //   child: CustomPaint(
                              //       painter: CustomTimerPainter(
                              //     animation: widget.controller,
                              //     backgroundColor: Colors.white,
                              //     color: COLOR_red,
                              //   )),
                              // ),
                              Align(
                                alignment: FractionalOffset.center,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      timerString,
                                      style: widget.controller.value == 0.0
                                          ? TextStyle(
                                              fontSize: 14.0,
                                              color: COLOR_white_fff5f5f5,
                                              fontWeight: FontWeight.w500)
                                          : TextStyle(
                                              color: COLOR_white_fff5f5f5,
                                              fontSize: 11.0,
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // AnimatedBuilder(
                    //     animation: controller,
                    //     builder: (context, child) {
                    //       return FloatingActionButton.extended(
                    //           onPressed: () {
                    //             if (controller.isAnimating)
                    //               controller.stop();
                    //             else {
                    //               controller.reverse(
                    //                   from: controller.value == 0.0
                    //                       ? 1.0
                    //                       : controller.value);
                    //             }
                    //           },
                    //           icon: Icon(controller.isAnimating
                    //               ? Icons.pause
                    //               : Icons.play_arrow),
                    //           label: Text(
                    //               controller.isAnimating ? "Pause" : "Play"));
                    //     }),
                  ],
                ),
              ),
            ],
          );
        });
  }
}

class CustomTimerPainter extends CustomPainter {
  CustomTimerPainter({
    required this.animation,
    required this.backgroundColor,
    required this.color,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color backgroundColor, color;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.butt
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(size.center(Offset.zero), size.width / 2.0, paint);
    paint.color = color;
    double progress = (1.0 - animation.value) * 2 * math.pi;
    canvas.drawArc(Offset.zero & size, math.pi * 1.5, -progress, false, paint);
  }

  @override
  bool shouldRepaint(CustomTimerPainter oldDelegate) {
    return animation.value != oldDelegate.animation.value ||
        color != oldDelegate.color ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}
