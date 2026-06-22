import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:laoepic_thesis_app/i18n/i18n_keys.dart';
import 'package:laoepic_thesis_app/i18n/ui_i18n.dart';
import 'package:laoepic_thesis_app/shared/utils/guide_display.dart';

enum PackageGuideCardVariant { compact, expanded }

/// Public guide profile card (no email/phone) — mirrors web `PackageGuideCard`.
class PackageGuideCard extends StatelessWidget {
  final GuideCardView guide;
  final PackageGuideCardVariant variant;

  const PackageGuideCard({
    super.key,
    required this.guide,
    this.variant = PackageGuideCardVariant.compact,
  });

  @override
  Widget build(BuildContext context) {
    final i18n = context.read<UiI18n>();
    final isCompact = variant == PackageGuideCardVariant.compact;
    final avatarSize = isCompact ? 88.0 : 108.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isCompact ? 16 : 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF084887).withValues(alpha: 0.15),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFF8FAFC),
            Colors.white,
            // const Color(0xFF084887).withValues(alpha: 0.04),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _GuideAvatar(url: guide.avatarUrl, size: avatarSize),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF58A07).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        i18n.tr(I18nKey.aboutGuide).toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: Color(0xFFF58A07),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      guide.name,
                      style: TextStyle(
                        fontSize: isCompact ? 18 : 22,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1A2332),
                      ),
                    ),
                    if (guide.bio != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        guide.bio!,
                        maxLines: isCompact ? 3 : 5,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isCompact ? 13 : 14,
                          height: 1.45,
                          color: Colors.blueGrey.shade700,
                        ),
                      ),
                    ],
                    if (guide.languages.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children:
                            guide.languages
                                .map(
                                  (lang) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(
                                          0xFF084887,
                                        ).withValues(alpha: 0.2),
                                      ),
                                    ),
                                    child: Text(
                                      lang,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF084887),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: const Color(0xFF084887).withValues(alpha: 0.1)),
          const SizedBox(height: 4),
          Text(
            i18n.tr(I18nKey.packageGuideNote),
            style: TextStyle(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              height: 1.35,
              color: Colors.blueGrey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideAvatar extends StatelessWidget {
  final String url;
  final double size;

  const _GuideAvatar({required this.url, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF084887).withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: size / 2,
        backgroundColor: const Color(0xFF084887).withValues(alpha: 0.08),
        backgroundImage: url.isNotEmpty ? NetworkImage(url) : null,
        onBackgroundImageError: (_, _) {},
        child:
            url.isEmpty
                ? Icon(
                  Icons.person,
                  size: size * 0.45,
                  color: const Color(0xFF084887),
                )
                : null,
      ),
    );
  }
}
