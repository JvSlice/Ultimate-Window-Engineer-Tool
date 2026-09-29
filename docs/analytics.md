# Anonymous Analytics

UWE routes all analytics through `lib/analytics/analytics_service.dart`.
No page, widget, calculator, or reference tool should call a provider SDK
directly.

## Configuration

Provider settings live in `lib/analytics/analytics_config.dart`.

Build-time values:

* `POSTHOG_API_KEY`: PostHog project token.
* `POSTHOG_HOST`: PostHog ingestion host. Defaults to `https://us.i.posthog.com`.
* `ANALYTICS_ENABLED`: master enabled flag. Defaults to `true`.
* `ANALYTICS_DEBUG`: enables provider debug logging.

Analytics is inactive when no provider key is configured. The app continues to
work normally when analytics is disabled, unreachable, or misconfigured.

Example build:

```sh
flutter build web --dart-define=POSTHOG_API_KEY=phc_xxx --dart-define=ANALYTICS_ENABLED=true
```

## Privacy

Analytics is anonymous. Do not log names, email addresses, project names,
engineering calculations, dimensions, user-entered values, or raw search text.

Search analytics may include query length, token count, result count, and the
selected result title/type. Conversion analytics may include the conversion tool,
category, and direction, but not the entered value or result.

Users can disable analytics from Settings.

## Adding Events

Add event names to `AnalyticsEvent` and call `AnalyticsService.instance`:

```dart
AnalyticsService.instance.logEvent(
  AnalyticsEvent.feedbackOpened,
  properties: {'source': 'settings'},
);
```

Use title-case event names, such as `Tool Opened` or `Search Performed`.
Use snake_case property names. Keep properties generic and non-sensitive.

## Current Event Groups

* Application: app opened, session started, session ended, app version.
* Navigation: page viewed, tool opened.
* Search: search performed, result selected, no results.
* Tools: calculator opened, conversion performed, reference page viewed.
* User actions: install/share/feedback/What’s New events.
