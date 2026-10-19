import 'package:flutter/material.dart';

class CatalogCategory {
  final String id;
  final String label;
  final String arLabel;
  final IconData icon;

  const CatalogCategory({
    required this.id,
    required this.label,
    required this.arLabel,
    required this.icon,
  });
}

class CatalogProfile {
  final String name;
  final String categoryId;
  final String categoryLabel;
  final IconData icon;

  const CatalogProfile({
    required this.name,
    required this.categoryId,
    required this.categoryLabel,
    required this.icon,
  });
}

class CatalogData {
  CatalogData._();

  static const List<CatalogCategory> categories = [
    CatalogCategory(
      id: 'all',
      label: 'All (36)',
      arLabel: 'الكل (36)',
      icon: Icons.apps,
    ),
    CatalogCategory(
      id: 'beams',
      label: 'Beams & Columns (8)',
      arLabel: 'الكمرات والأعمدة (8)',
      icon: Icons.view_column,
    ),
    CatalogCategory(
      id: 'channels',
      label: 'Channels (3)',
      arLabel: 'المجاري U (3)',
      icon: Icons.view_stream,
    ),
    CatalogCategory(
      id: 'angles',
      label: 'Angles (4)',
      arLabel: 'الزوايا (4)',
      icon: Icons.timeline,
    ),
    CatalogCategory(
      id: 'tubes',
      label: 'Hollow Sections (4)',
      arLabel: 'المواسير المفرغة (4)',
      icon: Icons.crop_square_outlined,
    ),
    CatalogCategory(
      id: 'pipes',
      label: 'Pipes (3)',
      arLabel: 'الأنابيب (3)',
      icon: Icons.radio_button_unchecked,
    ),
    CatalogCategory(
      id: 'sheets',
      label: 'Sheets & Plates (8)',
      arLabel: 'الألواح والصاج (8)',
      icon: Icons.crop_square,
    ),
    CatalogCategory(
      id: 'bars',
      label: 'Solid Bars (6)',
      arLabel: 'القضبان المصمتة (6)',
      icon: Icons.horizontal_rule,
    ),
  ];

