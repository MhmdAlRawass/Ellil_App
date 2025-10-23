import 'package:audio_app_example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

//class taht return a loading animation for downloading
class Loading extends StatelessWidget {
  const Loading({super.key, this.neededOpacity = false});

  final bool neededOpacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.onSecondary,
      child: Center(
        child: SpinKitRipple(
          color: pcolor,
          size: 40.0,
        ),
      ),
    );
  }
}
