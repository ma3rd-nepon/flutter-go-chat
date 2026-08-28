import 'package:flutter/material.dart';

class PageConfig {
  final PageId id;
  final Widget page;
  final bool hideUI;
  final bool canBeClosed;
  final IconData icon;

  const PageConfig({
    required this.id,
    required this.page,
    this.hideUI = false,
    this.canBeClosed = true,
    required this.icon
  });

  // String label(BuildContext context) {
  //   switch (id) {
  //     case (.chat):
  //       return context.l10n.labelChats;
  //     case (.calls):
  //       return context.l10n.labelCalls;
  //     case (.music):
  //       return context.l10n.labelMusic;
  //     case (.settings):
  //       return context.l10n.labelSettings;
  //     case (.profile):
  //       return context.l10n.labelProfile;
  //     case (.unknown):
  //       return context.l10n.labelUnknown;
  //   }
  // }

  String label(BuildContext context) {
    return id.name;
  }
}

enum PageId {
  chat,
  calls,
  music,
  friends,
  settings,
  profile,
  unknown;
}