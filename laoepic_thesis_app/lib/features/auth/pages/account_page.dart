
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:laoepic_thesis_app/features/auth/pages/change_password_page.dart';
import 'package:laoepic_thesis_app/features/auth/pages/edit_profile_page.dart';
import 'package:laoepic_thesis_app/features/auth/pages/login_page.dart';
import 'package:laoepic_thesis_app/features/info/pages/about_page.dart';
import 'package:laoepic_thesis_app/features/info/pages/contact_page.dart';
import 'package:laoepic_thesis_app/features/info/pages/help_center_page.dart';
import 'package:laoepic_thesis_app/shared/widgets/currency_display_button.dart';
import 'package:laoepic_thesis_app/core/api/api_locale_prefs.dart';
import 'package:laoepic_thesis_app/config/app_config.dart';
import 'package:laoepic_thesis_app/providers/package_detail_provider.dart';
import 'package:laoepic_thesis_app/providers/api_locale_provider.dart';
import 'package:laoepic_thesis_app/providers/package_provider.dart';
import 'package:laoepic_thesis_app/theme/app_colors.dart';
import 'package:laoepic_thesis_app/i18n/i18n_keys.dart';
import 'package:laoepic_thesis_app/i18n/ui_i18n.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:laoepic_thesis_app/shared/utils/responsive_layout.dart';

