
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:laoepic_thesis_app/i18n/i18n_keys.dart';
import 'package:laoepic_thesis_app/i18n/ui_i18n.dart';
import 'package:laoepic_thesis_app/theme/app_colors.dart';
import 'package:provider/provider.dart';

enum AppFeedbackKind { success, businessNotice, warning, info, error }

class _FeedbackStyle {
  const _FeedbackStyle({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.accentStripe,
    required this.ctaForeground,
    required this.ctaBackground,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final Color accentStripe;
  final Color ctaForeground;
  final Color ctaBackground;
}

_FeedbackStyle _styleFor(AppFeedbackKind kind) {
  switch (kind) {
    case AppFeedbackKind.success:
      return const _FeedbackStyle(
        icon: Icons.check_circle_rounded,
        iconColor: Color(0xFF2E7D32),
        iconBg: Color(0xFFE8F5E9),
        accentStripe: Color(0xFF2E7D32),
        ctaForeground: Colors.white,
        ctaBackground: Color(0xFF2E7D32),
      );
    case AppFeedbackKind.businessNotice:
      return const _FeedbackStyle(
        icon: Icons.policy_outlined,
        iconColor: AppColors.primary,
        iconBg: Color(0xFFE8EEF6),
        accentStripe: AppColors.primary,
        ctaForeground: Colors.white,
        ctaBackground: AppColors.primary,
      );
    case AppFeedbackKind.warning:
      return const _FeedbackStyle(
        icon: Icons.info_outline_rounded,
        iconColor: Color(0xFFE65100),
        iconBg: Color(0xFFFFF4E8),
        accentStripe: AppColors.accent,
        ctaForeground: Colors.white,
        ctaBackground: AppColors.accent,
      );
    case AppFeedbackKind.info:
      return const _FeedbackStyle(
        icon: Icons.lightbulb_outline_rounded,
        iconColor: AppColors.primary,
        iconBg: Color(0xFFE3EEF7),
        accentStripe: AppColors.primary,
        ctaForeground: Colors.white,
        ctaBackground: AppColors.primary,
      );
    case AppFeedbackKind.error:
      return const _FeedbackStyle(
        icon: Icons.cloud_off_outlined,
        iconColor: Color(0xFF546E7A),
        iconBg: Color(0xFFECEFF1),
        accentStripe: Color(0xFF78909C),
        ctaForeground: Colors.white,
        ctaBackground: AppColors.primary,
      );
  }
}

String _defaultTitle(UiI18n i18n, AppFeedbackKind kind) {
  switch (kind) {
    case AppFeedbackKind.success:
      return i18n.tr(I18nKey.feedbackSuccess);
    case AppFeedbackKind.businessNotice:
      return i18n.tr(I18nKey.feedbackBusinessNoticeTitle);
    case AppFeedbackKind.warning:
      return i18n.tr(I18nKey.feedbackWarning);
    case AppFeedbackKind.info:
      return i18n.tr(I18nKey.feedbackInfo);
    case AppFeedbackKind.error:
      return i18n.tr(I18nKey.feedbackTechnicalIssueTitle);
  }
}

String? _hintFor(AppFeedbackKind kind, UiI18n i18n) {
  switch (kind) {
    case AppFeedbackKind.businessNotice:
      return i18n.tr(I18nKey.feedbackBusinessNoticeHint);
    case AppFeedbackKind.error:
      return i18n.tr(I18nKey.feedbackTechnicalIssueHint);
    case AppFeedbackKind.success:
    case AppFeedbackKind.warning:
    case AppFeedbackKind.info:
      return null;
  }
}

/// Parses API / JSON error bodies into a short user-facing string.
String parseApiFeedbackMessage(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return trimmed;
  try {
    final decoded = jsonDecode(trimmed);
    if (decoded is Map) {
      final msg = decoded['message']?.toString();
      if (msg != null && msg.isNotEmpty) return msg;
    }
  } catch (_) {}
  if (trimmed.startsWith('{') && trimmed.contains('"message"')) {
    final match = RegExp(r'"message"\s*:\s*"([^"]+)"').firstMatch(trimmed);
    if (match != null) return match.group(1) ?? trimmed;
  }
  return trimmed;
}

/// Shows a styled dialog for success, error, warning, or info feedback to the traveler.
Future<void> showAppFeedback(
  BuildContext context, {
  required String message,
  AppFeedbackKind kind = AppFeedbackKind.info,
  String? title,
  bool showHint = true,
}) async {
  if (!context.mounted) return;
  final i18n = context.read<UiI18n>();
  final style = _styleFor(kind);
  final resolvedTitle = title ?? _defaultTitle(i18n, kind);
  final hint = showHint ? _hintFor(kind, i18n) : null;

  await showDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.42),
    builder: (dialogContext) {
      return Dialog(
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        backgroundColor: Colors.transparent,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.94, end: 1),
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          builder: (context, scale, child) {
            return Transform.scale(scale: scale, child: child);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.14),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                  spreadRadius: -4,
                ),
              ],
              border: Border.all(color: const Color(0xFFE8ECF0)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(height: 4, color: style.accentStripe),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 26, 24, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: style.iconBg,
                          shape: BoxShape.circle,
                        ),
                        child:
                            Icon(style.icon, color: style.iconColor, size: 32),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        resolvedTitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                          color: Color(0xFF1A2332),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: Colors.blueGrey.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (hint != null && hint.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blueGrey.shade50.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blueGrey.shade100),
                          ),
                          child: Text(
                            hint,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.45,
                              color: Colors.blueGrey.shade700,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: style.ctaBackground,
                            foregroundColor: style.ctaForeground,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          child: Text(
                            i18n.tr(I18nKey.commonOk),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

abstract final class AppFeedback {
  static String parseApiMessage(String raw) => parseApiFeedbackMessage(raw);

  static Future<void> showSuccess(
    BuildContext context, {
    required String message,
    String? title,
    bool showHint = false,
  }) => showAppFeedback(
    context,
    message: message,
    kind: AppFeedbackKind.success,
    title: title,
    showHint: showHint,
  );

  static Future<void> showBusinessNotice(
    BuildContext context, {
    required String message,
    String? title,
  }) => showAppFeedback(
    context,
    message: message,
    kind: AppFeedbackKind.businessNotice,
    title: title,
  );

  static Future<void> showError(
    BuildContext context, {
    required String message,
    String? title,
  }) => showAppFeedback(context, message: message, title: title, kind: AppFeedbackKind.error);

  static Future<void> showWarning(
    BuildContext context, {
    required String message,
    String? title,
  }) =>
      showAppFeedback(
        context,
        message: message,
        kind: AppFeedbackKind.warning,
        title: title,
        showHint: false,
      );

  static Future<void> showInfo(
    BuildContext context, {
    required String message,
    String? title,
  }) =>
      showAppFeedback(
        context,
        message: message,
        kind: AppFeedbackKind.info,
        title: title,
        showHint: false,
      );
}

extension AppFeedbackContext on BuildContext {
  Future<void> showSuccessMessage(
    String message, {
    String? title,
  }) =>
      AppFeedback.showSuccess(this, message: message, title: title);

  Future<void> showBusinessNoticeMessage(
    String message, {
    String? title,
  }) =>
      AppFeedback.showBusinessNotice(this, message: message, title: title);

  Future<void> showErrorMessage(
    String message, {
    String? title,
  }) =>
      AppFeedback.showError(this, message: message, title: title);

  Future<void> showInfoMessage(
    String message, {
    String? title,
  }) =>
      AppFeedback.showInfo(this, message: message, title: title);

  Future<void> showWarningMessage(
    String message, {
    String? title,
  }) =>
      AppFeedback.showWarning(this, message: message, title: title);
}
