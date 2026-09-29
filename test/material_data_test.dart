import 'package:flutter_test/flutter_test.dart';
import 'package:ultimate_window_engineer_tool/fabrication/lathe_speed_feed_page.dart';
import 'package:ultimate_window_engineer_tool/reference/materials/material_data.dart';
import 'package:ultimate_window_engineer_tool/reference/materials/material_models.dart';

void main() {
  group('material data', () {
    test('includes brass and copper in centralized material properties', () {
      final brass = materials.singleWhere(
        (material) => material.name == 'Brass (C360 Free-Cutting)',
      );
      final copper = materials.singleWhere(
        (material) => material.name == 'Copper (C110 ETP)',
      );

      expect(brass.category, MaterialCategory.nonFerrous);
      expect(copper.category, MaterialCategory.nonFerrous);

      for (final material in [brass, copper]) {
        expect(material.densityKgM3, greaterThan(0));
        expect(material.thermalExpansionMicroInInF, greaterThan(0));
        expect(material.strength?.yieldPsi, greaterThan(0));
        expect(material.strength?.tensilePsi, greaterThan(0));
        expect(material.hardness?.scale, isNotEmpty);
        expect(material.machining?.sfmNotes, isNotEmpty);
        expect(material.melting, isNotNull);
        expect(material.notes, contains('vary'));
      }
    });

    test('brass and copper are available to thermal expansion consumers', () {
      final expandableMaterials = materials
          .where((material) => material.thermalExpansionMicroInInF != null)
          .map((material) => material.name);

      expect(expandableMaterials, contains('Brass (C360 Free-Cutting)'));
      expect(expandableMaterials, contains('Copper (C110 ETP)'));
    });

    test(
      'lathe recommendations link to centralized brass and copper records',
      () {
        for (final recommendation in latheRecommendations.where(
          (item) => item.label == 'Brass' || item.label == 'Copper',
        )) {
          expect(
            materials.any(
              (material) => material.name == recommendation.centralMaterialName,
            ),
            isTrue,
          );
        }
      },
    );
  });
}