/// User profile hub with links to edit credentials, language, currency, and logout.
class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String userName = '—';
  String userEmail = '—';
  String? userPhone;
  String? profileImagePath;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      userName = prefs.getString('user_name') ?? '—';
      userEmail = prefs.getString('user_email') ?? '—';
      userPhone = prefs.getString('user_phone');
      profileImagePath = prefs.getString('user_photo_url');
      _loading = true;
      _error = null;
    });
    await _syncProfileFromApi();
  }

  Future<void> _syncProfileFromApi() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null || token.isEmpty) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    try {
      final res = await http.get(
        Uri.parse('${AppConfig.baseUrl}/users/me'),
        headers: await buildAuthApiHeaders(token),
      );
      final body = jsonDecode(res.body) as Map<String, dynamic>;

      if (res.statusCode == 200 && body['success'] == true) {
        final d = body['data'] as Map<String, dynamic>?;
        if (d != null) {
          final name = d['fullName']?.toString().trim() ?? '';
          final email = d['email']?.toString().trim() ?? '';
          final phone = d['phone']?.toString().trim();
          final rawImg = d['profileImage']?.toString().trim();
          final uid = int.tryParse(d['userId']?.toString() ?? '') ?? 0;

          await prefs.setString('user_name', name.isNotEmpty ? name : '—');
          await prefs.setString('user_email', email.isNotEmpty ? email : '—');
          if (phone != null && phone.isNotEmpty) {
            await prefs.setString('user_phone', phone);
          } else {
            await prefs.remove('user_phone');
          }
          if (rawImg != null && rawImg.isNotEmpty) {
            await prefs.setString('user_photo_url', rawImg);
          } else {
            await prefs.remove('user_photo_url');
          }
          if (uid > 0) await prefs.setInt('user_id', uid);

          if (mounted) {
            setState(() {
              userName = name.isNotEmpty ? name : '—';
              userEmail = email.isNotEmpty ? email : '—';
              userPhone = (phone != null && phone.isNotEmpty) ? phone : null;
              profileImagePath = (rawImg != null && rawImg.isNotEmpty) ? rawImg : null;
              _loading = false;
              _error = null;
            });
          }
          return;
        }
      }

      if (mounted) {
        final fallback = context.read<UiI18n>().tr(I18nKey.accountLoadProfileError);
        setState(() {
          _loading = false;
          _error = body['message']?.toString() ?? fallback;
        });
      }
    } catch (e) {
      if (mounted) {
        final msg = context.read<UiI18n>().tr(I18nKey.accountNetworkError);
        setState(() {
          _loading = false;
          _error = msg;
        });
      }
    }
  }

  String? get _avatarUrl {
    final p = profileImagePath?.trim();
    if (p == null || p.isEmpty) return null;
    return AppConfig.mediaUrl(p);
  }

  void confirmLogout() {
    final i18n = context.read<UiI18n>();
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(i18n.tr(I18nKey.accountSignOut)),
          content: Text(i18n.tr(I18nKey.accountSignOutConfirm)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                i18n.tr(I18nKey.commonCancel),
                style: TextStyle(color: AppColors.accent),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red.shade600),
              onPressed: () {
                Navigator.of(context).pop();
                logout();
              },
              child: Text(i18n.tr(I18nKey.accountSignOut)),
            ),
          ],
        );
      },
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  Future<void> _openEditProfile() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (context) => const EditProfilePage()),
    );
    if (mounted) await loadUserData();
  }

  Future<void> _openChangePassword() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (context) => const ChangePasswordPage()),
    );
  }

  String _localeLabel(UiI18n i18n, String code) {
    switch (code) {
      case 'th':
        return i18n.tr(I18nKey.accountLocaleThai);
      case 'lo':
        return i18n.tr(I18nKey.accountLocaleLao);
      default:
        return i18n.tr(I18nKey.accountLocaleEnglish);
    }
  }

  Future<void> _pickApiLocale() async {
    final i18n = context.read<UiI18n>();
    final chosen = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(i18n.tr(I18nKey.accountLocaleEnglish)),
                onTap: () => Navigator.pop(ctx, 'en'),
              ),
              ListTile(
                title: Text(i18n.tr(I18nKey.accountLocaleThai)),
                onTap: () => Navigator.pop(ctx, 'th'),
              ),
              ListTile(
                title: Text(i18n.tr(I18nKey.accountLocaleLao)),
                onTap: () => Navigator.pop(ctx, 'lo'),
              ),
            ],
          ),
        );
      },
    );
    if (chosen == null || !mounted) return;
    await context.read<ApiLocaleProvider>().setLocale(chosen);
    if (!mounted) return;
    await context.read<PackageProvider>().fetchPackages();
    if (!mounted) return;
    context.read<PackageDetailProvider>().clear();
  }

  @override
  Widget build(BuildContext context) {
    final i18n = context.watch<UiI18n>();
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: loadUserData,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context)),
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                        child: Text(
                          _error!,
                          style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                        ),
                      ),
                    ListTile(
                      leading: const Icon(Icons.person_outline, color: Colors.black87),
                      title: Text(i18n.tr(I18nKey.accountEditProfile)),
                      subtitle: Text(i18n.tr(I18nKey.accountEditProfileSubtitle)),
                      onTap: _openEditProfile,
                    ),
                    ListTile(
                      leading: const Icon(Icons.lock_outline, color: Colors.black87),
                      title: Text(i18n.tr(I18nKey.accountChangePassword)),
                      onTap: _openChangePassword,
                    ),
                    ListTile(
                      leading: const Icon(Icons.language_outlined, color: Colors.black87),
                      title: Text(i18n.tr(I18nKey.accountLanguageTitle)),
                      subtitle: Consumer<ApiLocaleProvider>(
                        builder: (_, loc, __) => Text(_localeLabel(i18n, loc.code)),
                      ),
                      onTap: _pickApiLocale,
                    ),
                    const CurrencyDisplayButton(),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.article_outlined, color: Colors.black54),
                      title: Text(i18n.tr(I18nKey.accountYourPosts)),
                      enabled: false,
                    ),
                    ListTile(
                      leading: const Icon(Icons.reviews_outlined, color: Colors.black54),
                      title: Text(i18n.tr(I18nKey.accountYourReviews)),
                      enabled: false,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                      child: Text(
                        i18n.tr(I18nKey.accountHelp),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.info_outline, color: Colors.black87),
                      title: Text(i18n.tr(I18nKey.accountAboutUs)),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AboutPage()),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.support_agent_outlined, color: Colors.black87),
                      title: Text(i18n.tr(I18nKey.accountContactSupport)),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ContactPage()),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.help_outline, color: Colors.black87),
                      title: Text(i18n.tr(I18nKey.accountHelpCenter)),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HelpCenterPage()),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: Text(
                        i18n.tr(I18nKey.accountSignOut),
                        style: const TextStyle(color: Colors.red),
                      ),
                      onTap: confirmLogout,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final url = _avatarUrl;
    return SizedBox(
      height: ResponsiveLayout.profileHeaderHeight(context),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/body_content/cover.jpg',
            fit: BoxFit.cover,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.15),
                  Colors.black.withValues(alpha: 0.55),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0),
                    Colors.black.withOpacity(0.45),
                  ],
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CircleAvatar(
                        radius: 38,
                        backgroundColor: Colors.white.withOpacity(0.35),
                        child:
                            url != null
                                ? ClipOval(
                                  child: Image.network(
                                    url,
                                    width: 76,
                                    height: 76,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) {
                                      return const Icon(
                                        Icons.person,
                                        size: 42,
                                        color: Colors.white,
                                      );
                                    },
                                  ),
                                )
                                : const Icon(Icons.person, size: 42, color: Colors.white),
                      ),
                      if (_loading)
                        Positioned(
                          right: -2,
                          bottom: -2,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          userName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userEmail,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
                        ),
                        if (userPhone != null && userPhone!.trim().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.phone_outlined, size: 14, color: Colors.white.withOpacity(0.85)),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  userPhone!,
                                  style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
