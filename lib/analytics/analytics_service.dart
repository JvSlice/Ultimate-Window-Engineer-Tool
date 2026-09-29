import 'package:flutter/widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'analytics_config.dart';

abstract class AnalyticsProvider {
  Future<void> setup({required AnalyticsConfig config, required bool optOut});

  Future<void> capture(String eventName, Map<String, Object> properties);
  Future<void> screen(String screenName, Map<String, Object> properties);
  Future<void> enable();
  Future<void> disable();
  Future<void> flush();
  Future<void> close();
}

class PostHogAnalyticsProvider implements AnalyticsProvider {
  @override
  Future<void> setup({
    required AnalyticsConfig config,
    required bool optOut,
  }) async {
    final postHogConfig = PostHogConfig(config.postHogApiKey)
      ..host = config.postHogHost
      ..debug = config.debug
      ..optOut = optOut
      ..captureApplicationLifecycleEvents = false
      ..sessionReplay = false
      ..surveys = false
      ..preloadFeatureFlags = false
      ..sendFeatureFlagEvents = false
      ..personProfiles = PostHogPersonProfiles.never
      ..flushAt = 20
      ..maxBatchSize = 20
      ..flushInterval = const Duration(seconds: 30);

    await Posthog().setup(postHogConfig);
  }

  @override
  Future<void> capture(String eventName, Map<String, Object> properties) {
    return Posthog().capture(eventName: eventName, properties: properties);
  }

  @override
  Future<void> screen(String screenName, Map<String, Object> properties) {
    return Posthog().screen(screenName: screenName, properties: properties);
  }

  @override
  Future<void> enable() => Posthog().enable();

  @override
  Future<void> disable() => Posthog().disable();

  @override
  Future<void> flush() => Posthog().flush();

  @override
  Future<void> close() => Posthog().close();
}

class AnalyticsService extends ChangeNotifier with WidgetsBindingObserver {
  static const _analyticsOptOutKey = 'analytics_opt_out';

  static AnalyticsService instance = AnalyticsService(
    config: analyticsConfig,
    provider: PostHogAnalyticsProvider(),
  );

  final AnalyticsConfig config;
  final AnalyticsProvider provider;

  bool _initialized = false;
  bool _providerReady = false;
  bool _analyticsEnabled = false;
  PackageInfo? _packageInfo;

  AnalyticsService({required this.config, required this.provider});

  bool get initialized => _initialized;
  bool get analyticsEnabled => _analyticsEnabled;
  bool get providerConfigured => config.hasProviderConfig;

  Future<void> initialize() async {
    if (_initialized) return;

    _initialized = true;
    _packageInfo = await _loadPackageInfo();

    final prefs = await SharedPreferences.getInstance();
    final optedOut = prefs.getBool(_analyticsOptOutKey) ?? false;
    _analyticsEnabled = config.providerEnabled && !optedOut;

    if (config.providerEnabled) {
      try {
        await provider.setup(config: config, optOut: !_analyticsEnabled);
        _providerReady = true;
      } catch (_) {
        _providerReady = false;
      }
    }

    WidgetsBinding.instance.addObserver(this);
    notifyListeners();
  }

  Future<void> setAnalyticsEnabled(bool enabled) async {
    final nextEnabled = enabled && config.providerEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_analyticsOptOutKey, !nextEnabled);

    await _silent(() async {
      if (!_providerReady) return;
      if (nextEnabled) {
        _analyticsEnabled = true;
        await provider.enable();
        await logEvent(AnalyticsEvent.analyticsEnabled);
      } else {
        await logEvent(AnalyticsEvent.analyticsDisabled);
        await provider.disable();
      }
    });

