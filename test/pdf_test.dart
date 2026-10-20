import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metal_weight/models/calculation_model.dart';
import 'package:metal_weight/services/pdf_export_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('PdfExportService detects shape categories accurately without false positives', () {
    CalculationModel makeModel(String title, String shape, String icon) {
      return CalculationModel(
        title: title,
        subtitle: '100 x 100 | L=6.0m x 1 pcs',
        weight: '50.00 kg',
        time: '17/10/2026 23:00',
        iconName: icon,
        bgColor: const Color(0xFFE8F0FE),
        iconColor: const Color(0xFF1A73E8),
        weightValue: 50.0,
        details: {'shape': shape},
      );
    }

    // Crucial regression tests: Tubes must NEVER match beams (from 'ub' substring)
    expect(PdfExportService.detectShapeCategory(makeModel('Square Tube (SHS) 50x50', 'Square Tube (SHS)', 'tube')), equals('tube'));
    expect(PdfExportService.detectShapeCategory(makeModel('Rectangular Tube (RHS) 60x40', 'Rectangular Tube (RHS)', 'tube')), equals('tube'));
    expect(PdfExportService.detectShapeCategory(makeModel('Stainless Steel Square Tube 40x40', 'Stainless Steel Square Tube', 'tube')), equals('tube'));
    expect(PdfExportService.detectShapeCategory(makeModel('Stainless Steel Rectangular Tube', 'Stainless Steel Rectangular Tube', 'tube')), equals('tube'));

    // Crucial regression tests: Pipes must NEVER match beams (from 'ipe' substring)
    expect(PdfExportService.detectShapeCategory(makeModel('Pipe Seamless 2 inch', 'Pipe Seamless', 'pipe')), equals('pipe'));
    expect(PdfExportService.detectShapeCategory(makeModel('Pipe ERW 3 inch', 'Pipe ERW', 'pipe')), equals('pipe'));
    expect(PdfExportService.detectShapeCategory(makeModel('Stainless Steel Pipe 1.5 inch', 'Stainless Steel Pipe', 'pipe')), equals('pipe'));

    // Beams must match beams correctly
    expect(PdfExportService.detectShapeCategory(makeModel('UB (Universal Beam) 203x133', 'UB (Universal Beam)', 'beam')), equals('beam'));
    expect(PdfExportService.detectShapeCategory(makeModel('UC (Universal Columns) 152x152', 'UC (Universal Columns)', 'beam')), equals('beam'));
    expect(PdfExportService.detectShapeCategory(makeModel('IPE Beam 140', 'IPE Beam', 'beam')), equals('beam'));
    expect(PdfExportService.detectShapeCategory(makeModel('HEB Beam 140', 'HEB Beam', 'beam')), equals('beam'));

    // Other shapes
    expect(PdfExportService.detectShapeCategory(makeModel('Equal Angle 50x50x5', 'Equal Angle', 'angle')), equals('angle'));
    expect(PdfExportService.detectShapeCategory(makeModel('UPN Channel 120', 'UPN Channel', 'channel')), equals('channel'));
    expect(PdfExportService.detectShapeCategory(makeModel('HR Sheet / HR Plate', 'HR Sheet / HR Plate', 'sheet')), equals('sheet'));
    expect(PdfExportService.detectShapeCategory(makeModel('Round Bar 25mm', 'Round Bar', 'round_bar')), equals('round_bar'));
    expect(PdfExportService.detectShapeCategory(makeModel('Flat Bar 50x6mm', 'Flat Bar', 'flat_bar')), equals('flat_bar'));
  });

  test('PdfExportService.generatePdfBytes generates valid PDF bytes without font errors', () async {
    final item = CalculationModel(
      title: 'Square Tube (SHS) 50x50x3.0',
      subtitle: '50x50x3.0 | L=6.0m x 1 pcs',
      weight: '26.10 kg',
      time: '17/10/2026 23:00',
      iconName: 'tube',
      bgColor: const Color(0xFFE8F0FE),
      iconColor: const Color(0xFF1A73E8),
      weightValue: 26.10,
      details: {
        'material': 'Steel',
        'shape': 'Square Tube (SHS)',
        'dimensions': '50x50x3.0 | L=6.0m x 1 pcs',
        'quantity': '1',
        'weightPerPiece': '4.35 kg/m',
        'totalWeight': '26.10 kg',
      },
    );

    final Uint8List bytes = await PdfExportService.generatePdfBytes(item);
    expect(bytes, isNotEmpty);
    expect(bytes.length, greaterThan(1000));

    // Verify PDF Magic header %PDF-
    final String header = String.fromCharCodes(bytes.sublist(0, 5));
    expect(header, equals('%PDF-'));
  });

  test('PdfExportService renders 2D blueprints for all profile categories', () async {
    final testProfiles = [
      {'title': 'UPN Channel 120', 'shape': 'UPN Channel', 'icon': 'channel'},
      {'title': 'Equal Angle 50x50x5', 'shape': 'Equal Angle', 'icon': 'angle'},
      {'title': 'Square Tube (SHS) 50x50x3.0', 'shape': 'Square Tube (SHS)', 'icon': 'tube'},
      {'title': 'Pipe Seamless 2 inch', 'shape': 'Pipe Seamless', 'icon': 'pipe'},
      {'title': 'HR Checkered Sheet 6mm', 'shape': 'HR Checkered Sheet', 'icon': 'sheet'},
      {'title': 'Round Bar 25mm', 'shape': 'Round Bar', 'icon': 'round_bar'},
      {'title': 'Flat Bar 50x6mm', 'shape': 'Flat Bar', 'icon': 'flat_bar'},
      {'title': 'UB (Universal Beam) 203 x 133 x 25', 'shape': 'Universal Beams & Columns (UB / UC)', 'icon': 'beam', 'variant': 'UB', 'size': '203 x 133 x 25'},
      {'title': 'UC (Universal Columns) 203 x 203 x 46', 'shape': 'Universal Beams & Columns (UB / UC)', 'icon': 'beam', 'variant': 'UC', 'size': '203 x 203 x 46'},
      {'title': 'W-Beam (Wide Flange) W 12x40', 'shape': 'W-Beam (Wide Flange)', 'icon': 'beam', 'variant': 'W-Beam', 'size': 'W 12x40'},
      {'title': 'IPE-AA Beam 140', 'shape': 'Beams (IPE / IPE-AA / HEA / HEB)', 'icon': 'beam', 'variant': 'IPE-AA', 'size': '140'},
      {'title': 'HEA Beam 140', 'shape': 'Beams (IPE / IPE-AA / HEA / HEB)', 'icon': 'beam', 'variant': 'HEA', 'size': '140'},
      {'title': 'HEB Beam 140', 'shape': 'Beams (IPE / IPE-AA / HEA / HEB)', 'icon': 'beam', 'variant': 'HEB', 'size': '140'},
      {'title': 'H-Beam (JIS) 150', 'shape': 'Beams (IPE / IPE-AA / HEA / HEB)', 'icon': 'beam', 'variant': 'JIS', 'size': '150'},
      {'title': 'UPE Channel 80', 'shape': 'Channels (UPN / UPE)', 'icon': 'channel', 'variant': 'UPE', 'size': '80'},
      {'title': 'U-Channel (JIS) 150', 'shape': 'Channels (UPN / UPE)', 'icon': 'channel', 'variant': 'JIS', 'size': '150'},
      {'title': 'Unequal Angle 30x20', 'shape': 'Unequal Angle', 'icon': 'angle', 'size': '30x20', 'thickness': '3'},
      {'title': 'Rectangular Tube (RHS) 60x40', 'shape': 'Rectangular Tube (RHS)', 'icon': 'tube', 'size': '60x40', 'thickness': '1.2'},
    ];

    for (final p in testProfiles) {
      final item = CalculationModel(
        title: p['title']!,
        subtitle: '${p['size'] ?? 'Standard'} | L=6.0m x 1 pcs',
        weight: '100.00 kg',
        time: '17/10/2026 22:00',
        iconName: p['icon']!,
        bgColor: const Color(0xFFE8F0FE),
        iconColor: const Color(0xFF1A73E8),
        weightValue: 100.0,
        details: {
          'material': 'Steel',
          'shape': p['shape']!,
          'size': p['size'] ?? 'Standard',
          'variant': p['variant'] ?? '',
          'dimensions': '${p['size'] ?? 'Standard'} | L=6.0m x 1 pcs',
          'quantity': '1',
          'weightPerPiece': '16.67 kg/m',
          'totalWeight': '100.00 kg',
        },
      );

      final bytes = await PdfExportService.generatePdfBytes(item);
      expect(bytes, isNotEmpty);
      expect(String.fromCharCodes(bytes.sublist(0, 5)), equals('%PDF-'));

      // Ensure the PDF remains strictly 1 single page without spilling onto page 2
      final pdfText = String.fromCharCodes(bytes);
      final pageMatches = RegExp(r'/Type\s*/Page\b').allMatches(pdfText).length;
      expect(pageMatches, equals(1));
    }
  });
}
