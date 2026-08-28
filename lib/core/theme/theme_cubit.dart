import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

import '../utils/json_loader.dart';
import 'theme_builder.dart';
import 'theme_extension.dart';
import 'theme_list.dart';

import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit(this._deviceBrightness) : super(ThemeState(
    base: _deviceBrightness == Brightness.dark ? .dark : .light,
  ));
  final Brightness _deviceBrightness;

  Future<void> init() async {
    await _buildTheme(base: state.base, accent: state.accent);
  }

  Future<void> setTheme({
    AppBaseThemeType? base,
    AppAccentThemeType? accent
  }) async {
    await _buildTheme(base: base ?? state.base, accent: accent ?? state.accent);
  }

  Future<void> _buildTheme({
    required AppBaseThemeType base,
    required AppAccentThemeType accent
  }) async {
    final basePath = 'assets/themes/base/${base.name}.json';
    final accentPath = 'assets/themes/accent/${accent.name}.json';

    final baseJson = await JsonLoader.load(basePath);
    final accentJson = await JsonLoader.load(accentPath);

    final theme = ThemeBuilder.build(base: baseJson, accent: accentJson);

    emit(state.copyWith(
      base: base,
      accent: accent,
      theme: theme
    ));
  }
}
