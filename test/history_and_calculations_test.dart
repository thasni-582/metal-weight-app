import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metal_weight/core/constants/standard_data.dart';
import 'package:metal_weight/core/localization/app_strings.dart';
import 'package:metal_weight/models/calculation_model.dart';

void main() {
  group('StandardData Tests', () {
    test('Standard sizes and thickness maps exist and are valid', () {
      expect(StandardData.equalAngles.isNotEmpty, isTrue);
      expect(StandardData.unequalAngles.isNotEmpty, isTrue);
      expect(StandardData.upnChannels.isNotEmpty, isTrue);
      expect(StandardData.ipeBeams.isNotEmpty, isTrue);
      expect(StandardData.ipeAaBeams.isNotEmpty, isTrue);
      expect(StandardData.ubBeams.isNotEmpty, isTrue);
      expect(StandardData.ucBeams.isNotEmpty, isTrue);
      expect(StandardData.wBeams.isNotEmpty, isTrue);
      expect(StandardData.aluminumCheckeredWeights.isNotEmpty, isTrue);

      // Verify specific sample values matching the reference specs
      expect(StandardData.equalAngles['50']?['5'], equals(3.77));
      expect(StandardData.upnChannels['100']?.weight, equals(10.60));
      expect(StandardData.ipeBeams['200']?.weight, equals(22.40));
      expect(StandardData.ipeAaBeams['100']?.weight, equals(6.70));
      // IPE-AA only 80 to 200
      expect(StandardData.ipeAaBeams.keys.toList(), equals(['80', '100', '120', '140', '160', '180', '200']));
      expect(StandardData.ipeAaBeams.containsKey('220'), isFalse);
      // Square & Rectangular Tubes start at 1.2 mm
      expect(StandardData.squareTubes['20x20']?['1.2'], equals(0.71));
      expect(StandardData.rectangularTubes['40x20']?['1.2'], equals(1.09));
      // Steel Pipes Schedule 20 from 1/2" up to 12" and beyond
      expect(StandardData.steelPipes['1/2" (21.3 mm)']?['Sch 20 (2.11mm)'], equals(1.00));
      expect(StandardData.steelPipes['3/4" (26.7 mm)']?['Sch 20 (2.11mm)'], equals(1.28));
      expect(StandardData.steelPipes['1" (33.4 mm)']?['Sch 20 (2.77mm)'], equals(2.09));
      expect(StandardData.steelPipes['2" (60.3 mm)']?['Sch 20 (2.77mm)'], equals(3.93));
      expect(StandardData.steelPipes['4" (114.3 mm)']?['Sch 20 (3.05mm)'], equals(8.36));
      expect(StandardData.steelPipes['6" (168.3 mm)']?['Sch 20 (3.40mm)'], equals(13.83));
      expect(StandardData.steelPipes['8" (219.1 mm)']?['Sch 20 (6.35mm)'], equals(33.32));
      expect(StandardData.steelPipes['10" (273.0 mm)']?['Sch 20 (6.35mm)'], equals(41.76));
      expect(StandardData.steelPipes['12" (323.8 mm)']?['Sch 20 (6.35mm)'], equals(49.71));
      expect(StandardData.steelPipes['14" (355.6 mm)']?['Sch 20 (7.92mm)'], equals(67.90));
      for (final size in [
        '1/2" (21.3 mm)',
        '3/4" (26.7 mm)',
        '1" (33.4 mm)',
        '1-1/4" (42.2 mm)',
        '1-1/2" (48.3 mm)',
        '2" (60.3 mm)',
        '2-1/2" (73.0 mm)',
        '3" (88.9 mm)',
        '4" (114.3 mm)',
        '5" (141.3 mm)',
        '6" (168.3 mm)',
        '8" (219.1 mm)',
        '10" (273.0 mm)',
        '12" (323.8 mm)',
      ]) {
        final schedules = StandardData.steelPipes[size]!.keys.toList();
        expect(schedules.any((s) => s.startsWith('Sch 20')), isTrue, reason: '$size should have Sch 20');
        expect(schedules.any((s) => s.startsWith('Sch 40')), isTrue, reason: '$size should have Sch 40');
        expect(schedules.any((s) => s.startsWith('Sch 80')), isTrue, reason: '$size should have Sch 80');
      }
      expect(StandardData.ubBeams['203 x 133 x 25']?.weight, equals(25.10));
      expect(StandardData.ubBeams['457 x 191 x 67']?.weight, equals(67.10));
      expect(StandardData.ucBeams['203 x 203 x 46']?.weight, equals(46.10));
      expect(StandardData.ucBeams['254 x 254 x 73']?.weight, equals(73.10));
      expect(StandardData.wBeams['W 8x10']?.weight, equals(14.90));
      expect(StandardData.wBeams['W 12x40']?.weight, equals(59.50));
      expect(StandardData.aluminumCheckeredWeights['3.0'], equals(9.80));
      expect(StandardData.densities['Galvanized Sheet'], equals(8.10));
      expect(StandardData.densities['HR Chequered Sheet'], equals(8.50));
    });
  });

  group('CalculationModel Serialization Tests', () {
    test('CalculationModel converts to JSON and back faithfully', () {
      final model = CalculationModel(
        title: 'Steel Angle Equal 50',
        subtitle: '50mm x 5mm | L=6.0m',
        weight: '22.62 kg',
        time: '13/10/2026 18:00',
        iconName: 'angle',
        bgColor: const Color(0xFFE8F0FE),
        iconColor: const Color(0xFF1A73E8),
        weightValue: 22.62,
        details: {
          'material': 'Steel',
          'shape': 'Angle Equal',
          'quantity': '1',
          'weightPerPiece': '3.77 kg/m',
          'totalWeight': '22.62 kg',
        },
      );

      final json = model.toJson();
      final revived = CalculationModel.fromJson(json);

      expect(revived.id, equals(model.id));
      expect(revived.title, equals(model.title));
      expect(revived.weightValue, equals(22.62));
      expect(revived.details['material'], equals('Steel'));
      expect(revived.details['totalWeight'], equals('22.62 kg'));
    });
  });

  group('Localization Tests', () {
    test('AppStrings supports English and Arabic keys', () {
      final en = AppStrings('en');
      final ar = AppStrings('ar');

      expect(en.get('app_title'), equals('Milen Trading'));
      expect(ar.get('app_title'), equals('ميلين للحديد'));

      expect(en.get('calculator'), equals('Calculator'));
      expect(ar.get('calculator'), equals('حاسبة الوزن'));

      expect(en.get('save_to_history'), equals('Save to History'));
      expect(ar.get('save_to_history'), equals('حفظ في السجل'));
    });
  });
}
