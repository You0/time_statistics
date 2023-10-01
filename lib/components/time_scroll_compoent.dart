import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'animated_digit/animated_digit_widget.dart';

class TimeScrollAnimation extends StatelessWidget {
  const TimeScrollAnimation(
      {Key? key,
      required this.hour,
      required this.minute,
      required this.second})
      : super(key: key);
  final int hour;
  final int minute;
  final int second;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 75,
          child: AnimatedDigitWidget(
            value: hour,
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 50,
            ),
          ),
        ),
        const Text(":",
            style: TextStyle(
              color: Colors.white,
              fontSize: 50,
            )),
        SizedBox(
          width: 75,
          child: AnimatedDigitWidget(
            value: minute,
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 50,
            ),
          ),
        ),
        const Text(":",
            style: TextStyle(
              color: Colors.white,
              fontSize: 50,
            )),
        SizedBox(
          width: 75,
          child: AnimatedDigitWidget(
            value: second,
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 50,
            ),
          ),
        ),
      ],
    );
  }
}
