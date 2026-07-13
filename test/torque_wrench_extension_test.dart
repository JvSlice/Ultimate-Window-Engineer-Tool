import 'package:flutter_test/flutter_test.dart';
import 'package:ultimate_window_engineer_tool/reference/physics/torque_wrench_extension_page.dart';

void main() {
  group('torque wrench extension calculator', () {
    test('inline forward extension lowers wrench setting', () {
      final result = calculateTorqueExtension(
        desiredTorque: 50,
        unit: TorqueUnit.footPounds,
        wrenchLengthIn: 18,
        extensionLengthIn: 3,
        angleDegrees: 0,
      );

      expect(result, isNotNull);
      expect(result!.effectiveLengthIn, 21);
      expect(
        torqueFromInLb(result.wrenchSettingInLb, TorqueUnit.footPounds),
        closeTo(42.857142857, 0.000001),
      );
    });

    test('perpendicular extension requires no length correction', () {
      final result = calculateTorqueExtension(
        desiredTorque: 50,
        unit: TorqueUnit.footPounds,
        wrenchLengthIn: 18,
        extensionLengthIn: 3,
        angleDegrees: 90,
      );

      expect(result, isNotNull);
      expect(result!.effectiveLengthIn, closeTo(18, 0.000001));
      expect(
        torqueFromInLb(result.wrenchSettingInLb, TorqueUnit.footPounds),
        closeTo(50, 0.000001),
      );
    });

    test('inline backward extension raises wrench setting', () {
      final result = calculateTorqueExtension(
        desiredTorque: 50,
        unit: TorqueUnit.footPounds,
        wrenchLengthIn: 18,
        extensionLengthIn: 3,
        angleDegrees: 180,
      );

      expect(result, isNotNull);
      expect(result!.effectiveLengthIn, 15);
      expect(
        torqueFromInLb(result.wrenchSettingInLb, TorqueUnit.footPounds),
        closeTo(60, 0.000001),
      );
    });

    test('supports newton meter input and output conversion', () {
      final desiredInLb = torqueToInLb(100, TorqueUnit.newtonMeters);

      expect(
        torqueFromInLb(desiredInLb, TorqueUnit.newtonMeters),
        closeTo(100, 0.000001),
      );
    });

    test('rejects invalid effective length', () {
      final result = calculateTorqueExtension(
        desiredTorque: 50,
        unit: TorqueUnit.footPounds,
        wrenchLengthIn: 3,
        extensionLengthIn: 3,
        angleDegrees: 180,
      );

      expect(result, isNull);
    });
  });
}
