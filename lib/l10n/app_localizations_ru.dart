// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String unexpectError(String error) {
    return 'Произошла непредвиденная ошибка: $error';
  }

  @override
  String get toMain => 'На главный экран';

  @override
  String get signIn => 'Войти';

  @override
  String get errorId => 'Введите корректный ID';

  @override
  String get enterLogin => 'Введите ваш ID';

  @override
  String get signInDesktop => 'Войти (ПК)';

  @override
  String get signInMobile => 'Войти (Мобильная версия)';

  @override
  String welcome(String name) {
    return 'Добро пожаловать в $name';
  }

  @override
  String get start => 'Начать общение';

  @override
  String callsCap(String platform) {
    return 'Привет со страницы ЗВОНКОВ, пользователь $platform!';
  }

  @override
  String get enterMessage => 'Введите сообщение';

  @override
  String get emptyChats => 'Пока здесь пусто, начните общение!';

  @override
  String get messageDeleted => 'Сообщение было удалено.';

  @override
  String get nameError => 'ОШИБКА ИМЕНИ';

  @override
  String get wasRecently => 'был(а) недавно в сети';

  @override
  String get you => 'Вы: ';

  @override
  String profileCap(String platform) {
    return 'Привет со страницы ПРОФИЛЯ, пользователь $platform!';
  }

  @override
  String get sectionVisual => 'Внешний вид';

  @override
  String get dropdownTheme => 'Выберите тему';

  @override
  String get dropdownAccent => 'Выберите акцентный цвет';

  @override
  String get dropdownParticle => 'Выберите эффект частиц';

  @override
  String get labelProfile => 'Профиль';

  @override
  String get labelChats => 'Сообщения';

  @override
  String get labelCalls => 'Звонки';

  @override
  String get labelSettings => 'Настройки';

  @override
  String get labelMusic => 'Музыка';

  @override
  String get labelUnknown => 'Неизвестно';

  @override
  String get searchBar => 'Поиск...';

  @override
  String get chooseLang => 'Выбрать язык';

  @override
  String get useGlass => 'Использовать Стеклянный дизайн';

  @override
  String get saveSettings => 'Сохранить настройки';

  @override
  String get logout => 'Выйти с учетной записи';
}
