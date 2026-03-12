import 'dart:math';

import 'package:flutter/material.dart';

enum ConversionTypes {
  windSpeedToPsf,
  pressurePsitoPsf,
  psftoPa,
  CFMperSQfttoCLMperSQm,
  inchesToCm,
  feetToInches,
  mmToInches,
  kgToLbs,
  forceNToLbsfAndKn,
  literToGallons,
}

enum Direction { to, from }

String conversionLabel(ConversionTypes t) {
  switch (t) {
    case ConversionTypes.windSpeedToPsf:
      return "Wind Speed to PSF";
    case ConversionTypes.pressurePsitoPsf:
      return "Pressure PSI to PSF";
    case ConversionTypes.psftoPa:
      return "Pressure PSF to PA";
    case ConversionTypes.CFMperSQfttoCLMperSQm:
      return "CFM per Sqft to Cubic liters per sqM";

    case ConversionTypes.inchesToCm:
      return "Inches to Cm";
    case ConversionTypes.feetToInches:
      return "Feet to Inches";
    case ConversionTypes.mmToInches:
      return "MM to Inches";
    case ConversionTypes.kgToLbs:
      return "Kg to LBS";
    case ConversionTypes.forceNToLbsfAndKn:
      return "N to LBSF to kn";
    case ConversionTypes.literToGallons:
      return "L to Gallons";
  }
}

String directionLabel(Direction d) => d == Direction.to ? "To" : "From";

String performConversion({
  required ConversionTypes type,
  required Direction direction,
  required double input,
}) {
  switch (type) {
    case ConversionTypes.windSpeedToPsf:
      if (direction == Direction.to) {
        final psf = 0.00256 * pow(input, 2);
        return "${psf.toStringAsFixed(2)} psf";
      } else {
        final mph = sqrt(input / 0.00256);
        return "${mph.toStringAsFixed(2)} mph";
      }

    case ConversionTypes.pressurePsitoPsf:
      if (direction == Direction.to) {
        final psf = input * 144;
        return "${psf.toStringAsFixed(4)} psf";
      } else {
        final psi = input / 144;
        return "${psi.toStringAsFixed(4)} psi";
      }
    case ConversionTypes.psftoPa:
      if (direction == Direction.to) {
        final Pa = input * 47.88025898;
        return "${Pa.toStringAsFixed(4)} Pa";
      } else {
        final psf = input / 47.88025898;
        return "${psf.toStringAsFixed(4)} PSF";
      }
    case ConversionTypes.CFMperSQfttoCLMperSQm:
      if (direction == Direction.to) {
        final clm = input * 5.08;
        return "${clm.toStringAsFixed(2)} Cubic litter per minute per sq Meter";
      } else {
        final cfm = input / 5.08;
        return "${cfm.toStringAsFixed(2)} CFM per Sq ft";
      }
    case ConversionTypes.inchesToCm:
      if (direction == Direction.to) {
        final cm = input * 2.54;
        return "${cm.toStringAsFixed(4)} cm";
      } else {
        final inches = input / 2.54;
        return "${inches.toStringAsFixed(3)} inches";
      }
    case ConversionTypes.feetToInches:
      if (direction == Direction.to) {
        final inches = input * 12;
        return "${inches.toStringAsFixed(4)} inches";
      } else {
        final feet = input / 12;
        return "${feet.toStringAsFixed(4)} feet";
      }
    case ConversionTypes.mmToInches:
      if (direction == Direction.to) {
        final inches = input / 25.4;
        return "${inches.toStringAsFixed(4} inches";
      } else {
        final mm = input * 25.4;
        return "${mm.toStringAsFixed(4)} mm";
      }
    case ConversionTypes.kgToLbs:
      if (direction == Direction.to) {
        final lbs = input * 2.20462;
        return "${lbs.toStringAsFixed(4)} lbs";
      } else {
        final kg = input / 2.20462;
        return "${kg.toStringAsFixed(4)} kg";
      }
    case ConversionTypes.forceNToLbsfAndKn:
      if (direction == Direction.to) {
        final lbf = input * 0.224809;
        return "${lbf.toStringAsFixed(4)} lbsf";
      } else {
        final double newtons = (input >= 1)
            ? (input / 0.224809)
            : (input * 1000);
        return "${newtons.toStringAsFixed(2)} N";
      }
    case ConversionTypes.literToGallons:
      if (direction == Direction.to) {
        final gallons = input * 0.264172;
        return "${gallons.toStringAsFixed(4)} gallons";
      } else {
        final liters = input / 0.264172;
        return "${liters.toStringAsFixed(4)} liters";
      }
  }
}
