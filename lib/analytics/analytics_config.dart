class AnalyticsConfig {
  final bool enabled;
  final String postHogApiKey;
  final String postHogHost;
  final bool debug;

  const AnalyticsConfig({
    required this.enabled,
    required this.postHogApiKey,
    required this.postHogHost,
    required this.debug,
  });

  bool get hasProviderConfig => postHogApiKey.trim().isNotEmpty;
  bool get providerEnabled => enabled && hasProviderConfig;
}

const analyticsConfig = AnalyticsConfig(
  enabled: bool.fromEnvironment('ANALYTICS_ENABLED', defaultValue: true),
  postHogApiKey: String.fromEnvironment('POSTHOG_API_KEY'),
  postHogHost: String.fromEnvironment(
    'POSTHOG_HOST',
    defaultValue: 'https://us.i.posthog.com',
  ),
  debug: bool.fromEnvironment('ANALYTICS_DEBUG'),
);
