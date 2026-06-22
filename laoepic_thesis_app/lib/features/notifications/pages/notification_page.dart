
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:laoepic_thesis_app/features/booking/pages/booking_detail_page.dart';
import 'package:laoepic_thesis_app/core/api/api_locale_prefs.dart';
import 'package:laoepic_thesis_app/config/app_config.dart';
import 'package:laoepic_thesis_app/data/models/notification_model.dart';
import 'package:laoepic_thesis_app/theme/app_colors.dart';
import 'package:laoepic_thesis_app/i18n/i18n_keys.dart';
import 'package:laoepic_thesis_app/i18n/ui_i18n.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Inbox of booking and account notifications with tap-through to related screens.
class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<NotificationItem> notifications = [];
  int unreadNotificationsCount = 0;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }
  Future<void> fetchNotifications() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      if (!mounted) return;
      final i18n = context.read<UiI18n>();
      setState(() {
        _loading = false;
        _error = i18n.tr(I18nKey.notificationsNeedLogin);
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/notifications'),
        headers: await buildAuthApiHeaders(token),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final raw = body['data'];
        if (body['success'] == true && raw is List) {
          final list =
              raw
                  .map(
                    (e) => NotificationItem.fromJson(e as Map<String, dynamic>),
                  )
                  .toList();
          if (!mounted) return;
          setState(() {
            notifications = list;
            _recomputeUnread();
            _loading = false;
            _error = null;
          });
          return;
        }
      }

      if (!mounted) return;
      final i18n = context.read<UiI18n>();
      final err = i18n.tr(
        I18nKey.notificationsLoadFailed,
        params: {'code': '${response.statusCode}'},
      );
      setState(() {
        _loading = false;
        _error = err;
      });
    } catch (e) {
      if (!mounted) return;
      final i18n = context.read<UiI18n>();
      final err = i18n.tr(I18nKey.notificationsNetworkError);
      setState(() {
        _loading = false;
        _error = err;
      });
    }
  }

  void _recomputeUnread() {
    unreadNotificationsCount =
        notifications.where((n) => n.statusNotification == 'new').length;
  }

  void navigateToBookingDetail(int orderId) {
    if (orderId <= 0) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingDetailPage(orderId: orderId),
      ),
    );
  }

  Future<void> _markAllRead() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token != null) {
      try {
        await http.post(
          Uri.parse('${AppConfig.baseUrl}/notifications/read-all'),
          headers: await buildAuthApiHeaders(token),
        );
      } catch (_) {}
    }
    if (!mounted) return;
    setState(() {
      for (final n in notifications) {
        n.statusNotification = 'read';
      }
      _recomputeUnread();
    });
  }

  Future<void> _markOneRead(NotificationItem item) async {
    if (item.statusNotification == 'read') return;
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token != null && item.notificationId.isNotEmpty) {
      try {
        await http.patch(
          Uri.parse(
            '${AppConfig.baseUrl}/notifications/${item.notificationId}/read',
          ),
          headers: await buildAuthApiHeaders(token),
        );
      } catch (_) {}
    }
    if (!mounted) return;
    setState(() {
      item.statusNotification = 'read';
      _recomputeUnread();
    });
  }

  Color _statusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('confirm')) return const Color(0xFF2E7D32);
    if (s.contains('pend')) return AppColors.accent;
    if (s.contains('cancel')) return const Color(0xFFC62828);
    return Colors.blueGrey;
  }

  String _displayTitle(UiI18n i18n, NotificationItem item) {
    if (item.message.isNotEmpty) {
      return item.title.trim().isNotEmpty
          ? item.title
          : i18n.tr(I18nKey.notificationsFallbackTitle);
    }
    if (item.title.trim().isNotEmpty) {
      return item.title;
    }
    return i18n.tr(I18nKey.notificationsBookingUpdate);
  }

  String _displaySubtitle(UiI18n i18n, NotificationItem item) {
    if (item.message.isNotEmpty) {
      final parts = <String>[item.message];
      if (item.orderId > 0) {
        parts.add(
          i18n.tr(
            I18nKey.notificationsBookingHash,
            params: {'id': '${item.orderId}'},
          ),
        );
      }
      return parts.join('\n');
    }
    final dash = i18n.tr(I18nKey.commonEmDash);
    final status =
        item.orderStatus.trim().isNotEmpty ? item.orderStatus : dash;
    return '${i18n.tr(I18nKey.notificationsBookingHash, params: {'id': '${item.orderId}'})}\n${i18n.tr(I18nKey.notificationsStatusLine, params: {'status': status})}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final i18n = context.watch<UiI18n>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        title: Text(
          i18n.tr(I18nKey.notificationsTitle),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (notifications.isNotEmpty && unreadNotificationsCount > 0)
            IconButton(
              tooltip: i18n.tr(I18nKey.notificationsMarkAllRead),
              onPressed: _markAllRead,
              icon: const Icon(Icons.done_all_rounded, color: Colors.white),
            ),
        ],
      ),
      body: _buildBody(theme, i18n),
    );
  }

  Widget _buildBody(ThemeData theme, UiI18n i18n) {
    if (_loading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              i18n.tr(I18nKey.notificationsLoading),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.black54,
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return RefreshIndicator(
        color: AppColors.primary,
        onRefresh: fetchNotifications,
        child: _EmptyOrErrorState(
          icon: Icons.cloud_off_outlined,
          title: i18n.tr(I18nKey.notificationsErrorTitle),
          message: _error!,
          actionLabel: i18n.tr(I18nKey.notificationsTryAgain),
          onAction: fetchNotifications,
          accent: AppColors.primary,
        ),
      );
    }

    if (notifications.isEmpty) {
      return RefreshIndicator(
        color: AppColors.primary,
        onRefresh: fetchNotifications,
        child: _EmptyOrErrorState(
          icon: Icons.notifications_none_rounded,
          title: i18n.tr(I18nKey.notificationsEmptyTitle),
          message: i18n.tr(I18nKey.notificationsEmptyMessage),
          actionLabel: i18n.tr(I18nKey.notificationsRefresh),
          onAction: fetchNotifications,
          accent: AppColors.accent,
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: fetchNotifications,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final item = notifications[index];
          final isUnread = item.statusNotification == 'new';
          final imageUri =
              item.imageUrl.trim().isEmpty
                  ? ''
                  : AppConfig.mediaUrl(item.imageUrl);

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  await _markOneRead(item);
                  if (!context.mounted) return;
                  navigateToBookingDetail(item.orderId);
                },
                borderRadius: BorderRadius.circular(16),
                child: Ink(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          isUnread
                              ? AppColors.primary.withOpacity(0.22)
                              : const Color(0xFFE8ECF0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          width: 4,
                          decoration: BoxDecoration(
                            color:
                                isUnread
                                    ? AppColors.accent
                                    : Colors.transparent,
                            borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(15),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _Avatar(url: imageUri, isUnread: isUnread),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              _displayTitle(i18n, item),
                                              style: theme.textTheme.titleSmall
                                                  ?.copyWith(
                                                    fontWeight:
                                                        isUnread
                                                            ? FontWeight.w700
                                                            : FontWeight.w600,
                                                    color: const Color(
                                                      0xFF1A2332,
                                                    ),
                                                    height: 1.25,
                                                  ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (isUnread)
                                            Container(
                                              width: 8,
                                              height: 8,
                                              margin: const EdgeInsets.only(
                                                left: 6,
                                                top: 4,
                                              ),
                                              decoration: const BoxDecoration(
                                                color: AppColors.accent,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        _displaySubtitle(i18n, item),
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: const Color(0xFF5C6B7A),
                                              height: 1.4,
                                            ),
                                        maxLines: 4,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (item.orderStatus
                                          .trim()
                                          .isNotEmpty) ...[
                                        const SizedBox(height: 10),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _statusColor(
                                              item.orderStatus,
                                            ).withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Text(
                                            item.orderStatus,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: _statusColor(
                                                item.orderStatus,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 4,
                                    top: 2,
                                  ),
                                  child: Icon(
                                    Icons.chevron_right_rounded,
                                    color: Colors.grey.shade400,
                                    size: 26,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String url;
  final bool isUnread;

  const _Avatar({required this.url, required this.isUnread});

  @override
  Widget build(BuildContext context) {
    const double size = 52;
    final ring = BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        color:
            isUnread
                ? AppColors.accent.withOpacity(0.5)
                : const Color(0xFFE8ECF0),
        width: 2,
      ),
    );

    Widget inner;
    if (url.isEmpty) {
      inner = Container(
        color: const Color(0xFFEEF2F6),
        alignment: Alignment.center,
        child: Icon(
          Icons.notifications_active_outlined,
          color: isUnread ? AppColors.primary : Colors.blueGrey.shade300,
          size: 26,
        ),
      );
    } else {
      inner = Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Container(
            color: const Color(0xFFEEF2F6),
            alignment: Alignment.center,
            child: Icon(
              Icons.image_not_supported_outlined,
              color: Colors.blueGrey.shade300,
              size: 24,
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: const Color(0xFFEEF2F6),
            alignment: Alignment.center,
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary.withOpacity(0.6),
              ),
            ),
          );
        },
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: ring,
      child: ClipOval(child: inner),
    );
  }
}

class _EmptyOrErrorState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;
  final Color accent;

  const _EmptyOrErrorState({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, size: 52, color: accent),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A2332),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.45,
                        color: Colors.blueGrey.shade600,
                      ),
                    ),
                    const SizedBox(height: 28),
                    FilledButton.icon(
                      onPressed: onAction,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.refresh_rounded, size: 20),
                      label: Text(actionLabel),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
