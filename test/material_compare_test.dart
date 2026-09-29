import 'package:flutter_test/flutter_test.dart';
import 'package:ultimate_window_engineer_tool/app_theme.dart';
import 'package:ultimate_window_engineer_tool/home/search/main_menu_search_engine.dart';
import 'package:ultimate_window_engineer_tool/home/search/search_registry.dart';
import 'package:ultimate_window_engineer_tool/reference/materials/material_compare_page.dart';
import 'package:ultimate_window_engineer_tool/reference/materials/material_data.dart';

void main() {
  group('material comparison', () {
    test('builds aligned rows for up to three selected materials', () {
      final selected = [
        materials.singleWhere((material) => material.name == '6061-T6'),
        materials.singleWhere(
          (material) => material.name == 'Brass (C360 Free-Cutting)',
        ),
        materials.singleWhere(
          (material) => material.name == 'Copper (C110 ETP)',
        ),
        materials.singleWhere(
          (material) => material.name == 'Concrete (Normal Weight)',
        ),
      ];

      final rows = buildMaterialComparisonRows(selected);
      final category = rows.singleWhere((row) => row.label == 'Category');
      final density = rows.singleWhere(
        (row) => row.label == 'Density (kg/m^3)',
      );
      final machinability = rows.singleWhere(
        (row) => row.label == 'Machinability',
      );

      expect(category.values, ['Aluminum', 'Non-ferrous', 'Non-ferrous']);
      expect(density.values, ['2700.000', '8490.000', '8960.000']);
      expect(machinability.values, ['90%', '100%', '20%']);
    });

    test(
      'fills empty comparison slots when fewer than three materials selected',
      () {
        final rows = buildMaterialComparisonRows([
          materials.singleWhere((material) => material.name == '6061-T6'),
        ]);

        final category = rows.singleWhere((row) => row.label == 'Category');

        expect(category.values, ['Aluminum', '-', '-']);
      },
    );

    test('compare materials is discoverable through search', () {
      final engine = MainMenuSearchEngine();
      final hits = engine.buildHits(
        query: 'compare materials machinability',
        entries: buildSearchRegistry(AppThemeController()),
        onOpenEntry: (_) {},
        onOpenConvertIt: () {},
      );

      expect(hits.first.title, 'Compare Materials');
    });
  });
}
