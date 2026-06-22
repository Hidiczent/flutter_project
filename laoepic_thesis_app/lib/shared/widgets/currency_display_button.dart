
import 'package:flutter/material.dart';
import 'package:laoepic_thesis_app/i18n/ui_i18n.dart';
import 'package:laoepic_thesis_app/providers/price_display_provider.dart';
import 'package:laoepic_thesis_app/theme/app_colors.dart';
import 'package:provider/provider.dart';

/// Currency switcher (LAK / USD / THB) — mirrors web [CurrencyDisplaySelect].
class CurrencyDisplayButton extends StatelessWidget {
  final bool compact;

  const CurrencyDisplayButton({super.key, this.compact = false});

  String _label(PriceDisplayMode mode) {
    switch (mode) {
      case PriceDisplayMode.lak:
        return 'LAK';
      case PriceDisplayMode.usd:
        return 'USD';
      case PriceDisplayMode.thb:
        return 'THB';
    }
  }

  @override
  Widget build(BuildContext context) {
    final i18n = context.watch<UiI18n>();
    final pdp = context.watch<PriceDisplayProvider>();

    return ListTile(
      leading: Icon(
        Icons.payments_outlined,
        color: compact ? Colors.black87 : AppColors.primary,
      ),
      title: Text(i18n.tr('booking.price_display_label')),
      subtitle: Text(_label(pdp.mode)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showPicker(context, i18n, pdp),
    );
  }

  void _showPicker(BuildContext context, UiI18n i18n, PriceDisplayProvider pdp) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  i18n.tr('booking.price_display_label'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                for (final mode in PriceDisplayMode.values)
                  ListTile(
                    enabled: pdp.isModeAvailable(mode),
                    leading: Radio<PriceDisplayMode>(
                      value: mode,
                      groupValue: pdp.mode,
                      onChanged: pdp.isModeAvailable(mode)
                          ? (_) {
                            pdp.setMode(mode);
                            Navigator.pop(ctx);
                          }
                          : null,
                    ),
                    title: Text(_label(mode)),
                    subtitle: pdp.isModeAvailable(mode)
                        ? null
                        : Text(i18n.tr('booking.price_display_unavailable')),
                    onTap: pdp.isModeAvailable(mode)
                        ? () {
                          pdp.setMode(mode);
                          Navigator.pop(ctx);
                        }
                        : null,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
