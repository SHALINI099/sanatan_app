import 'package:flutter/widgets.dart';

/// Language code sent with localised API requests.
///
/// Defaults to Hindi and is overwritten by the dashboard once the persisted
/// language preference has been read.
String appLocale = 'hi';

/// Shared navigator observer for widgets that implement [RouteAware].
final RouteObserver<PageRoute<dynamic>> routeObserver =
    RouteObserver<PageRoute<dynamic>>();
