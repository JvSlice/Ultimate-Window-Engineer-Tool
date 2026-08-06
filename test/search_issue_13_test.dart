import 'package:flutter_test/flutter_test.dart';
import 'package:ultimate_window_engineer_tool/app_theme.dart';
import 'package:ultimate_window_engineer_tool/home/search/main_menu_search_engine.dart';
import 'package:ultimate_window_engineer_tool/home/search/search_registry.dart';

void main() {
  late MainMenuSearchEngine engine;

  setUp(() {
    engine = MainMenuSearchEngine();
  });

  List<String> titlesFor(String query) {
    final hits = engine.buildHits(
      query: query,
      entries: buildSearchRegistry(AppThemeController()),
      onOpenEntry: (_) {},
      onOpenConvertIt: () {},
    );
    return hits.map((hit) => hit.title).toList();
  }

  test('fridge prioritizes refrigerator appliance reference entry', () {
    final titles = titlesFor('fridge');

    expect(titles.first, 'Refrigerator');
    expect(titles, isNot(contains('2D Shapes')));
    expect(titles, isNot(contains('Angle Visualizer')));
    expect(titles, isNot(contains('COG Estimator')));
  });

  test(
    'refrigerator amps prioritizes refrigerator appliance reference entry',
    () {
      final titles = titlesFor('refrigerator amps');

      expect(titles.first, 'Refrigerator');
    },
  );

  test('cups prioritizes volume unit conversion over weak page matches', () {
    final titles = titlesFor('cups');

    expect(titles.first, 'Cups');
    expect(titles.take(3), isNot(contains('Test Buck Calculator')));
    expect(titles.take(3), isNot(contains('Box')));
    expect(titles.take(3), isNot(contains('Common Appliance Power Usage')));
  });

  test('pressure units prioritize pressure conversions', () {
    expect(titlesFor('psi').first, anyOf('PSI', 'PSI ↔ PSF'));
    expect(titlesFor('inches of water').first, 'Inches of Water Column');
  });

  test('common typo for fridge does not introduce unrelated results', () {
    final titles = titlesFor('frdge');

    expect(titles.first, 'Refrigerator');
    expect(titles.length, lessThanOrEqualTo(3));
    expect(titles, isNot(contains('2D Shapes')));
  });

  test('concrete expansion prioritizes thermal expansion calculator', () {
    expect(titlesFor('concrete expansion').first, 'Thermal Expansion');
  });
}
