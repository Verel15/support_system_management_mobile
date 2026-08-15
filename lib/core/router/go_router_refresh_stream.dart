import 'dart:async';

import 'package:flutter/foundation.dart';

/// Bridges a [Stream] (e.g. a Bloc's state stream) to a [Listenable] so
/// `go_router`'s `refreshListenable` can react to auth state changes and
/// re-evaluate redirects.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
