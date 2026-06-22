
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:laoepic_thesis_app/core/api/api_locale_prefs.dart';
import 'package:laoepic_thesis_app/config/app_config.dart';
import 'package:laoepic_thesis_app/i18n/i18n_keys.dart';
import 'package:laoepic_thesis_app/i18n/ui_i18n.dart';
import 'package:laoepic_thesis_app/providers/api_locale_provider.dart';
import 'package:laoepic_thesis_app/features/booking/pages/booking_detail_page.dart';
import 'package:laoepic_thesis_app/features/booking/pages/booking_travelers_page.dart';
import 'package:laoepic_thesis_app/theme/app_colors.dart';
import 'package:laoepic_thesis_app/shared/widgets/app_feedback.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:laoepic_thesis_app/data/services/phajay_payment_navigator.dart';
import 'package:laoepic_thesis_app/data/services/phajay_payment_service.dart';
import 'package:laoepic_thesis_app/features/booking/widgets/booking_terms_accept_tile.dart';
import 'package:laoepic_thesis_app/data/models/package_model.dart';
import 'package:laoepic_thesis_app/shared/utils/guide_display.dart';
import 'package:laoepic_thesis_app/features/package/widgets/package_guide_card.dart';

const Color _pageBg = Color(0xFFF4F6F9);

/// Multi-step booking wizard for choosing dates, travelers, and confirming a package reservation.
class BookingPage extends StatefulWidget {
  final int packageId;

  const BookingPage({super.key, required this.packageId});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();

  final nameController = TextEditingController();
  final surnameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final birthController = TextEditingController();
  final noteController = TextEditingController();
  final passportController = TextEditingController();
  final nationalityController = TextEditingController();

  int _step = 0;
  String _packageTitle = '';
  String _packageLocation = '';
  GuideInfo? _packageGuide;
  List<Map<String, dynamic>> _schedules = [];
  String? _selectedScheduleId;
  bool _loadingPackage = true;
  String? _loadError;
  bool _isSubmitting = false;
  bool _wantsInsurance = false;
  bool _termsAccepted = false;
  String _payBank = 'bcel';
  int _peopleCount = 1;
  final List<TravelerFormEntry> _travelers = [TravelerFormEntry()];

  int get _maxPeople {
    final s = _selectedSchedule;
    if (s == null) return envMaxPeopleFallback;
    final left = _seatsLeft(s);
    return left > 0 ? left.clamp(1, envMaxPeopleFallback) : 1;
  }

  static const int envMaxPeopleFallback = 20;

