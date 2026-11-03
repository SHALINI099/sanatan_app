import 'dart:ui';


class UpiConfig {
  UpiConfig._();

  // ------------------------------------------------------------------ master switch

  static const bool _kDirectEnabled = true;
  static bool _directEnabled = _kDirectEnabled;


  static bool get directEnabled => _directEnabled;

  // ------------------------------------------------------------------ detection

  static const List<String> _kPriorityPackages = <String>[
    'com.phonepe.app',
    'com.google.android.apps.nbu.paisa.user',
    'net.one97.paytm',
  ];
  static List<String> _priorityPackages = _kPriorityPackages;
  static List<String> get priorityPackages => _priorityPackages;

  static const String _kPreselectPackage = 'com.phonepe.app';
  static String _preselectPackage = _kPreselectPackage;

  static String get preselectPackage => _preselectPackage;

  static const int _kMaxApps = 3;
  static int _maxApps = _kMaxApps;


  static int get maxApps => _maxApps;

  static const int _kDetectionTimeoutMs = 800;
  static int _detectionTimeoutMs = _kDetectionTimeoutMs;

  static int get detectionTimeoutMs => _detectionTimeoutMs;

  static const int _kDetectionInvokeTimeoutMs = 3000;
  static int _detectionInvokeTimeoutMs = _kDetectionInvokeTimeoutMs;


  static int get detectionInvokeTimeoutMs => _detectionInvokeTimeoutMs;

  /// The ceiling handed to the native side, kept just inside [detectionInvokeTimeoutMs] so
  /// native answers late rather than Dart giving up.
  static int get detectionHardDeadlineMs =>
      (_detectionInvokeTimeoutMs * 0.8).round();

  static const int _kDetectionRetryDelayMs = 600;
  static int _detectionRetryDelayMs = _kDetectionRetryDelayMs;


  static int get detectionRetryDelayMs => _detectionRetryDelayMs;

  static const int _kDetectionPollMs = 50;
  static int _detectionPollMs = _kDetectionPollMs;
  static int get detectionPollMs => _detectionPollMs;

  static const bool _kWarmSubscription = true;
  static bool _warmSubscription = _kWarmSubscription;

  /// When true, a subscription is minted AHEAD of the tap (at paywall open, on plan select,
  /// on UPI-card select) so the tap costs no network round-trip.
  ///
  /// Off by default: warming calls `createSubscription` for every user who merely opens the
  /// paywall, leaving an orphan `created` subscription behind for everyone who never pays.
  /// With this off the call happens exactly where the user's intent is — Continue, with an
  /// app already chosen — at the cost of one round-trip inside the "Opening {app}…" wait.
  static bool get warmSubscription => _warmSubscription;

  static const bool _kPreferAutoPay = true;
  static bool _preferAutoPay = _kPreferAutoPay;

  static bool get preferAutoPay => _preferAutoPay;

  static const int _kAutoPayWaitMs = 500;
  static int _autoPayWaitMs = _kAutoPayWaitMs;

  /// MUST stay below [detectionTimeoutMs] — see the invariant enforced in [applyOverrides].
  static int get autoPayWaitMs => _autoPayWaitMs;

  // ------------------------------------------------------------------ lifecycle

  static const int _kStrandedGraceMs = 2500;
  static int _strandedGraceMs = _kStrandedGraceMs;

  /// Grace given to a real SDK callback before the stranded guard is released (D15).
  static int get strandedGraceMs => _strandedGraceMs;

  static const int _kConfirmBudgetSeconds = 120;
  static int _confirmBudgetSeconds = _kConfirmBudgetSeconds;

  /// WALL-CLOCK, never an attempt count (D18).
  static int get confirmBudgetSeconds => _confirmBudgetSeconds;

  static const int _kRetryIntervalSeconds = 3;
  static int _retryIntervalSeconds = _kRetryIntervalSeconds;
  static int get retryIntervalSeconds => _retryIntervalSeconds;

  static const int _kConfirmMaxAttempts = 2;
  static int _confirmMaxAttempts = _kConfirmMaxAttempts;

