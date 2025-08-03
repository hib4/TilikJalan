import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tilikjalan/core/core.dart';
import 'package:tilikjalan/features/auth/auth.dart';
import 'package:tilikjalan/l10n/l10n.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return AppTheme(
      colorTheme: AppColors.colors(),
      textTheme: AppTextStyles.textStyles(),
      child: MaterialApp(
        title: 'TilikJalan',
        theme: AppThemeData.themeData().themeData,
        darkTheme: AppThemeData.themeData().themeData,
        themeMode: ThemeMode.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        debugShowCheckedModeBanner: false,
        home: const AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child: LoginPage(),
        ),
      ),
    );
  }
}
