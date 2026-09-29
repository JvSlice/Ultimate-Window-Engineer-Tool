import 'package:flutter_test/flutter_test.dart';
import 'package:ultimate_window_engineer_tool/app_theme.dart';
import 'package:ultimate_window_engineer_tool/fabrication/lathe_speed_feed_page.dart';
import 'package:ultimate_window_engineer_tool/home/search/main_menu_search_engine.dart';
import 'package:ultimate_window_engineer_tool/home/search/search_registry.dart';

void main() {
  group('lathe speed and feed calculator', () {
    test('calculates imperial spindle speed and feed rate', () {
      final result = calculateLatheSpeedFeed(
        unitSystem: LatheUnitSystem.imperial,
        diameter: 2,
        cuttingSpeed: 300,
        feedPerRev: 0.006,
      );

      expect(result.rpm, closeTo(572.96, 0.01));
      expect(result.feedRate, closeTo(3.44, 0.01));
    });

    test('calculates metric spindle speed and feed rate', () {
      final result = calculateLatheSpeedFeed(
        unitSystem: LatheUnitSystem.metric,
        diameter: 50,
        cuttingSpeed: 100,
        feedPerRev: 0.15,
      );

      expect(result.rpm, closeTo(636.62, 0.01));
      expect(result.feedRate, closeTo(95.49, 0.01));
    });

    test('includes required starting materials and tool values', () {
      final labels = latheRecommendations.map((item) => item.label);

      expect(labels, containsAll(['Aluminum', 'Mild Steel']));
      expect(labels, containsAll(['Stainless Steel', 'Brass', 'Copper']));

      final brass = latheRecommendations.singleWhere(
        (item) => item.label == 'Brass',
      );

      expect(brass.sfmFor(LatheToolMaterial.hss), greaterThan(0));
      expect(brass.sfmFor(LatheToolMaterial.carbide), greaterThan(0));
      expect(brass.feedInPerRevFor(LatheToolMaterial.hss), greaterThan(0));
    });

    test('lathe calculator is discoverable through search', () {
      final engine = MainMenuSearchEngine();
      final hits = engine.buildHits(
        query: 'lathe rpm sfm',
        entries: buildSearchRegistry(AppThemeController()),
        onOpenEntry: (_) {},
        onOpenConvertIt: () {},
      );

      expect(hits.first.title, 'Lathe Speed & Feed');
    });
  });
}
