import 'dart:async';
import 'package:flutter/material.dart';

import '../../controllers/controllers.dart';

class LikeAnimation extends StatefulWidget {
  final LikeAnimationController controller;
  final IconData icon;
  final Color iconColor;
  final double size;
  final Duration duration;

  const LikeAnimation({
    super.key,
    required this.controller,
    this.icon = Icons.favorite,
    this.iconColor = Colors.white,
    this.size = 100,
    this.duration = const Duration(milliseconds: 400),
  });

  @override
  State<LikeAnimation> createState() => _LikeAnimationState();
}

class _LikeAnimationState extends State<LikeAnimation> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  bool _visible = false;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _scale =
        Tween<double>(begin: 0.6, end: 1.2).chain(CurveTween(curve: Curves.easeOutBack)).animate(_animController);
    _opacity = Tween<double>(begin: 0, end: 1).chain(CurveTween(curve: Curves.easeInOut)).animate(_animController);

    widget.controller.listenable.addListener(() {
      if (widget.controller.listenable.value) {
        _startAnimation();
        // Reset trigger so it can be reused
        widget.controller.setShowAnimation = false;
      }
    });
  }

  void _startAnimation() {
    _visible = true;
    _animController.forward(from: 0).then((_) {
      Timer(const Duration(milliseconds: 150), () {
        if (mounted) {
          _visible = false;
          _animController.reset(); // Optional: reset for next run
        }
      });
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          return Opacity(
            opacity: _visible ? _opacity.value : 0,
            child: Transform.scale(
              scale: _scale.value,
              child: Icon(widget.icon, color: widget.iconColor, size: widget.size),
            ),
          );
        },
      ),
    );
  }
}