  /// Hard cap on how many times `checkSubscriptionStatus` is called per confirmation, on
  /// top of [confirmBudgetSeconds]. Whichever limit is reached first ends the poll, so the
  /// wall-clock budget still protects a slow network — this just stops the loop hammering
  /// the endpoint dozens of times. 0 or less means "no cap, budget only".
  static int get confirmMaxAttempts => _confirmMaxAttempts;

  // ------------------------------------------------------------------ copy

  static const String _kHeaderLabel = 'Pay Securely';
  static String _headerLabel = _kHeaderLabel;

  /// Empty hides the header entirely (no orphan header over an empty row).
  static String get headerLabel => _headerLabel;

  static const String _kOtherLabel = 'Other UPI';
  static String _otherLabel = _kOtherLabel;

  /// Empty hides the Other tile.
  static String get otherLabel => _otherLabel;

  static const String _kOtherIconUrl = 'https://cdn.razorpay.com/app/bhim.png';
  static String _otherIconUrl = _kOtherIconUrl;
  static String get otherIconUrl => _otherIconUrl;

  static const double _kOtherIconScale = 1.35;
  static double _otherIconScale = _kOtherIconScale;

  /// The BHIM mark ships as a square PNG with transparent padding baked in, so at the same
  /// box size it reads noticeably smaller than the full-bleed app icons beside it. Scaling
  /// the drawn image up inside the same circle makes the row look even. 1.0 disables it.
  static double get otherIconScale => _otherIconScale;

  static const String _kPopularBadgeLabel = 'POPULAR';
  static String _popularBadgeLabel = _kPopularBadgeLabel;

  /// Empty = no badge on any card.
  static String get popularBadgeLabel => _popularBadgeLabel;

  static const String _kPopularBadgePackage = 'com.phonepe.app';
  static String _popularBadgePackage = _kPopularBadgePackage;
  static String get popularBadgePackage => _popularBadgePackage;

  static const String _kConfirmingLabel = 'Confirming with your bank…';
  static String _confirmingLabel = _kConfirmingLabel;
  static String get confirmingLabel => _confirmingLabel;

  static const String _kPendingLabel = 'Taking longer than usual…';
  static String _pendingLabel = _kPendingLabel;
  static String get pendingLabel => _pendingLabel;

  static const String _kRefreshLabel = "I've paid — Refresh";
  static String _refreshLabel = _kRefreshLabel;
  static String get refreshLabel => _refreshLabel;

  static const String _kWaitLabel = 'Please wait…';
  static String _waitLabel = _kWaitLabel;
  static String get waitLabel => _waitLabel;

  static const String _kOpeningLabel = 'Opening {app}…';
  static String _openingLabel = _kOpeningLabel;

  /// MUST contain `{app}` — [applyOverrides] rejects an override that drops the token,
  /// otherwise the user sees a wait with no name on it.
  static String get openingLabel => _openingLabel;

  /// The only correct way to build the opening label.
  static String openingLabelFor(String appName) =>
      _openingLabel.replaceAll('{app}', appName);

  static const String _kErrorLaunchFailed =
      'Could not open that UPI app. Please try another.';
  static String _errorLaunchFailed = _kErrorLaunchFailed;
  static String get errorLaunchFailed => _errorLaunchFailed;

  static const String _kErrorCancelled = 'Payment cancelled.';
  static String _errorCancelled = _kErrorCancelled;
  static String get errorCancelled => _errorCancelled;

  static const String _kErrorDefault = 'Payment could not be completed.';
  static String _errorDefault = _kErrorDefault;
  static String get errorDefault => _errorDefault;

  static const String _kCtaLabel = 'Buy Now';
  static String _ctaLabel = _kCtaLabel;

  /// The paywall's normal CTA text — the bottom rung of the label ladder.
  static String get ctaLabel => _ctaLabel;

  static const String _kCheckoutDescription = 'Om Shanti Premium';
  static String _checkoutDescription = _kCheckoutDescription;
  static String get checkoutDescription => _checkoutDescription;

  // ------------------------------------------------------------------ card styling

