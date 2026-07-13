// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String unexpectError(String error) {
    return 'Une erreur inattendue est survenue : $error';
  }

  @override
  String get toMain => 'Retour à l\'accueil';

  @override
  String get signIn => 'Se connecter';

  @override
  String get errorId => 'Entrez un ID valide';

  @override
  String get enterLogin => 'Entrez votre ID';

  @override
  String get signInDesktop => 'Se connecter (Bureau)';

  @override
  String get signInMobile => 'Se connecter (Mobile)';

  @override
  String welcome(String name) {
    return 'Bienvenue sur $name';
  }

  @override
  String get start => 'Commencer à discuter';

  @override
  String callsCap(String platform) {
    return 'Bonjour depuis la page APPELS, utilisateur $platform !';
  }

  @override
  String get enterMessage => 'Entrez un message';

  @override
  String get emptyChats => 'C\'est vide pour le moment, commencez une conversation !';

  @override
  String get messageDeleted => 'Le message a été supprimé.';

  @override
  String get nameError => 'ERREUR DE NOM';

  @override
  String get wasRecently => 'vu récemment';

  @override
  String get you => 'Vous : ';

  @override
  String profileCap(String platform) {
    return 'Bonjour depuis la page PROFIL, utilisateur $platform !';
  }

  @override
  String get sectionVisual => 'Apparence';

  @override
  String get dropdownTheme => 'Choisir un thème';

  @override
  String get dropdownAccent => 'Choisir une couleur d\'accent';

  @override
  String get dropdownParticle => 'Choisir un effet de particules';

  @override
  String get labelProfile => 'Profil';

  @override
  String get labelChats => 'Messages';

  @override
  String get labelCalls => 'Appels';

  @override
  String get labelSettings => 'Paramètres';

  @override
  String get labelMusic => 'Musique';

  @override
  String get labelUnknown => 'Inconnu';

  @override
  String get searchBar => 'Rechercher...';

  @override
  String get chooseLang => 'Choisir la langue';

  @override
  String get useGlass => 'Utiliser la conception en verre';

  @override
  String get saveSettings => 'Enregistrer les paramètres';

  @override
  String get logout => 'Se déconnecter';
}
