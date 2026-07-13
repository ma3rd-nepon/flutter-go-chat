import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_go_chat/l10n/app_localizations.dart';
import 'package:flutter_go_chat/l10n/locale_list.dart';
import 'package:flutter/widgets.dart';


class AppLocale {
  static final supportedLocales =
    LocaleList.values.map((e) => e.locale).toList();

  static const List<LocalizationsDelegate> delegates = [
    AppLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
}