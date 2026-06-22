
import 'package:flutter/material.dart';
import 'package:laoepic_thesis_app/features/info/pages/about_page.dart';
import 'package:laoepic_thesis_app/features/info/pages/contact_page.dart';
import 'package:laoepic_thesis_app/i18n/ui_i18n.dart';
import 'package:laoepic_thesis_app/providers/bottom_nav_provider.dart';
import 'package:laoepic_thesis_app/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FaqItem {
  final String qKey;
  final String aKey;
  const _FaqItem(this.qKey, this.aKey);
}

class _FaqCategory {
  final String id;
  final IconData icon;
  final String titleKey;
  final List<_FaqItem> items;
  const _FaqCategory({
    required this.id,
    required this.icon,
    required this.titleKey,
    required this.items,
  });
}

const _categories = [
  _FaqCategory(
    id: 'booking',
    icon: Icons.calendar_today_outlined,
    titleKey: 'help.cat_booking',
    items: [
      _FaqItem('help.faq.b1_q', 'help.faq.b1_a'),
      _FaqItem('help.faq.b2_q', 'help.faq.b2_a'),
      _FaqItem('help.faq.b3_q', 'help.faq.b3_a'),
    ],
  ),
  _FaqCategory(
    id: 'payment',
    icon: Icons.credit_card_outlined,
    titleKey: 'help.cat_payment',
    items: [
      _FaqItem('help.faq.p1_q', 'help.faq.p1_a'),
      _FaqItem('help.faq.p2_q', 'help.faq.p2_a'),
      _FaqItem('help.faq.p3_q', 'help.faq.p3_a'),
    ],
  ),
  _FaqCategory(
    id: 'account',
    icon: Icons.person_outline,
    titleKey: 'help.cat_account',
    items: [
      _FaqItem('help.faq.a1_q', 'help.faq.a1_a'),
      _FaqItem('help.faq.a2_q', 'help.faq.a2_a'),
    ],
  ),
];

/// FAQ and self-service help topics for common booking and account questions.
class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({super.key});

  @override
  State<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  final _searchController = TextEditingController();
  String _query = '';
  bool _loggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() => _loggedIn = prefs.getString('jwt_token') != null);
    }
  }

  List<_FaqCategory> _filtered(UiI18n i18n) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _categories;
    return _categories
        .map((cat) {
          final items = cat.items.where((item) {
            final question = i18n.tr(item.qKey).toLowerCase();
            final answer = i18n.tr(item.aKey).toLowerCase();
            return question.contains(q) || answer.contains(q);
          }).toList();
          return _FaqCategory(
            id: cat.id,
            icon: cat.icon,
            titleKey: cat.titleKey,
            items: items,
          );
        })
        .where((c) => c.items.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final i18n = context.watch<UiI18n>();
    final filtered = _filtered(i18n);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(i18n.tr('help.title')),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [AppColors.primary, const Color(0xFF0A5A9E)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.help_outline, color: Colors.white, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        i18n.tr('help.title'),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  i18n.tr('help.subtitle'),
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9), height: 1.4),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: i18n.tr('help.search_placeholder'),
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            i18n.tr('help.quick_links'),
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _QuickLink(
                icon: Icons.card_travel_outlined,
                label: i18n.tr('help.link_packages'),
                onTap: () {
                  context.read<BottomNavProvider>().changeIndex(1);
                  Navigator.popUntil(context, (r) => r.isFirst);
                },
              ),
              if (_loggedIn)
                _QuickLink(
                  icon: Icons.history,
                  label: i18n.tr('help.link_bookings'),
                  onTap: () {
                    context.read<BottomNavProvider>().changeIndex(3);
                    Navigator.popUntil(context, (r) => r.isFirst);
                  },
                ),
              if (!_loggedIn)
                _QuickLink(
                  icon: Icons.login,
                  label: i18n.tr('help.link_login'),
                  onTap: () => Navigator.pop(context),
                ),
              _QuickLink(
                icon: Icons.info_outline,
                label: i18n.tr('help.link_about'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutPage()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            i18n.tr('help.faq_title'),
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
          const SizedBox(height: 10),
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                i18n.tr('help.no_results'),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            )
          else
            ...filtered.map((cat) => _FaqCategoryBlock(cat: cat, i18n: i18n, query: _query)),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    i18n.tr('help.how_to_title'),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  const SizedBox(height: 12),
                  _StepRow(num: 1, title: i18n.tr('help.step1_title'), desc: i18n.tr('help.step1_desc')),
                  _StepRow(num: 2, title: i18n.tr('help.step2_title'), desc: i18n.tr('help.step2_desc')),
                  _StepRow(num: 3, title: i18n.tr('help.step3_title'), desc: i18n.tr('help.step3_desc')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.mail_outline, color: AppColors.primary),
              title: Text(i18n.tr('help.contact_title')),
              subtitle: Text(i18n.tr('help.contact_subtitle')),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ContactPage()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickLink extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickLink({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

class _FaqCategoryBlock extends StatelessWidget {
  final _FaqCategory cat;
  final UiI18n i18n;
  final String query;

  const _FaqCategoryBlock({required this.cat, required this.i18n, required this.query});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Icon(cat.icon, size: 18, color: AppColors.accent),
                  const SizedBox(width: 8),
                  Text(
                    i18n.tr(cat.titleKey).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            for (var i = 0; i < cat.items.length; i++)
              _FaqTile(
                question: i18n.tr(cat.items[i].qKey),
                answer: i18n.tr(cat.items[i].aKey),
                initiallyExpanded: query.isNotEmpty && i == 0,
              ),
          ],
        ),
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  final String question;
  final String answer;
  final bool initiallyExpanded;

  const _FaqTile({
    required this.question,
    required this.answer,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.grey.shade100),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        title: Text(question, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(answer, style: TextStyle(fontSize: 14, height: 1.45, color: Colors.grey.shade700)),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final int num;
  final String title;
  final String desc;

  const _StepRow({required this.num, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.accent,
            child: Text('$num', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(desc, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
