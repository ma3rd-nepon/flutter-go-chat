import 'package:flutter/material.dart';

enum AppIcon {
  logo(Icons.egg),
  chatBubble(Icons.chat_bubble),
  login(Icons.explore),
  calls(Icons.phone),
  music(Icons.headphones),
  settings(Icons.settings),
  profile(Icons.account_circle),
  unknown(Icons.question_mark),
  eyeOn(Icons.visibility),
  eyeOff(Icons.visibility_off);


  const AppIcon(this.icon);
  final IconData icon;
}