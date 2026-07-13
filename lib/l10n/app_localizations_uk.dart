// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String unexpectError(String error) {
    return 'Сталася неочікувана помилка: $error';
  }

  @override
  String get toMain => 'На головний екран';

  @override
  String get signIn => 'Увійти';

  @override
  String get errorId => 'Введіть коректний ID';

  @override
  String get enterLogin => 'Введіть ваш ID';

  @override
  String get signInDesktop => 'Увійти (ПК)';

  @override
  String get signInMobile => 'Увійти (Мобільна версія)';

  @override
  String welcome(String name) {
    return 'Ласкаво просимо до $name';
  }

  @override
  String get start => 'Почати спілкування';

  @override
  String callsCap(String platform) {
    return 'Вітаємо зі сторінки ДЗВІНКІВ, користувачу $platform!';
  }

  @override
  String get enterMessage => 'Введіть повідомлення';

  @override
  String get emptyChats => 'Тут поки порожньо, почніть спілкування!';

  @override
  String get messageDeleted => 'Повідомлення було видалено.';

  @override
  String get nameError => 'ПОМИЛКА ІМЕНІ';

  @override
  String get wasRecently => 'був(ла) нещодавно онлайн';

  @override
  String get you => 'Ви: ';

  @override
  String profileCap(String platform) {
    return 'Вітаємо зі сторінки ПРОФІЛЮ, користувачу $platform!';
  }

  @override
  String get sectionVisual => 'Зовнішній вигляд';

  @override
  String get dropdownTheme => 'Оберіть тему';

  @override
  String get dropdownAccent => 'Оберіть акцентний колір';

  @override
  String get dropdownParticle => 'Оберіть ефект частинок';

  @override
  String get labelProfile => 'Профіль';

  @override
  String get labelChats => 'Повідомлення';

  @override
  String get labelCalls => 'Дзвінки';

  @override
  String get labelSettings => 'Налаштування';

  @override
  String get labelMusic => 'Музика';

  @override
  String get labelUnknown => 'Невідомо';

  @override
  String get searchBar => 'Пошук...';

  @override
  String get chooseLang => 'Вибрати мову';

  @override
  String get useGlass => 'Використовуйте скляний дизайн';

  @override
  String get saveSettings => 'Зберегти налаштування';

  @override
  String get logout => 'Вийти';
}
