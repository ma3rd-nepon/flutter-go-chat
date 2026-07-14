import 'package:flutter/material.dart';
import 'package:flutter_go_chat/app/theme/theme_extension.dart';
import 'package:flutter_go_chat/app/theme/theme_list.dart';
import 'package:flutter_go_chat/core/services/app_scope/scope.dart';
import 'package:flutter_go_chat/core/layers/particles/particle_preset.dart';
import 'package:flutter_go_chat/l10n/locale_list.dart';
import 'package:flutter_go_chat/core/extensions/l10n_extension.dart';
import 'package:flutter_go_chat/features/settings/widgets/divider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final g = AppScope.of(context);
    final colors = Theme.of(context).extension<AppThemeExtension>()!.colors;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: .start,
              crossAxisAlignment: .start,
              spacing: 30,
              children: [
                Text(context.l10n.sectionVisual),

                const NovaDivider(),

                Row(
                  mainAxisAlignment: .start,
                  children: [
                    DropdownMenu<AppThemeType>(
                      initialSelection: g.settingsController.currentTheme,
                      label: Text(context.l10n.dropdownTheme),
                      dropdownMenuEntries: AppThemeType.values
                          .map(
                            (theme) => DropdownMenuEntry(
                              label: theme.label,
                              value: theme,
                            ),
                          )
                          .toList(),
                      onSelected: (value) {
                        g.settingsController.changeTheme(value, null);
                      },
                    ),
                    const SizedBox(width: 30),
                    DropdownMenu<AppAccentType>(
                      initialSelection: g.settingsController.currentAccent,
                      label: Text(context.l10n.dropdownAccent),
                      dropdownMenuEntries: AppAccentType.values
                          .map(
                            (accent) => DropdownMenuEntry(
                              label: accent.label,
                              value: accent,
                            ),
                          )
                          .toList(),
                      onSelected: (value) {
                        g.settingsController.changeTheme(null, value);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                const NovaDivider(),

                const SizedBox(height: 20),
                // Row(children: [
                //   Expanded(child: TextField(decoration: InputDecoration(hintText: "set wallpaper URL"), controller: wallpController)),
                //   IconButton(
                //     icon: Icon(AppIcons.easterEgg),
                //     onPressed: () { g.changeWallpaperType(wallpController.text.trim()); wallpController.clear(); },
                //   )
                // ]),
                DropdownMenu<ParticlePreset>(
                  label: Text(context.l10n.dropdownParticle),
                  // dropdownMenuEntries: [
                  //   DropdownMenuEntry(value: "network", label: "Network"),
                  //   DropdownMenuEntry(value: "snow", label: "Snow"),
                  //   DropdownMenuEntry(value: "rain", label: "Rain"),
                  //   DropdownMenuEntry(value: "dust", label: "Dust"),
                  //   DropdownMenuEntry(value: "starrain", label: "Star Rain"),
                  // ],
                  dropdownMenuEntries: g.settingsController.particlePresets
                      .map(
                        (preset) => DropdownMenuEntry(
                          label: preset.label,
                          value: preset,
                        ),
                      )
                      .toList(),
                  onSelected: (value) {
                    g.settingsController.changeParticlePreset(value!);
                  },
                ),

                const SizedBox(height: 20),

                const NovaDivider(),

                const SizedBox(height: 20),

                DropdownMenu<LocaleList>(
                  initialSelection: LocaleList.values.firstWhere(
                    (locale) =>
                        locale.name == g.settingsController.currentLocale,
                    orElse: () => LocaleList.en,
                  ),
                  label: Text(
                    context.l10n.chooseLang,
                  ), // context.l10n.dropdownLanguage
                  dropdownMenuEntries: LocaleList.values
                      .map(
                        (locale) => DropdownMenuEntry(
                          label: locale.label,
                          value: locale,
                        ),
                      )
                      .toList(),
                  onSelected: (value) {
                    g.settingsController.changeLanguage(value?.name ?? "en");
                  },
                ),

                const SizedBox(height: 20),

                const NovaDivider(),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Text(context.l10n.useGlass),
                    Checkbox(
                      value: g.settingsController.useGlass,
                      onChanged: (value) {
                        if (value != null) {
                          g.settingsController.toggleGlass(value);
                        }
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                const NovaDivider(),

                const SizedBox(height: 20),

                Row(
                  mainAxisSize: .min,
                  children: [Text("This will be a background settings ^^")],
                ),

                const SizedBox(height: 20),

                const NovaDivider(),

                const SizedBox(height: 20),

                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await g.settingsController.save();
                      },
                      child: Text(context.l10n.saveSettings),
                    ),

                    const SizedBox(width: 20),

                    ElevatedButton(
                      onPressed: () async {
                        await g.authController.logout();

                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/welcome',
                          (route) => false,
                        );
                      },
                      child: Text(context.l10n.logout),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                const NovaDivider(),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Over the last two days, the application design has been completely reworked from the ground up. The UI architecture was redesigned twice to establish a flexible foundation for future customization and visual improvements. A custom design system was introduced, including reusable surface widgets and theme infrastructure. Numerous layout and overflow issues across different screen sizes were resolved, resulting in a more stable responsive interface. Full settings support was implemented, covering themes, accents, localization, visual preferences, and persistence. User profile functionality and interface components were also added and integrated into the overall application structure. These changes provide a solid base for future features such as advanced glass effects, shaders, wallpapers, and further UI enhancements.",
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