    _analyticsEnabled = nextEnabled;
    notifyListeners();
  }

  Future<void> logAppOpened() {
    return logEvent(AnalyticsEvent.appOpened);
  }

  Future<void> logSessionStarted() {
    return logEvent(AnalyticsEvent.sessionStarted);
  }

  Future<void> logSessionEnded() {
    return logEvent(AnalyticsEvent.sessionEnded);
  }

  Future<void> logPageViewed(String pageTitle) {
    return logScreen(pageTitle, properties: {'page_title': pageTitle});
  }

  Future<void> logToolOpened(String toolName, {String? source}) {
    return _silent(() async {
      final properties = <String, Object>{'tool_name': toolName};
      if (source != null) properties['source'] = source;
      await logEvent(AnalyticsEvent.toolOpened, properties: properties);
      if (toolName.toLowerCase().contains('calculator')) {
        await logEvent(AnalyticsEvent.calculatorOpened, properties: properties);
      }
    });
  }

  Future<void> logReferencePageViewed(String pageTitle) {
    return logEvent(
      AnalyticsEvent.referencePageViewed,
      properties: {'page_title': pageTitle},
    );
  }

  Future<void> logConversionPerformed({
    required String toolLabel,
    required String category,
    required String direction,
  }) {
    return logEvent(
      AnalyticsEvent.conversionPerformed,
      properties: {
        'conversion_tool': toolLabel,
        'category': category,
        'direction': direction,
      },
    );
  }

  Future<void> logSearchPerformed({
    required String query,
    required int resultCount,
  }) {
    final tokenCount = _tokenCount(query);
    return logEvent(
      resultCount == 0
          ? AnalyticsEvent.searchReturnedNoResults
          : AnalyticsEvent.searchPerformed,
      properties: {
        'query_length': query.trim().length,
        'query_token_count': tokenCount,
        'result_count': resultCount,
      },
    );
  }

  Future<void> logSearchResultSelected({
    required String resultTitle,
    required String resultType,
    required int position,
  }) {
    return logEvent(
      AnalyticsEvent.searchResultSelected,
      properties: {
        'result_title': resultTitle,
        'result_type': resultType,
        'position': position,
      },
    );
  }

  Future<void> logUserAction(String eventName) {
    return logEvent(eventName);
  }

  Future<void> logEvent(
    String eventName, {
    Map<String, Object?> properties = const {},
  }) {
    return _silent(() async {
      if (!_canSend) return;
      await provider.capture(eventName, _baseProperties(properties));
    });
  }

  Future<void> logScreen(
    String screenName, {
    Map<String, Object?> properties = const {},
  }) {
    return _silent(() async {
      if (!_canSend) return;
      await provider.screen(screenName, _baseProperties(properties));
      await provider.capture(
        AnalyticsEvent.pageViewed,
        _baseProperties({'page_title': screenName, ...properties}),
      );
    });
  }

  bool get _canSend => _initialized && _providerReady && _analyticsEnabled;

  Map<String, Object> _baseProperties(Map<String, Object?> properties) {
    final info = _packageInfo;
    return {
      if (info != null) 'app_version': info.version,
      if (info != null) 'build_number': info.buildNumber,
      'analytics_schema': 1,
      for (final entry in properties.entries)
        if (entry.value != null) entry.key: entry.value!,
    };
  }

  int _tokenCount(String query) {
    return query
        .trim()
        .split(RegExp(r'\s+'))
        .where((token) => token.isNotEmpty)
        .length;
  }

  Future<PackageInfo?> _loadPackageInfo() async {
    try {
      return await PackageInfo.fromPlatform();
    } catch (_) {
      return null;
    }
  }

  Future<void> _silent(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {
      // Analytics must never affect app behavior.
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        logEvent(AnalyticsEvent.appOpened);
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        logSessionEnded();
        _silent(provider.flush);
        break;
      case AppLifecycleState.inactive:
        break;
    }
  }

  Future<void> close() async {
    WidgetsBinding.instance.removeObserver(this);
    await _silent(() async {
      await logSessionEnded();
      if (_providerReady) await provider.close();
    });
  }
}

class AnalyticsEvent {
  static const appOpened = 'App Opened';
  static const sessionStarted = 'Session Started';
  static const sessionEnded = 'Session Ended';
  static const appVersion = 'App Version';
  static const pageViewed = 'Page Viewed';
  static const toolOpened = 'Tool Opened';
  static const searchPerformed = 'Search Performed';
  static const searchResultSelected = 'Search Result Selected';
  static const searchReturnedNoResults = 'Search Returned No Results';
  static const calculatorOpened = 'Calculator Opened';
  static const conversionPerformed = 'Conversion Performed';
  static const referencePageViewed = 'Reference Page Viewed';
  static const installAppClicked = 'Install App Clicked';
  static const shareAppClicked = 'Share App Clicked';
  static const feedbackOpened = 'Feedback Opened';
  static const feedbackSubmitted = 'Feedback Submitted';
  static const whatsNewViewed = "What's New Viewed";
  static const analyticsEnabled = 'Analytics Enabled';
  static const analyticsDisabled = 'Analytics Disabled';
}
