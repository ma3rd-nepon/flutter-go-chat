// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String unexpectError(String error) {
    return 'Unexpected error occured: $error';
  }

  @override
  String get toMain => 'To Main Screen';

  @override
  String get signIn => 'Sign in';

  @override
  String get errorId => 'Enter valid ID';

  @override
  String get enterLogin => 'Enter your ID';

  @override
  String get signInDesktop => 'Sign in (Desktop)';

  @override
  String get signInMobile => 'Sign in (Mobile)';

  @override
  String welcome(String name) {
    return 'Welcome to the $name';
  }

  @override
  String get start => 'Start Messaging';

  @override
  String callsCap(String platform) {
    return 'Hello from CALLS Page to $platform user!';
  }

  @override
  String get enterMessage => 'Enter a message';

  @override
  String get emptyChats => 'While it\'s empty, start chatting!';

  @override
  String get messageDeleted => 'The message was deleted.';

  @override
  String get nameError => 'NAME ERROR';

  @override
  String get wasRecently => 'last seen recently';

  @override
  String get you => 'You: ';

  @override
  String profileCap(String platform) {
    return 'Hello from PROFILE page to $platform user!';
  }

  @override
  String get sectionVisual => 'Visual';

  @override
  String get dropdownTheme => 'choose a Theme';

  @override
  String get dropdownAccent => 'choose an Accent';

  @override
  String get dropdownParticle => 'choose a Particle Preset';

  @override
  String get labelProfile => 'Profile';

  @override
  String get labelChats => 'Messages';

  @override
  String get labelCalls => 'Calls';

  @override
  String get labelSettings => 'Settings';

  @override
  String get labelMusic => 'Music';

  @override
  String get labelUnknown => 'Unknown';

  @override
  String get searchBar => 'Search smth...';

  @override
  String get chooseLang => 'Choose Language';

  @override
  String get useGlass => 'Use Glass UI';

  @override
  String get saveSettings => 'Save Settings';

  @override
  String get logout => 'Log out';
}
