import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/habit_tracker_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/home_screen.dart';
import 'utils/constants.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()..loadSettings()),
        ChangeNotifierProvider(create: (_) => HabitTrackerProvider()..loadAll()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: 'ddxHabits',
            debugShowCheckedModeBanner: false,
            themeMode: _getThemeMode(settings.themeMode),
            theme: _buildLightTheme(),
            darkTheme: _buildDarkTheme(settings.themeMode),
            home: const HomeScreen(),
          );
        },
      ),
    );
  }

  ThemeMode _getThemeMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
      case AppThemeMode.system:
        return ThemeMode.dark;
    }
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.mintDark,
        primary: AppColors.mintDark,
        secondary: AppColors.mint,
        surface: AppColors.background,
      ),
      scaffoldBackgroundColor: AppColors.background,
      useMaterial3: true,
    );
  }

  ThemeData _buildDarkTheme(AppThemeMode mode) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.darkGreenPrimary,
        primary: AppColors.darkGreenPrimary,
        secondary: AppColors.darkGreenAccent,
        surface: AppColors.darkGreenSurface,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: AppColors.darkGreenBg,
      useMaterial3: true,
    );
  }
}
