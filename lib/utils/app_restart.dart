import 'package:flutter/material.dart';

class AppRestart extends StatefulWidget {
  final Widget child;

  const AppRestart({Key? key, required this.child}) : super(key: key);

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_AppRestartState>()?.restartApp();
  }

  @override
  _AppRestartState createState() => _AppRestartState();
}

class _AppRestartState extends State<AppRestart> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
} 