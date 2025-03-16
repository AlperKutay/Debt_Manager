import 'package:flutter/material.dart';

class RestartWidget extends StatefulWidget {
  final Widget child;

  const RestartWidget({Key? key, required this.child}) : super(key: key);

  static void restartApp(BuildContext context) {
    print("Restarting app...");
    final state = context.findAncestorStateOfType<_RestartWidgetState>();
    if (state != null) {
      print("Found RestartWidget state, restarting...");
      state.restartApp();
    } else {
      print("Could not find RestartWidget state!");
    }
  }

  @override
  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    print("Rebuilding with new key...");
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    print("Building RestartWidget with key: $key");
    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
} 