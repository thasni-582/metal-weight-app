import 'package:flutter_test/flutter_test.dart';
import 'package:metal_weight/core/constants/catalog_data.dart';

void main() {
  group('Catalog Profiles Completeness Tests', () {
    test('Catalog contains exactly 36 distinct client products', () {
      expect(CatalogData.profiles.length, equals(36));
      expect(CatalogData.allShapeNames.length, equals(36));

      // Verify no duplicates
      final uniqueNames = CatalogData.allShapeNames.toSet();
      expect(uniqueNames.length, equals(36));
    });

    test('Special client requested items exist in catalog', () {
      final names = CatalogData.allShapeNames;

      // Stainless steel tubes
      expect(names.contains('Stainless Steel Square Tube'), isTrue);
      expect(names.contains('Stainless Steel Rectangular Tube'), isTrue);

      // Stainless steel checkered sheet
      expect(names.contains('Stainless Steel Checkered Sheet'), isTrue);

      // Pipes
      expect(names.contains('Pipe ERW'), isTrue);
      expect(names.contains('Pipe Seamless'), isTrue);
      expect(names.contains('Stainless Steel Pipe'), isTrue);

      // IPE-AA Beam
      expect(names.contains('IPE-AA Beam'), isTrue);
      expect(names.contains('IPE Beam'), isTrue);
      expect(names.contains('HEA Beam'), isTrue);
      expect(names.contains('HEB Beam'), isTrue);
      expect(names.contains('H-Beam (JIS)'), isTrue);
      expect(names.contains('UB (Universal Beam)'), isTrue);
      expect(names.contains('UC (Universal Columns)'), isTrue);
      expect(names.contains('W-Beam (Wide Flange)'), isTrue);
    });

    test('All 7 categories exist and partition the 36 items', () {
      expect(CatalogData.categories.length, equals(8)); // 'all' + 7 groups

      final beams = CatalogData.getProfilesForCategory('beams');
      final channels = CatalogData.getProfilesForCategory('channels');
      final angles = CatalogData.getProfilesForCategory('angles');
      final tubes = CatalogData.getProfilesForCategory('tubes');
      final pipes = CatalogData.getProfilesForCategory('pipes');
      final sheets = CatalogData.getProfilesForCategory('sheets');
      final bars = CatalogData.getProfilesForCategory('bars');

      expect(beams.length, equals(8));
      expect(channels.length, equals(3));
      expect(angles.length, equals(4));
      expect(tubes.length, equals(4));
      expect(pipes.length, equals(3));
      expect(sheets.length, equals(8));
      expect(bars.length, equals(6));

      expect(beams.length + channels.length + angles.length + tubes.length + pipes.length + sheets.length + bars.length, equals(36));
    });
  });
}
