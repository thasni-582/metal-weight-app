import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metal_weight/core/constants/standard_data.dart';
import 'package:metal_weight/core/localization/app_strings.dart';
import 'package:metal_weight/core/providers/app_settings_provider.dart';
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
      // Square & Rectangular Tubes start at 1.2 mm and include complete client catalog
      expect(StandardData.squareTubes['19x19']?['1.2'], equals(0.67));
      expect(StandardData.squareTubes['20x20']?['1.2'], equals(0.71));
      expect(StandardData.rectangularTubes['40x20']?['1.2'], equals(1.09));
      expect(StandardData.rectangularTubes['100x50']?['1.2'], equals(2.76));
      expect(StandardData.rectangularTubes['100x50']?['1.5'], equals(3.43));
      expect(StandardData.rectangularTubes['100x50']?['2.0'], equals(4.53));
      expect(StandardData.rectangularTubes.containsKey('30x15'), isTrue);
      // Steel Pipes Schedule 20 from 1/2" up to 12" and beyond (ANSI B 36.10 Table)
      expect(StandardData.steelPipes.length, equals(35));
      expect(StandardData.steelPipes['1/4" (13.7 mm)']?['Sch 40 / STD (2.24mm)'], equals(0.63));
      expect(StandardData.steelPipes['1/2" (21.3 mm)']?['Sch 20 (2.60mm)'], equals(1.21));
      expect(StandardData.steelPipes['1/2" (21.3 mm)']?['Sch 160 (4.78mm)'], equals(1.95));
      expect(StandardData.steelPipes['1/2" (21.3 mm)']?['Sch XXS (7.47mm)'], equals(2.55));
      expect(StandardData.steelPipes['3/4" (26.7 mm)']?['Sch 20 (2.60mm)'], equals(1.56));
      expect(StandardData.steelPipes['1" (33.4 mm)']?['Sch 20 (3.20mm)'], equals(2.41));
      expect(StandardData.steelPipes['2" (60.3 mm)']?['Sch 20 (3.60mm)'], equals(5.03));
      expect(StandardData.steelPipes['4" (114.3 mm)']?['Sch 20 (4.50mm)'], equals(12.20));
      expect(StandardData.steelPipes['6" (168.3 mm)']?['Sch 20 (5.00mm)'], equals(19.70));
      expect(StandardData.steelPipes['8" (219.1 mm)']?['Sch 20 (6.35mm)'], equals(33.31));
      expect(StandardData.steelPipes['8" (219.1 mm)']?['Sch 100 (15.09mm)'], equals(75.92));
      expect(StandardData.steelPipes['10" (273.0 mm)']?['Sch 20 (6.35mm)'], equals(41.77));
      expect(StandardData.steelPipes['12" (323.8 mm)']?['Sch 20 (6.35mm)'], equals(49.73));
      expect(StandardData.steelPipes['14" (355.6 mm)']?['Sch 20 (7.92mm)'], equals(67.90));
      expect(StandardData.steelPipes['24" (609.6 mm)']?['Sch 80 (30.96mm)'], equals(442.00));
      // Large pipe sizes above 24"
      expect(StandardData.steelPipes['26" (660.4 mm)']?['Sch 10 (7.92mm)'], equals(127.30));
      expect(StandardData.steelPipes['28" (711.2 mm)']?['Sch 30 (15.88mm)'], equals(271.20));
      expect(StandardData.steelPipes['30" (762.0 mm)']?['Sch 20 / XS (12.70mm)'], equals(234.60));
      expect(StandardData.steelPipes['36" (914.4 mm)']?['Sch 40 (19.05mm)'], equals(426.40));
      expect(StandardData.steelPipes['48" (1219.0 mm)']?['Sch STD (9.53mm)'], equals(284.24));
      expect(StandardData.steelPipes['48" (1219.0 mm)']?['Sch XS (12.70mm)'], equals(377.79));
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
      expect(StandardData.wBeams.length, equals(166));
      expect(StandardData.wBeams['W 8 x 8 x 31 (203 x 203 x 46.1)']?.weight, equals(46.10));
      expect(StandardData.wBeams['W 12 x 8 x 40 (305 x 203 x 60)']?.weight, equals(60.00));
      expect(StandardData.wBeams['W 40 x 12 x 327 (1016 x 305 x 486)']?.weight, equals(486.00));
      expect(StandardData.findWBeam('W 8 x 8 x 31')?.weight, equals(46.10));
      expect(StandardData.aluminumCheckeredWeights['3.0'], equals(9.80));
      expect(StandardData.densities['Galvanized Sheet'], equals(8.10));
      expect(StandardData.densities['HR Chequered Sheet'], equals(8.50));
    });

    test('W-Beam catalog completeness and geometry proportions', () {
      expect(StandardData.wBeams.length, equals(166));
      for (final entry in StandardData.wBeams.entries) {
        final spec = entry.value;
        expect(spec.h, greaterThan(0));
        expect(spec.b, greaterThan(0));
        expect(spec.tw, greaterThan(0));
        expect(spec.tf, greaterThan(0));
        expect(spec.weight, greaterThan(0));
        expect(spec.area, greaterThan(0));
      }

      // Wide-flange square column profiles (b/h >= 0.70)
      final w8x8 = StandardData.wBeams['W 8 x 8 x 31 (203 x 203 x 46.1)']!;
      expect(w8x8.b / w8x8.h, greaterThanOrEqualTo(0.70));

      final w14x16 = StandardData.wBeams['W 14 x 16 x 145 (356 x 406 x 216)']!;
      expect(w14x16.b / w14x16.h, greaterThanOrEqualTo(0.70));

      // Deep, slender I-beam profiles (b/h < 0.70)
      final w14x5 = StandardData.wBeams['W 14 x 5 x 22 (356 x 127 x 32.9)']!;
      expect(w14x5.b / w14x5.h, lessThan(0.70));

      final w36x12 = StandardData.wBeams['W 36 x 12 x 135 (914 x 305 x 201)']!;
      expect(w36x12.b / w36x12.h, lessThan(0.70));

      final w40x12 = StandardData.wBeams['W 40 x 12 x 149 (1016 x 305 x 222)']!;
      expect(w40x12.b / w40x12.h, lessThan(0.70));

      // Flexible matching
      expect(StandardData.findWBeam('W 8 x 8 x 31'), isNotNull);
      expect(StandardData.findWBeam('203 x 203 x 46.1'), isNotNull);
      expect(StandardData.findWBeam('W 36 x 12 x 135'), isNotNull);
      expect(StandardData.findWBeam('1016 x 305 x 486'), isNotNull);
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
    test('Client Catalog I-Beams and H-Beams are accurate and solve client weight discrepancy', () {
      // 14 Client I-Beams
      expect(StandardData.clientIBeams.length, equals(14));
      expect(StandardData.clientIBeams['150x75']?.weight, equals(14.00));
      expect(StandardData.clientIBeams['198x99']?.weight, equals(18.20));
      expect(StandardData.clientIBeams['200x100']?.weight, equals(21.30));
      expect(StandardData.clientIBeams['248x124']?.weight, equals(25.70));
      expect(StandardData.clientIBeams['250x125']?.weight, equals(29.60));
      expect(StandardData.clientIBeams['250x125']?.area, equals(37.66));
      expect(StandardData.clientIBeams['298x149']?.weight, equals(32.00));
      expect(StandardData.clientIBeams['300x150']?.weight, equals(36.70));
      expect(StandardData.clientIBeams['346x174']?.weight, equals(41.20));
      expect(StandardData.clientIBeams['350x175']?.weight, equals(49.40));
      expect(StandardData.clientIBeams['396x199']?.weight, equals(56.60));
      expect(StandardData.clientIBeams['400x200']?.weight, equals(66.00));
      expect(StandardData.clientIBeams['496x199']?.weight, equals(79.50));
      expect(StandardData.clientIBeams['500x200']?.weight, equals(89.60));
      expect(StandardData.clientIBeams['596x199']?.weight, equals(92.50));

      // 8 Client H-Beams
      expect(StandardData.clientHBeams.length, equals(8));
      expect(StandardData.clientHBeams['100x100']?.weight, equals(16.90));
      expect(StandardData.clientHBeams['125x125']?.weight, equals(23.50));
      expect(StandardData.clientHBeams['150x150']?.weight, equals(31.10));
      expect(StandardData.clientHBeams['200x200']?.weight, equals(49.90));
      expect(StandardData.clientHBeams['250x250']?.weight, equals(71.80));
      expect(StandardData.clientHBeams['300x300']?.weight, equals(93.00));
      expect(StandardData.clientHBeams['350x350']?.weight, equals(134.90));
      expect(StandardData.clientHBeams['400x200']?.weight, equals(65.40));

      // Test client complaint case: 250x125x6x9 at 12m length
      final spec = StandardData.findClientIBeam(250.0, 125.0, 6.0, 9.0);
      expect(spec, isNotNull);
      expect(spec!.weight, equals(29.60));
      final double totalWeight12m = spec.weight * 12.0;
      expect(totalWeight12m, closeTo(355.20, 0.001)); // Exactly 355.20 kg, solving the 12.12 kg discrepancy!
      expect(totalWeight12m.toStringAsFixed(2), equals('355.20'));
    });

    test('AppSettingsProvider auto-sync payload carries home screen dimensions and quantity', () {
      final settings = AppSettingsProvider();
      expect(settings.syncVersion, equals(0));
      expect(settings.syncedProfileFromHome, isNull);

      settings.syncProfileFromHome(
        material: 'Steel',
        shape: 'H-Beam (JIS)',
        size: '250x125',
        thickness: '',
        variant: 'JIS',
        lengthInM: 12.0,
        quantity: 5,
        weightPerM: 29.60,
        sectionArea: 37.66,
      );

      expect(settings.syncVersion, equals(1));
      expect(settings.syncedProfileFromHome, isNotNull);
      final p = settings.syncedProfileFromHome!;
      expect(p.material, equals('Steel'));
      expect(p.shape, equals('H-Beam (JIS)'));
      expect(p.size, equals('250x125'));
      expect(p.lengthInM, equals(12.0));
      expect(p.quantity, equals(5));
      expect(p.weightPerM, equals(29.60));
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
