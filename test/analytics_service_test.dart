import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ultimate_window_engineer_tool/analytics/analytics_config.dart';
import 'package:ultimate_window_engineer_tool/analytics/analytics_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('analytics service', () {
    test(
      'initializes provider when configured and preference allows it',
      () async {
        SharedPreferences.setMockInitialValues({});
        final provider = _FakeAnalyticsProvider();
        final service = AnalyticsService(
          config: const AnalyticsConfig(
            enabled: true,
            postHogApiKey: 'test-key',
            postHogHost: 'https://example.test',
            debug: false,
          ),
          provider: provider,
        );

        await service.initialize();

        expect(service.analyticsEnabled, isTrue);
        expect(provider.setupCalled, isTrue);
        expect(provider.setupOptOut, isFalse);
      },
    );

    test('does not initialize provider without an api key', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = _FakeAnalyticsProvider();
      final service = AnalyticsService(
        config: const AnalyticsConfig(
          enabled: true,
          postHogApiKey: '',
          postHogHost: 'https://example.test',
          debug: false,
        ),
        provider: provider,
      );

      await service.initialize();
      await service.logEvent(AnalyticsEvent.appOpened);

      expect(service.analyticsEnabled, isFalse);
      expect(provider.setupCalled, isFalse);
      expect(provider.captures, isEmpty);
    });

    test(
      'analytics opt-out disables provider and suppresses future events',
      () async {
        SharedPreferences.setMockInitialValues({});
        final provider = _FakeAnalyticsProvider();
        final service = AnalyticsService(
          config: const AnalyticsConfig(
            enabled: true,
            postHogApiKey: 'test-key',
            postHogHost: 'https://example.test',
            debug: false,
          ),
          provider: provider,
        );

        await service.initialize();
        await service.setAnalyticsEnabled(false);
        await service.logEvent(AnalyticsEvent.appOpened);

        expect(service.analyticsEnabled, isFalse);
        expect(provider.disableCalled, isTrue);
        expect(
          provider.captures.map((capture) => capture.eventName),
          contains(AnalyticsEvent.analyticsDisabled),
        );
        expect(
          provider.captures.where(
            (capture) => capture.eventName == AnalyticsEvent.appOpened,
          ),
          isEmpty,
        );
      },
    );

    test('search analytics omits raw query text', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = _FakeAnalyticsProvider();
      final service = AnalyticsService(
        config: const AnalyticsConfig(
          enabled: true,
          postHogApiKey: 'test-key',
          postHogHost: 'https://example.test',
          debug: false,
        ),
        provider: provider,
      );

      await service.initialize();
      await service.logSearchPerformed(
        query: 'secret project fridge dimensions',
        resultCount: 1,
      );

      final properties = provider.captures.single.properties;
      expect(properties.keys, isNot(contains('query')));
      expect(properties.values.join(' '), isNot(contains('secret')));
      expect(properties['query_length'], 32);
      expect(properties['query_token_count'], 4);
    });

    test('calculator tool opens emit calculator event', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = _FakeAnalyticsProvider();
      final service = AnalyticsService(
        config: const AnalyticsConfig(
          enabled: true,
          postHogApiKey: 'test-key',
          postHogHost: 'https://example.test',
          debug: false,
        ),
        provider: provider,
      );

      await service.initialize();
      await service.logToolOpened('Test Buck Calculator');

      expect(
        provider.captures.map((capture) => capture.eventName),
        containsAll([
          AnalyticsEvent.toolOpened,
          AnalyticsEvent.calculatorOpened,
        ]),
      );
    });
  });
}

class _FakeAnalyticsProvider implements AnalyticsProvider {
  bool setupCalled = false;
  bool? setupOptOut;
  bool enableCalled = false;
  bool disableCalled = false;
  final captures = <_CapturedEvent>[];

  @override
  Future<void> setup({
    required AnalyticsConfig config,
    required bool optOut,
  }) async {
    setupCalled = true;
    setupOptOut = optOut;
  }

  @override
  Future<void> capture(String eventName, Map<String, Object> properties) async {
    captures.add(_CapturedEvent(eventName, properties));
  }

  @override
  Future<void> screen(
    String screenName,
    Map<String, Object> properties,
  ) async {}

  @override
  Future<void> enable() async {
    enableCalled = true;
  }

  @override
  Future<void> disable() async {
    disableCalled = true;
  }

  @override
  Future<void> flush() async {}

  @override
  Future<void> close() async {}
}

class _CapturedEvent {
  final String eventName;
  final Map<String, Object> properties;

  const _CapturedEvent(this.eventName, this.properties);
}
