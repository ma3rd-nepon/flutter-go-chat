import 'package:flutter/material.dart';

class StartupScreen extends StatefulWidget {
  final bool isLoggedIn;
  final bool isDesktop;
  final Orientation orientation;
  const StartupScreen({super.key, this.isDesktop=true, required this.isLoggedIn, this.orientation=Orientation.portrait});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startup();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
  
  Future<void> _startup() async {
    // here will be an initialization methods
    if (!mounted) return;

    Navigator.pushReplacementNamed(context, widget.isLoggedIn ? '/main_ui' : '/welcome');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: CircularProgressIndicator()
        )
      )
    );
  }
}