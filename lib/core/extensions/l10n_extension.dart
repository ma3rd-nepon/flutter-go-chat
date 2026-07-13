import 'package:flutter/widgets.dart';
import 'package:flutter_go_chat/l10n/app_localizations.dart';

extension LocalizationExtension on BuildContext {
  AppLocalizations get l10n =>
      AppLocalizations.of(this)!;
}