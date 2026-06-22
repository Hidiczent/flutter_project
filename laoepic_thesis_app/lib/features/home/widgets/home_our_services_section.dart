
import 'package:flutter/material.dart';
import 'package:laoepic_thesis_app/i18n/i18n_keys.dart';
import 'package:laoepic_thesis_app/i18n/ui_i18n.dart';
import 'package:laoepic_thesis_app/theme/app_colors.dart';
import 'package:provider/provider.dart';

/// Grid of service categories explaining what Lao Epic offers to travelers.
class HomeOurServicesSection extends StatelessWidget {
  const HomeOurServicesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final i18n = context.watch<UiI18n>();
    final items = [
      (Icons.explore_outlined, I18nKey.homeServiceDiscover),
      (Icons.verified_user_outlined, I18nKey.homeServiceTrusted),
      (Icons.support_agent_outlined, I18nKey.homeServiceSupport),
      (Icons.payments_outlined, I18nKey.homeServiceSecurePay),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          i18n.tr(I18nKey.homeOurServicesTitle),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.35,
          children: [
            for (final item in items)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(item.$1, color: AppColors.primary, size: 28),
                    const Spacer(),
                    Text(
                      i18n.tr(item.$2),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}
