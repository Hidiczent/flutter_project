import 'package:laoepic_thesis_app/config/app_config.dart';
import 'package:laoepic_thesis_app/data/models/package_model.dart';

/// View model for guide cards (mirrors web `guideDisplay.ts`).
class GuideCardView {
  final String name;
  final String? bio;
  final List<String> languages;
  final String avatarUrl;

  const GuideCardView({
    required this.name,
    this.bio,
    required this.languages,
    required this.avatarUrl,
  });
}

List<String> parseGuideLanguages(String? raw) {
  if (raw == null || raw.trim().isEmpty) return const [];
  return raw
      .split(RegExp(r'[,/|]'))
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();
}

GuideCardView? mapGuideToCard(GuideInfo? guide) {
  if (guide == null || guide.fullName.trim().isEmpty) return null;
  final avatar = guide.avatarUrl?.trim();
  return GuideCardView(
    name: guide.fullName.trim(),
    bio: guide.bio?.trim().isNotEmpty == true ? guide.bio!.trim() : null,
    languages: parseGuideLanguages(guide.languages),
    avatarUrl: avatar != null && avatar.isNotEmpty
        ? AppConfig.mediaUrl(avatar)
        : '',
  );
}

GuideInfo? guideFromJsonMap(Map<String, dynamic>? json) {
  if (json == null) return null;
  final g = json['guide'];
  if (g is! Map<String, dynamic>) return null;
  try {
    return GuideInfo.fromJson(g);
  } catch (_) {
    return null;
  }
}
