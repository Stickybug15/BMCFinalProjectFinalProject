import 'dart:async';
import 'package:flutter/material.dart';

class AnimatedHeader extends StatefulWidget {
  final String title;
  const AnimatedHeader({super.key, required this.title});

  @override
  State<AnimatedHeader> createState() => _AnimatedHeaderState();
}

class _AnimatedHeaderState extends State<AnimatedHeader> {
  String _animatedTitle = '';
  int _characterIndex = 0;
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    _startTypingAnimation();
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    super.dispose();
  }

  void _startTypingAnimation() {
    const typingSpeed = Duration(milliseconds: 150);
    _typingTimer = Timer.periodic(typingSpeed, (timer) {
      if (_characterIndex < widget.title.length) {
        setState(() {
          _animatedTitle += widget.title[_characterIndex];
          _characterIndex++;
        });
      } else {
        _typingTimer?.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _animatedTitle,
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
}
