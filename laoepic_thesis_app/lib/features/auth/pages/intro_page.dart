
import 'package:flutter/material.dart';
import 'package:laoepic_thesis_app/features/home/pages/home_page.dart';
import 'package:laoepic_thesis_app/i18n/i18n_keys.dart';
import 'package:laoepic_thesis_app/i18n/ui_i18n.dart';
import 'package:provider/provider.dart';
import 'package:laoepic_thesis_app/shared/utils/responsive_layout.dart';

/// Welcome splash shown after registration before entering the main app shell.
class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    final i18n = context.watch<UiI18n>();
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ResponsiveScrollBody(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const LaoEpicLogo(),
              SizedBox(height: ResponsiveLayout.gap(context, factor: 0.05)),
              Text(
                i18n.tr(I18nKey.introPlanYour),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.black54,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                i18n.tr(I18nKey.introEpicVacation),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
              ),
              SizedBox(height: ResponsiveLayout.gap(context, factor: 0.05)),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF084887),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    i18n.tr(I18nKey.introGetStarted),
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