  static const double _kIconSize = 52;
  static double _iconSize = _kIconSize;
  static double get iconSize => _iconSize;

  static const double _kCardRadius = 14;
  static double _cardRadius = _kCardRadius;
  static double get cardRadius => _cardRadius;

  static const double _kCardGap = 18;
  static double _cardGap = _kCardGap;
  static double get cardGap => _cardGap;

  static const double _kCardBorderWidth = 1.5;
  static double _cardBorderWidth = _kCardBorderWidth;
  static double get cardBorderWidth => _cardBorderWidth;

  static const double _kSelectedBorderWidth = 1.5;
  static double _selectedBorderWidth = _kSelectedBorderWidth;
  static double get selectedBorderWidth => _selectedBorderWidth;

  static const double _kLabelFontSize = 13;
  static double _labelFontSize = _kLabelFontSize;
  static double get labelFontSize => _labelFontSize;

  static const double _kBadgeFontSize = 8;
  static double _badgeFontSize = _kBadgeFontSize;
  static double get badgeFontSize => _badgeFontSize;

  static const double _kBadgeRadius = 8;
  static double _badgeRadius = _kBadgeRadius;
  static double get badgeRadius => _badgeRadius;

  static const double _kHeaderFontSize = 16;
  static double _headerFontSize = _kHeaderFontSize;
  static double get headerFontSize => _headerFontSize;

  static const int _kSelectedBorderColor = 0xFFFF9800;
  static int _selectedBorderColorValue = _kSelectedBorderColor;
  static Color get selectedBorderColor => Color(_selectedBorderColorValue);

  static const int _kCardBorderColor = 0x33000000;
  static int _cardBorderColorValue = _kCardBorderColor;
  static Color get cardBorderColor => Color(_cardBorderColorValue);

  static const int _kCardFillColor = 0xFFFFFFFF;
  static int _cardFillColorValue = _kCardFillColor;
  static Color get cardFillColor => Color(_cardFillColorValue);

  static const int _kLabelColor = 0xFF9E9E9E;
  static int _labelColorValue = _kLabelColor;

  /// Label colour for a card that is NOT selected.
  static Color get labelColor => Color(_labelColorValue);

  static const int _kSelectedLabelColor = 0xFFFF9800;
  static int _selectedLabelColorValue = _kSelectedLabelColor;

  /// Label colour for the selected card. The design signals selection with the LABEL and
  /// the icon ring, not with a surrounding box.
  static Color get selectedLabelColor => Color(_selectedLabelColorValue);

  static const int _kHeaderColor = 0xFF6B6B6B;
  static int _headerColorValue = _kHeaderColor;
  static Color get headerColor => Color(_headerColorValue);

  static const double _kIconRingWidth = 2.5;
  static double _iconRingWidth = _kIconRingWidth;

  /// Ring drawn around each brand logo. Selection tints it; unselected keeps it neutral.
  static double get iconRingWidth => _iconRingWidth;

  static const int _kIconRingColor = 0x22000000;
  static int _iconRingColorValue = _kIconRingColor;
  static Color get iconRingColor => Color(_iconRingColorValue);


  static const int _kBadgeTextColor = 0xFFFFFFFF;
  static int _badgeTextColorValue = _kBadgeTextColor;
  static Color get badgeTextColor => Color(_badgeTextColorValue);

  // ------------------------------------------------------------------ overrides

