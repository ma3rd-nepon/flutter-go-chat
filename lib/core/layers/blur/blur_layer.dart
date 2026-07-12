import 'package:flutter/material.dart';

class BlurLayer extends StatefulWidget {
  const BlurLayer({super.key});

  @override
  State<BlurLayer> createState() => _BlurLayerState();
}

class _BlurLayerState extends State<BlurLayer> {
  @override
  Widget build(BuildContext context) {
    return ImageFiltered(imageFilter: .blur(sigmaX: 3, sigmaY: 3));
  } 
}