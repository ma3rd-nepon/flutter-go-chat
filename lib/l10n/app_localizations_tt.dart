// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tatar (`tt`).
class AppLocalizationsTt extends AppLocalizations {
  AppLocalizationsTt([String locale = 'tt']) : super(locale);

  @override
  String unexpectError(String error) {
    return 'Көтелмәгән хата килеп чыкты: $error';
  }

  @override
  String get toMain => 'Баш биткә';

  @override
  String get signIn => 'Керү';

  @override
  String get errorId => 'Дөрес ID кертегез';

  @override
  String get enterLogin => 'ID-ыгызны кертегез';

  @override
  String get signInDesktop => 'Керү (Компьютер)';

  @override
  String get signInMobile => 'Керү (Мобиль версия)';

  @override
  String welcome(String name) {
    return '$name га рәхим итегез';
  }

  @override
  String get start => 'Языша башлау';

  @override
  String callsCap(String platform) {
    return 'ШАЛТЫРАТУЛАР битеннән сәлам, $platform кулланучысы!';
  }

  @override
  String get enterMessage => 'Хәбәр языгыз';

  @override
  String get emptyChats => 'Әлегә монда буш, аралаша башлагыз!';

  @override
  String get messageDeleted => 'Хәбәр бетерелде.';

  @override
  String get nameError => 'ИСЕМ ХАТАСЫ';

  @override
  String get wasRecently => 'күптән түгел челтәрдә булган';

  @override
  String get you => 'Сез: ';

  @override
  String profileCap(String platform) {
    return 'ПРОФИЛЬ битеннән сәлам, $platform кулланучысы!';
  }

  @override
  String get sectionVisual => 'Тышкы күренеш';

  @override
  String get dropdownTheme => 'Тема сайлагыз';

  @override
  String get dropdownAccent => 'Төс акцентын сайлагыз';

  @override
  String get dropdownParticle => 'Кисәкчәләр эффектын сайлагыз';

  @override
  String get labelProfile => 'Профиль';

  @override
  String get labelChats => 'Хәбәрләр';

  @override
  String get labelCalls => 'Шалтыратулар';

  @override
  String get labelSettings => 'Көйләүләр';

  @override
  String get labelMusic => 'Музыка';

  @override
  String get labelUnknown => 'Билгесез';

  @override
  String get searchBar => 'Эзләү...';

  @override
  String get chooseLang => 'Sprache auswählen';

  @override
  String get useGlass => 'verwenden Sie ein Glasdesign';

  @override
  String get saveSettings => 'einstellungen speichern';

  @override
  String get logout => 'Вийти';
}
