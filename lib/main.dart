import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: PomodoroTimer()));

class PomodoroTimer extends StatefulWidget {
  const PomodoroTimer({super.key});

  @override
  _PomodoroTimerState createState() => _PomodoroTimerState();
}

class _PomodoroTimerState extends State<PomodoroTimer> {
  static const int maxTime = 25 * 60; // 25분 타이머
  int remainingTime = maxTime;
  Timer? timer;
  bool isRunning = false;

  void startTimer() {
    if (timer != null) {
      timer?.cancel();
    }
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingTime > 0) {
          remainingTime--;
        } else {
          timer.cancel();
          remainingTime = maxTime;
          isRunning = false;
        }
      });
    });
    setState(() {
      isRunning = true;
    });
  }

  void stopTimer() {
    timer?.cancel();
    setState(() {
      isRunning = false;
    });
  }

  void resetTimer() {
    timer?.cancel();
    setState(() {
      remainingTime = maxTime;
      isRunning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double percent = remainingTime / maxTime;

    return Scaffold(
      backgroundColor: const Color(0xFF161720),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 20),
            Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(300, 300),
                  painter: CircularProgressPainter(percent),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "${(remainingTime ~/ 60).toString().padLeft(2, '0')}:${(remainingTime % 60).toString().padLeft(2, '0')}",
                      style: const TextStyle(
                        fontSize: 48,
                        color: Color(0xFF9CFF57),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    IconButton(
                      icon: Icon(
                        isRunning ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 40,
                      ),
                      onPressed: () {
                        if (isRunning) {
                          stopTimer();
                        } else {
                          startTimer();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  final double progress;

  CircularProgressPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    double lineWidth = 15.0;
    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = min(size.width / 2, size.height / 2) - lineWidth / 2;

    // 배경 원 그리기
    Paint backgroundPaint = Paint()
      ..color = Colors.grey[800]!
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, backgroundPaint);

    // 흰색 부분 그리기 (처음 20분)
    Paint whitePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    double whiteAngle = min(progress, 20 / 25) * 2 * pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, // 시작 각도 (12시 방향)
      whiteAngle, // 반시계 방향으로 진행
      false,
      whitePaint,
    );

    // 청록색 부분 그리기 (마지막 5분)
    if (progress > 20 / 25) {
      Paint lastFiveMinutesPaint = Paint()
        ..color = const Color(0xFF00C3CC)
        ..strokeWidth = lineWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      double lastFiveMinutesAngle = (progress - 20 / 25) * 2 * pi;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2 + whiteAngle, // 흰색 부분 이후 시작
        lastFiveMinutesAngle, // 반시계 방향으로 계속 진행
        false,
        lastFiveMinutesPaint,
      );
    }
  }

  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
