import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:metal_weight/core/constants/app_colors.dart';
import 'package:metal_weight/core/constants/company_data.dart';
import 'package:metal_weight/core/constants/standard_data.dart';
import 'package:metal_weight/models/calculation_model.dart';

class PdfExportService {
  PdfExportService._();

  static String _cleanText(String input) {
    if (input.isEmpty) return '';
    return input
        .replaceAll('²', '2')
        .replaceAll('³', '3')
        .replaceAll('Ø', 'DIA ')
        .replaceAll('ø', 'dia ')
        .replaceAll('–', '-') // en dash
        .replaceAll('—', '-') // em dash
        .replaceAll('−', '-') // minus sign
        .replaceAll('×', 'x') // multiplication sign
        .replaceAll('✕', 'x')
        .replaceAll('’', "'")
        .replaceAll('‘', "'")
        .replaceAll('”', '"')
        .replaceAll('“', '"')
        .replaceAll('•', '*')
        .replaceAll('…', '...')
        .replaceAll('±', '+/-')
        .replaceAll('°', ' deg')
        .replaceAll('\u00A0', ' ')
        .replaceAll(RegExp(r'[^\x20-\x7E\n\r\t]'), '');
  }

  /// Generates the raw PDF bytes for a given CalculationModel.
  static Future<Uint8List> generatePdfBytes(CalculationModel item) async {
    final doc = pw.Document(
      title: 'Milen Trading - ${_cleanText(item.title)}',
      author: CompanyData.companyName,
      creator: 'Milen Trading App',
    );
    final details = item.details;
    final now = DateTime.now();
    final dateStr = '${now.day}/${now.month}/${now.year}';

    pw.ThemeData? theme;
    try {
      final fontRegular = await PdfGoogleFonts.robotoRegular();
      final fontBold = await PdfGoogleFonts.robotoBold();
      theme = pw.ThemeData.withFont(base: fontRegular, bold: fontBold);
    } catch (_) {
      theme = null;
    }

    doc.addPage(
      pw.MultiPage(
        theme: theme,
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context docContext) {
          return [
            // Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      CompanyData.legalName.toUpperCase(),
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('2C3E50'),
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      '${CompanyData.website} | Structural Steel & Metal Quotation',
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'DATE: $dateStr',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('2C3E50'),
                      ),
                    ),
                    pw.Text(
                      'REF: MS-${now.millisecondsSinceEpoch.toString().substring(7)}',
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.Divider(thickness: 1.5, color: PdfColor.fromHex('E67E22')),
            pw.SizedBox(height: 14),

            // Title Card
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('F5F6FA'),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                border: pw.Border.all(color: PdfColor.fromHex('E1E2ED')),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    _cleanText(item.title),
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('2C3E50'),
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    _cleanText(item.subtitle),
                    style: const pw.TextStyle(
                      fontSize: 11,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 18),

            // Technical Specifications Table
            pw.Text(
              'SPECIFICATIONS & PARAMETERS',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('2C3E50'),
              ),
            ),
            pw.SizedBox(height: 8),

            pw.Table(
              border: pw.TableBorder.all(color: PdfColor.fromHex('E1E2ED'), width: 1),
              children: [
                _buildTableRow('Material Type', _cleanText(details['material']?.toString() ?? 'Steel'), true),
                _buildTableRow('Shape / Profile', _cleanText(details['shape']?.toString() ?? item.title), false),
                _buildTableRow('Dimensions', _cleanText(details['dimensions']?.toString() ?? item.subtitle), true),
                _buildTableRow('Quantity', '${details['quantity'] ?? '1'} pcs', false),
                if (details['weightPerPiece'] != null)
                  _buildTableRow('Weight / Piece', _cleanText(details['weightPerPiece'].toString()), true),
                _buildTableRow('Total Weight', _cleanText(item.weight), false, isHighlight: true),
                if (details['totalCost'] != null)
                  _buildTableRow('Estimated Cost', '${details['totalCost']} SAR', true, isCost: true),
                if (details['volume'] != null)
                  _buildTableRow('Volume', _cleanText(details['volume'].toString()), false),
                if (details['surfaceArea'] != null)
                  _buildTableRow('Surface Area', _cleanText(details['surfaceArea'].toString()), true),
                _buildTableRow('Calculation Time', item.time, false),
              ],
            ),
            pw.SizedBox(height: 14),

            // 2D Technical Cross-Section Blueprint Card
            _buildShapeBlueprintCard(item),
            pw.SizedBox(height: 14),

            // Summary Highlight Box
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(14),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('2C3E50'),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'TOTAL NET WEIGHT',
                        style: const pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.white,
                        ),
                      ),
                      pw.Text(
                        _cleanText(item.weight),
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('E67E22'),
                        ),
                      ),
                    ],
                  ),
                  if (details['totalCost'] != null)
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'ESTIMATED TOTAL COST',
                          style: const pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.white,
                          ),
                        ),
                        pw.Text(
                          '${details['totalCost']} SAR',
                          style: const pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            pw.SizedBox(height: 18),

            // Branch Offices Information Block
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('F8FAFC'),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                border: pw.Border.all(color: PdfColor.fromHex('E2E8F0'), width: 0.8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('WESTERN REGION (JEDDAH)',
                          style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('2C3E50'))),
                      pw.SizedBox(height: 2),
                      pw.Text('Tel: +966 597 67 87 97', style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700)),
                      pw.Text('info@milantrades.com', style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('CENTRAL REGION (RIYADH)',
                          style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('2C3E50'))),
                      pw.SizedBox(height: 2),
                      pw.Text('Tel: +966 569 79 49 71', style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700)),
                      pw.Text('sales@milantrades.com', style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('EASTERN REGION (DAMMAM)',
                          style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('2C3E50'))),
                      pw.SizedBox(height: 2),
                      pw.Text('Tel: +966 566 51 28 99', style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700)),
                      pw.Text('sales@milantrades.com', style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700)),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 12),

            // Footer Note
            pw.Divider(thickness: 1, color: PdfColors.grey300),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Generated with ${CompanyData.companyName} Calculator',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                ),
                pw.Text(
                  '(c) 2026 ${CompanyData.legalName}. All rights reserved.',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                ),
              ],
            ),
          ];
        },
      ),
    );

    return await doc.save();
  }

  /// Opens the native system PDF preview with direct Save as PDF and Print options.
  static Future<bool> previewAndPrintPdf(
    CalculationModel item, {
    BuildContext? context,
  }) async {
    try {
      final bytes = await generatePdfBytes(item);
      final fileName = 'Milen_Trading_Quotation_${DateTime.now().millisecondsSinceEpoch}.pdf';
      return await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => bytes,
        name: fileName,
      );
    } catch (e, stack) {
      debugPrint('PdfExportService preview error: $e\n$stack');
      return false;
    }
  }

  /// Shares the PDF file directly via system share sheet (WhatsApp, Email, etc.).
  static Future<bool> sharePdfDocument(
    CalculationModel item, {
    BuildContext? context,
  }) async {
    try {
      final bytes = await generatePdfBytes(item);
      final now = DateTime.now();

      // Clean, safe filename without spaces or special characters
      final cleanTitle = _cleanText(item.title)
          .replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_')
          .replaceAll(RegExp(r'_+'), '_');
      final fileName = 'Milen_Trading_${cleanTitle}_${now.millisecondsSinceEpoch}.pdf';

      Rect? sharePositionOrigin;
      if (context != null && context.mounted) {
        try {
          final RenderBox? box = context.findRenderObject() as RenderBox?;
          if (box != null && box.hasSize) {
            sharePositionOrigin = box.localToGlobal(Offset.zero) & box.size;
          }
        } catch (_) {}
      }

      // 1. Flutter Web support (Chrome/Edge/Safari/Mobile Browser):
      // On Web, dart:io and path_provider are unsupported. Printing.sharePdf and
      // Printing.layoutPdf handle web downloads and browser PDF preview seamlessly.
      if (kIsWeb) {
        try {
          final bool shared = await Printing.sharePdf(
            bytes: bytes,
            filename: fileName,
            bounds: sharePositionOrigin,
          );
          if (!shared) {
            await Printing.layoutPdf(
              onLayout: (format) async => bytes,
              name: fileName,
            );
          }
          return true;
        } catch (webErr) {
          debugPrint('Web PDF export fallback: $webErr');
          await Printing.layoutPdf(
            onLayout: (format) async => bytes,
            name: fileName,
          );
          return true;
        }
      }

      // 2. Mobile / Desktop platforms (Android, iOS):
      try {
        Directory tempDir;
        try {
          tempDir = await getTemporaryDirectory();
        } catch (_) {
          tempDir = await getApplicationDocumentsDirectory();
        }

        final file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(bytes, flush: true);

        if (!await file.exists() || (await file.length()) == 0) {
          throw Exception('Failed to write PDF file to disk');
        }

        final xFile = XFile(
          file.path,
          mimeType: 'application/pdf',
          name: fileName,
        );

        await Share.shareXFiles(
          [xFile],
          subject: '${CompanyData.companyName} Quotation - ${_cleanText(item.title)}',
          sharePositionOrigin: sharePositionOrigin,
        );
        return true;
      } catch (mobileShareErr) {
        debugPrint('Mobile share_plus error: $mobileShareErr, attempting Printing.sharePdf fallback');
        return await Printing.sharePdf(
          bytes: bytes,
          filename: fileName,
          bounds: sharePositionOrigin,
        );
      }
    } catch (e, stack) {
      debugPrint('PdfExportService share error: $e\n$stack');
      return false;
    }
  }

  /// Shows the user a bottom sheet with choices to Preview/Save or Share the PDF.
  static Future<void> showExportOptionsModal(
    BuildContext context,
    CalculationModel item,
  ) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryOrange.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.picture_as_pdf,
                        color: AppColors.secondaryOrange,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Quotation PDF Export',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${item.title} (${item.weight})',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white70 : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Option 1: Preview & Save PDF
                InkWell(
                  onTap: () {
                    Navigator.pop(ctx);
                    previewAndPrintPdf(item, context: context);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryOrange.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.secondaryOrange.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryOrange,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.visibility, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Preview & Save PDF',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'View quotation, print, or save directly to device',
                                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.secondaryOrange),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Option 2: Share PDF Document
                InkWell(
                  onTap: () {
                    Navigator.pop(ctx);
                    sharePdfDocument(item, context: context);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primaryDark.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryDark,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.share, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Share PDF Document',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Send PDF directly to customers via WhatsApp, Email, etc.',
                                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.primaryDark),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Main entry point for exporting a calculation. Directly opens system share platform (WhatsApp, etc.).
  static Future<bool> exportSingleCalculation(
    CalculationModel item, {
    BuildContext? context,
  }) async {
    return await sharePdfDocument(item, context: context);
  }

  static pw.TableRow _buildTableRow(
    String label,
    String value,
    bool isStriped, {
    bool isHighlight = false,
    bool isCost = false,
  }) {
    return pw.TableRow(
      decoration: pw.BoxDecoration(
        color: isStriped ? PdfColor.fromHex('F8FAFC') : PdfColors.white,
      ),
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: pw.Text(
            value,
            textAlign: pw.TextAlign.right,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: isHighlight || isCost ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: isHighlight
                  ? PdfColor.fromHex('E67E22')
                  : (isCost ? PdfColor.fromHex('2C3E50') : PdfColors.black),
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildPdfDimBadge(String text, {double fontSize = 7.5}) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4.0, vertical: 1.5),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
        border: pw.Border.all(color: PdfColor.fromHex('0D5C9D'), width: 0.8),
      ),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: fontSize,
          fontWeight: pw.FontWeight.bold,
          color: PdfColor.fromHex('0D5C9D'),
        ),
      ),
    );
  }

  static Map<String, String> _extractProfileDimensions(CalculationModel? item, String shapeCategory) {
    final title = item?.title ?? '';
    final subtitle = item?.subtitle ?? '';
    final dims = item?.details['dimensions']?.toString() ?? '';
    final combined = '$title $subtitle $dims';

    String hStr = '';
    String bStr = '';
    String twStr = '';
    String tfStr = '';
    String tStr = '';
    String dStr = '';

    switch (shapeCategory) {
      case 'beam':
        final matchSize = RegExp(r'\b(80|100|120|140|160|180|200|220|240|270|300|330|360|400|450|500|550|600)\b')
            .firstMatch(combined);
        final sizeKey = matchSize != null ? matchSize.group(1)! : '140';

        if (combined.toLowerCase().contains('ipe-aa') && StandardData.ipeAaBeams.containsKey(sizeKey)) {
          final s = StandardData.ipeAaBeams[sizeKey]!;
          hStr = s.h.toStringAsFixed(0);
          bStr = s.b.toStringAsFixed(0);
          twStr = s.tw.toStringAsFixed(1);
          tfStr = s.tf.toStringAsFixed(1);
        } else if (combined.toLowerCase().contains('hea') && StandardData.heaBeams.containsKey(sizeKey)) {
          final s = StandardData.heaBeams[sizeKey]!;
          hStr = s.h.toStringAsFixed(0);
          bStr = s.b.toStringAsFixed(0);
          twStr = s.tw.toStringAsFixed(1);
          tfStr = s.tf.toStringAsFixed(1);
        } else if (combined.toLowerCase().contains('heb') && StandardData.hebBeams.containsKey(sizeKey)) {
          final s = StandardData.hebBeams[sizeKey]!;
          hStr = s.h.toStringAsFixed(0);
          bStr = s.b.toStringAsFixed(0);
          twStr = s.tw.toStringAsFixed(1);
          tfStr = s.tf.toStringAsFixed(1);
        } else if (StandardData.ipeBeams.containsKey(sizeKey)) {
          final s = StandardData.ipeBeams[sizeKey]!;
          hStr = s.h.toStringAsFixed(0);
          bStr = s.b.toStringAsFixed(0);
          twStr = s.tw.toStringAsFixed(1);
          tfStr = s.tf.toStringAsFixed(1);
        } else {
          hStr = sizeKey;
          bStr = '73';
          twStr = '4.7';
          tfStr = '6.9';
        }
        break;

      case 'channel':
        final matchSize = RegExp(r'\b(50|65|80|100|120|140|160|180|200|220|240|260|280|300|320|350|380|400)\b')
            .firstMatch(combined);
        final sizeKey = matchSize != null ? matchSize.group(1)! : '140';

        if (combined.toLowerCase().contains('upe') && StandardData.upeChannels.containsKey(sizeKey)) {
          final s = StandardData.upeChannels[sizeKey]!;
          hStr = s.h.toStringAsFixed(0);
          bStr = s.b.toStringAsFixed(0);
          twStr = s.tw.toStringAsFixed(1);
          tfStr = s.tf.toStringAsFixed(1);
        } else if (combined.toLowerCase().contains('jis') && StandardData.jisChannels.containsKey(sizeKey)) {
          final s = StandardData.jisChannels[sizeKey]!;
          hStr = s.h.toStringAsFixed(0);
          bStr = s.b.toStringAsFixed(0);
          twStr = s.tw.toStringAsFixed(1);
          tfStr = s.tf.toStringAsFixed(1);
        } else if (StandardData.upnChannels.containsKey(sizeKey)) {
          final s = StandardData.upnChannels[sizeKey]!;
          hStr = s.h.toStringAsFixed(0);
          bStr = s.b.toStringAsFixed(0);
          twStr = s.tw.toStringAsFixed(1);
          tfStr = s.tf.toStringAsFixed(1);
        } else {
          hStr = sizeKey;
          bStr = '60';
          twStr = '7.0';
          tfStr = '10.0';
        }
        break;

      case 'angle':
        final match = RegExp(r'(\d+)\s*[xX*×]\s*(\d+)(?:\s*[xX*×]\s*(\d+(?:\.\d+)?))?').firstMatch(combined);
        if (match != null) {
          bStr = match.group(1)!;
          hStr = match.group(2)!;
          tStr = match.group(3) ?? '5.0';
        } else {
          final mSingle = RegExp(r'\b(\d+)\b').firstMatch(combined);
          final val = mSingle != null ? mSingle.group(1)! : '50';
          bStr = val;
          hStr = val;
          tStr = '5.0';
        }
        break;

      case 'tube':
        final match = RegExp(r'(\d+)\s*[xX*×]\s*(\d+)(?:\s*[xX*×]\s*(\d+(?:\.\d+)?))?').firstMatch(combined);
        if (match != null) {
          hStr = match.group(1)!;
          bStr = match.group(2)!;
          tStr = match.group(3) ?? '3.0';
        } else {
          hStr = '50';
          bStr = '50';
          tStr = '3.0';
        }
        break;

      case 'pipe':
        final match = RegExp(r'(\d+(?:\.\d+)?)\s*[xX*×]\s*(\d+(?:\.\d+)?)').firstMatch(combined);
        if (match != null) {
          dStr = match.group(1)!;
          tStr = match.group(2)!;
        } else {
          final mDia = RegExp(r'(\d+(?:\.\d+)?)\s*(?:mm|inch|in|"|\b)').firstMatch(combined);
          dStr = mDia != null ? mDia.group(1)! : '60.3';
          tStr = '3.2';
        }
        break;

      case 'sheet':
        final mThick = RegExp(r'(\d+(?:\.\d+)?)\s*(?:mm|\b)').firstMatch(subtitle.isNotEmpty ? subtitle : title);
        tStr = mThick != null ? mThick.group(1)! : '2.0';
        bStr = '1000';
        break;

      case 'flat_bar':
        final match = RegExp(r'(\d+)\s*[xX*×]\s*(\d+(?:\.\d+)?)').firstMatch(combined);
        if (match != null) {
          bStr = match.group(1)!;
          tStr = match.group(2)!;
        } else {
          bStr = '50';
          tStr = '6';
        }
        break;

      case 'round_bar':
        final match = RegExp(r'(\d+(?:\.\d+)?)\s*(?:mm|\b)').firstMatch(combined);
        dStr = match != null ? match.group(1)! : '25';
        break;
    }

    return {
      'h': hStr,
      'b': bStr,
      'tw': twStr,
      'tf': tfStr,
      't': tStr,
      'd': dStr,
    };
  }

  static List<pw.Widget> _buildPdfDimensionBadges(String shapeCategory, CalculationModel? item) {
    final dims = _extractProfileDimensions(item, shapeCategory);
    final badges = <pw.Widget>[];

    switch (shapeCategory) {
      case 'beam':
        if (dims['h']!.isNotEmpty) {
          badges.add(pw.Positioned(left: 198.0, top: 73.0, child: _buildPdfDimBadge(dims['h']!)));
        }
        if (dims['b']!.isNotEmpty) {
          badges.add(pw.Positioned(left: 120.0, top: 137.0, child: _buildPdfDimBadge(dims['b']!)));
        }
        if (dims['tf']!.isNotEmpty) {
          badges.add(pw.Positioned(left: 46.0, top: 27.0, child: _buildPdfDimBadge(dims['tf']!)));
        }
        if (dims['tw']!.isNotEmpty) {
          badges.add(pw.Positioned(left: 154.0, top: 51.0, child: _buildPdfDimBadge(dims['tw']!)));
        }
        break;

      case 'channel':
        if (dims['h']!.isNotEmpty) {
          badges.add(pw.Positioned(left: 58.0, top: 73.0, child: _buildPdfDimBadge(dims['h']!)));
        }
        if (dims['b']!.isNotEmpty) {
          badges.add(pw.Positioned(left: 120.0, top: 140.0, child: _buildPdfDimBadge(dims['b']!)));
        }
        if (dims['tf']!.isNotEmpty) {
          badges.add(pw.Positioned(left: 184.0, top: 24.0, child: _buildPdfDimBadge(dims['tf']!)));
        }
        if (dims['tw']!.isNotEmpty) {
          badges.add(pw.Positioned(left: 128.0, top: 59.0, child: _buildPdfDimBadge(dims['tw']!)));
        }
        break;

      case 'angle':
        if (dims['h']!.isNotEmpty) {
          badges.add(pw.Positioned(left: 46.0, top: 73.0, child: _buildPdfDimBadge(dims['h']!)));
        }
        if (dims['b']!.isNotEmpty) {
          badges.add(pw.Positioned(left: 120.0, top: 130.0, child: _buildPdfDimBadge(dims['b']!)));
        }
        if (dims['t']!.isNotEmpty) {
          badges.add(pw.Positioned(left: 118.0, top: 77.0, child: _buildPdfDimBadge(dims['t']!)));
        }
        break;

      case 'tube':
        if (dims['h']!.isNotEmpty) {
          badges.add(pw.Positioned(left: 194.0, top: 73.0, child: _buildPdfDimBadge(dims['h']!)));
        }
        if (dims['b']!.isNotEmpty) {
          badges.add(pw.Positioned(left: 120.0, top: 138.0, child: _buildPdfDimBadge(dims['b']!)));
        }
        if (dims['t']!.isNotEmpty) {
          badges.add(pw.Positioned(left: 46.0, top: 73.0, child: _buildPdfDimBadge('t=${dims['t']}')));
        }
        break;

      case 'pipe':
        if (dims['d']!.isNotEmpty) {
          badges.add(pw.Positioned(left: 114.0, top: 133.0, child: _buildPdfDimBadge('OD ${dims['d']}')));
        }
        if (dims['t']!.isNotEmpty) {
          badges.add(pw.Positioned(left: 36.0, top: 73.0, child: _buildPdfDimBadge('t=${dims['t']}')));
        }
        break;

      case 'sheet':
        if (dims['b']!.isNotEmpty) {
          badges.add(pw.Positioned(left: 120.0, top: 98.0, child: _buildPdfDimBadge('${dims['b']} mm')));
        }
        if (dims['t']!.isNotEmpty) {
          badges.add(pw.Positioned(left: 228.0, top: 73.0, child: _buildPdfDimBadge('t=${dims['t']} mm')));
        }
        break;

      case 'flat_bar':
        if (dims['b']!.isNotEmpty) {
          badges.add(pw.Positioned(left: 120.0, top: 101.0, child: _buildPdfDimBadge('${dims['b']} mm')));
        }
        if (dims['t']!.isNotEmpty) {
          badges.add(pw.Positioned(left: 216.0, top: 73.0, child: _buildPdfDimBadge('t=${dims['t']} mm')));
        }
        break;

      case 'round_bar':
        if (dims['d']!.isNotEmpty) {
          badges.add(pw.Positioned(left: 114.0, top: 129.0, child: _buildPdfDimBadge('DIA ${dims['d']} mm')));
        }
        break;
    }

    return badges;
  }

  static pw.Widget _buildPdfEngineeringSpecTable(CalculationModel? item, String shapeCategory) {
    if (item == null) return pw.SizedBox();

    final details = item.details;
    final String shape = (details['shape']?.toString() ?? item.title).toUpperCase();
    String variantStr = 'PROFILE';
    if (shapeCategory == 'pipe') {
      variantStr = 'PIPE';
    } else if (shapeCategory == 'beam') {
      if (shape.contains('HEA')) {
        variantStr = 'HEA';
      } else if (shape.contains('HEB')) {
        variantStr = 'HEB';
      } else if (shape.contains('IPE-AA')) {
        variantStr = 'IPE-AA';
      } else if (shape.contains('IPE')) {
        variantStr = 'IPE';
      } else if (shape.contains('UC')) {
        variantStr = 'UC';
      } else if (shape.contains('UB')) {
        variantStr = 'UB';
      } else {
        variantStr = 'BEAM';
      }
    } else if (shapeCategory == 'channel') {
      if (shape.contains('UPN')) {
        variantStr = 'UPN';
      } else if (shape.contains('UPE')) {
        variantStr = 'UPE';
      } else {
        variantStr = 'CHANNEL';
      }
    } else if (shapeCategory == 'angle') {
      variantStr = 'ANGLE';
    } else if (shapeCategory == 'tube') {
      variantStr = shape.contains('RECTANGULAR') || shape.contains('RHS') ? 'RHS' : 'SHS';
    } else if (shapeCategory == 'sheet') {
      variantStr = 'SHEET';
    } else if (shapeCategory == 'round_bar') {
      variantStr = 'ROUND';
    } else if (shapeCategory == 'flat_bar') {
      variantStr = 'FLAT';
    }

    final dimStr = details['dimensions']?.toString() ?? item.subtitle;
    String sizeStr = dimStr.split('x').first.trim();
    if (sizeStr.contains('(')) sizeStr = sizeStr.split('(').first.trim();
    if (sizeStr.isEmpty) sizeStr = 'STD';

    double wVal = 0.0;
    if (details['weightPerPiece'] != null) {
      final m = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(details['weightPerPiece'].toString());
      if (m != null) wVal = double.tryParse(m.group(1)!) ?? 0.0;
    }
    if (wVal <= 0.0) {
      final m = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(item.weight);
      if (m != null) wVal = double.tryParse(m.group(1)!) ?? 0.0;
    }
    final String weightStr = wVal.toStringAsFixed(2);
    final String weightUnit = shapeCategory == 'sheet' ? 'Kg/m²' : 'Kg/m';
    final String sectionAreaStr = (wVal * 1.27).toStringAsFixed(2);

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('F1F5F9'),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        border: pw.Border.all(color: PdfColor.fromHex('CBD5E1'), width: 0.8),
      ),
      child: pw.Column(
        children: [
          _buildSpecRow(variantStr, sizeStr, 'Standard'),
          pw.SizedBox(height: 3),
          _buildSpecRow('weight', weightStr, weightUnit),
          pw.SizedBox(height: 3),
          _buildSpecRow('section', sectionAreaStr, 'cm²'),
        ],
      ),
    );
  }

  static pw.Widget _buildSpecRow(String label, String value, String unit) {
    return pw.Row(
      children: [
        pw.SizedBox(
          width: 48,
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 8.5,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('1E293B'),
            ),
          ),
        ),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
          decoration: pw.BoxDecoration(
            color: PdfColors.white,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
            border: pw.Border.all(color: PdfColor.fromHex('0D5C9D'), width: 0.8),
          ),
          child: pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 8.5,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('0D5C9D'),
            ),
          ),
        ),
        pw.SizedBox(width: 6),
        pw.Text(
          unit,
          style: const pw.TextStyle(
            fontSize: 8.0,
            color: PdfColors.grey700,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildShapeBlueprintCard(CalculationModel item) {
    final String shapeCategory = _detectShapeCategory(item);
    final String cleanTitle = _cleanText(item.title);
    final String dimSummary = _cleanText(item.details['dimensions']?.toString() ?? item.subtitle);

    String profileTypeDesc = 'Structural Steel Profile';
    String dimParams = 'Standard Dimensions: $dimSummary';

    switch (shapeCategory) {
      case 'beam':
        profileTypeDesc = 'Structural I/H Section (EN 10025 / DIN 1025 / ASTM)';
        dimParams = 'Height (h) x Flange Width (b) x Web (tw) x Flange (tf)';
        break;
      case 'channel':
        profileTypeDesc = 'Parallel / Taper Flange U-Channel (DIN 1026 / JIS)';
        dimParams = 'Height (h) x Flange Width (b) x Web (tw) x Flange (tf)';
        break;
      case 'angle':
        profileTypeDesc = 'Structural L-Profile Angle (EN 10056 / ASTM A36)';
        dimParams = 'Leg Width (A) x Leg Width (B) x Thickness (t)';
        break;
      case 'tube':
        profileTypeDesc = 'Structural Hollow Section - SHS/RHS (EN 10219 / ASTM A500)';
        dimParams = 'Outer Width (W) x Outer Height (H) x Wall Thickness (t)';
        break;
      case 'pipe':
        profileTypeDesc = 'Round Hollow Section / Pipe (ASTM A53 / API 5L / EN 10217)';
        dimParams = 'Outer Diameter (D) x Wall Thickness (t) x Length (L)';
        break;
      case 'sheet':
        final mat = item.details['material']?.toString() ?? 'Steel';
        final isCheckered = (item.title + (item.details['shape']?.toString() ?? '')).toLowerCase().contains('checkered');
        profileTypeDesc = isCheckered
            ? '$mat Checkered Plate (EN 1386 / ASTM A786)'
            : '$mat Sheet / Plate (EN 10029 / ASTM A36 / AISI)';
        dimParams = 'Width (W) x Thickness (t) x Length (L)';
        break;
      case 'round_bar':
        profileTypeDesc = 'Solid Round Engineering Bar (AISI / DIN 1013)';
        dimParams = 'Diameter (D) x Length (L)';
        break;
      case 'flat_bar':
        profileTypeDesc = 'Solid Flat Bar / Strip (EN 10058 / DIN 1017)';
        dimParams = 'Width (W) x Thickness (T) x Length (L)';
        break;
    }

    return pw.Container(
      width: double.infinity,
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('F8FAFC'),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: PdfColor.fromHex('CBD5E1'), width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Blueprint Card Header
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('2C3E50'),
              borderRadius: const pw.BorderRadius.vertical(top: pw.Radius.circular(7)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Row(
                  children: [
                    pw.Container(
                      width: 6,
                      height: 6,
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex('E67E22'),
                        shape: pw.BoxShape.circle,
                      ),
                    ),
                    pw.SizedBox(width: 6),
                    pw.Text(
                      'TECHNICAL 2D CROSS-SECTION BLUEPRINT',
                      style: const pw.TextStyle(
                        fontSize: 8.5,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('FDF2E9'),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                    border: pw.Border.all(color: PdfColor.fromHex('E67E22'), width: 0.6),
                  ),
                  child: pw.Text(
                    cleanTitle.toUpperCase(),
                    style: pw.TextStyle(
                      fontSize: 7.5,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('E67E22'),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Blueprint Drawing & Parameter Details
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                // Technical Parameters & Mini Spec Table (Left)
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Text(
                        profileTypeDesc,
                        style: pw.TextStyle(
                          fontSize: 10.0,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('2C3E50'),
                        ),
                      ),
                      pw.SizedBox(height: 3),
                      pw.Text(
                        'Spec: $dimSummary',
                        style: const pw.TextStyle(
                          fontSize: 8.5,
                          color: PdfColors.grey800,
                        ),
                      ),
                      pw.SizedBox(height: 3),
                      pw.Text(
                        'Dimension Keys: $dimParams',
                        style: const pw.TextStyle(
                          fontSize: 7.5,
                          color: PdfColors.grey600,
                        ),
                      ),
                      pw.SizedBox(height: 6),

                      // Technical Spec Table matching mobile app
                      _buildPdfEngineeringSpecTable(item, shapeCategory),
                      pw.SizedBox(height: 6),

                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                        decoration: pw.BoxDecoration(
                          color: PdfColor.fromHex('EDF2F7'),
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                        ),
                        child: pw.Text(
                          '2D Cross-section for profile identification & engineering verification',
                          style: const pw.TextStyle(
                            fontSize: 7.0,
                            color: PdfColors.grey700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(width: 12),

                // 2D Vector Drawing (Right - High-Resolution 275 x 160)
                pw.Container(
                  width: 275,
                  height: 160,
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                    border: pw.Border.all(color: PdfColor.fromHex('CBD5E1'), width: 0.8),
                  ),
                  child: pw.Stack(
                    children: [
                      pw.CustomPaint(
                        size: const PdfPoint(275, 160),
                        painter: (PdfGraphics canvas, PdfPoint size) {
                          _drawVectorCrossSection(canvas, size, shapeCategory, item: item);
                        },
                      ),
                      ..._buildPdfDimensionBadges(shapeCategory, item),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @visibleForTesting
  static String detectShapeCategory(CalculationModel item) => _detectShapeCategory(item);

  static String _detectShapeCategory(CalculationModel item) {
    final title = (item.title).toLowerCase();
    final shape = (item.details['shape']?.toString() ?? '').toLowerCase();
    final icon = item.iconName.toLowerCase();
    final combined = ' $title $shape $icon ';

    // 1. Hollow Sections / Tubes (SHS, RHS, Square Tube, Rectangular Tube)
    // NOTE: Must check before beams, because 'tube' contains 'ub' ('t-ub-e')!
    if (combined.contains('tube') ||
        combined.contains('shs') ||
        combined.contains('rhs') ||
        combined.contains('box') ||
        icon == 'tube' ||
        icon == 'square') {
      return 'tube';
    }

    // 2. Pipes (Round Tube, ERW, Seamless, Pipe)
    // NOTE: Must check before beams, because 'pipe' contains 'ipe' ('p-ipe')!
    if (combined.contains('pipe') ||
        combined.contains('erw') ||
        combined.contains('seamless') ||
        combined.contains('circular') ||
        icon == 'pipe') {
      return 'pipe';
    }

    // 3. Channels (UPN, UPE, JIS Channel, C-Profile)
    if (combined.contains('channel') ||
        combined.contains('upn') ||
        combined.contains('upe') ||
        combined.contains('c-profile') ||
        icon == 'channel') {
      return 'channel';
    }

    // 4. Angles (Equal Angle, Unequal Angle, L-Profile)
    if (combined.contains('angle') ||
        combined.contains('l-profile') ||
        icon == 'angle') {
      return 'angle';
    }

    // 5. Sheets & Plates (HR Sheet, Plate, Checkered, Chequered)
    if (combined.contains('sheet') ||
        combined.contains('plate') ||
        combined.contains('checkered') ||
        combined.contains('chequered') ||
        icon == 'sheet') {
      return 'sheet';
    }

    // 6. Solid Flat Bars
    if (combined.contains('flat') || icon == 'flat_bar') {
      return 'flat_bar';
    }

    // 7. Solid Round Bars & Hexagonal Bars
    if (combined.contains('round bar') ||
        combined.contains('ms round') ||
        combined.contains('ss round') ||
        combined.contains('shaft') ||
        combined.contains('hexagon') ||
        icon == 'round_bar' ||
        icon == 'hexagon') {
      return 'round_bar';
    }

    // 8. Beams & Columns (IPE, IPE-AA, HEA, HEB, JIS H-Beam, UB, UC, W-Beam)
    // Word boundary \b is essential to prevent false positives with 'tube' or 'pipe'
    final RegExp beamRegex =
        RegExp(r'\b(beam|ipe|ipe-aa|hea|heb|ub|uc|w-beam|wide flange|h-beam|i-beam)\b');
    if (beamRegex.hasMatch(combined) || icon == 'beam') {
      return 'beam';
    }

    // Fallbacks
    if (icon == 'round_bar') return 'round_bar';
    if (icon == 'flat_bar') return 'flat_bar';
    if (icon == 'sheet') return 'sheet';
    if (icon == 'pipe') return 'pipe';
    if (icon == 'tube') return 'tube';
    if (icon == 'angle') return 'angle';
    if (icon == 'channel') return 'channel';

    return 'beam';
  }

  static void _drawVectorCrossSection(
      PdfGraphics canvas, PdfPoint size, String category,
      {CalculationModel? item}) {
    final cx = size.x / 2;
    final cy = size.y / 2;
    final steelColor = PdfColor.fromHex('2C3E50');
    final accentColor = PdfColor.fromHex('E67E22');
    final gridColor = PdfColor.fromHex('F1F5F9');
    final centerlineColor = PdfColor.fromHex('94A3B8');

    // Subtle background engineering grid
    canvas
      ..setStrokeColor(gridColor)
      ..setLineWidth(0.5);
    for (double x = 10; x < size.x; x += 14) {
      canvas..moveTo(x, 4)..lineTo(x, size.y - 4);
    }
    for (double y = 8; y < size.y; y += 14) {
      canvas..moveTo(4, y)..lineTo(size.x - 4, y);
    }
    canvas.strokePath();

    canvas
      ..setFillColor(steelColor)
      ..setStrokeColor(steelColor)
      ..setLineWidth(1.0);

    switch (category) {
      case 'beam':
        final isHBeam = item != null &&
            RegExp(r'\b(hea|heb|uc|w-beam|jis|h-beam|wide flange)\b',
                    caseSensitive: false)
                .hasMatch('${item.title} ${item.subtitle} ${item.iconName}');
        final double w = isHBeam ? 100.0 : 76.0;
        final double h = isHBeam ? 100.0 : 110.0;
        final double tf = isHBeam ? 14.0 : 12.0;
        final double tw = isHBeam ? 10.0 : 8.5;
        canvas.setFillColor(PdfColor.fromHex('0D5C9D'));
        // Top flange
        canvas.drawRRect(cx - w / 2, cy + h / 2 - tf, w, tf, 2, 2);
        // Web
        canvas.drawRect(cx - tw / 2, cy - h / 2 + tf, tw, h - 2 * tf);
        // Bottom flange
        canvas.drawRRect(cx - w / 2, cy - h / 2, w, tf, 2, 2);
        canvas.fillPath();

        // CAD stroke outlines
        canvas
          ..setStrokeColor(PdfColor.fromHex('BDC3C7'))
          ..setLineWidth(0.8)
          ..drawRRect(cx - w / 2, cy + h / 2 - tf, w, tf, 2, 2)
          ..drawRect(cx - tw / 2, cy - h / 2 + tf, tw, h - 2 * tf)
          ..drawRRect(cx - w / 2, cy - h / 2, w, tf, 2, 2)
          ..strokePath();

        // Dimension markings
        canvas
          ..setStrokeColor(accentColor)
          ..setLineWidth(0.8);
        // Height arrow on the right
        _drawArrowV(canvas, cx + w / 2 + 12, cy - h / 2, cy + h / 2);
        _drawWitnessH(canvas, cx + w / 2, cx + w / 2 + 16, cy - h / 2);
        _drawWitnessH(canvas, cx + w / 2, cx + w / 2 + 16, cy + h / 2);

        // Width arrow at the bottom
        _drawArrowH(canvas, cx - w / 2, cx + w / 2, cy - h / 2 - 12);
        _drawWitnessV(canvas, cx - w / 2, cy - h / 2 - 16, cy - h / 2);
        _drawWitnessV(canvas, cx + w / 2, cy - h / 2 - 16, cy - h / 2);

        // Flange thickness arrow on top-left
        _drawArrowV(canvas, cx - w / 2 - 12, cy + h / 2 - tf, cy + h / 2);
        _drawWitnessH(canvas, cx - w / 2 - 16, cx - w / 2, cy + h / 2 - tf);
        _drawWitnessH(canvas, cx - w / 2 - 16, cx - w / 2, cy + h / 2);

        // Web thickness pointer arrows (Upper web section, matching App 2D blueprint)
        final double webArrowY = cy + 22.0;
        _drawArrowH(canvas, cx - tw / 2 - 10, cx - tw / 2, webArrowY);
        _drawArrowH(canvas, cx + tw / 2, cx + tw / 2 + 10, webArrowY);
        break;

      case 'channel':
        const w = 66.0;
        const h = 110.0;
        const tf = 12.0;
        const tw = 9.0;
        final left = cx - w / 2;
        canvas.setFillColor(PdfColor.fromHex('0D5C9D'));
        // Back web
        canvas.drawRect(left, cy - h / 2, tw, h);
        // Top flange
        canvas.drawRRect(left + tw, cy + h / 2 - tf, w - tw, tf, 2, 2);
        // Bottom flange
        canvas.drawRRect(left + tw, cy - h / 2, w - tw, tf, 2, 2);
        canvas.fillPath();

        // CAD stroke outlines
        canvas
          ..setStrokeColor(PdfColor.fromHex('BDC3C7'))
          ..setLineWidth(0.8)
          ..drawRect(left, cy - h / 2, tw, h)
          ..drawRRect(left + tw, cy + h / 2 - tf, w - tw, tf, 2, 2)
          ..drawRRect(left + tw, cy - h / 2, w - tw, tf, 2, 2)
          ..strokePath();

        // Dimension markings
        canvas
          ..setStrokeColor(accentColor)
          ..setLineWidth(0.8);
        _drawArrowV(canvas, left - 12, cy - h / 2, cy + h / 2);
        _drawArrowH(canvas, left, left + w, cy - h / 2 - 12);
        _drawWitnessV(canvas, left, cy - h / 2 - 16, cy - h / 2);
        _drawWitnessV(canvas, left + w, cy - h / 2 - 16, cy - h / 2);
        _drawWitnessH(canvas, left - 16, left, cy - h / 2);
        _drawWitnessH(canvas, left - 16, left, cy + h / 2);

        // Web thickness pointer
        _drawArrowH(canvas, left - 10, left, cy + 18.0);
        _drawArrowH(canvas, left + tw, left + tw + 10, cy + 18.0);
        break;

      case 'angle':
        const legA = 90.0;
        const legB = 90.0;
        const t = 12.0;
        final left = cx - legB / 2;
        final bottom = cy - legA / 2;
        canvas.setFillColor(PdfColor.fromHex('0D5C9D'));
        canvas.drawRect(left, bottom, t, legA);
        canvas.drawRect(left + t, bottom, legB - t, t);
        canvas.fillPath();

        // CAD stroke outline
        canvas
          ..setStrokeColor(PdfColor.fromHex('BDC3C7'))
          ..setLineWidth(0.8)
          ..moveTo(left, bottom)
          ..lineTo(left, bottom + legA)
          ..lineTo(left + t, bottom + legA)
          ..lineTo(left + t, bottom + t)
          ..lineTo(left + legB, bottom + t)
          ..lineTo(left + legB, bottom)
          ..closePath()
          ..strokePath();

        // Dimension markings
        canvas
          ..setStrokeColor(accentColor)
          ..setLineWidth(0.8);
        _drawArrowV(canvas, left - 12, bottom, bottom + legA);
        _drawArrowH(canvas, left, left + legB, bottom - 12);
        _drawWitnessH(canvas, left - 16, left, bottom);
        _drawWitnessH(canvas, left - 16, left, bottom + legA);
        _drawWitnessV(canvas, left, bottom - 16, bottom);
        _drawWitnessV(canvas, left + legB, bottom - 16, bottom);

        // Thickness callout
        _drawArrowH(canvas, left + t / 2, left + t + 16, bottom + legA * 0.45);
        break;

      case 'tube':
        final itemStr =
            '${item?.title ?? ''} ${item?.details['shape'] ?? ''}'.toLowerCase();
        final dimStr =
            item?.details['dimensions']?.toString() ?? item?.subtitle ?? '';
        final bool isRectangular =
            itemStr.contains('rectangular') || itemStr.contains('rhs');

        // Extract dimension numbers (e.g. "80x40" -> 80 and 40)
        double dimH = 80.0;
        double dimW = 40.0;

        final matchDim =
            RegExp(r'(\d+(?:\.\d+)?)\s*[xX*×]\s*(\d+(?:\.\d+)?)').firstMatch(dimStr);
        if (matchDim != null) {
          dimH = double.tryParse(matchDim.group(1)!) ?? 80.0;
          dimW = double.tryParse(matchDim.group(2)!) ?? 40.0;
        }

        double w;
        double h;
        if (isRectangular) {
          if (dimH >= dimW) {
            h = 100.0;
            w = (h * (dimW / dimH)).clamp(48.0, 75.0);
          } else {
            w = 100.0;
            h = (w * (dimH / dimW)).clamp(48.0, 75.0);
          }
        } else {
          w = 80.0;
          h = 80.0;
        }

        const double t = 8.5;
        // Blueprint Fill (#0D5C9D)
        canvas.setFillColor(PdfColor.fromHex('0D5C9D'));
        canvas.drawRRect(cx - w / 2, cy - h / 2, w, h, 4, 4);
        canvas.fillPath();

        // Inner cut
        canvas.setFillColor(PdfColors.white);
        canvas.drawRRect(
            cx - w / 2 + t, cy - h / 2 + t, w - 2 * t, h - 2 * t, 3, 3);
        canvas.fillPath();

        // CAD stroke outlines
        canvas
          ..setStrokeColor(PdfColor.fromHex('BDC3C7'))
          ..setLineWidth(0.8)
          ..drawRRect(cx - w / 2, cy - h / 2, w, h, 4, 4)
          ..drawRRect(cx - w / 2 + t, cy - h / 2 + t, w - 2 * t, h - 2 * t, 3, 3)
          ..strokePath();

        // Dimension markings matching App:
        canvas
          ..setStrokeColor(accentColor)
          ..setLineWidth(0.8);
        _drawArrowV(canvas, cx + w / 2 + 12, cy - h / 2, cy + h / 2);
        _drawWitnessH(canvas, cx + w / 2, cx + w / 2 + 16, cy - h / 2);
        _drawWitnessH(canvas, cx + w / 2, cx + w / 2 + 16, cy + h / 2);

        _drawArrowH(canvas, cx - w / 2, cx + w / 2, cy - h / 2 - 12);
        _drawWitnessV(canvas, cx - w / 2, cy - h / 2 - 16, cy - h / 2);
        _drawWitnessV(canvas, cx + w / 2, cy - h / 2 - 16, cy - h / 2);

        // Thickness callout on the left
        canvas
          ..moveTo(cx - w / 2 + t / 2, cy)
          ..lineTo(cx - w / 2 - 16, cy)
          ..strokePath();
        _drawArrowH(canvas, cx - w / 2 - 16, cx - w / 2 + t / 2, cy);
        break;

      case 'pipe':
        const rOuter = 48.0;
        const rInner = 35.0;
        canvas.setFillColor(PdfColor.fromHex('0D5C9D'));
        canvas.drawEllipse(cx, cy, rOuter, rOuter);
        canvas.fillPath();
        canvas.setFillColor(PdfColors.white);
        canvas.drawEllipse(cx, cy, rInner, rInner);
        canvas.fillPath();

        // CAD stroke outlines
        canvas
          ..setStrokeColor(PdfColor.fromHex('BDC3C7'))
          ..setLineWidth(0.8)
          ..drawEllipse(cx, cy, rOuter, rOuter)
          ..drawEllipse(cx, cy, rInner, rInner)
          ..strokePath();

        // Centerlines
        canvas
          ..setStrokeColor(centerlineColor)
          ..setLineWidth(0.6)
          ..moveTo(cx - rOuter - 12, cy)
          ..lineTo(cx + rOuter + 12, cy)
          ..moveTo(cx, cy - rOuter - 12)
          ..lineTo(cx, cy + rOuter + 12)
          ..strokePath();

        // Diameter arrow at bottom
        canvas
          ..setStrokeColor(accentColor)
          ..setLineWidth(0.8);
        _drawArrowH(canvas, cx - rOuter, cx + rOuter, cy - rOuter - 12);
        _drawWitnessV(canvas, cx - rOuter, cy - rOuter - 16, cy - rOuter);
        _drawWitnessV(canvas, cx + rOuter, cy - rOuter - 16, cy - rOuter);

        // Wall thickness callout on left
        canvas
          ..moveTo(cx - (rOuter + rInner) / 2, cy)
          ..lineTo(cx - rOuter - 18, cy)
          ..strokePath();
        _drawArrowH(canvas, cx - rOuter - 18, cx - (rOuter + rInner) / 2, cy);
        break;

      case 'sheet':
        // 2D Cross-section for Sheets and Plates of ALL materials, matching App 2D blueprint exactly
        const w = 150.0;
        const h = 26.0;
        canvas.setFillColor(PdfColor.fromHex('0D5C9D'));
        canvas.drawRect(cx - w / 2, cy - h / 2, w, h);
        canvas.fillPath();

        // CAD stroke outline
        canvas
          ..setStrokeColor(PdfColor.fromHex('BDC3C7'))
          ..setLineWidth(0.8)
          ..drawRect(cx - w / 2, cy - h / 2, w, h)
          ..strokePath();

        // Dimension markings
        canvas
          ..setStrokeColor(accentColor)
          ..setLineWidth(0.8);

        // Thickness dimension on the right
        _drawArrowV(canvas, cx + w / 2 + 12, cy - h / 2, cy + h / 2);
        _drawWitnessH(canvas, cx + w / 2, cx + w / 2 + 16, cy - h / 2);
        _drawWitnessH(canvas, cx + w / 2, cx + w / 2 + 16, cy + h / 2);

        // Width dimension at the bottom
        _drawArrowH(canvas, cx - w / 2, cx + w / 2, cy - h / 2 - 12);
        _drawWitnessV(canvas, cx - w / 2, cy - h / 2 - 16, cy - h / 2);
        _drawWitnessV(canvas, cx + w / 2, cy - h / 2 - 16, cy - h / 2);
        break;

      case 'round_bar':
        const r = 44.0;
        canvas.setFillColor(PdfColor.fromHex('0D5C9D'));
        canvas.drawEllipse(cx, cy, r, r);
        canvas.fillPath();

        canvas
          ..setStrokeColor(PdfColor.fromHex('BDC3C7'))
          ..setLineWidth(0.8)
          ..drawEllipse(cx, cy, r, r)
          ..strokePath();

        // Centerlines
        canvas
          ..setStrokeColor(centerlineColor)
          ..setLineWidth(0.6)
          ..moveTo(cx - r - 12, cy)
          ..lineTo(cx + r + 12, cy)
          ..moveTo(cx, cy - r - 12)
          ..lineTo(cx, cy + r + 12)
          ..strokePath();

        // Diameter arrow at bottom
        canvas
          ..setStrokeColor(accentColor)
          ..setLineWidth(0.8);
        _drawArrowH(canvas, cx - r, cx + r, cy - r - 12);
        _drawWitnessV(canvas, cx - r, cy - r - 16, cy - r);
        _drawWitnessV(canvas, cx + r, cy - r - 16, cy - r);
        break;

      default:
        // Flat Bar - 2D Cross-section
        const w = 130.0;
        const h = 32.0;
        canvas.setFillColor(PdfColor.fromHex('0D5C9D'));
        canvas.drawRect(cx - w / 2, cy - h / 2, w, h);
        canvas.fillPath();

        canvas
          ..setStrokeColor(PdfColor.fromHex('BDC3C7'))
          ..setLineWidth(0.8)
          ..drawRect(cx - w / 2, cy - h / 2, w, h)
          ..strokePath();

        // Dimension markings
        canvas
          ..setStrokeColor(accentColor)
          ..setLineWidth(0.8);
        _drawArrowH(canvas, cx - w / 2, cx + w / 2, cy - h / 2 - 12);
        _drawWitnessV(canvas, cx - w / 2, cy - h / 2 - 16, cy - h / 2);
        _drawWitnessV(canvas, cx + w / 2, cy - h / 2 - 16, cy - h / 2);

        _drawArrowV(canvas, cx + w / 2 + 12, cy - h / 2, cy + h / 2);
        _drawWitnessH(canvas, cx + w / 2, cx + w / 2 + 16, cy - h / 2);
        _drawWitnessH(canvas, cx + w / 2, cx + w / 2 + 16, cy + h / 2);
        break;
    }
  }

  static void _drawArrowV(PdfGraphics canvas, double x, double y1, double y2) {
    canvas
      ..moveTo(x, y1)
      ..lineTo(x, y2)
      ..moveTo(x - 3.0, y1 + 4.5)
      ..lineTo(x, y1)
      ..lineTo(x + 3.0, y1 + 4.5)
      ..moveTo(x - 3.0, y2 - 4.5)
      ..lineTo(x, y2)
      ..lineTo(x + 3.0, y2 - 4.5)
      ..strokePath();
  }

  static void _drawArrowH(PdfGraphics canvas, double x1, double x2, double y) {
    canvas
      ..moveTo(x1, y)
      ..lineTo(x2, y)
      ..moveTo(x1 + 4.5, y - 3.0)
      ..lineTo(x1, y)
      ..lineTo(x1 + 4.5, y + 3.0)
      ..moveTo(x2 - 4.5, y - 3.0)
      ..lineTo(x2, y)
      ..lineTo(x2 - 4.5, y + 3.0)
      ..strokePath();
  }

  static void _drawWitnessH(PdfGraphics canvas, double x1, double x2, double y) {
    canvas
      ..moveTo(x1, y)
      ..lineTo(x2, y)
      ..strokePath();
  }

  static void _drawWitnessV(PdfGraphics canvas, double x, double y1, double y2) {
    canvas
      ..moveTo(x, y1)
      ..lineTo(x, y2)
      ..strokePath();
  }
}
