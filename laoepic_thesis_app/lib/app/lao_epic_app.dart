import 'package:flutter/material.dart';
import 'package:laoepic_thesis_app/app/auth_check_page.dart';
import 'package:laoepic_thesis_app/providers/api_locale_provider.dart';
import 'package:laoepic_thesis_app/theme/app_theme.dart';
import 'package:laoepic_thesis_app/shared/utils/responsive_layout.dart';
import 'package:provider/provider.dart';

/// Root [MaterialApp]: theme, locale, text scaling, and auth gate.
class LaoEpicApp extends StatelessWidget {
  const LaoEpicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ApiLocaleProvider>(
      builder: (context, apiLocale, _) {
        return MaterialApp(
          locale: ApiLocaleProvider.materialLocaleFrom(apiLocale.code),
          theme: AppTheme.light(apiLocale.code),
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: ResponsiveLayout.textScaler(context)),
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: AuthCheckPage(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
