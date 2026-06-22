import 'package:laoepic_thesis_app/i18n/ui_i18n.dart';
import 'package:laoepic_thesis_app/providers/package_detail_provider.dart';
import 'package:laoepic_thesis_app/providers/api_locale_provider.dart';
import 'package:laoepic_thesis_app/providers/bottom_nav_provider.dart';
import 'package:laoepic_thesis_app/providers/favorite_provider.dart';
import 'package:laoepic_thesis_app/providers/package_provider.dart';
import 'package:laoepic_thesis_app/providers/price_display_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/// Global [ChangeNotifier] providers for the app shell.
List<SingleChildWidget> buildAppProviders(UiI18n uiI18n) {
  return [
    ChangeNotifierProvider<UiI18n>.value(value: uiI18n),
    ChangeNotifierProvider(
      create: (context) {
        final i18n = context.read<UiI18n>();
        final loc =
            ApiLocaleProvider()..onLocaleChanged = i18n.syncFromLocaleCode;
        loc.load();
        return loc;
      },
    ),
    ChangeNotifierProvider(create: (_) => BottomNavProvider()),
    ChangeNotifierProvider(create: (_) => FavoriteProvider()),
    ChangeNotifierProvider(create: (_) => PackageProvider()),
    ChangeNotifierProvider(create: (_) => PackageDetailProvider()),
    ChangeNotifierProvider(create: (_) => PriceDisplayProvider()..load()),
  ];
}