  static const List<CatalogProfile> profiles = [
    // 1. Sheets & Plates (8 items)
    CatalogProfile(
      name: 'HR Sheet / HR Plate',
      categoryId: 'sheets',
      categoryLabel: 'Sheets & Plates',
      icon: Icons.crop_square,
    ),
    CatalogProfile(
      name: 'HR Checkered Sheet',
      categoryId: 'sheets',
      categoryLabel: 'Sheets & Plates',
      icon: Icons.grid_view_rounded,
    ),
    CatalogProfile(
      name: 'Stainless Steel Sheet',
      categoryId: 'sheets',
      categoryLabel: 'Sheets & Plates',
      icon: Icons.crop_square,
    ),
    CatalogProfile(
      name: 'Stainless Steel Checkered Sheet',
      categoryId: 'sheets',
      categoryLabel: 'Sheets & Plates',
      icon: Icons.grid_view_rounded,
    ),
    CatalogProfile(
      name: 'Aluminum Sheet',
      categoryId: 'sheets',
      categoryLabel: 'Sheets & Plates',
      icon: Icons.crop_square,
    ),
    CatalogProfile(
      name: 'Aluminum Checkered Sheet',
      categoryId: 'sheets',
      categoryLabel: 'Sheets & Plates',
      icon: Icons.grid_view_rounded,
    ),
    CatalogProfile(
      name: 'Brass Sheet',
      categoryId: 'sheets',
      categoryLabel: 'Sheets & Plates',
      icon: Icons.crop_square,
    ),
    CatalogProfile(
      name: 'Copper Sheet',
      categoryId: 'sheets',
      categoryLabel: 'Sheets & Plates',
      icon: Icons.crop_square,
    ),

    // 2. Beams & Columns (8 items)
    CatalogProfile(
      name: 'IPE Beam',
      categoryId: 'beams',
      categoryLabel: 'Beams & Columns',
      icon: Icons.view_column,
    ),
    CatalogProfile(
      name: 'IPE-AA Beam',
      categoryId: 'beams',
      categoryLabel: 'Beams & Columns',
      icon: Icons.view_column,
    ),
    CatalogProfile(
      name: 'HEA Beam',
      categoryId: 'beams',
      categoryLabel: 'Beams & Columns',
      icon: Icons.view_column,
    ),
    CatalogProfile(
      name: 'HEB Beam',
      categoryId: 'beams',
      categoryLabel: 'Beams & Columns',
      icon: Icons.view_column,
    ),
    CatalogProfile(
      name: 'H-Beam (JIS)',
      categoryId: 'beams',
      categoryLabel: 'Beams & Columns',
      icon: Icons.view_column,
    ),
    CatalogProfile(
      name: 'UB (Universal Beam)',
      categoryId: 'beams',
      categoryLabel: 'Beams & Columns',
      icon: Icons.view_column,
    ),
    CatalogProfile(
      name: 'UC (Universal Columns)',
      categoryId: 'beams',
      categoryLabel: 'Beams & Columns',
      icon: Icons.view_column,
    ),
    CatalogProfile(
      name: 'W-Beam (Wide Flange)',
      categoryId: 'beams',
      categoryLabel: 'Beams & Columns',
      icon: Icons.view_column,
    ),

    // 3. Channels (3 items)
    CatalogProfile(
      name: 'UPN Channel',
      categoryId: 'channels',
      categoryLabel: 'Channels',
      icon: Icons.view_stream,
    ),
    CatalogProfile(
      name: 'UPE Channel',
      categoryId: 'channels',
      categoryLabel: 'Channels',
      icon: Icons.view_stream,
    ),
    CatalogProfile(
      name: 'U-Channel (JIS)',
      categoryId: 'channels',
      categoryLabel: 'Channels',
      icon: Icons.view_stream,
    ),

    // 4. Angles (4 items)
    CatalogProfile(
      name: 'Equal Angle',
      categoryId: 'angles',
      categoryLabel: 'Angles',
      icon: Icons.timeline,
    ),
    CatalogProfile(
      name: 'Unequal Angle',
      categoryId: 'angles',
      categoryLabel: 'Angles',
      icon: Icons.timeline,
    ),
    CatalogProfile(
      name: 'SS Angle (Stainless Steel)',
      categoryId: 'angles',
      categoryLabel: 'Angles',
      icon: Icons.timeline,
    ),
    CatalogProfile(
      name: 'Aluminum Angle',
      categoryId: 'angles',
      categoryLabel: 'Angles',
      icon: Icons.timeline,
    ),

    // 5. Hollow Sections / Tubes (4 items)
    CatalogProfile(
      name: 'Square Tube (SHS)',
      categoryId: 'tubes',
      categoryLabel: 'Hollow Sections',
      icon: Icons.crop_square_outlined,
    ),
    CatalogProfile(
      name: 'Rectangular Tube (RHS)',
      categoryId: 'tubes',
      categoryLabel: 'Hollow Sections',
      icon: Icons.crop_square_outlined,
    ),
    CatalogProfile(
      name: 'Stainless Steel Square Tube',
      categoryId: 'tubes',
      categoryLabel: 'Hollow Sections',
      icon: Icons.crop_square_outlined,
    ),
    CatalogProfile(
      name: 'Stainless Steel Rectangular Tube',
      categoryId: 'tubes',
      categoryLabel: 'Hollow Sections',
      icon: Icons.crop_square_outlined,
    ),

    // 6. Pipes (3 items)
    CatalogProfile(
      name: 'Pipe ERW',
      categoryId: 'pipes',
      categoryLabel: 'Pipes',
      icon: Icons.radio_button_unchecked,
    ),
    CatalogProfile(
      name: 'Pipe Seamless',
      categoryId: 'pipes',
      categoryLabel: 'Pipes',
      icon: Icons.radio_button_unchecked,
    ),
    CatalogProfile(
      name: 'Stainless Steel Pipe',
      categoryId: 'pipes',
      categoryLabel: 'Pipes',
      icon: Icons.radio_button_unchecked,
    ),

    // 7. Solid Bars (6 items)
    CatalogProfile(
      name: 'Flat Bar',
      categoryId: 'bars',
      categoryLabel: 'Solid Bars',
      icon: Icons.crop_original,
    ),
    CatalogProfile(
      name: 'MS Round Bar',
      categoryId: 'bars',
      categoryLabel: 'Solid Bars',
      icon: Icons.horizontal_rule,
    ),
    CatalogProfile(
      name: 'SS Round Bar (Stainless Steel)',
      categoryId: 'bars',
      categoryLabel: 'Solid Bars',
      icon: Icons.horizontal_rule,
    ),
    CatalogProfile(
      name: 'Aluminum Round Bar',
      categoryId: 'bars',
      categoryLabel: 'Solid Bars',
      icon: Icons.horizontal_rule,
    ),
    CatalogProfile(
      name: 'Brass Round Bar',
      categoryId: 'bars',
      categoryLabel: 'Solid Bars',
      icon: Icons.horizontal_rule,
    ),
    CatalogProfile(
      name: 'Copper Round Bar',
      categoryId: 'bars',
      categoryLabel: 'Solid Bars',
      icon: Icons.horizontal_rule,
    ),
  ];

  static List<String> get allShapeNames => profiles.map((p) => p.name).toList();

  static List<CatalogProfile> getProfilesForCategory(String categoryId) {
    if (categoryId == 'all') return profiles;
    return profiles.where((p) => p.categoryId == categoryId).toList();
  }

  static String getCategoryForShape(String shapeName) {
    for (final p in profiles) {
      if (p.name == shapeName) return p.categoryId;
    }
    if (shapeName.contains('Beam') || shapeName.contains('Universal')) return 'beams';
    if (shapeName.contains('Channel')) return 'channels';
    if (shapeName.contains('Angle')) return 'angles';
    if (shapeName.contains('Tube') || shapeName.contains('SHS') || shapeName.contains('RHS')) return 'tubes';
    if (shapeName.contains('Pipe')) return 'pipes';
    if (shapeName.contains('Sheet') || shapeName.contains('Plate')) return 'sheets';
    if (shapeName.contains('Bar')) return 'bars';
    return 'all';
  }
}
