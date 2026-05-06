import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityProvider extends ChangeNotifier {
  final Connectivity _connectivity;
  bool _isOnline = true;
  StreamSubscription? _sub;

  ConnectivityProvider({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity() {
    _init();
  }

  bool get isOnline => _isOnline;

  void _init() async {
    final result = await _connectivity.checkConnectivity();
    _isOnline = _hasConnection(result);
    notifyListeners();

    _sub = _connectivity.onConnectivityChanged.listen((result) {
      final online = _hasConnection(result);
      if (online != _isOnline) {
        _isOnline = online;
        notifyListeners();
      }
    });
  }

  bool _hasConnection(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