  /// Apply an optional `upi_config` map from the `getSubscriptionPlans` response.
  ///
  /// Every field is independent and optional: an unrecognised key is ignored, a wrongly
  /// typed value leaves that single field at its Dart default rather than failing the whole
  /// apply. This runs on the payment path, so it must never throw.
  static void applyOverrides(dynamic raw) {
    reset();
    if (raw is! Map) return;

    _directEnabled = _boolOr(raw['upi_direct_enabled'], _kDirectEnabled);

    final priority = _stringListOr(raw['upi_priority_packages'], _kPriorityPackages);
    _priorityPackages = priority.isEmpty ? _kPriorityPackages : priority;

    _preselectPackage = _stringOr(raw['upi_preselect_package'], _kPreselectPackage);
    _maxApps = _intOr(raw['upi_max_apps'], _kMaxApps);
    _detectionTimeoutMs =
        _intOr(raw['upi_detection_timeout_ms'], _kDetectionTimeoutMs);
    _detectionInvokeTimeoutMs = _intOr(
        raw['upi_detection_invoke_timeout_ms'], _kDetectionInvokeTimeoutMs);
    _detectionPollMs = _intOr(raw['upi_detection_poll_ms'], _kDetectionPollMs);
    _detectionRetryDelayMs = _intOr(
        raw['upi_detection_retry_delay_ms'], _kDetectionRetryDelayMs);
    _preferAutoPay =
        _boolOr(raw['upi_prefer_autopay_enumeration'], _kPreferAutoPay);
    _warmSubscription =
        _boolOr(raw['upi_warm_subscription'], _kWarmSubscription);
    _autoPayWaitMs = _intOr(raw['upi_autopay_wait_ms'], _kAutoPayWaitMs);
    _strandedGraceMs = _intOr(raw['upi_stranded_grace_ms'], _kStrandedGraceMs);
    _confirmBudgetSeconds =
        _intOr(raw['upi_confirm_budget_seconds'], _kConfirmBudgetSeconds);
    _retryIntervalSeconds =
        _intOr(raw['upi_retry_interval_seconds'], _kRetryIntervalSeconds);
    _confirmMaxAttempts =
        _intOr(raw['upi_confirm_max_attempts'], _kConfirmMaxAttempts);

    // Empty string is MEANINGFUL for these three (it hides the element), so they are read
    // with _stringOr's allowEmpty path rather than being coerced back to the default.
    _headerLabel = _stringOr(raw['upi_payment_header_label'], _kHeaderLabel,
        allowEmpty: true);
    _otherLabel =
        _stringOr(raw['upi_other_label'], _kOtherLabel, allowEmpty: true);
    _popularBadgeLabel = _stringOr(
        raw['upi_popular_badge_label'], _kPopularBadgeLabel,
        allowEmpty: true);

    _otherIconUrl = _stringOr(raw['upi_other_icon_url'], _kOtherIconUrl);
    _otherIconScale =
        _doubleOr(raw['upi_other_icon_scale'], _kOtherIconScale);
    _popularBadgePackage =
        _stringOr(raw['upi_popular_badge_package'], _kPopularBadgePackage);
    _confirmingLabel =
        _stringOr(raw['upi_confirming_label'], _kConfirmingLabel);
    _pendingLabel = _stringOr(raw['upi_pending_label'], _kPendingLabel);
    _refreshLabel = _stringOr(raw['upi_refresh_label'], _kRefreshLabel);
    _waitLabel = _stringOr(raw['upi_wait_label'], _kWaitLabel);
    _errorLaunchFailed =
        _stringOr(raw['upi_error_launch_failed'], _kErrorLaunchFailed);
    _errorCancelled = _stringOr(raw['upi_error_cancelled'], _kErrorCancelled);
    _errorDefault = _stringOr(raw['upi_error_default'], _kErrorDefault);
    _checkoutDescription =
        _stringOr(raw['upi_checkout_description'], _kCheckoutDescription);
    _ctaLabel = _stringOr(raw['upi_cta_label'], _kCtaLabel);

    // The `{app}` token is what makes this label useful. An override that drops it is
    // rejected outright rather than silently producing an anonymous wait.
    final opening = _stringOr(raw['upi_opening_label'], _kOpeningLabel);
    _openingLabel = opening.contains('{app}') ? opening : _kOpeningLabel;

    _iconSize = _doubleOr(raw['upi_card_icon_size'], _kIconSize);
    _cardRadius = _doubleOr(raw['upi_card_radius'], _kCardRadius);
    _cardGap = _doubleOr(raw['upi_card_gap'], _kCardGap);
    _cardBorderWidth =
        _doubleOr(raw['upi_card_border_width'], _kCardBorderWidth);
    _selectedBorderWidth = _doubleOr(
        raw['upi_card_selected_border_width'], _kSelectedBorderWidth);
    _labelFontSize = _doubleOr(raw['upi_card_label_font_size'], _kLabelFontSize);
    _badgeFontSize = _doubleOr(raw['upi_badge_font_size'], _kBadgeFontSize);
    _badgeRadius = _doubleOr(raw['upi_badge_radius'], _kBadgeRadius);
    _headerFontSize = _doubleOr(raw['upi_header_font_size'], _kHeaderFontSize);

    _selectedBorderColorValue =
        _colorOr(raw['upi_selected_border_color'], _kSelectedBorderColor);
    _cardBorderColorValue =
        _colorOr(raw['upi_card_border_color'], _kCardBorderColor);
    _cardFillColorValue = _colorOr(raw['upi_card_fill_color'], _kCardFillColor);
    _labelColorValue = _colorOr(raw['upi_card_label_color'], _kLabelColor);
    _selectedLabelColorValue = _colorOr(
        raw['upi_card_selected_label_color'], _kSelectedLabelColor);
    _headerColorValue = _colorOr(raw['upi_header_color'], _kHeaderColor);
    _iconRingWidth = _doubleOr(raw['upi_icon_ring_width'], _kIconRingWidth);
    _iconRingColorValue =
        _colorOr(raw['upi_icon_ring_color'], _kIconRingColor);
    _badgeTextColorValue =
        _colorOr(raw['upi_badge_text_color'], _kBadgeTextColor);

    _enforceInvariants();
  }

