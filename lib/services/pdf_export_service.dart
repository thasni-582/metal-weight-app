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
import 'package:metal_weight/models/profile_spec.dart';

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

    final details = item?.details ?? {};
    final directW = details['width']?.toString().trim() ?? '';
    final directH = details['height']?.toString().trim() ?? '';
    final directT = details['thickness']?.toString().trim() ?? '';
    final directD = details['outerDia']?.toString().trim() ?? '';
    final directTw = details['webThickness']?.toString().trim() ?? '';
    final directTf = details['flangeThickness']?.toString().trim() ?? '';

    String hStr = '';
    String bStr = '';
    String twStr = '';
    String tfStr = '';
    String tStr = '';
    String dStr = '';

    switch (shapeCategory) {
      case 'beam':
        if (directH.isNotEmpty && directW.isNotEmpty) {
          hStr = directH;
          bStr = directW;
          twStr = directTw.isNotEmpty ? directTw : '6.0';
          tfStr = directTf.isNotEmpty ? directTf : '10.0';
        } else {
          final rawSize = item?.details['size']?.toString().trim() ?? '';
          final rawVariant = item?.details['variant']?.toString().trim().toUpperCase() ?? '';

          StandardProfileSpec? spec;
          if (rawVariant == 'UC' && StandardData.ucBeams.containsKey(rawSize)) {
            spec = StandardData.ucBeams[rawSize];
          } else if (rawVariant == 'UB' && StandardData.ubBeams.containsKey(rawSize)) {
            spec = StandardData.ubBeams[rawSize];
          } else if (StandardData.clientIBeams.containsKey(rawSize)) {
            spec = StandardData.clientIBeams[rawSize];
          } else if (StandardData.clientHBeams.containsKey(rawSize)) {
            spec = StandardData.clientHBeams[rawSize];
          } else if (StandardData.wBeams.containsKey(rawSize)) {
            spec = StandardData.wBeams[rawSize];
          } else if (StandardData.findWBeam(rawSize) != null) {
            spec = StandardData.findWBeam(rawSize);
          } else if (StandardData.ucBeams.containsKey(rawSize)) {
            spec = StandardData.ucBeams[rawSize];
          } else if (StandardData.ubBeams.containsKey(rawSize)) {
            spec = StandardData.ubBeams[rawSize];
          } else if (StandardData.ipeAaBeams.containsKey(rawSize)) {
            spec = StandardData.ipeAaBeams[rawSize];
          } else if (StandardData.heaBeams.containsKey(rawSize)) {
            spec = StandardData.heaBeams[rawSize];
          } else if (StandardData.findHeaBeam(rawSize) != null) {
            spec = StandardData.findHeaBeam(rawSize);
          } else if (StandardData.hebBeams.containsKey(rawSize)) {
            spec = StandardData.hebBeams[rawSize];
          } else if (StandardData.ipeBeams.containsKey(rawSize)) {
            spec = StandardData.ipeBeams[rawSize];
          } else if (StandardData.jisBeams.containsKey(rawSize)) {
            spec = StandardData.jisBeams[rawSize];
          }

          // Search in catalogs if not directly matched by rawSize
          if (spec == null) {
            final isUB = combined.toUpperCase().contains('UB') && !combined.toUpperCase().contains('UC');
            final isUC = combined.toUpperCase().contains('UC') && !combined.toUpperCase().contains('UB');
            if (isUC) {
              for (final entry in StandardData.ucBeams.entries) {
                if (combined.contains(entry.key)) {
                  spec = entry.value;
                  break;
                }
              }
            } else if (isUB) {
              for (final entry in StandardData.ubBeams.entries) {
                if (combined.contains(entry.key)) {
                  spec = entry.value;
                  break;
                }
              }
            }
            if (spec == null) {
              spec = StandardData.findWBeam(rawSize) ??
                  StandardData.findWBeam(combined) ??
                  StandardData.findHeaBeam(rawSize) ??
                  StandardData.findHeaBeam(combined);
            }
          }

          if (spec != null) {
            hStr = spec.h.toStringAsFixed(spec.h % 1 == 0 ? 0 : 1);
            bStr = spec.b.toStringAsFixed(spec.b % 1 == 0 ? 0 : 1);
            twStr = spec.tw.toStringAsFixed(1);
            tfStr = spec.tf.toStringAsFixed(1);
          } else {
            final matchSize = RegExp(r'\b(80|100|120|140|160|180|200|220|240|260|280|300|320|330|340|360|400|450|500|550|600|650|700|800|900|1000)\b')
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
          }
        }
        break;

      case 'channel':
        if (directH.isNotEmpty && directW.isNotEmpty) {
          hStr = directH;
          bStr = directW;
          twStr = directTw.isNotEmpty ? directTw : '6.0';
          tfStr = directTf.isNotEmpty ? directTf : '10.0';
        } else {
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
        }
        break;

      case 'angle':
        if (directW.isNotEmpty && directH.isNotEmpty) {
          bStr = directW;
          hStr = directH;
          tStr = directT.isNotEmpty ? directT : '5.0';
        } else {
          final rawSize = item?.details['size']?.toString().trim() ?? '';
          final rawThick = item?.details['thickness']?.toString().trim() ?? '';
          final fullDimStr = '$dims $subtitle $title';

          // Check for 3-part dimensions (e.g. "30x20 x 3" or "50x50x5")
          final match3 = RegExp(r'(\d+)\s*[xX*×]\s*(\d+)\s*[xX*×]\s*[tT]?\s*(\d+(?:\.\d+)?)').firstMatch(fullDimStr);
          final match2 = RegExp(r'(\d+)\s*[xX*×]\s*(\d+)').firstMatch(rawSize.isNotEmpty ? rawSize : fullDimStr);

          if (match3 != null) {
            hStr = match3.group(1)!;
            bStr = match3.group(2)!;
            tStr = match3.group(3)!;
          } else if (match2 != null) {
            hStr = match2.group(1)!;
            bStr = match2.group(2)!;
            tStr = rawThick.isNotEmpty ? rawThick : '5.0';
          } else {
            final mSingle = RegExp(r'\b(\d+)\b').firstMatch(rawSize.isNotEmpty ? rawSize : combined);
            final val = mSingle != null ? mSingle.group(1)! : '50';
            hStr = val;
            bStr = val;
            tStr = rawThick.isNotEmpty ? rawThick : '5.0';
          }
        }
        break;

      case 'tube':
        if (directW.isNotEmpty && directH.isNotEmpty) {
          bStr = directW;
          hStr = directH;
          tStr = directT.isNotEmpty ? directT : '1.2';
        } else {
          final rawSize = item?.details['size']?.toString().trim() ?? '';
          final rawThick = item?.details['thickness']?.toString().trim() ?? '';
          final fullDimStr = '$dims $subtitle $title';
          final match3 = RegExp(r'(\d+(?:\.\d+)?)\s*[xX*×]\s*(\d+(?:\.\d+)?)\s*[xX*×]\s*[tT]?\s*(\d+(?:\.\d+)?)')
              .firstMatch(fullDimStr);
          final match2 = RegExp(r'(\d+(?:\.\d+)?)\s*[xX*×]\s*(\d+(?:\.\d+)?)')
              .firstMatch(rawSize.isNotEmpty ? rawSize : fullDimStr);

          if (match3 != null) {
            // Calculator format "W x H x tT x L..." has width first, height second
            if (dims.contains('t') || dims.contains('L')) {
              bStr = match3.group(1)!;
              hStr = match3.group(2)!;
            } else {
              hStr = match3.group(1)!;
              bStr = match3.group(2)!;
            }
            tStr = match3.group(3)!;
          } else if (match2 != null) {
            if (dims.contains('t') || dims.contains('L')) {
              bStr = match2.group(1)!;
              hStr = match2.group(2)!;
            } else {
              hStr = match2.group(1)!;
              bStr = match2.group(2)!;
            }
            final matchT = RegExp(r'[tT]\s*(\d+(?:\.\d+)?)').firstMatch(fullDimStr);
            tStr = rawThick.isNotEmpty
                ? rawThick
                : (matchT != null ? matchT.group(1)! : '1.2');
          } else {
            hStr = '50';
            bStr = '50';
            tStr = rawThick.isNotEmpty ? rawThick : '1.2';
          }
        }
        break;

      case 'pipe':
        if (directD.isNotEmpty) {
          dStr = directD;
          tStr = directT.isNotEmpty ? directT : '3.91';
        } else {
          final rawSize = item?.details['size']?.toString().trim() ?? '';
          final rawThick = item?.details['thickness']?.toString().trim() ?? '';

          if (rawSize.contains('(') && rawSize.contains('mm')) {
            final start = rawSize.indexOf('(') + 1;
            final end = rawSize.indexOf('mm');
            dStr = rawSize.substring(start, end).trim();
          } else {
            final mDia = RegExp(r'[ØOODod]\s*(\d+(?:\.\d+)?)').firstMatch('$rawSize $dims $subtitle');
            dStr = mDia != null ? mDia.group(1)! : '60.3';
          }

          if (rawThick.contains('(') && rawThick.contains('mm')) {
            final start = rawThick.indexOf('(') + 1;
            final end = rawThick.indexOf('mm');
            tStr = rawThick.substring(start, end).trim();
          } else {
            final mThick = RegExp(r'[tT]\s*(\d+(?:\.\d+)?)').firstMatch('$rawThick $dims $subtitle');
            tStr = mThick != null ? mThick.group(1)! : (rawThick.isNotEmpty ? rawThick : '3.91');
          }
        }
        break;

      case 'sheet':
        if (directW.isNotEmpty && directT.isNotEmpty) {
          bStr = directW;
          tStr = directT;
        } else {
          final rawSize = item?.details['size']?.toString().trim() ?? '';
          final rawThick = item?.details['thickness']?.toString().trim() ?? '';
          final match3 = RegExp(r'(\d+)\s*[xX*×]\s*(\d+)\s*[xX*×]\s*[tT]?\s*(\d+(?:\.\d+)?)').firstMatch(dims);
          if (match3 != null) {
            bStr = match3.group(2)!;
            tStr = match3.group(3)!;
          } else {
            final mDim = RegExp(r'(\d+)\s*[xX*×]\s*(\d+)').firstMatch(rawThick.isNotEmpty ? rawThick : dims);
            bStr = mDim != null ? mDim.group(1)! : '1000';
            final mThick = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(rawSize.isNotEmpty ? rawSize : subtitle);
            tStr = mThick != null ? mThick.group(1)! : '2.0';
          }
        }
        break;

      case 'flat_bar':
        if (directW.isNotEmpty && directT.isNotEmpty) {
          bStr = directW;
          tStr = directT;
        } else {
          final rawSize = item?.details['size']?.toString().trim() ?? '';
          final rawThick = item?.details['thickness']?.toString().trim() ?? '';
          if (rawSize.isNotEmpty && rawThick.isNotEmpty) {
            bStr = rawSize;
            tStr = rawThick;
          } else {
            final match3 = RegExp(r'(\d+)\s*[xX*×]\s*(\d+)\s*[xX*×]\s*[tT]?\s*(\d+(?:\.\d+)?)').firstMatch(dims);
            if (match3 != null) {
              bStr = match3.group(2)!;
              tStr = match3.group(3)!;
            } else {
              final match = RegExp(r'(\d+)\s*[xX*×]\s*(\d+(?:\.\d+)?)').firstMatch('$dims $subtitle $title');
              if (match != null) {
                bStr = match.group(1)!;
                tStr = match.group(2)!;
              } else {
                bStr = '50';
                tStr = '6';
              }
            }
          }
        }
        break;

      case 'round_bar':
        if (directD.isNotEmpty) {
          dStr = directD;
        } else {
          final rawSize = item?.details['size']?.toString().trim() ?? '';
          if (rawSize.isNotEmpty) {
            dStr = rawSize;
          } else {
            final match = RegExp(r'[Ø\b](\d+(?:\.\d+)?)').firstMatch('$dims $subtitle $title');
            dStr = match != null ? match.group(1)! : '25';
          }
        }
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
        final rawVar = item?.details['variant']?.toString().trim().toUpperCase() ?? '';
        final titleUpper = '${item?.title ?? ''} ${item?.subtitle ?? ''}'.toUpperCase();
        String beamVariant = 'I';
        if (rawVar == 'UC' || titleUpper.contains(' UC ') || titleUpper.endsWith(' UC')) {
          beamVariant = 'UC';
        } else if (rawVar == 'UB' || titleUpper.contains(' UB ') || titleUpper.endsWith(' UB')) {
          beamVariant = 'UB';
        } else if (rawVar == 'HEA' || titleUpper.contains('HEA')) {
          beamVariant = 'HEA';
        } else if (rawVar == 'HEB' || titleUpper.contains('HEB')) {
          beamVariant = 'HEB';
        } else if (rawVar == 'IPE-AA' || titleUpper.contains('IPE-AA')) {
          beamVariant = 'IPE-AA';
        } else if (rawVar == 'IPE' || (titleUpper.contains('IPE') && !titleUpper.contains('IPE-AA') && !titleUpper.contains('I-BEAM'))) {
          beamVariant = 'IPE';
        } else if (rawVar == 'I' || titleUpper.contains('I-BEAM')) {
          beamVariant = 'I';
        } else if (rawVar == 'H' || titleUpper.contains('H-BEAM') || titleUpper.contains('JIS')) {
          beamVariant = 'H';
        } else if (titleUpper.contains('W-BEAM') || titleUpper.contains('WIDE FLANGE')) {
          beamVariant = 'W-BEAM';
        } else {
          final double hCheck = double.tryParse(dims['h'] ?? '') ?? 0.0;
          final double bCheck = double.tryParse(dims['b'] ?? '') ?? 0.0;
          beamVariant = (hCheck > 0 && bCheck > 0 && (bCheck / hCheck) >= 0.70) ? 'H' : 'I';
        }

        final double hParsed = double.tryParse(dims['h'] ?? '') ?? 0.0;
        final double bParsed = double.tryParse(dims['b'] ?? '') ?? 0.0;
        final double beamAspect = (hParsed > 0 && bParsed > 0)
            ? (bParsed / hParsed)
            : ((beamVariant == 'UC' || beamVariant == 'HEA' || beamVariant == 'HEB') ? 1.0 : 0.55);
        final isHBeam = beamAspect >= 0.70;

        // Profile label inside left pocket (matching App 2D blueprint)
        final String pocketBadgeText = (beamVariant == 'W-BEAM' || beamVariant == 'W-Beam') ? 'W' : beamVariant;
        final double pocketLeft = isHBeam ? 88.0 : 100.0;
        final double pocketWidth = isHBeam ? 44.0 : 33.0;
        final double pocketFontSize = pocketBadgeText == 'W'
            ? 14.0
            : (pocketBadgeText.length <= 2
                ? 12.0
                : (pocketBadgeText.length <= 3
                    ? (isHBeam ? 12.0 : 10.5)
                    : 8.0));
        badges.add(
          pw.Positioned(
            left: pocketLeft,
            top: 72.0,
            child: pw.Container(
              width: pocketWidth,
              alignment: pw.Alignment.center,
              child: pw.Text(
                pocketBadgeText,
                maxLines: 1,
                style: pw.TextStyle(
                  fontSize: pocketFontSize,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('1E293B'),
                ),
              ),
            ),
          ),
        );

        final double hBadgeX = isHBeam ? 212.0 : 200.0;
        if (dims['h']!.isNotEmpty) {
          badges.add(pw.Positioned(left: hBadgeX, top: 73.0, child: _buildPdfDimBadge(dims['h']!)));
        }
        if (dims['b']!.isNotEmpty) {
          badges.add(pw.Positioned(left: 120.0, top: 137.0, child: _buildPdfDimBadge(dims['b']!)));
        }
        if (dims['tf']!.isNotEmpty) {
          badges.add(pw.Positioned(left: 46.0, top: 27.0, child: _buildPdfDimBadge(dims['tf']!)));
        }
        final double twBadgeX = isHBeam ? 160.0 : 150.0;
        if (dims['tw']!.isNotEmpty) {
          badges.add(pw.Positioned(left: twBadgeX, top: 51.0, child: _buildPdfDimBadge(dims['tw']!)));
        }
        break;

      case 'channel':
        if (dims['h']!.isNotEmpty) {
          badges.add(pw.Positioned(left: 170.0, top: 73.0, child: _buildPdfDimBadge(dims['h']!)));
        }
        if (dims['b']!.isNotEmpty) {
          badges.add(pw.Positioned(left: 125.0, top: 140.0, child: _buildPdfDimBadge(dims['b']!)));
        }
        if (dims['tf']!.isNotEmpty) {
          badges.add(pw.Positioned(left: 130.0, top: 48.0, child: _buildPdfDimBadge(dims['tf']!)));
        }
        if (dims['tw']!.isNotEmpty) {
          badges.add(pw.Positioned(left: 128.0, top: 88.0, child: _buildPdfDimBadge(dims['tw']!)));
        }
        break;

      case 'angle':
        final itemStr = (item?.title ?? '').toUpperCase();
        final bool isUnequal = itemStr.contains('UNEQUAL');
        if (isUnequal) {
          if (dims['h']!.isNotEmpty) {
            badges.add(pw.Positioned(left: 46.0, top: 73.0, child: _buildPdfDimBadge(dims['h']!)));
          }
          if (dims['b']!.isNotEmpty) {
            badges.add(pw.Positioned(left: 120.0, top: 130.0, child: _buildPdfDimBadge(dims['b']!)));
          }
          if (dims['t']!.isNotEmpty) {
            badges.add(pw.Positioned(left: 118.0, top: 77.0, child: _buildPdfDimBadge(dims['t']!)));
          }
        } else {
          if (dims['h']!.isNotEmpty) {
            badges.add(pw.Positioned(left: 46.0, top: 73.0, child: _buildPdfDimBadge(dims['h']!)));
          }
          if (dims['t']!.isNotEmpty) {
            badges.add(pw.Positioned(left: 198.0, top: 98.0, child: _buildPdfDimBadge(dims['t']!)));
          }
        }
        break;

      case 'tube':
        final double dimH = double.tryParse(dims['h'] ?? '80') ?? 80.0;
        final double dimW = double.tryParse(dims['b'] ?? '40') ?? 40.0;
        final bool isRectangular = (dimH - dimW).abs() > 1.0;
        double w;
        double h;
        if (isRectangular) {
          if (dimW >= dimH) {
            w = 100.0;
            h = (w * (dimH / (dimW > 0 ? dimW : 1.0))).clamp(40.0, 75.0);
          } else {
            h = 100.0;
            w = (h * (dimW / (dimH > 0 ? dimH : 1.0))).clamp(40.0, 75.0);
          }
        } else {
          w = 80.0;
          h = 80.0;
        }

        if (dims['h']!.isNotEmpty) {
          badges.add(pw.Positioned(left: 150.0 + w / 2 + 15.0, top: 73.0, child: _buildPdfDimBadge(dims['h']!)));
        }
        if (dims['b']!.isNotEmpty) {
          badges.add(pw.Positioned(left: 150.0 - 20.0, top: (85.0 + h / 2 + 13.0).clamp(115.0, 150.0), child: _buildPdfDimBadge(dims['b']!)));
        }
        if (dims['t']!.isNotEmpty) {
          badges.add(pw.Positioned(left: 150.0 - w / 2 - 46.0, top: 73.0, child: _buildPdfDimBadge('t=${dims['t']}')));
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
          badges.add(pw.Positioned(left: 232.0, top: 73.0, child: _buildPdfDimBadge('t=${dims['t']} mm')));
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
      final rawVar = details['variant']?.toString().trim().toUpperCase() ?? '';
      if (rawVar == 'UC') {
        variantStr = 'UC';
      } else if (rawVar == 'UB') {
        variantStr = 'UB';
      } else if (rawVar == 'I' || shape.contains('I-BEAM')) {
        variantStr = 'I-Beam (JIS)';
      } else if (rawVar == 'H' || shape.contains('H-BEAM') || shape.contains('JIS')) {
        variantStr = 'H-Beam (JIS)';
      } else if (shape.contains('HEA')) {
        variantStr = 'HEA';
      } else if (shape.contains('HEB')) {
        variantStr = 'HEB';
      } else if (shape.contains('IPE-AA')) {
        variantStr = 'IPE-AA';
      } else if (shape.contains('IPE')) {
        variantStr = 'IPE';
      } else if (shape.contains('W-BEAM') || shape.contains('WIDE FLANGE')) {
        variantStr = 'W-BEAM';
      } else if (shape.contains('UC') && !shape.contains('UB')) {
        variantStr = 'UC';
      } else if (shape.contains('UB') && !shape.contains('UC')) {
        variantStr = 'UB';
      } else {
        variantStr = 'BEAM';
      }
    } else if (shapeCategory == 'channel') {
      if (shape.contains('JIS')) {
        variantStr = 'JIS';
      } else if (shape.contains('UPE')) {
        variantStr = 'UPE';
      } else {
        variantStr = 'UPN';
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
    // Extract size: take the primary segment before '|' (which separates length/pieces)
    final String primaryPart = dimStr.split('|').first.trim();
    String sizeStr = primaryPart;
    if (sizeStr.contains('(')) {
      sizeStr = sizeStr.split('(').first.trim();
    } else if (sizeStr.contains('x L')) {
      sizeStr = sizeStr.split('x L').first.trim();
    } else if (sizeStr.contains('x') &&
        !shapeCategory.contains('tube') &&
        !shapeCategory.contains('angle') &&
        !shapeCategory.contains('flat') &&
        !shapeCategory.contains('beam')) {
      sizeStr = sizeStr.split('x').first.trim();
    }
    if (sizeStr.isEmpty) sizeStr = 'STD';

    double wVal = 0.0;
    if (details['unitWeightPerM'] != null) {
      final m = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(details['unitWeightPerM'].toString());
      if (m != null) wVal = double.tryParse(m.group(1)!) ?? 0.0;
    }
    if (wVal <= 0.0 && details['unitWeight'] != null) {
      final m = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(details['unitWeight'].toString());
      if (m != null) wVal = double.tryParse(m.group(1)!) ?? 0.0;
    }
    if (wVal <= 0.0) {
      double totalPieceW = 0.0;
      if (details['weightPerPiece'] != null) {
        final m = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(details['weightPerPiece'].toString());
        if (m != null) totalPieceW = double.tryParse(m.group(1)!) ?? 0.0;
      }
      if (totalPieceW <= 0.0) {
        final m = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(item.weight);
        if (m != null) totalPieceW = double.tryParse(m.group(1)!) ?? 0.0;
      }

      double lengthInM = 0.0;
      if (details['length'] != null) {
        final lenVal = double.tryParse(details['length'].toString()) ?? 0.0;
        if (lenVal > 0) lengthInM = lenVal > 100 ? lenVal / 1000.0 : lenVal;
      }
      if (lengthInM <= 0.0) {
        final matchL = RegExp(r'[xX]\s*L\s*(\d+(?:\.\d+)?)').firstMatch(dimStr);
        if (matchL != null) {
          final lenVal = double.tryParse(matchL.group(1)!) ?? 0.0;
          if (lenVal > 0) lengthInM = lenVal > 100 ? lenVal / 1000.0 : lenVal;
        }
      }

      if (lengthInM > 0.0 && totalPieceW > 0.0) {
        wVal = totalPieceW / lengthInM;
      } else {
        wVal = totalPieceW;
      }
    }
    final String weightStr = wVal.toStringAsFixed(2);
    final String weightUnit = shapeCategory == 'sheet' ? 'Kg/m2' : 'Kg/m';

    // Section area cm2 - extract direct catalog specification from details first to match app exactly
    String sectionAreaStr = '';
    if (details['sectionArea'] != null) {
      final m = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(details['sectionArea'].toString());
      if (m != null) {
        sectionAreaStr = double.tryParse(m.group(1)!)?.toStringAsFixed(2) ?? '';
      }
    }
    if (sectionAreaStr.isEmpty) {
      if (wVal > 0.0) {
        sectionAreaStr = (wVal / 0.785).toStringAsFixed(2);
      }
    }

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('F1F5F9'),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        border: pw.Border.all(color: PdfColor.fromHex('CBD5E1'), width: 0.8),
      ),
      child: pw.Column(
        children: [
          if (!(shapeCategory == 'angle' && !shape.contains('UNEQUAL'))) ...[
            _buildSpecRow(variantStr, sizeStr, 'Standard'),
            pw.SizedBox(height: 3),
          ],
          _buildSpecRow('weight', weightStr, weightUnit),
          pw.SizedBox(height: 3),
          _buildSpecRow('section', sectionAreaStr, 'cm2'),
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
        final rawVar = item?.details['variant']?.toString().trim().toUpperCase() ?? '';
        final titleUpper = '${item?.title ?? ''} ${item?.subtitle ?? ''} ${item?.iconName ?? ''}'.toUpperCase();
        final double hVal = (item?.details['height'] is num)
            ? (item!.details['height'] as num).toDouble()
            : (double.tryParse(item?.details['height']?.toString() ?? '') ?? 0.0);
        final double bVal = (item?.details['width'] is num)
            ? (item!.details['width'] as num).toDouble()
            : (double.tryParse(item?.details['width']?.toString() ?? '') ?? 0.0);
        final double rawAspect = (hVal > 0 && bVal > 0)
            ? (bVal / hVal)
            : ((rawVar == 'UC' || rawVar == 'HEA' || rawVar == 'HEB') ? 1.0 : 0.55);
        final isHBeam = rawAspect >= 0.70;
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

        // Dimension markings matching engineering slide rule standard
        canvas
          ..setStrokeColor(accentColor)
          ..setLineWidth(0.8);

        // Height arrow on the right
        _drawArrowV(canvas, left + w + 12, cy - h / 2, cy + h / 2);
        _drawWitnessH(canvas, left + w, left + w + 16, cy - h / 2);
        _drawWitnessH(canvas, left + w, left + w + 16, cy + h / 2);

        // Width arrow at the bottom
        _drawArrowH(canvas, left, left + w, cy - h / 2 - 12);
        _drawWitnessV(canvas, left, cy - h / 2 - 16, cy - h / 2);
        _drawWitnessV(canvas, left + w, cy - h / 2 - 16, cy - h / 2);

        // Flange thickness opposing arrows (top flange)
        final double flangeX = left + tw + (w - tw) * 0.55;
        canvas
          ..moveTo(flangeX, cy + h / 2 + 10)
          ..lineTo(flangeX, cy + h / 2)
          ..moveTo(flangeX - 2.5, cy + h / 2 + 3.5)
          ..lineTo(flangeX, cy + h / 2)
          ..lineTo(flangeX + 2.5, cy + h / 2 + 3.5)
          ..strokePath();
        canvas
          ..moveTo(flangeX, cy + h / 2 - tf - 10)
          ..lineTo(flangeX, cy + h / 2 - tf)
          ..moveTo(flangeX - 2.5, cy + h / 2 - tf - 3.5)
          ..lineTo(flangeX, cy + h / 2 - tf)
          ..lineTo(flangeX + 2.5, cy + h / 2 - tf - 3.5)
          ..strokePath();

        // Web thickness pointer (inward horizontal arrows across web)
        final double webY = cy - 14.0;
        _drawArrowH(canvas, left - 10, left, webY);
        _drawArrowH(canvas, left + tw + 10, left + tw, webY);
        break;

      case 'angle':
        final itemStr = '${item?.title ?? ''} ${item?.details['shape'] ?? ''}'.toLowerCase();
        final bool isUnequal = itemStr.contains('unequal');
        final angleDims = _extractProfileDimensions(item, 'angle');
        final double hVal = double.tryParse(angleDims['h'] ?? '30') ?? 30.0;
        final double bVal = double.tryParse(angleDims['b'] ?? '20') ?? 20.0;
        final double rawAspect = bVal / (hVal > 0 ? hVal : 30.0);
        final double legA = isUnequal ? 104.0 : 90.0;
        final double legB = isUnequal
            ? (legA * rawAspect.clamp(0.40, 0.90)).clamp(48.0, 80.0)
            : 90.0;
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
        _drawWitnessH(canvas, left - 16, left, bottom);
        _drawWitnessH(canvas, left - 16, left, bottom + legA);

        if (isUnequal) {
          _drawArrowH(canvas, left, left + legB, bottom - 12);
          _drawWitnessV(canvas, left, bottom - 16, bottom);
          _drawWitnessV(canvas, left + legB, bottom - 16, bottom);
          _drawArrowH(canvas, left + t / 2, left + t + 16, bottom + legA * 0.45);
        } else {
          // Equal Angle: Right thickness inward-pointing arrows
          _drawWitnessH(canvas, left + legB, left + legB + 16, bottom);
          _drawWitnessH(canvas, left + legB, left + legB + 16, bottom + t);
          _drawArrowV(canvas, left + legB + 10, bottom + t + 10, bottom + t);
          _drawArrowV(canvas, left + legB + 10, bottom - 10, bottom);
        }
        break;

      case 'tube':
        final dims = _extractProfileDimensions(item, 'tube');
        final double dimH = double.tryParse(dims['h'] ?? '80') ?? 80.0;
        final double dimW = double.tryParse(dims['b'] ?? '40') ?? 40.0;
        final bool isRectangular = (dimH - dimW).abs() > 1.0;

        double w;
        double h;
        if (isRectangular) {
          if (dimW >= dimH) {
            // Horizontal rectangular tube (e.g. 500 x 100)
            w = 100.0;
            h = (w * (dimH / (dimW > 0 ? dimW : 1.0))).clamp(40.0, 75.0);
          } else {
            // Vertical rectangular tube (e.g. 40 x 20 or 100 x 50)
            h = 100.0;
            w = (h * (dimW / (dimH > 0 ? dimH : 1.0))).clamp(40.0, 75.0);
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
