/// A UPI app on this device that can sign an AutoPay mandate, as reported by the native
/// bridge (playbook Phase 3.1).
class UpiApp {
  final String packageName;
  final String appName;

  /// The gateway's CDN brand logo. PREFER THIS over [iconBase64]. The launcher icon is
  /// whatever resolution and shape the device happens to have, with no background — it
  /// renders as a muddy blob on the paywall.
  final String? appLogoUrl;
  final String? iconBase64;

  const UpiApp({
    required this.packageName,
    required this.appName,
    this.appLogoUrl,
    this.iconBase64,
  });

  static UpiApp? fromMap(Map<dynamic, dynamic> m) {
    final pkg = m['packageName'] as String?;
    if (pkg == null || pkg.isEmpty) return null;
    String? nonEmpty(Object? v) {
      final s = v as String?;
      return (s != null && s.trim().isNotEmpty) ? s : null;
    }

    return UpiApp(
      packageName: pkg,
      appName: nonEmpty(m['appName']) ?? pkg,
      appLogoUrl: nonEmpty(m['appLogoUrl']),
      iconBase64: nonEmpty(m['iconBase64']),
    );
  }
}

/// Outcome of a subscription create. Carries the gateway key alongside the id because the
/// direct-UPI submit needs both and they arrive from the same response.
class CreatedSubscription {
  final String? subscriptionId;
  final String? keyId;
  final String? error;

  const CreatedSubscription({this.subscriptionId, this.keyId, this.error});

  bool get isUsable =>
      subscriptionId != null &&
      subscriptionId!.isNotEmpty &&
      keyId != null &&
      keyId!.isNotEmpty;
}

/// Result of a direct-UPI hand-off, mirroring the native `status` field.
class UpiLaunchResult {
  final bool success;
  final bool cancelled;
  final String? subscriptionId;
  final String? paymentId;
  final String? signature;
  final String? error;

  const UpiLaunchResult({
    required this.success,
    this.cancelled = false,
    this.subscriptionId,
    this.paymentId,
    this.signature,
    this.error,
  });
}