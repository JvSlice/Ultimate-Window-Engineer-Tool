import 'dart:async';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_theme.dart';
import 'home/main_menu_page.dart';
import 'release_notes/release_note.dart';
import 'release_notes/release_notes_parser.dart';

class SplashPage extends StatefulWidget {
  final AppThemeController themeController;

  const SplashPage({super.key, required this.themeController});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  static const _seenVersionKey = 'last_seen_splash_version';

  PackageInfo? _packageInfo;
  ReleaseNote? _latestNote;
  Timer? _timer;
  bool _ready = false;
  bool _navigating = false;

  @override
  void initState() {
    super.initState();
    _loadSplashState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadSplashState() async {
    final info = await PackageInfo.fromPlatform();
    final prefs = await SharedPreferences.getInstance();
    final versionKey = '${info.version}+${info.buildNumber}';

    if (prefs.getString(_seenVersionKey) == versionKey) {
      _openMainMenu();
      return;
    }

    final notes = await loadReleaseNotes();
    if (!mounted) return;

    setState(() {
      _packageInfo = info;
      _latestNote = notes.isEmpty ? null : notes.first;
      _ready = true;
    });

    _timer = Timer(const Duration(seconds: 5), _finishSplash);
  }

  Future<void> _finishSplash() async {
    if (_navigating) return;
    _navigating = true;

    final info = _packageInfo ?? await PackageInfo.fromPlatform();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _seenVersionKey,
      '${info.version}+${info.buildNumber}',
    );

    if (!mounted) return;
    _openMainMenu();
  }

  void _openMainMenu() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => MainMenuPage(themeController: widget.themeController),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final info = _packageInfo;
    final note = _latestNote;

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) {
        if (_ready) _finishSplash();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.0,
                    colors: [accent.withValues(alpha: 0.16), Colors.black],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: AnimatedOpacity(
                      opacity: _ready ? 1 : 0.45,
                      duration: const Duration(milliseconds: 500),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'UWE',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: accent,
                              fontSize: 72,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 8,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ultimate Window Engineer',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: accent.withValues(alpha: 0.86),
                              fontSize: 18,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 30),
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              border: Border.all(color: accent, width: 2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: _ready
                                ? _ChangeSummary(
                                    accent: accent,
                                    version: info == null
                                        ? 'Loading'
                                        : 'v${info.version}',
                                    buildNumber: info?.buildNumber ?? '',
                                    note: note,
                                  )
                                : Center(
                                    child: CircularProgressIndicator(
                                      color: accent,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            _ready
                                ? 'Tap anywhere or press Continue'
                                : 'Loading...',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: accent.withValues(alpha: 0.68),
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: _ready ? _finishSplash : null,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: accent,
                              side: BorderSide(color: accent, width: 2),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('Continue'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChangeSummary extends StatelessWidget {
  final Color accent;
  final String version;
  final String buildNumber;
  final ReleaseNote? note;

  const _ChangeSummary({
    required this.accent,
    required this.version,
    required this.buildNumber,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    final entries = _summaryEntries(note);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "What's new in $version",
          style: TextStyle(
            color: accent,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (buildNumber.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            'Build $buildNumber',
            style: TextStyle(color: accent.withValues(alpha: 0.7)),
          ),
        ],
        if (note != null && note!.releaseDate.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            'Released: ${note!.releaseDate}',
            style: TextStyle(color: accent.withValues(alpha: 0.7)),
          ),
        ],
        const SizedBox(height: 16),
        for (final entry in entries)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              '> $entry',
              style: TextStyle(
                color: accent.withValues(alpha: 0.9),
                fontSize: 15,
                height: 1.25,
              ),
            ),
          ),
      ],
    );
  }

  List<String> _summaryEntries(ReleaseNote? note) {
    if (note == null) return const ['Release notes are ready.'];

    final entries = <String>[];
    for (final section in note.sections) {
      if (section.title == 'Known Issues') continue;
      entries.addAll(section.entries);
      if (entries.length >= 5) break;
    }

    return entries.isEmpty ? const ['Release notes are ready.'] : entries;
  }
}
