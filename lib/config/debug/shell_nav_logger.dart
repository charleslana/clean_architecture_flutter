import 'package:flutter/widgets.dart';

import '../../utils/debug_log.dart';

class ShellNavLogger extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    debugLog('router', '  ↳ push');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    debugLog('router', '  ↲ pop');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    debugLog('router', '  ⇄ replace');
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    debugLog('router', '  ✗ remove');
  }
}
