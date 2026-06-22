
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:laoepic_thesis_app/core/api/api_locale_prefs.dart';
import 'package:laoepic_thesis_app/config/app_config.dart';
import 'package:laoepic_thesis_app/i18n/i18n_keys.dart';
import 'package:laoepic_thesis_app/i18n/ui_i18n.dart';
import 'package:laoepic_thesis_app/shared/widgets/app_feedback.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Loads cancellation policy from the API or local cache.
Future<Map<String, dynamic>?> fetchCancellationPolicy() async {
  try {
    final res = await http.get(
      Uri.parse('${AppConfig.baseUrl}/bookings/cancellation-policy'),
      headers: await buildPublicApiHeaders(),
    );
    if (res.statusCode != 200) return null;
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (body['success'] == true && body['data'] is Map) {
      return Map<String, dynamic>.from(body['data'] as Map);
    }
  } catch (_) {}
  return null;
}

/// Maps raw cancellation API errors to localized, user-friendly messages.
String humanizeCancelError(UiI18n i18n, String msg) {
  final lower = msg.toLowerCase();
  if (lower.contains('cancellation is only allowed') ||
      lower.contains('days before departure')) {
    return i18n.tr(I18nKey.historyCancelTooLate, params: {'days': '7'});
  }
  return i18n.tr(I18nKey.historyCancelFailGeneric);
}

/// Calls the backend to cancel a booking and returns the parsed response payload.
Future<bool> submitBookingCancel({
  required BuildContext context,
  required int bookingId,
  required String reason,
}) async {
  final i18n = context.read<UiI18n>();
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('jwt_token');
  if (token == null) return false;

  final response = await http.post(
    Uri.parse('${AppConfig.baseUrl}/bookings/$bookingId/cancel'),
    headers: {
      ...await buildAuthApiHeaders(token),
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'reason': reason.isEmpty ? 'Cancelled by user' : reason,
    }),
  );

  final body = jsonDecode(response.body) as Map<String, dynamic>;
  if (response.statusCode == 200 && body['success'] == true) {
    final mode = body['data'] is Map
        ? (body['data'] as Map)['mode']?.toString()
        : null;
    final message = mode == 'request'
        ? i18n.tr(I18nKey.historyCancelRequestSubmitted)
        : i18n.tr(I18nKey.historyCancelSuccess);
    if (context.mounted) {
      await AppFeedback.showSuccess(context, message: message);
    }
    return true;
  }

  if (context.mounted) {
    final parsed = humanizeCancelError(
      i18n,
      AppFeedback.parseApiMessage(response.body).isNotEmpty
          ? AppFeedback.parseApiMessage(response.body)
          : (body['message']?.toString() ?? ''),
    );
    await AppFeedback.showError(context, message: parsed);
  }
  return false;
}

/// Presents the cancellation policy and confirmation dialog for an active booking.
Future<void> showCancelBookingDialog(
  BuildContext context, {
  required int bookingId,
  required bool isRequestCancel,
  VoidCallback? onSuccess,
}) async {
  final i18n = context.read<UiI18n>();
  final reasonController = TextEditingController();
  final policy = await fetchCancellationPolicy();
  if (!context.mounted) return;

  final policyTitle =
      policy?['title']?.toString() ?? i18n.tr(I18nKey.historyCancelPolicyTitle);
  final rules =
      (policy?['rules'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .where((s) => s.isNotEmpty)
          .toList() ??
      <String>[];

  var policyAccepted = false;

  await showDialog<void>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) {
        final confirmText = isRequestCancel
            ? i18n.tr(I18nKey.historyCancelConfirmRequest)
            : i18n.tr(I18nKey.historyCancelConfirm);
        final canSubmit = rules.isEmpty || policyAccepted;

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red.shade400),
              const SizedBox(width: 10),
              Expanded(child: Text(i18n.tr(I18nKey.historyCancelTitle))),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  confirmText,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: Colors.blueGrey.shade700,
                  ),
                ),
                if (rules.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFE082)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          policyTitle,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: Colors.amber.shade900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...rules.map(
                          (rule) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text('• $rule', style: const TextStyle(fontSize: 12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  CheckboxListTile(
                    value: policyAccepted,
                    onChanged: (v) {
                      setDialogState(() => policyAccepted = v ?? false);
                    },
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(i18n.tr(I18nKey.historyCancelPolicyAgree)),
                  ),
                ],
                const SizedBox(height: 16),
                TextField(
                  controller: reasonController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: i18n.tr(I18nKey.historyReasonLabel),
                    hintText: i18n.tr(I18nKey.historyReasonHint),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(i18n.tr(I18nKey.commonClose)),
            ),
            FilledButton.icon(
              onPressed: canSubmit
                  ? () async {
                    Navigator.pop(ctx);
                    final ok = await submitBookingCancel(
                      context: context,
                      bookingId: bookingId,
                      reason: reasonController.text,
                    );
                    if (ok) onSuccess?.call();
                  }
                  : null,
              icon: const Icon(Icons.check_rounded, size: 18),
              label: Text(i18n.tr(I18nKey.commonConfirm)),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFC62828),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    ),
  );
  reasonController.dispose();
}
