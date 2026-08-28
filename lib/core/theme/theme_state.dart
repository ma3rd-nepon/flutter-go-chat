import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';

import 'theme_list.dart';

part 'theme_state.freezed.dart';

@freezed
abstract class ThemeState with _$ThemeState {
  const factory ThemeState({
    @Default(AppBaseThemeType.dark)
    AppBaseThemeType base,

    @Default(AppAccentThemeType.pink)
    AppAccentThemeType accent,

    ThemeData? theme    
  }) = _ThemeState;
}