import 'package:flutter_test/flutter_test.dart';
import 'package:ultimate_window_engineer_tool/conversions/unit_conversions.dart';
import 'package:ultimate_window_engineer_tool/home/search/main_menu_search_engine.dart';

void main() {
  ConversionTool tool(String label) {
    return conversionTools.singleWhere((tool) => tool.label == label);
  }

  group('water column pressure conversions', () {
    test('converts inches of water column to PSF and back', () {
      final waterToPsf = tool('in. w.c. ↔ PSF');

      expect(waterToPsf.convert(Direction.to, 1), '5.202 psf');
      expect(waterToPsf.convert(Direction.to, 10), '52.02 psf');
      expect(waterToPsf.convert(Direction.from, 1), '0.1922 in. w.c.');
    });

    test('converts inches of water column to PSI and back', () {
      final waterToPsi = tool('in. w.c. ↔ PSI');

      expect(waterToPsi.convert(Direction.to, 1), '0.03613 psi');
      expect(waterToPsi.convert(Direction.to, 10), '0.3613 psi');
      expect(waterToPsi.convert(Direction.from, 1), '27.68 in. w.c.');
    });
  });

  group('water column search conversions', () {
    test('returns instant conversion hits for water column aliases', () {
      final engine = MainMenuSearchEngine();

      final psfHits = engine.buildHits(
        query: '10 in wc to psf',
        entries: const [],
        onOpenEntry: (_) {},
        onOpenConvertIt: () {},
      );
      final psiHits = engine.buildHits(
        query: '1 iwc to psi',
        entries: const [],
        onOpenEntry: (_) {},
        onOpenConvertIt: () {},
      );

      expect(psfHits.first.title, '10 in wc → 52.02 psf');
      expect(psiHits.first.title, '1 iwc → 0.03613 psi');
    });
  });
}