  /// If the AutoPay wait meets or exceeds the detection budget, the Dart timeout fires
  /// first, the native fallback-to-plain never runs, and "no icons at all" comes back
  /// silently. Clamp rather than trust the payload.
  static void _enforceInvariants() {
    if (_detectionTimeoutMs <= 0) _detectionTimeoutMs = _kDetectionTimeoutMs;
    if (_detectionInvokeTimeoutMs <= 0) {
      _detectionInvokeTimeoutMs = _kDetectionInvokeTimeoutMs;
    }
    // The invoke budget must cover the tap wait, otherwise the tap is waiting on a call
    // that already gave up.
    if (_detectionInvokeTimeoutMs < _detectionTimeoutMs) {
      _detectionInvokeTimeoutMs = _detectionTimeoutMs;
    }
    if (_autoPayWaitMs < 0) _autoPayWaitMs = _kAutoPayWaitMs;
    if (_autoPayWaitMs >= _detectionTimeoutMs) {
      _autoPayWaitMs = (_detectionTimeoutMs * 0.6).round();
    }
    if (_detectionPollMs <= 0) _detectionPollMs = _kDetectionPollMs;
    if (_detectionRetryDelayMs < 0) {
      _detectionRetryDelayMs = _kDetectionRetryDelayMs;
    }
    if (_maxApps <= 0) _maxApps = _kMaxApps;
    if (_confirmBudgetSeconds <= 0) {
      _confirmBudgetSeconds = _kConfirmBudgetSeconds;
    }
    if (_retryIntervalSeconds <= 0) {
      _retryIntervalSeconds = _kRetryIntervalSeconds;
    }
    if (_strandedGraceMs < 0) _strandedGraceMs = _kStrandedGraceMs;
    // A scale below 1 would shrink the mark further; above 2 crops it to abstraction.
    if (_otherIconScale < 1 || _otherIconScale > 2) {
      _otherIconScale = _kOtherIconScale;
    }
  }

