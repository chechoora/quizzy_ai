import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:poc_ai_quiz/domain/analytics/analytics_events.dart';
import 'package:poc_ai_quiz/domain/analytics/analytics_service.dart';
import 'package:poc_ai_quiz/util/logger.dart';

/// Tracks a [AnalyticsEvents.screenView] event for every named route pushed
/// onto the root navigator, so screens don't each need their own tracking
/// call. Routes without a [RouteSettings.name] (e.g. modal bottom sheets) are
/// skipped.
class AnalyticsNavigatorObserver extends NavigatorObserver {
  AnalyticsNavigatorObserver({required this.analyticsService, required this.logger});

  final AnalyticsService analyticsService;
  final Logger logger;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _track(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _track(newRoute);
  }

  void _track(Route<dynamic>? route) {
    final name = route?.settings.name;
    if (name == null) {
      logger.d('_track: unnamed route, skipping');
      return;
    }
    logger.d('_track: screen=$name');
    unawaited(analyticsService.track(
      AnalyticsEvents.screenView,
      properties: {AnalyticsProperties.screenName: name},
    ));
  }
}
