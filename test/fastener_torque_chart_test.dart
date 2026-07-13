import 'package:flutter_test/flutter_test.dart';
import 'package:ultimate_window_engineer_tool/fabrication/thread_data.dart';
import 'package:ultimate_window_engineer_tool/reference/fastener_torque_chart_page.dart';

void main() {
  group('fastener torque chart', () {
    test('calculates torque from displayed formula basis', () {
      const size = FastenerTorqueSize(
        label: '1/2-13',
        system: ThreadSystem.unc,
        diameterIn: 0.500,
        tensileStressAreaIn2: 0.1419,
      );
      const grade = FastenerTorqueGrade(
        label: 'SAE Grade 5',
        proofStrengthPsi: 85000,
        note: '',
      );

      final dry = calculateFastenerTorqueValue(
        size: size,
        grade: grade,
        condition: FastenerTorqueCondition.dry,
      );
      final lubricated = calculateFastenerTorqueValue(
        size: size,
        grade: grade,
        condition: FastenerTorqueCondition.lubricated,
      );

      expect(dry.torqueFtLb, closeTo(75.38, 0.01));
      expect(lubricated.torqueFtLb, closeTo(56.54, 0.01));
      expect(lubricated.torqueFtLb < dry.torqueFtLb, isTrue);
    });

    test('contains expected inch and metric reference groups', () {
      expect(
        saeTorqueGrades.map((grade) => grade.label),
        contains('SAE Grade 8'),
      );
      expect(
        metricTorqueGrades.map((grade) => grade.label),
        contains('Class 10.9'),
      );
      expect(saeFastenerSizes.map((size) => size.label), contains('1/2-13'));
      expect(
        metricFastenerSizes.map((size) => size.label),
        contains('M10 x 1.5'),
      );
    });

    test('uses the Drill and Tap Selector thread size lists', () {
      expect(saeFastenerSizes.length, commonUNC.length + commonUNF.length);
      expect(metricFastenerSizes.length, commonMetric.length);
      expect(saeFastenerSizes.map((size) => size.label), contains('#4-40'));
      expect(saeFastenerSizes.map((size) => size.label), contains('1/4-28'));
      expect(
        metricFastenerSizes.map((size) => size.label),
        contains('M42 x 3.0'),
      );
    });

    test('derives tensile stress area from thread geometry', () {
      final size = fastenerTorqueSizeFromThread(
        commonUNC.singleWhere((thread) => thread.label == '1/4-20'),
      );

      expect(size.tensileStressAreaIn2, closeTo(0.0318, 0.0001));
    });
  });
}