  /// Back to the compiled-in defaults. Called at the top of every [applyOverrides] so a
  /// payload that drops a key restores that key rather than keeping the previous fetch's
  /// value.
  static void reset() {
    _directEnabled = _kDirectEnabled;
    _priorityPackages = _kPriorityPackages;
    _preselectPackage = _kPreselectPackage;
    _maxApps = _kMaxApps;
    _detectionTimeoutMs = _kDetectionTimeoutMs;
    _detectionInvokeTimeoutMs = _kDetectionInvokeTimeoutMs;
    _detectionPollMs = _kDetectionPollMs;
    _detectionRetryDelayMs = _kDetectionRetryDelayMs;
    _preferAutoPay = _kPreferAutoPay;
    _warmSubscription = _kWarmSubscription;
    _autoPayWaitMs = _kAutoPayWaitMs;
    _strandedGraceMs = _kStrandedGraceMs;
    _confirmBudgetSeconds = _kConfirmBudgetSeconds;
    _retryIntervalSeconds = _kRetryIntervalSeconds;
    _confirmMaxAttempts = _kConfirmMaxAttempts;
    _headerLabel = _kHeaderLabel;
    _otherLabel = _kOtherLabel;
    _otherIconUrl = _kOtherIconUrl;
    _otherIconScale = _kOtherIconScale;
    _popularBadgeLabel = _kPopularBadgeLabel;
    _popularBadgePackage = _kPopularBadgePackage;
    _confirmingLabel = _kConfirmingLabel;
    _pendingLabel = _kPendingLabel;
    _refreshLabel = _kRefreshLabel;
    _waitLabel = _kWaitLabel;
    _openingLabel = _kOpeningLabel;
    _errorLaunchFailed = _kErrorLaunchFailed;
    _errorCancelled = _kErrorCancelled;
    _errorDefault = _kErrorDefault;
    _checkoutDescription = _kCheckoutDescription;
    _ctaLabel = _kCtaLabel;
    _iconSize = _kIconSize;
    _cardRadius = _kCardRadius;
    _cardGap = _kCardGap;
    _cardBorderWidth = _kCardBorderWidth;
    _selectedBorderWidth = _kSelectedBorderWidth;
    _labelFontSize = _kLabelFontSize;
    _badgeFontSize = _kBadgeFontSize;
    _badgeRadius = _kBadgeRadius;
    _headerFontSize = _kHeaderFontSize;
    _selectedBorderColorValue = _kSelectedBorderColor;
    _cardBorderColorValue = _kCardBorderColor;
    _cardFillColorValue = _kCardFillColor;
    _labelColorValue = _kLabelColor;
    _selectedLabelColorValue = _kSelectedLabelColor;
    _headerColorValue = _kHeaderColor;
    _iconRingWidth = _kIconRingWidth;
    _iconRingColorValue = _kIconRingColor;
    _badgeTextColorValue = _kBadgeTextColor;
  }

  // ------------------------------------------------------------------ coercion

  static bool _boolOr(dynamic v, bool fallback) {
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) {
      final s = v.trim().toLowerCase();
      if (s == 'true' || s == '1' || s == 'yes') return true;
      if (s == 'false' || s == '0' || s == 'no') return false;
    }
    return fallback;
  }

  static int _intOr(dynamic v, int fallback) {
    if (v is int) return v;
    if (v is num) return v.round();
    if (v is String) return int.tryParse(v.trim()) ?? fallback;
    return fallback;
  }

  static double _doubleOr(dynamic v, double fallback) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v.trim()) ?? fallback;
    return fallback;
  }

  static String _stringOr(dynamic v, String fallback, {bool allowEmpty = false}) {
    if (v is! String) return fallback;
    final s = v.trim();
    if (s.isEmpty && !allowEmpty) return fallback;
    return s;
  }

  /// Accepts a hex string (`#RRGGBB`, `#AARRGGBB`, with or without `0x`/`#`) or a raw int.
  /// A 6-digit value is assumed fully opaque.
  static int _colorOr(dynamic v, int fallback) {
    if (v is int) return v;
    if (v is! String) return fallback;
    var s = v.trim().replaceFirst('#', '').replaceFirst('0x', '');
    if (s.length == 6) s = 'FF$s';
    if (s.length != 8) return fallback;
    return int.tryParse(s, radix: 16) ?? fallback;
  }

  /// The comma-or-list form both appear in the wild; accept either.
  static List<String> _stringListOr(dynamic v, List<String> fallback) {
    if (v is List) {
      final out = v
          .whereType<String>()
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(growable: false);
      return out.isEmpty ? fallback : out;
    }
    if (v is String) {
      final out = v
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(growable: false);
      return out.isEmpty ? fallback : out;
    }
    return fallback;
  }
}