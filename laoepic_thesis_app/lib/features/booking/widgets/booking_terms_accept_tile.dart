
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:laoepic_thesis_app/features/info/pages/about_page.dart';
import 'package:laoepic_thesis_app/features/info/pages/help_center_page.dart';
import 'package:laoepic_thesis_app/i18n/i18n_keys.dart';
import 'package:laoepic_thesis_app/i18n/ui_i18n.dart';
import 'package:laoepic_thesis_app/theme/app_colors.dart';
import 'package:provider/provider.dart';

/// Terms checkbox with tappable About / Help links (parity with web booking form).
class BookingTermsAcceptTile extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const BookingTermsAcceptTile({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<BookingTermsAcceptTile> createState() => _BookingTermsAcceptTileState();
}

class _BookingTermsAcceptTileState extends State<BookingTermsAcceptTile> {
  late TapGestureRecognizer _aboutRecognizer;
  late TapGestureRecognizer _helpRecognizer;

  @override
  void initState() {
    super.initState();
    _aboutRecognizer = TapGestureRecognizer()..onTap = _openAbout;
    _helpRecognizer = TapGestureRecognizer()..onTap = _openHelp;
  }

  @override
  void dispose() {
    _aboutRecognizer.dispose();
    _helpRecognizer.dispose();
    super.dispose();
  }

  void _openAbout() {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(builder: (_) => const AboutPage()),
    );
  }

  void _openHelp() {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(builder: (_) => const HelpCenterPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final i18n = context.watch<UiI18n>();
    final prefix = i18n.tr(I18nKey.bookingFormTermsAcceptPrefix);
    final aboutLabel = i18n.tr(I18nKey.txtAboutUs);
    final helpLabel = i18n.tr(I18nKey.helpTitle);

    const baseStyle = TextStyle(
      fontSize: 13,
      height: 1.45,
      color: Color(0xFF37474F),
    );
    final linkStyle = baseStyle.copyWith(
      color: AppColors.primary,
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.underline,
      decorationColor: AppColors.primary,
    );

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => widget.onChanged(!widget.value),
        child: Container(
          padding: const EdgeInsets.fromLTRB(8, 10, 12, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: widget.value,
                onChanged: (v) => widget.onChanged(v ?? false),
                activeColor: AppColors.primary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text.rich(
                    TextSpan(
                      style: baseStyle,
                      children: [
                        TextSpan(text: '$prefix '),
                        TextSpan(
                          text: aboutLabel,
                          style: linkStyle,
                          recognizer: _aboutRecognizer,
                        ),
                        const TextSpan(text: ' · '),
                        TextSpan(
                          text: helpLabel,
                          style: linkStyle,
                          recognizer: _helpRecognizer,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
