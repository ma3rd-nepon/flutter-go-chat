// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String unexpectError(String error) {
    return 'Ein unerwarteter Fehler ist aufgetreten: $error';
  }

  @override
  String get toMain => 'Zur Startseite';

  @override
  String get signIn => 'Anmelden';

  @override
  String get errorId => 'Gültige ID eingeben';

  @override
  String get enterLogin => 'Ihre ID eingeben';

  @override
  String get signInDesktop => 'Anmelden (Desktop)';

  @override
  String get signInMobile => 'Anmelden (Mobil)';

  @override
  String welcome(String name) {
    return 'Willkommen bei $name';
  }

  @override
  String get start => 'Chatten beginnen';

  @override
  String callsCap(String platform) {
    return 'Hallo von der ANRUFE-Seite an den $platform-Benutzer!';
  }

  @override
  String get enterMessage => 'Nachricht eingeben';

  @override
  String get emptyChats => 'Hier ist noch nichts, starte eine Unterhaltung!';

  @override
  String get messageDeleted => 'Die Nachricht wurde gelöscht.';

  @override
  String get nameError => 'NAMENSFEHLER';

  @override
  String get wasRecently => 'zuletzt vor kurzem online';

  @override
  String get you => 'Du: ';

  @override
  String profileCap(String platform) {
    return 'Hallo von der PROFIL-Seite an den $platform-Benutzer!';
  }

  @override
  String get sectionVisual => 'Darstellung';

  @override
  String get dropdownTheme => 'Thema auswählen';

  @override
  String get dropdownAccent => 'Akzentfarbe auswählen';

  @override
  String get dropdownParticle => 'Partikeleffekt auswählen';

  @override
  String get labelProfile => 'Profil';

  @override
  String get labelChats => 'Nachrichten';

  @override
  String get labelCalls => 'Anrufe';

  @override
  String get labelSettings => 'Einstellungen';

  @override
  String get labelMusic => 'Musik';

  @override
  String get labelUnknown => 'Unbekannt';

  @override
  String get searchBar => 'Suchen...';

  @override
  String get chooseLang => 'Sprache auswählen';

  @override
  String get useGlass => 'verwenden Sie ein Glasdesign';

  @override
  String get saveSettings => 'einstellungen speichern';

  @override
  String get logout => 'Abmelden';
}
