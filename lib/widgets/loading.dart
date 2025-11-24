import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoadingWidget extends StatelessWidget {
  final double size;
  final Color? backgroundColor;
  final String? text;

  const LoadingWidget({
    super.key,
    this.size = 100,
    this.backgroundColor,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: backgroundColor ?? Colors.transparent,
      child: SizedBox(
        width: size.w,
        height: size.w,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Lottie.asset(
              'assets/animations/Banana.json',
              width: size.w,
              height: size.w,
              fit: BoxFit.contain,
              repeat: true,
            ),
          ],
        ),
      ),
    );
  }
}
