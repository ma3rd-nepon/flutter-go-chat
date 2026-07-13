import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tt.dart';
import 'app_localizations_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('fr'),
    Locale('ru'),
    Locale('tt'),
    Locale('uk')
  ];

  /// Error occured text
  ///
  /// In en, this message translates to:
  /// **'Unexpected error occured: {error}'**
  String unexpectError(String error);

  /// To main screen text
  ///
  /// In en, this message translates to:
  /// **'To Main Screen'**
  String get toMain;

  /// Sign in text on Login Page
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// Error ID text on Login page
  ///
  /// In en, this message translates to:
  /// **'Enter valid ID'**
  String get errorId;

  /// Enter login on Login page
  ///
  /// In en, this message translates to:
  /// **'Enter your ID'**
  String get enterLogin;

  /// Sign in text on Login page button from desktop
  ///
  /// In en, this message translates to:
  /// **'Sign in (Desktop)'**
  String get signInDesktop;

  /// Sign in text on Login page button from mobile
  ///
  /// In en, this message translates to:
  /// **'Sign in (Mobile)'**
  String get signInMobile;

  /// Greetings text on Welcome page
  ///
  /// In en, this message translates to:
  /// **'Welcome to the {name}'**
  String welcome(String name);

  /// Start button text
  ///
  /// In en, this message translates to:
  /// **'Start Messaging'**
  String get start;

  /// Cap for Calls Page
  ///
  /// In en, this message translates to:
  /// **'Hello from CALLS Page to {platform} user!'**
  String callsCap(String platform);

  /// Enter a message text field in chats
  ///
  /// In en, this message translates to:
  /// **'Enter a message'**
  String get enterMessage;

  /// Message for empty chat list or chat
  ///
  /// In en, this message translates to:
  /// **'While it\'s empty, start chatting!'**
  String get emptyChats;

  /// Text for deleted message
  ///
  /// In en, this message translates to:
  /// **'The message was deleted.'**
  String get messageDeleted;

  /// Name error in chats
  ///
  /// In en, this message translates to:
  /// **'NAME ERROR'**
  String get nameError;

  /// User status in chats/profile
  ///
  /// In en, this message translates to:
  /// **'last seen recently'**
  String get wasRecently;

  /// yoo wassup
  ///
  /// In en, this message translates to:
  /// **'You: '**
  String get you;

  /// Profile page cap
  ///
  /// In en, this message translates to:
  /// **'Hello from PROFILE page to {platform} user!'**
  String profileCap(String platform);

  /// Name of Visual section in Settings
  ///
  /// In en, this message translates to:
  /// **'Visual'**
  String get sectionVisual;

  /// dropdownMenu text for Theme
  ///
  /// In en, this message translates to:
  /// **'choose a Theme'**
  String get dropdownTheme;

  /// dropdownMenu text for Accent
  ///
  /// In en, this message translates to:
  /// **'choose an Accent'**
  String get dropdownAccent;

  /// dropdownMenu text for Particles
  ///
  /// In en, this message translates to:
  /// **'choose a Particle Preset'**
  String get dropdownParticle;

  /// Name of the profile button in navigation bar
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get labelProfile;

  /// Name of the chats button in navigation bar
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get labelChats;

  /// Name of the calls button in navigation bar
  ///
  /// In en, this message translates to:
  /// **'Calls'**
  String get labelCalls;

  /// Name of the settings button in navigation bar
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get labelSettings;

  /// Name of the music button in navigation bar
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get labelMusic;

  /// Name of the unknown button in navigation bar
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get labelUnknown;

  /// Search field in App bar
  ///
  /// In en, this message translates to:
  /// **'Search smth...'**
  String get searchBar;

  /// Choose language text
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get chooseLang;

  /// Use Glass text
  ///
  /// In en, this message translates to:
  /// **'Use Glass UI'**
  String get useGlass;

  /// save settings text
  ///
  /// In en, this message translates to:
  /// **'Save Settings'**
  String get saveSettings;

  /// Logout button in settings
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en', 'fr', 'ru', 'tt', 'uk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
    case 'fr': return AppLocalizationsFr();
    case 'ru': return AppLocalizationsRu();
    case 'tt': return AppLocalizationsTt();
    case 'uk': return AppLocalizationsUk();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
