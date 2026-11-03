import 'dart:io';

/// [HttpOverrides] that accepts every TLS certificate, valid or not.
///
/// This disables certificate validation for all `dart:io` HTTP traffic,
/// including Dio. It exists because the backend serves a certificate the
/// platform trust store rejects; it should be removed once the backend
/// presents a certificate chain that validates normally.
class PermissiveHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = _acceptAllCertificates;
  }

  static bool _acceptAllCertificates(
    X509Certificate certificate,
    String host,
    int port,
  ) =>
      true;
}
