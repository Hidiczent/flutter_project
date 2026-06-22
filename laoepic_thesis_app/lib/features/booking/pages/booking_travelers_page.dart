
import 'package:flutter/material.dart';
import 'package:laoepic_thesis_app/i18n/i18n_keys.dart';
import 'package:laoepic_thesis_app/i18n/ui_i18n.dart';
import 'package:laoepic_thesis_app/theme/app_colors.dart';

/// One traveler’s form fields (disposed by parent).
class TravelerFormEntry {
  final TextEditingController firstName = TextEditingController();
  final TextEditingController lastName = TextEditingController();
  final TextEditingController birth = TextEditingController();
  final TextEditingController passport = TextEditingController();

  void dispose() {
    firstName.dispose();
    lastName.dispose();
    birth.dispose();
    passport.dispose();
  }

  String get fullName =>
      '${firstName.text.trim()} ${lastName.text.trim()}'.trim();

  Map<String, dynamic>? toPassengerJson(String? Function(String) formatBirth) {
    final name = fullName;
    if (name.isEmpty) return null;
    final birthFormatted = formatBirth(birth.text);
    if (birthFormatted == null) return null;
    final map = <String, dynamic>{
      'fullName': name,
      'dateOfBirth': birthFormatted,
    };
    if (passport.text.trim().isNotEmpty) {
      map['documentNo'] = passport.text.trim();
      map['documentType'] = 'passport';
    }
    return map;
  }
}

/// Reusable form section for collecting passenger names and birth dates during checkout.
class BookingTravelersSection extends StatelessWidget {
  final UiI18n i18n;
  final int peopleCount;
  final int maxPeople;
  final List<TravelerFormEntry> travelers;
  final ValueChanged<int> onPeopleCountChanged;
  final String requiredMsg;
  final Widget contactSection;

  const BookingTravelersSection({
    super.key,
    required this.i18n,
    required this.peopleCount,
    required this.maxPeople,
    required this.travelers,
    required this.onPeopleCountChanged,
    required this.requiredMsg,
    required this.contactSection,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _SectionCard(
          icon: Icons.groups_2_outlined,
          title: i18n.tr(
            I18nKey.bookingFormTravelersCount,
            params: {'count': '$peopleCount'},
          ),
          child: Row(
            children: [
              IconButton(
                onPressed:
                    peopleCount > 1
                        ? () => onPeopleCountChanged(peopleCount - 1)
                        : null,
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Text(
                '$peopleCount',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(
                onPressed:
                    peopleCount < maxPeople
                        ? () => onPeopleCountChanged(peopleCount + 1)
                        : null,
                icon: const Icon(Icons.add_circle_outline),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  i18n.tr(
                    I18nKey.bookingFormSeatsLeft,
                    params: {'left': '$maxPeople', 'total': '$maxPeople'},
                  ),
                  style: TextStyle(fontSize: 12, color: Colors.blueGrey.shade600),
                ),
              ),
            ],
          ),
        ),
        ...List.generate(travelers.length, (i) {
          final t = travelers[i];
          return Padding(
            padding: const EdgeInsets.only(top: 12),
            child: _SectionCard(
              icon: Icons.person_outline_rounded,
              title: i18n.tr(
                I18nKey.bookingFormTravelerNumber,
                params: {'n': '${i + 1}'},
              ),
              child: Column(
                children: [
                  _FormField(
                    label: i18n.tr(I18nKey.bookingFormFirstName),
                    controller: t.firstName,
                    requiredMsg: requiredMsg,
                    icon: Icons.badge_outlined,
                  ),
                  _FormField(
                    label: i18n.tr(I18nKey.bookingFormLastName),
                    controller: t.lastName,
                    requiredMsg: requiredMsg,
                    icon: Icons.badge_outlined,
                  ),
                  _BirthDateField(
                    label: i18n.tr(I18nKey.bookingFormBirth),
                    controller: t.birth,
                    requiredMsg: requiredMsg,
                  ),
                  _FormField(
                    label: i18n.tr(I18nKey.bookingFormPassport),
                    controller: t.passport,
                    icon: Icons.card_travel_outlined,
                    optional: true,
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 12),
        contactSection,
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8ECF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final String? requiredMsg;
  final bool optional;

  const _FormField({
    required this.label,
    required this.controller,
    required this.icon,
    this.requiredMsg,
    this.optional = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primary.withOpacity(0.75)),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
        validator:
            optional
                ? null
                : (v) => v == null || v.trim().isEmpty ? requiredMsg : null,
      ),
    );
  }
}

class _BirthDateField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String requiredMsg;

  const _BirthDateField({
    required this.label,
    required this.controller,
    required this.requiredMsg,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(
            Icons.cake_outlined,
            color: AppColors.primary.withOpacity(0.75),
          ),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onTap: () async {
          final now = DateTime.now();
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime(now.year - 25),
            firstDate: DateTime(1920),
            lastDate: now,
          );
          if (picked != null) {
            controller.text =
                '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
          }
        },
        validator: (v) => v == null || v.isEmpty ? requiredMsg : null,
      ),
    );
  }
}
