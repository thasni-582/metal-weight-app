import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:metal_weight/core/constants/app_colors.dart';

/// Accurate, interactive 2D engineering cross-section diagram for custom calculator shapes.
class CustomShape2DDiagram extends StatelessWidget {
  final String shape;
  final String unitDim; // 'mm' or 'in'
  final String lengthStr;
  final String widthStr;
  final String thicknessStr;
  final String outerDiaStr;
  final String heightStr;
  final String webThickStr;
  final String flangeThickStr;

  const CustomShape2DDiagram({
    super.key,
    required this.shape,
    required this.unitDim,
    required this.lengthStr,
    required this.widthStr,
    required this.thicknessStr,
    required this.outerDiaStr,
    required this.heightStr,
    required this.webThickStr,
    required this.flangeThickStr,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            color: AppColors.blueprintBlue,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    shape.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.7,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    '2D CROSS-SECTION',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2D Canvas Area
          SizedBox(
            height: 205,
            width: double.infinity,
            child: CustomPaint(
              size: const Size(double.infinity, 205),
              painter: _ShapeDiagramPainter(
                shape: shape,
                unit: unitDim,
                width: widthStr.isNotEmpty ? widthStr : '500',
                thickness: thicknessStr.isNotEmpty ? thicknessStr : '12',
                outerDia: outerDiaStr.isNotEmpty ? outerDiaStr : '50',
                height: heightStr.isNotEmpty ? heightStr : '100',
                webThick: webThickStr.isNotEmpty ? webThickStr : '6',
                flangeThick: flangeThickStr.isNotEmpty ? flangeThickStr : '8',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShapeDiagramPainter extends CustomPainter {
  final String shape;
  final String unit;
  final String width;
  final String thickness;
  final String outerDia;
  final String height;
  final String webThick;
  final String flangeThick;

  _ShapeDiagramPainter({
    required this.shape,
    required this.unit,
    required this.width,
    required this.thickness,
    required this.outerDia,
    required this.height,
    required this.webThick,
    required this.flangeThick,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Subtle grid background
    _drawGridBackground(canvas, size);

    switch (shape) {
      case 'Sheet / Plate':
      case 'Flat Bar':
        _drawPlateOrFlatBar(canvas, size);
        break;
      case 'Round Bar':
        _drawRoundBar(canvas, size);
        break;
      case 'Square Bar':
        _drawSquareBar(canvas, size);
        break;
      case 'Hexagonal Bar':
        _drawHexagon(canvas, size);
        break;
      case 'Round Tube / Pipe':
        _drawRoundTube(canvas, size);
        break;
      case 'Square / Rectangular Tube':
        _drawRectangularTube(canvas, size);
        break;
      case 'Angle (L-Profile)':
        _drawAngle(canvas, size);
        break;
      case 'U-Channel / Channel (C-Profile)':
      case 'Channel (C-Profile)':
        _drawChannel(canvas, size);
        break;
      case 'I-Beam / H-Beam':
        _drawIBeam(canvas, size);
        break;
      default:
        _drawPlateOrFlatBar(canvas, size);
    }
  }

  void _drawGridBackground(Canvas canvas, Size size) {
    final Paint bgPaint = Paint()..color = const Color(0xFFFAFCFF);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final Paint gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 0.5;

    const double step = 20.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  void _drawPlateOrFlatBar(Canvas canvas, Size size) {
    final Paint steelPaint = Paint()..color = AppColors.blueprintAccent;
    const double plateW = 165.0;
    const double plateH = 38.0;
    // Shift slightly left to balance the right thickness dimension line
    final double startX = (size.width - (plateW + 36.0)) / 2;
    final double startY = (size.height - (plateH + 28.0)) / 2;

    final Rect rect = Rect.fromLTWH(startX, startY, plateW, plateH);
    canvas.drawRect(rect, steelPaint);

    // Thickness dimension (Right)
    final double hDimX = startX + plateW + 20.0;
    _drawExtensionLine(canvas, Offset(startX + plateW, startY), Offset(hDimX + 8, startY));
    _drawExtensionLine(canvas, Offset(startX + plateW, startY + plateH), Offset(hDimX + 8, startY + plateH));
    _drawDimensionLine(
      canvas,
      Offset(hDimX, startY),
      Offset(hDimX, startY + plateH),
      't=$thickness $unit',
      isVertical: true,
    );

    // Width dimension (Bottom)
    final double bDimY = startY + plateH + 22.0;
    _drawExtensionLine(canvas, Offset(startX, startY + plateH), Offset(startX, bDimY + 8));
    _drawExtensionLine(canvas, Offset(startX + plateW, startY + plateH), Offset(startX + plateW, bDimY + 8));
    _drawDimensionLine(
      canvas,
      Offset(startX, bDimY),
      Offset(startX + plateW, bDimY),
      'W=$width $unit',
    );
  }

  void _drawRoundBar(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, (size.height - 24.0) / 2);
    const double radius = 50.0;

    final Paint steelPaint = Paint()..color = AppColors.blueprintAccent;
    canvas.drawCircle(center, radius, steelPaint);

    // Crosshairs
    final Paint crossPaint = Paint()
      ..color = Colors.white70
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(center.dx - radius - 10, center.dy), Offset(center.dx + radius + 10, center.dy), crossPaint);
    canvas.drawLine(Offset(center.dx, center.dy - radius - 10), Offset(center.dx, center.dy + radius + 10), crossPaint);

    // Diameter dimension
    final double dimY = center.dy + radius + 22.0;
    _drawExtensionLine(canvas, Offset(center.dx - radius, center.dy), Offset(center.dx - radius, dimY + 8));
    _drawExtensionLine(canvas, Offset(center.dx + radius, center.dy), Offset(center.dx + radius, dimY + 8));
    _drawDimensionLine(
      canvas,
      Offset(center.dx - radius, dimY),
      Offset(center.dx + radius, dimY),
      'Ø=$outerDia $unit',
    );
  }

  void _drawSquareBar(Canvas canvas, Size size) {
    const double side = 88.0;
    final double startX = (size.width - side) / 2;
    final double startY = (size.height - (side + 28.0)) / 2;

    final Paint steelPaint = Paint()..color = AppColors.blueprintAccent;
    canvas.drawRect(Rect.fromLTWH(startX, startY, side, side), steelPaint);

    // Width dimension
    final double dimY = startY + side + 22.0;
    _drawExtensionLine(canvas, Offset(startX, startY + side), Offset(startX, dimY + 8));
    _drawExtensionLine(canvas, Offset(startX + side, startY + side), Offset(startX + side, dimY + 8));
    _drawDimensionLine(
      canvas,
      Offset(startX, dimY),
      Offset(startX + side, dimY),
      'S=$width $unit',
    );
  }

  void _drawHexagon(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, (size.height - 24.0) / 2);
    const double r = 52.0;

    final Path path = Path();
    for (int i = 0; i < 6; i++) {
      final double angle = (i * 60) * math.pi / 180;
      final double x = center.dx + r * math.cos(angle);
      final double y = center.dy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    final Paint steelPaint = Paint()..color = AppColors.blueprintAccent;
    canvas.drawPath(path, steelPaint);

    // Across Flats dimension
    final double flatW = r * math.sqrt(3);
    final double dimY = center.dy + r + 20.0;
    _drawExtensionLine(canvas, Offset(center.dx - flatW / 2, center.dy + r), Offset(center.dx - flatW / 2, dimY + 8));
    _drawExtensionLine(canvas, Offset(center.dx + flatW / 2, center.dy + r), Offset(center.dx + flatW / 2, dimY + 8));
    _drawDimensionLine(
      canvas,
      Offset(center.dx - flatW / 2, dimY),
      Offset(center.dx + flatW / 2, dimY),
      'W=$width $unit',
    );
  }

  void _drawRoundTube(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2 - 14.0, (size.height - 24.0) / 2);
    const double outerR = 54.0;
    const double innerR = 38.0;

    final Path path = Path()
      ..addOval(Rect.fromCircle(center: center, radius: outerR))
      ..addOval(Rect.fromCircle(center: center, radius: innerR))
      ..fillType = PathFillType.evenOdd;

    final Paint steelPaint = Paint()..color = AppColors.blueprintAccent;
    canvas.drawPath(path, steelPaint);

    // Diameter
    final double dimY = center.dy + outerR + 22.0;
    _drawExtensionLine(canvas, Offset(center.dx - outerR, center.dy), Offset(center.dx - outerR, dimY + 8));
    _drawExtensionLine(canvas, Offset(center.dx + outerR, center.dy), Offset(center.dx + outerR, dimY + 8));
    _drawDimensionLine(
      canvas,
      Offset(center.dx - outerR, dimY),
      Offset(center.dx + outerR, dimY),
      'Ø=$outerDia $unit',
    );

    // Wall thickness callout
    _drawCallout(
      canvas,
      Offset(center.dx + (outerR + innerR) / 2, center.dy),
      Offset(center.dx + outerR + 26.0, center.dy - 22.0),
      't=$thickness $unit',
    );
  }

  void _drawRectangularTube(Canvas canvas, Size size) {
    final double wNum = double.tryParse(width) ?? 100.0;
    final double hNum = double.tryParse(height) ?? 100.0;

    double outerW;
    double outerH;
    if ((wNum - hNum).abs() <= 1.0) {
      outerW = 96.0;
      outerH = 96.0;
    } else if (wNum > hNum) {
      outerW = 125.0;
      outerH = (outerW * (hNum / (wNum > 0 ? wNum : 1.0))).clamp(50.0, 85.0);
    } else {
      outerH = 110.0;
      outerW = (outerH * (wNum / (hNum > 0 ? hNum : 1.0))).clamp(50.0, 85.0);
    }

    const double t = 14.0;
    // Shift slightly right to balance left height dimension line
    final double startX = (size.width - outerW) / 2 + 10.0;
    final double startY = (size.height - (outerH + 28.0)) / 2;

    final Path path = Path()
      ..addRect(Rect.fromLTWH(startX, startY, outerW, outerH))
      ..addRect(Rect.fromLTWH(startX + t, startY + t, outerW - 2 * t, outerH - 2 * t))
      ..fillType = PathFillType.evenOdd;

    final Paint steelPaint = Paint()..color = AppColors.blueprintAccent;
    canvas.drawPath(path, steelPaint);

    // Height dimension (Left)
    final double hDimX = startX - 20.0;
    _drawExtensionLine(canvas, Offset(startX, startY), Offset(hDimX - 8, startY));
    _drawExtensionLine(canvas, Offset(startX, startY + outerH), Offset(hDimX - 8, startY + outerH));
    _drawDimensionLine(
      canvas,
      Offset(hDimX, startY),
      Offset(hDimX, startY + outerH),
      'H=$height $unit',
      isVertical: true,
    );

    // Width dimension (Bottom)
    final double bDimY = startY + outerH + 22.0;
    _drawExtensionLine(canvas, Offset(startX, startY + outerH), Offset(startX, bDimY + 8));
    _drawExtensionLine(canvas, Offset(startX + outerW, startY + outerH), Offset(startX + outerW, bDimY + 8));
    _drawDimensionLine(
      canvas,
      Offset(startX, bDimY),
      Offset(startX + outerW, bDimY),
      'W=$width $unit',
    );

    // Wall thickness callout (Right)
    _drawCallout(
      canvas,
      Offset(startX + outerW - t / 2, startY + outerH / 2),
      Offset(startX + outerW + 26.0, startY + outerH / 2 - 20.0),
      't=$thickness $unit',
    );
  }

  void _drawAngle(Canvas canvas, Size size) {
    const double legA = 96.0;
    const double legB = 96.0;
    const double t = 16.0;
    final double startX = (size.width - legB) / 2 + 10.0;
    final double startY = (size.height - (legA + 28.0)) / 2;

    final Path path = Path()
      ..moveTo(startX, startY)
      ..lineTo(startX + t, startY)
      ..lineTo(startX + t, startY + legA - t)
      ..lineTo(startX + legB, startY + legA - t)
      ..lineTo(startX + legB, startY + legA)
      ..lineTo(startX, startY + legA)
      ..close();

    final Paint steelPaint = Paint()..color = AppColors.blueprintAccent;
    canvas.drawPath(path, steelPaint);

    // Height (Left)
    final double hDimX = startX - 20.0;
    _drawExtensionLine(canvas, Offset(startX, startY), Offset(hDimX - 8, startY));
    _drawExtensionLine(canvas, Offset(startX, startY + legA), Offset(hDimX - 8, startY + legA));
    _drawDimensionLine(
      canvas,
      Offset(hDimX, startY),
      Offset(hDimX, startY + legA),
      'H=$height $unit',
      isVertical: true,
    );

    // Width (Bottom)
    final double bDimY = startY + legA + 22.0;
    _drawExtensionLine(canvas, Offset(startX, startY + legA), Offset(startX, bDimY + 8));
    _drawExtensionLine(canvas, Offset(startX + legB, startY + legA), Offset(startX + legB, bDimY + 8));
    _drawDimensionLine(
      canvas,
      Offset(startX, bDimY),
      Offset(startX + legB, bDimY),
      'W=$width $unit',
    );

    // Thickness callout
    _drawCallout(
      canvas,
      Offset(startX + t / 2, startY + 28.0),
      Offset(startX + t + 28.0, startY + 20.0),
      't=$thickness $unit',
    );
  }

  void _drawChannel(Canvas canvas, Size size) {
    const double h = 100.0;
    const double b = 62.0;
    const double tw = 12.0;
    const double tf = 14.0;
    final double startX = (size.width - b) / 2 + 10.0;
    final double startY = (size.height - (h + 28.0)) / 2;

    final Path path = Path()
      ..moveTo(startX, startY)
      ..lineTo(startX + b, startY)
      ..lineTo(startX + b, startY + tf)
      ..lineTo(startX + tw, startY + tf)
      ..lineTo(startX + tw, startY + h - tf)
      ..lineTo(startX + b, startY + h - tf)
      ..lineTo(startX + b, startY + h)
      ..lineTo(startX, startY + h)
      ..close();

    final Paint steelPaint = Paint()..color = AppColors.blueprintAccent;
    canvas.drawPath(path, steelPaint);

    // Height (Left)
    final double hDimX = startX - 20.0;
    _drawExtensionLine(canvas, Offset(startX, startY), Offset(hDimX - 8, startY));
    _drawExtensionLine(canvas, Offset(startX, startY + h), Offset(hDimX - 8, startY + h));
    _drawDimensionLine(
      canvas,
      Offset(hDimX, startY),
      Offset(hDimX, startY + h),
      'H=$height $unit',
      isVertical: true,
    );

    // Flange Width (Bottom)
    final double bDimY = startY + h + 22.0;
    _drawExtensionLine(canvas, Offset(startX, startY + h), Offset(startX, bDimY + 8));
    _drawExtensionLine(canvas, Offset(startX + b, startY + h), Offset(startX + b, bDimY + 8));
    _drawDimensionLine(
      canvas,
      Offset(startX, bDimY),
      Offset(startX + b, bDimY),
      'W=$width $unit',
    );

    // tw & tf callouts
    _drawCallout(
      canvas,
      Offset(startX + tw / 2, startY + h / 2),
      Offset(startX + tw + 28.0, startY + h / 2),
      'tw=$webThick $unit',
    );
    _drawCallout(
      canvas,
      Offset(startX + b * 0.6, startY + tf / 2),
      Offset(startX + b * 0.6 + 24.0, startY - 14.0),
      'tf=$flangeThick $unit',
    );
  }

  void _drawIBeam(Canvas canvas, Size size) {
    const double h = 106.0;
    const double b = 74.0;
    const double tw = 11.0;
    const double tf = 13.0;
    const double r = 6.0;
    final double startX = (size.width - b) / 2 - 8.0;
    final double startY = (size.height - (h + 28.0)) / 2;

    final Path path = Path()
      // Top Flange
      ..moveTo(startX, startY)
      ..lineTo(startX + b, startY)
      ..lineTo(startX + b, startY + tf)
      ..lineTo(startX + (b + tw) / 2 + r, startY + tf)
      ..arcToPoint(
        Offset(startX + (b + tw) / 2, startY + tf + r),
        radius: const Radius.circular(r),
        clockwise: false,
      )
      // Web
      ..lineTo(startX + (b + tw) / 2, startY + h - tf - r)
      ..arcToPoint(
        Offset(startX + (b + tw) / 2 + r, startY + h - tf),
        radius: const Radius.circular(r),
        clockwise: false,
      )
      // Bottom Flange
      ..lineTo(startX + b, startY + h - tf)
      ..lineTo(startX + b, startY + h)
      ..lineTo(startX, startY + h)
      ..lineTo(startX, startY + h - tf)
      ..lineTo(startX + (b - tw) / 2 - r, startY + h - tf)
      ..arcToPoint(
        Offset(startX + (b - tw) / 2, startY + h - tf - r),
        radius: const Radius.circular(r),
        clockwise: false,
      )
      // Web other side
      ..lineTo(startX + (b - tw) / 2, startY + tf + r)
      ..arcToPoint(
        Offset(startX + (b - tw) / 2 - r, startY + tf),
        radius: const Radius.circular(r),
        clockwise: false,
      )
      ..lineTo(startX, startY + tf)
      ..close();

    canvas.drawPath(path, Paint()..color = const Color(0xFF0D5C9D));
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFBDC3C7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // Height (Right)
    final double hDimX = startX + b + 18.0;
    _drawExtensionLine(canvas, Offset(startX + b, startY), Offset(hDimX + 8, startY));
    _drawExtensionLine(canvas, Offset(startX + b, startY + h), Offset(hDimX + 8, startY + h));
    _drawDimensionLine(
      canvas,
      Offset(hDimX, startY),
      Offset(hDimX, startY + h),
      'H=$height $unit',
      isVertical: true,
    );

    // Flange Width (Bottom)
    final double bDimY = startY + h + 22.0;
    _drawExtensionLine(canvas, Offset(startX, startY + h), Offset(startX, bDimY + 8));
    _drawExtensionLine(canvas, Offset(startX + b, startY + h), Offset(startX + b, bDimY + 8));
    _drawDimensionLine(
      canvas,
      Offset(startX, bDimY),
      Offset(startX + b, bDimY),
      'W=$width $unit',
    );

    // tw & tf callouts
    _drawCallout(
      canvas,
      Offset(startX + (b - tw) / 2, startY + h / 2),
      Offset(startX - 26.0, startY + h / 2),
      'tw=$webThick $unit',
    );
    _drawCallout(
      canvas,
      Offset(startX + b * 0.75, startY + tf / 2),
      Offset(startX + b * 0.75 + 16.0, startY - 14.0),
      'tf=$flangeThick $unit',
    );
  }

  void _drawDimensionLine(
    Canvas canvas,
    Offset p1,
    Offset p2,
    String label, {
    bool isVertical = false,
  }) {
    final Paint linePaint = Paint()
      ..color = AppColors.primaryDark
      ..strokeWidth = 1.2;

    canvas.drawLine(p1, p2, linePaint);

    // Arrows
    _drawArrow(canvas, p1, p2);
    _drawArrow(canvas, p2, p1);

    // Midpoint label
    final Offset mid = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
    _drawLabelBox(canvas, mid, label);
  }

  void _drawExtensionLine(Canvas canvas, Offset p1, Offset p2) {
    final Paint extPaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 0.9;
    canvas.drawLine(p1, p2, extPaint);
  }

  void _drawArrow(Canvas canvas, Offset tip, Offset from) {
    const double len = 6.0;
    final double angle = math.atan2(tip.dy - from.dy, tip.dx - from.dx);
    final Path path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(tip.dx - len * math.cos(angle - math.pi / 6), tip.dy - len * math.sin(angle - math.pi / 6))
      ..lineTo(tip.dx - len * math.cos(angle + math.pi / 6), tip.dy - len * math.sin(angle + math.pi / 6))
      ..close();

    canvas.drawPath(path, Paint()..color = AppColors.primaryDark);
  }

  void _drawCallout(Canvas canvas, Offset from, Offset to, String label) {
    final Paint paint = Paint()
      ..color = AppColors.primaryDark
      ..strokeWidth = 1.1;
    canvas.drawLine(from, to, paint);
    canvas.drawCircle(from, 2.5, Paint()..color = AppColors.primaryDark);

    _drawLabelBox(canvas, Offset(to.dx + 22.0, to.dy), label);
  }

  void _drawLabelBox(Canvas canvas, Offset center, String text) {
    final TextSpan span = TextSpan(
      text: text,
      style: const TextStyle(
        color: AppColors.primaryDark,
        fontSize: 11.5,
        fontWeight: FontWeight.bold,
      ),
    );
    final TextPainter tp = TextPainter(
      text: span,
      textDirection: TextDirection.ltr,
    )..layout();

    final double bgW = tp.width + 10;
    final double bgH = tp.height + 5;
    final Rect bgRect = Rect.fromCenter(center: center, width: bgW, height: bgH);

    canvas.drawRRect(
      RRect.fromRectAndRadius(bgRect, const Radius.circular(3.5)),
      Paint()..color = Colors.white,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bgRect, const Radius.circular(3.5)),
      Paint()
        ..color = AppColors.primaryDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _ShapeDiagramPainter oldDelegate) {
    return oldDelegate.shape != shape ||
        oldDelegate.unit != unit ||
        oldDelegate.width != width ||
        oldDelegate.thickness != thickness ||
        oldDelegate.outerDia != outerDia ||
        oldDelegate.height != height ||
        oldDelegate.webThick != webThick ||
        oldDelegate.flangeThick != flangeThick;
  }
}