  void _setPeopleCount(int n) {
    final capped = n.clamp(1, _maxPeople);
    setState(() {
      _peopleCount = capped;
      while (_travelers.length < capped) {
        _travelers.add(TravelerFormEntry());
      }
      while (_travelers.length > capped) {
        _travelers.removeLast().dispose();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final locale = context.read<ApiLocaleProvider>().code;
      await context.read<UiI18n>().reloadFromAssets(locale);
      if (!mounted) return;
      _loadPackageAndSchedules();
      _prefillUser();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    nameController.dispose();
    surnameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    birthController.dispose();
    noteController.dispose();
    passportController.dispose();
    nationalityController.dispose();
    for (final t in _travelers) {
      t.dispose();
    }
    super.dispose();
  }

  Future<void> _prefillUser() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email') ?? '';
    final name = prefs.getString('user_name') ?? '';
    final phone = prefs.getString('user_phone') ?? '';
    if (email.isNotEmpty) emailController.text = email;
    if (phone.isNotEmpty) phoneController.text = phone;
    if (name.isNotEmpty && _travelers.isNotEmpty) {
      final parts = name.trim().split(RegExp(r'\s+'));
      _travelers[0].firstName.text = parts.first;
      if (parts.length > 1) {
        _travelers[0].lastName.text = parts.sublist(1).join(' ');
      }
    }
  }

  bool _isScheduleBookable(Map<String, dynamic> s) {
    if ((s['status']?.toString() ?? '') != 'open') return false;

    final hints = s['bookingHints'];
    if (hints is Map) {
      final map = Map<String, dynamic>.from(hints);
      if (map['bookingLikelyBlocked'] == true) return false;
      if (map['hasAdultPrice'] == false) return false;
      return true;
    }

    return _hasEffectiveAdultPrice(s) && _seatsLeft(s) > 0;
  }

  bool _hasEffectiveAdultPrice(Map<String, dynamic> s) {
    final prices = s['prices'] as List<dynamic>? ?? [];
    final now = DateTime.now();
    for (final raw in prices) {
      if (raw is! Map) continue;
      final p = Map<String, dynamic>.from(raw);
      if (p['priceType']?.toString() != 'adult') continue;
      final effStr = p['effectiveAt']?.toString();
      if (effStr == null || effStr.isEmpty) continue;
      final eff = DateTime.tryParse(effStr);
      if (eff != null && !eff.isAfter(now)) return true;
    }
    return false;
  }

  String _mapBookingApiMessage(UiI18n i18n, String? raw) {
    final m = raw?.trim() ?? '';
    if (m.contains('Price tier not found')) {
      return i18n.tr(I18nKey.bookingFormNoPriceTier);
    }
    if (m.contains('Not enough seats')) {
      return i18n.tr(I18nKey.bookingFormNotEnoughSeats);
    }
    if (m.contains('already have an active booking')) {
      return i18n.tr(I18nKey.bookingFormDuplicateBooking);
    }
    return m.isNotEmpty ? m : i18n.tr(I18nKey.bookingFormBookingFailed);
  }

  Future<void> _loadPackageAndSchedules() async {
    final i18n = context.read<UiI18n>();
    if (!mounted) return;
    setState(() {
      _loadingPackage = true;
      _loadError = null;
    });
    try {
      final headers = await buildPublicApiHeaders();
      if (!mounted) return;

      final pkgRes = await http.get(
        Uri.parse('${AppConfig.baseUrl}/packages/${widget.packageId}'),
        headers: headers,
      );
      final schedRes = await http.get(
        Uri.parse(
          '${AppConfig.baseUrl}/packages/${widget.packageId}/schedules',
        ),
        headers: headers,
      );
      if (!mounted) return;

      if (pkgRes.statusCode != 200 || schedRes.statusCode != 200) {
        final code =
            pkgRes.statusCode != 200
                ? pkgRes.statusCode
                : schedRes.statusCode;
        setState(() {
          _loadError = i18n.tr(
            I18nKey.bookingFormLoadDeparturesFailed,
            params: {'code': '$code'},
          );
          _loadingPackage = false;
        });
        return;
      }

      final pkgBody = jsonDecode(pkgRes.body) as Map<String, dynamic>;
      final schedBody = jsonDecode(schedRes.body) as Map<String, dynamic>;
      final data = pkgBody['data'] as Map<String, dynamic>?;
      final raw = schedBody['data'] as List<dynamic>? ?? [];
      final bookable =
          raw
              .map((e) => Map<String, dynamic>.from(e as Map))
              .where(_isScheduleBookable)
              .toList();

      if (!mounted) return;
      GuideInfo? guide;
      final guideRaw = data?['guide'];
      if (guideRaw is Map<String, dynamic>) {
        try {
          guide = GuideInfo.fromJson(guideRaw);
        } catch (_) {}
      }

      setState(() {
        _packageTitle = data?['title']?.toString() ?? '';
        _packageLocation = data?['location']?.toString() ?? '';
        _packageGuide = guide;
        _schedules = bookable;
        _selectedScheduleId = null;
        _loadingPackage = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = i18n.tr(
          I18nKey.bookingFormErrorPrefix,
          params: {'error': e.toString()},
        );
        _loadingPackage = false;
      });
    }
  }

  Map<String, dynamic>? get _selectedSchedule {
    if (_selectedScheduleId == null) return null;
    for (final s in _schedules) {
      if (s['scheduleId']?.toString() == _selectedScheduleId) return s;
    }
    return null;
  }

  String _fmtDateTime(String? iso) {
    if (iso == null || iso.isEmpty) return '—';
    try {
      return DateFormat(
        'dd MMM yyyy · HH:mm',
      ).format(DateTime.parse(iso).toLocal());
    } catch (_) {
      return iso;
    }
  }

  String? _formatBirthDate(String input) {
    try {
      final parsed = DateFormat('dd/MM/yyyy').parseStrict(input);
      return DateFormat('yyyy-MM-dd').format(parsed);
    } catch (_) {
      return null;
    }
  }

  int _seatsLeft(Map<String, dynamic> s) {
    final hints = s['bookingHints'];
    if (hints is Map) {
      final remaining = hints['seatsRemaining'];
      if (remaining is int) return remaining;
      final parsed = int.tryParse('$remaining');
      if (parsed != null) return parsed;
    }
    final cap = int.tryParse(s['capacity']?.toString() ?? '') ?? 0;
    final booked =
        int.tryParse(
          (s['bookedCount'] ?? s['booked_count'])?.toString() ?? '',
        ) ??
        0;
    return (cap - booked).clamp(0, cap);
  }

  bool _validateStep(int step) {
    final i18n = context.read<UiI18n>();
    if (step == 0) {
      if (_selectedScheduleId == null || _selectedScheduleId!.isEmpty) {
        context.showWarningMessage(
          i18n.tr(I18nKey.bookingFormSelectDepartureSnackbar),
        );
        return false;
      }
      return true;
    }
    if (step == 1) {
      if (!(_formKey.currentState?.validate() ?? false)) return false;
      for (final t in _travelers) {
        if (t.fullName.isEmpty) {
          context.showWarningMessage(
            i18n.tr(I18nKey.bookingFormTravelerNameRequired),
          );
          return false;
        }
        if (_formatBirthDate(t.birth.text) == null) {
          context.showWarningMessage(i18n.tr(I18nKey.bookingFormInvalidBirth));
          return false;
        }
      }
      return true;
    }
    return true;
  }

  void _goToStep(int step) {
    setState(() => _step = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _onNext() {
    if (!_validateStep(_step)) return;
    if (_step < 2) {
      _goToStep(_step + 1);
    }
  }

  void _onBack() {
    if (_step > 0) _goToStep(_step - 1);
  }

  Future<void> _submitBooking({required bool payNow}) async {
    final i18n = context.read<UiI18n>();
    if (!_validateStep(1)) {
      _goToStep(1);
      return;
    }

    // Prevent users from hitting backend validation by checking the payment cutoff in UI.
    // Backend rule: payment must be completed at least N days before departure.
    const paymentMinDaysBeforeDeparture = 3;
    final departureRaw = _selectedSchedule?['departureDatetime']?.toString();
    if (departureRaw != null && departureRaw.isNotEmpty) {
      final dep = DateTime.tryParse(departureRaw);
      if (dep != null) {
        final deadline = dep.subtract(const Duration(days: paymentMinDaysBeforeDeparture));
        if (!deadline.isAfter(DateTime.now())) {
          await context.showWarningMessage(
            i18n.tr(
              I18nKey.bookingFormPaymentMinDays,
              params: {'days': paymentMinDaysBeforeDeparture.toString()},
              fallback: 'Payment must be completed at least $paymentMinDaysBeforeDeparture day(s) before departure.',
            ),
          );
          return;
        }
      }
    }

    final passengers = <Map<String, dynamic>>[];
    for (final t in _travelers) {
      final p = t.toPassengerJson(_formatBirthDate);
      if (p == null) {
        await context.showWarningMessage(i18n.tr(I18nKey.bookingFormInvalidBirth));
        _goToStep(1);
        return;
      }
      passengers.add(p);
    }

    setState(() => _isSubmitting = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null || token.isEmpty) {
      if (mounted) {
        await context.showWarningMessage(i18n.tr(I18nKey.bookingFormMustLogin));
      }
      setState(() => _isSubmitting = false);
      return;
    }

    if (!_termsAccepted) {
      if (mounted) {
        await context.showWarningMessage(i18n.tr(I18nKey.bookingFormTermsRequired));
        _goToStep(2);
      }
      setState(() => _isSubmitting = false);
      return;
    }

    final contactBits = <String>[
      if (phoneController.text.trim().isNotEmpty)
        'Phone: ${phoneController.text.trim()}',
      if (emailController.text.trim().isNotEmpty)
        'Email: ${emailController.text.trim()}',
      if (nationalityController.text.trim().isNotEmpty)
        'Nationality: ${nationalityController.text.trim()}',
      if (noteController.text.trim().isNotEmpty) noteController.text.trim(),
      if (_wantsInsurance) i18n.tr(I18nKey.bookingFormInsuranceNote),
    ];
    final note = contactBits.join(' · ');

    try {
      final bookRes = await http.post(
        Uri.parse('${AppConfig.baseUrl}/bookings'),
        headers: {
          ...await buildAuthApiHeaders(token),
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'scheduleId': _selectedScheduleId,
          'peopleCount': _peopleCount,
          if (phoneController.text.trim().isNotEmpty)
            'contactPhone': phoneController.text.trim(),
          if (note.isNotEmpty) 'note': note,
          'passengers': passengers,
        }),
      );

      final bookBody = jsonDecode(bookRes.body) as Map<String, dynamic>;
      if (bookRes.statusCode != 201 || bookBody['success'] != true) {
        final parsedBody = parseApiFeedbackMessage(bookRes.body);
        final msg = _mapBookingApiMessage(
          i18n,
          parsedBody.isNotEmpty
              ? parsedBody
              : bookBody['message']?.toString(),
        );
        if (mounted) {
          await context.showErrorMessage(msg);
        }
        return;
      }

      final bookingId =
          (bookBody['data'] as Map<String, dynamic>?)?['bookingId']?.toString();
      if (bookingId == null || bookingId.isEmpty) {
        if (mounted) {
          await context.showErrorMessage(
            i18n.tr(I18nKey.bookingFormInvalidBookingResponse),
          );
        }
        return;
      }

      String? invoiceId;
      var invBody = <String, dynamic>{};
      final invRes = await http.post(
        Uri.parse('${AppConfig.baseUrl}/invoices/from-booking/$bookingId'),
        headers: {
          ...await buildAuthApiHeaders(token),
          'Content-Type': 'application/json',
        },
      );
      invBody = jsonDecode(invRes.body) as Map<String, dynamic>;
      if (invRes.statusCode == 201 && invBody['success'] == true) {
        invoiceId =
            (invBody['data'] as Map<String, dynamic>?)?['invoiceId']
                ?.toString();
      } else if (invBody['message']?.toString().contains('already exists') ==
          true) {
        final getInv = await http.get(
          Uri.parse('${AppConfig.baseUrl}/invoices/by-booking/$bookingId'),
          headers: await buildAuthApiHeaders(token),
        );
        if (getInv.statusCode == 200) {
          invBody = jsonDecode(getInv.body) as Map<String, dynamic>;
          invoiceId =
              (invBody['data'] as Map<String, dynamic>?)?['invoiceId']
                  ?.toString();
        }
      }

      if (invoiceId == null || invoiceId.isEmpty) {
        if (mounted) {
          await _showResultDialog(
            title: i18n.tr(I18nKey.bookingFormBookingCreated),
            message: i18n.tr(
              I18nKey.bookingFormInvoiceFailBody,
              params: {'id': bookingId},
            ),
            icon: Icons.info_outline_rounded,
            color: AppColors.primary,
          );
        }
        return;
      }

      final bookData = bookBody['data'] as Map<String, dynamic>? ?? {};
      final expiresAt = bookData['expiresAt']?.toString() ?? '';
      final minDays =
          bookData['paymentMinDaysBeforeDeparture']?.toString() ?? '7';

      if (!payNow) {
        if (mounted) {
          await _showResultDialog(
            title: i18n.tr(I18nKey.bookingFormBookingCreated),
            message: i18n.tr(
              I18nKey.bookingFormPayLaterBody,
              params: {
                'id': bookingId,
                'days': minDays,
                'expires': expiresAt.isNotEmpty ? expiresAt : '—',
              },
            ),
            icon: Icons.schedule_rounded,
            color: AppColors.primary,
            popTwice: true,
            onOk: () {
              if (!mounted) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => BookingDetailPage(
                        orderId: int.tryParse(bookingId) ?? 0,
                      ),
                ),
              );
            },
          );
        }
        return;
      }

      final invData = invBody['data'] as Map<String, dynamic>?;
      final invoiceNo = invData?['invoiceNo']?.toString();
      final bookingIdInt = int.tryParse(bookingId) ?? 0;
      if (bookingIdInt <= 0) return;

      if (!mounted) return;
      final opened = await PhajayPaymentNavigator.start(
        context: context,
        token: token,
        bookingId: bookingIdInt,
        invoiceId: invoiceId,
        invoiceNo: invoiceNo,
        bank: _payBank,
        currencyCode:
            invData?['currencyCode']?.toString() ??
            bookData['currencyCode']?.toString() ??
            'LAK',
      );
      if (!opened && mounted) {
        await context.showErrorMessage(
          i18n.tr(I18nKey.bookingFormNoPaymentUrl),
        );
      } else if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        await context.showErrorMessage(
          i18n.tr(
            I18nKey.bookingFormErrorPrefix,
            params: {'error': e.toString()},
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _showResultDialog({
    required String title,
    required String message,
    required IconData icon,
    required Color color,
    bool popTwice = false,
    VoidCallback? onOk,
  }) async {
    final i18n = context.read<UiI18n>();
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            icon: Icon(icon, color: color, size: 40),
            title: Text(title, textAlign: TextAlign.center),
            content: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(height: 1.45, color: Colors.blueGrey.shade700),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              FilledButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  if (onOk != null) {
                    onOk();
                  } else if (popTwice && mounted) {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  } else if (mounted) {
                    Navigator.pop(context);
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(140, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(i18n.tr(I18nKey.commonOk)),
              ),
            ],
          ),
    );
  }

  List<String> _stepLabels(UiI18n i18n) {
    final isLo = context.read<ApiLocaleProvider>().code == 'lo';
    return [
      i18n.tr(
        I18nKey.bookingFormStepDeparture,
        fallback: isLo ? 'ກຳນົດອອກ' : 'Departure',
      ),
      i18n.tr(
        I18nKey.bookingFormStepDetails,
        fallback: isLo ? 'ຂໍ້ມູນ' : 'Details',
      ),
      i18n.tr(
        I18nKey.bookingFormStepReview,
        fallback: isLo ? 'ກວດສອບ' : 'Review',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final i18n = context.watch<UiI18n>();
    final theme = Theme.of(context);
    final isLo = context.watch<ApiLocaleProvider>().code == 'lo';
    final stepLabels = _stepLabels(i18n);

    return Scaffold(
      backgroundColor: _pageBg,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(
          i18n.tr(I18nKey.bookingFormTitle),
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (_step > 0 && !_isSubmitting) {
              _onBack();
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Column(
        children: [
          _BookingStepHeader(step: _step, labels: stepLabels),
          if (_packageTitle.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _PackageBanner(
                title: _packageTitle,
                location: _packageLocation,
              ),
            ),
          Expanded(
            child:
                _loadingPackage
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 36,
                            height: 36,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            i18n.tr(I18nKey.commonLoading),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    )
                    : _loadError != null
                    ? _LoadErrorView(
                      message: _loadError!,
                      retryLabel: i18n.tr(I18nKey.bookingFormRetryLoad),
                      onRetry: _loadPackageAndSchedules,
                    )
                    : Form(
                      key: _formKey,
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        onPageChanged: (i) => setState(() => _step = i),
                        children: [
                          _DepartureStep(
                            i18n: i18n,
                            schedules: _schedules,
                            selectedId: _selectedScheduleId,
                            hint: i18n.tr(
                              I18nKey.bookingFormSelectDepartureHint,
                            ),
                            emptyText: i18n.tr(I18nKey.bookingFormNoDepartures),
                            onSelect: (id) {
                              setState(() => _selectedScheduleId = id);
                              if (_peopleCount > _maxPeople) {
                                _setPeopleCount(_maxPeople);
                              }
                            },
                            fmtDateTime: _fmtDateTime,
                            seatsLeft: _seatsLeft,
                          ),
                          BookingTravelersSection(
                            i18n: i18n,
                            peopleCount: _peopleCount,
                            maxPeople: _maxPeople,
                            travelers: _travelers,
                            onPeopleCountChanged: _setPeopleCount,
                            requiredMsg: i18n.tr(I18nKey.bookingFormRequired),
                            contactSection: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _SectionCard(
                                  icon: Icons.contact_phone_outlined,
                                  title: i18n.tr(I18nKey.bookingFormContactInfo),
                                  child: Column(
                                    children: [
                                      Text(
                                        i18n.tr(I18nKey.bookingFormSubtitle),
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.blueGrey.shade600,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      _FormField(
                                        label: i18n.tr(I18nKey.bookingFormPhone),
                                        controller: phoneController,
                                        requiredMsg:
                                            i18n.tr(I18nKey.bookingFormRequired),
                                        icon: Icons.phone_outlined,
                                        keyboardType: TextInputType.phone,
                                      ),
                                      _FormField(
                                        label: i18n.tr(I18nKey.bookingFormEmail),
                                        controller: emailController,
                                        requiredMsg:
                                            i18n.tr(I18nKey.bookingFormRequired),
                                        icon: Icons.email_outlined,
                                        keyboardType: TextInputType.emailAddress,
                                      ),
                                      _FormField(
                                        label: i18n.tr(
                                          I18nKey.bookingFormNationality,
                                        ),
                                        controller: nationalityController,
                                        icon: Icons.flag_outlined,
                                        optional: true,
                                      ),
                                      _FormField(
                                        label: i18n.tr(I18nKey.bookingFormNote),
                                        controller: noteController,
                                        icon: Icons.notes_outlined,
                                        optional: true,
                                        maxLines: 3,
                                      ),
                                      CheckboxListTile(
                                        value: _wantsInsurance,
                                        onChanged: (v) => setState(
                                          () => _wantsInsurance = v ?? false,
                                        ),
                                        contentPadding: EdgeInsets.zero,
                                        title: Text(
                                          i18n.tr(I18nKey.bookingFormInsuranceLabel),
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        subtitle: Text(
                                          i18n.tr(I18nKey.bookingFormInsuranceHint),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.blueGrey.shade600,
                                          ),
                                        ),
                                        controlAffinity:
                                            ListTileControlAffinity.leading,
                                      ),
                                    ],
                                  ),
                                ),
                                if (mapGuideToCard(_packageGuide) != null) ...[
                                  const SizedBox(height: 12),
                                  PackageGuideCard(
                                    guide: mapGuideToCard(_packageGuide)!,
                                    variant: PackageGuideCardVariant.expanded,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          _ReviewStep(
                            i18n: i18n,
                            packageTitle: _packageTitle,
                            schedule: _selectedSchedule,
                            fmtDateTime: _fmtDateTime,
                            peopleCount: _peopleCount,
                            travelerNames:
                                _travelers.map((t) => t.fullName).toList(),
                            phone: phoneController.text.trim(),
                            email: emailController.text.trim(),
                            nationality: nationalityController.text.trim(),
                            note: noteController.text.trim(),
                            wantsInsurance: _wantsInsurance,
                            paymentMinDays: '3',
                          ),
                        ],
                      ),
                    ),
          ),
          if (_step == 2 && !_loadingPackage && _loadError == null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String>(
                    value: _payBank,
                    decoration: InputDecoration(
                      labelText: i18n.tr(I18nKey.bookingFormPayBank),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: PhajayPaymentService.qrBanks
                        .map(
                          (b) => DropdownMenuItem(
                            value: b,
                            child: Text(
                              b == 'm_money' ? 'M-Money' : b.toUpperCase(),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _payBank = v);
                    },
                  ),
                  BookingTermsAcceptTile(
                    value: _termsAccepted,
                    onChanged: (v) => setState(() => _termsAccepted = v),
                  ),
                ],
              ),
            ),
          _BottomBar(
            step: _step,
            isSubmitting: _isSubmitting,
            canProceed:
                !_loadingPackage &&
                _loadError == null &&
                _schedules.isNotEmpty &&
                (_step != 2 || _termsAccepted),
            backLabel: i18n.tr(
              I18nKey.bookingFormBack,
              fallback: isLo ? 'ກັບຄືນ' : 'Back',
            ),
            continueLabel: i18n.tr(I18nKey.commonContinue),
            submitLabel: i18n.tr(I18nKey.bookingFormBookPay),
            payLaterLabel: i18n.tr(I18nKey.bookingFormPayLater),
            onBack: _onBack,
            onNext: _onNext,
            onPayNow:
                _step == 2
                    ? () => _submitBooking(payNow: true)
                    : null,
            onPayLater:
                _step == 2
                    ? () => _submitBooking(payNow: false)
                    : null,
          ),
        ],
      ),
    );
  }
}

// ─── Step indicator ───────────────────────────────────────────────────────────

class _BookingStepHeader extends StatelessWidget {
  final int step;
  final List<String> labels;

  const _BookingStepHeader({required this.step, required this.labels});

  static const double _circleSize = 32;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(labels.length, (i) {
          final done = i < step;
          final active = i == step;
          final lineBeforeDone = i > 0 && i <= step;
          final lineAfterDone = i < labels.length - 1 && i < step;

          return Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: _circleSize,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child:
                            i > 0
                                ? Container(
                                  height: 2,
                                  color:
                                      lineBeforeDone
                                          ? AppColors.primary
                                          : Colors.blueGrey.shade200,
                                )
                                : const SizedBox.shrink(),
                      ),
                      _StepCircle(
                        done: done,
                        active: active,
                        index: i,
                        size: _circleSize,
                      ),
                      Expanded(
                        child:
                            i < labels.length - 1
                                ? Container(
                                  height: 2,
                                  color:
                                      lineAfterDone
                                          ? AppColors.primary
                                          : Colors.blueGrey.shade200,
                                )
                                : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Text(
                    labels[i],
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.25,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      color:
                          active ? AppColors.primary : Colors.blueGrey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _StepCircle extends StatelessWidget {
  final bool done;
  final bool active;
  final int index;
  final double size;

  const _StepCircle({
    required this.done,
    required this.active,
    required this.index,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: done || active ? AppColors.primary : Colors.blueGrey.shade200,
        shape: BoxShape.circle,
      ),
      child: Center(
        child:
            done
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                : Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: active ? Colors.white : Colors.blueGrey.shade600,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
      ),
    );
  }
}

class _PackageBanner extends StatelessWidget {
  final String title;
  final String location;

  const _PackageBanner({required this.title, required this.location});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.88)],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.tour_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (location.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.place_outlined,
                        size: 14,
                        color: Colors.white.withOpacity(0.85),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
    );
  }
}

// ─── Step 1: Departure ────────────────────────────────────────────────────────

class _DepartureStep extends StatelessWidget {
  final UiI18n i18n;
  final List<Map<String, dynamic>> schedules;
  final String? selectedId;
  final String hint;
  final String emptyText;
  final ValueChanged<String> onSelect;
  final String Function(String?) fmtDateTime;
  final int Function(Map<String, dynamic>) seatsLeft;

  const _DepartureStep({
    required this.i18n,
    required this.schedules,
    required this.selectedId,
    required this.hint,
    required this.emptyText,
    required this.onSelect,
    required this.fmtDateTime,
    required this.seatsLeft,
  });

  @override
  Widget build(BuildContext context) {
    final isLo = context.watch<ApiLocaleProvider>().code == 'lo';
    final returnLabel = i18n.tr(
      I18nKey.bookingDetailLabelReturn,
      fallback: isLo ? 'ກັບມາ' : 'Return',
    );
    if (schedules.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.event_busy_rounded,
                size: 56,
                color: AppColors.primary.withOpacity(0.4),
              ),
              const SizedBox(height: 16),
              Text(
                emptyText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.45,
                  color: Colors.blueGrey.shade700,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Text(
          hint,
          style: TextStyle(
            fontSize: 14,
            color: Colors.blueGrey.shade600,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 12),
        ...schedules.map((s) {
          final id = s['scheduleId']?.toString() ?? '';
          final selected = id == selectedId;
          final left = seatsLeft(s);
          final cap = int.tryParse(s['capacity']?.toString() ?? '') ?? 0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onSelect(id),
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          selected
                              ? AppColors.primary
                              : const Color(0xFFE8ECF0),
                      width: selected ? 2 : 1,
                    ),
                    boxShadow: [
                      if (selected)
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.12),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        selected
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_off_rounded,
                        color: selected ? AppColors.primary : Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.flight_takeoff_rounded,
                                  size: 18,
                                  color: AppColors.primary.withOpacity(0.9),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    fmtDateTime(
                                      s['departureDatetime']?.toString(),
                                    ),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      color: Color(0xFF1A2332),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (s['returnDatetime'] != null &&
                                s['returnDatetime'].toString().isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    Icons.flight_land_rounded,
                                    size: 16,
                                    color: Colors.blueGrey.shade400,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      '$returnLabel: ${fmtDateTime(s['returnDatetime']?.toString())}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.blueGrey.shade600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    left > 0
                                        ? const Color(0xFFE8F5E9)
                                        : Colors.red.shade50,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                i18n.tr(
                                  I18nKey.bookingFormSeatsLeft,
                                  params: {'left': '$left', 'total': '$cap'},
                                ),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      left > 0
                                          ? const Color(0xFF2E7D32)
                                          : Colors.red.shade700,
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
            ),
          );
        }),
      ],
    );
  }
}

// ─── Step 2: Details ──────────────────────────────────────────────────────────

class _DetailsStep extends StatelessWidget {
  final UiI18n i18n;
  final String subtitle;
  final TextEditingController nameController;
  final TextEditingController surnameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController birthController;
  final TextEditingController nationalityController;
  final TextEditingController noteController;
  final String requiredMsg;

  const _DetailsStep({
    required this.i18n,
    required this.subtitle,
    required this.nameController,
    required this.surnameController,
    required this.phoneController,
    required this.emailController,
    required this.birthController,
    required this.nationalityController,
    required this.noteController,
    required this.requiredMsg,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _SectionCard(
          icon: Icons.person_outline_rounded,
          title: i18n.tr(I18nKey.bookingFormYourInfo),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: Colors.blueGrey.shade600,
                ),
              ),
              const SizedBox(height: 16),
              _FormField(
                label: i18n.tr(I18nKey.bookingFormFirstName),
                controller: nameController,
                requiredMsg: requiredMsg,
                icon: Icons.badge_outlined,
              ),
              _FormField(
                label: i18n.tr(I18nKey.bookingFormLastName),
                controller: surnameController,
                requiredMsg: requiredMsg,
                icon: Icons.badge_outlined,
              ),
              _FormField(
                label: i18n.tr(I18nKey.bookingFormPhone),
                controller: phoneController,
                requiredMsg: requiredMsg,
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              _FormField(
                label: i18n.tr(I18nKey.bookingFormEmail),
                controller: emailController,
                requiredMsg: requiredMsg,
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              _BirthDateField(
                label: i18n.tr(I18nKey.bookingFormBirth),
                controller: birthController,
                requiredMsg: requiredMsg,
              ),
              _FormField(
                label: i18n.tr(I18nKey.bookingFormNationality),
                controller: nationalityController,
                icon: Icons.flag_outlined,
                optional: true,
              ),
              _FormField(
                label: i18n.tr(I18nKey.bookingFormNote),
                controller: noteController,
                icon: Icons.notes_outlined,
                optional: true,
                maxLines: 3,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final String? requiredMsg;
  final bool optional;
  final TextInputType? keyboardType;
  final int maxLines;

  const _FormField({
    required this.label,
    required this.controller,
    required this.icon,
    this.requiredMsg,
    this.optional = false,
    this.keyboardType,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primary.withOpacity(0.75)),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE8ECF0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE8ECF0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
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
      child: InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime(2000),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );
          if (picked != null) {
            controller.text = DateFormat('dd/MM/yyyy').format(picked);
          }
        },
        borderRadius: BorderRadius.circular(14),
        child: IgnorePointer(
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: Icon(
                Icons.cake_outlined,
                color: AppColors.primary.withOpacity(0.75),
              ),
              suffixIcon: Icon(
                Icons.calendar_today_rounded,
                color: Colors.blueGrey.shade400,
                size: 20,
              ),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            validator: (v) => v == null || v.isEmpty ? requiredMsg : null,
          ),
        ),
      ),
    );
  }
}

// ─── Step 3: Review ───────────────────────────────────────────────────────────

class _ReviewStep extends StatelessWidget {
  final UiI18n i18n;
  final String packageTitle;
  final Map<String, dynamic>? schedule;
  final String Function(String?) fmtDateTime;
  final int peopleCount;
  final List<String> travelerNames;
  final String phone;
  final String email;
  final String nationality;
  final String note;
  final bool wantsInsurance;
  final String paymentMinDays;

  const _ReviewStep({
    required this.i18n,
    required this.packageTitle,
    required this.schedule,
    required this.fmtDateTime,
    required this.peopleCount,
    required this.travelerNames,
    required this.phone,
    required this.email,
    required this.nationality,
    required this.note,
    required this.wantsInsurance,
    required this.paymentMinDays,
  });

  @override
  Widget build(BuildContext context) {
    final isLo = context.watch<ApiLocaleProvider>().code == 'lo';
    final em = i18n.tr(I18nKey.commonEmDash);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Text(
          i18n.tr(I18nKey.bookingFormReviewTitle),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A2332),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          i18n.tr(I18nKey.bookingFormReviewSubtitle),
          style: TextStyle(
            fontSize: 14,
            height: 1.45,
            color: Colors.blueGrey.shade600,
          ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          icon: Icons.event_available_outlined,
          title: i18n.tr(I18nKey.bookingFormDeparture),
          child: Column(
            children: [
              _ReviewRow(
                icon: Icons.tour_outlined,
                label: i18n.tr(I18nKey.bookingDetailSectionPackage),
                value: packageTitle.isNotEmpty ? packageTitle : em,
              ),
              if (schedule != null) ...[
                _ReviewRow(
                  icon: Icons.flight_takeoff_rounded,
                  label: i18n.tr(I18nKey.bookingDetailLabelDeparture),
                  value: fmtDateTime(
                    schedule!['departureDatetime']?.toString(),
                  ),
                ),
                if (schedule!['returnDatetime'] != null)
                  _ReviewRow(
                    icon: Icons.flight_land_rounded,
                    label: i18n.tr(
                      I18nKey.bookingDetailLabelReturn,
                      fallback: isLo ? 'ກັບມາ' : 'Return',
                    ),
                    value: fmtDateTime(schedule!['returnDatetime']?.toString()),
                  ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        _SectionCard(
          icon: Icons.person_outline_rounded,
          title: i18n.tr(
            I18nKey.bookingFormTravelersCount,
            params: {'count': '$peopleCount'},
          ),
          child: Column(
            children: [
              for (var i = 0; i < travelerNames.length; i++)
                _ReviewRow(
                  icon: Icons.badge_outlined,
                  label: i18n.tr(
                    I18nKey.bookingFormTravelerNumber,
                    params: {'n': '${i + 1}'},
                  ),
                  value:
                      travelerNames[i].isNotEmpty ? travelerNames[i] : em,
                ),
              _ReviewRow(
                icon: Icons.phone_outlined,
                label: i18n.tr(I18nKey.bookingFormPhone),
                value: phone.isNotEmpty ? phone : em,
              ),
              _ReviewRow(
                icon: Icons.email_outlined,
                label: i18n.tr(I18nKey.bookingFormEmail),
                value: email.isNotEmpty ? email : em,
              ),
              if (nationality.isNotEmpty)
                _ReviewRow(
                  icon: Icons.flag_outlined,
                  label: i18n.tr(I18nKey.bookingFormNationality),
                  value: nationality,
                ),
              if (note.isNotEmpty)
                _ReviewRow(
                  icon: Icons.notes_outlined,
                  label: i18n.tr(I18nKey.bookingFormNote),
                  value: note,
                ),
              if (wantsInsurance)
                _ReviewRow(
                  icon: Icons.health_and_safety_outlined,
                  label: i18n.tr(I18nKey.bookingFormInsuranceLabel),
                  value: i18n.tr(I18nKey.bookingFormInsuranceYes),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.accentSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.accent.withOpacity(0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppColors.accent,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  i18n.tr(
                    I18nKey.bookingFormPaymentPolicy,
                    params: {'days': paymentMinDays},
                  ),
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: Colors.brown.shade800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ReviewRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.blueGrey.shade400),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueGrey.shade500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A2332),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared widgets ───────────────────────────────────────────────────────────

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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 22),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Color(0xFF1A2332),
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

class _BottomBar extends StatelessWidget {
  final int step;
  final bool isSubmitting;
  final bool canProceed;
  final String backLabel;
  final String continueLabel;
  final String submitLabel;
  final String payLaterLabel;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback? onPayNow;
  final VoidCallback? onPayLater;

  const _BottomBar({
    required this.step,
    required this.isSubmitting,
    required this.canProceed,
    required this.backLabel,
    required this.continueLabel,
    required this.submitLabel,
    required this.payLaterLabel,
    required this.onBack,
    required this.onNext,
    this.onPayNow,
    this.onPayLater,
  });

  @override
  Widget build(BuildContext context) {
    final isReview = step == 2;

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child:
          isReview
              ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed:
                          !canProceed || isSubmitting ? null : onPayNow,
                      icon: const Icon(Icons.payment_rounded, size: 20),
                      label: Text(submitLabel),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed:
                          !canProceed || isSubmitting ? null : onPayLater,
                      icon: const Icon(Icons.schedule_rounded, size: 20),
                      label: Text(payLaterLabel),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextButton(
                    onPressed: isSubmitting ? null : onBack,
                    child: Text(backLabel),
                  ),
                ],
              )
              : Row(
                children: [
                  if (step > 0)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: isSubmitting ? null : onBack,
                        icon: const Icon(Icons.arrow_back_rounded, size: 20),
                        label: Text(backLabel),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: BorderSide(
                            color: AppColors.primary.withOpacity(0.4),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  if (step > 0) const SizedBox(width: 10),
                  Expanded(
                    flex: step > 0 ? 2 : 1,
                    child: FilledButton(
                      onPressed: !canProceed || isSubmitting ? null : onNext,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child:
                          isSubmitting
                              ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                              : Text(
                                continueLabel,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                    ),
                  ),
                ],
              ),
    );
  }
}

class _LoadErrorView extends StatelessWidget {
  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  const _LoadErrorView({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 52,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.blueGrey.shade700, height: 1.45),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(retryLabel),
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
