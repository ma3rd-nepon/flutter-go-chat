import 'package:flutter/material.dart';
import 'package:flutter_go_chat/core/extensions/l10n_extension.dart';

class PageConfig {
  final PageId id;
  final Widget page;
  final bool canBeClosed;
  final bool hideUI;
  final IconData icon;

  const PageConfig({
    required this.id,
    required this.page,
    this.canBeClosed = true,
    this.hideUI = false,
    required this.icon
  });

  String label(BuildContext context) {
    switch (id) {
      case (.chat):
        return context.l10n.labelChats;
      case (.calls):
        return context.l10n.labelCalls;
      case (.music):
        return context.l10n.labelMusic;
      case (.settings):
        return context.l10n.labelSettings;
      case (.profile):
        return context.l10n.labelProfile;
      case (.unknown):
        return context.l10n.labelUnknown;
    }
  }
}

///  Аааааааайййййй-ди страниц для навигации
enum PageId {
  chat,
  calls,
  music,
  settings,
  profile,
  unknown;
}
