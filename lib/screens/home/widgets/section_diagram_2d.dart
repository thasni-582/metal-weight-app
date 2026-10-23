import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:metal_weight/core/constants/app_colors.dart';
import 'package:metal_weight/core/constants/standard_data.dart';
import 'package:metal_weight/models/profile_spec.dart';

/// Interactive 2D Blueprint Engineering Diagram Widget
class Section2DDiagramWidget extends StatefulWidget {
  final String shapeType; // e.g. 'Angle Equal', 'Channels', 'Beams', etc.
  final String selectedSize;
  final String selectedThickness;
  final double lengthMeters;
  final List<String> availableSizes;
  final ValueChanged<String>? onVariantChanged;
  final ValueChanged<double>? onLengthChanged;
  final ValueChanged<String>? onSizeChanged;
  final String? activeVariant;
  final double? overrideWeight;
  final double? overrideSectionArea;

  const Section2DDiagramWidget({
    super.key,
    required this.shapeType,
    required this.selectedSize,
    required this.selectedThickness,
    this.lengthMeters = 6.0,
    required this.availableSizes,
    this.onVariantChanged,
    this.onLengthChanged,
    this.onSizeChanged,
    this.activeVariant,
    this.overrideWeight,
    this.overrideSectionArea,
  });

  @override
  State<Section2DDiagramWidget> createState() => _Section2DDiagramWidgetState();
}

class _Section2DDiagramWidgetState extends State<Section2DDiagramWidget> {
  late String _currentVariant;
  late double _sliderValue;

  @override
  void initState() {
    super.initState();
    _currentVariant = widget.activeVariant ?? _getDefaultVariant(widget.shapeType);
    _sliderValue = _calcInitialSliderVal();
  }

  @override
  void didUpdateWidget(covariant Section2DDiagramWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeVariant != null && widget.activeVariant != _currentVariant) {
      _currentVariant = widget.activeVariant!;
      _sliderValue = _calcInitialSliderVal();
    } else if (widget.shapeType != oldWidget.shapeType) {
      _currentVariant = widget.activeVariant ?? _getDefaultVariant(widget.shapeType);
      _sliderValue = _calcInitialSliderVal();
    } else if (widget.selectedSize != oldWidget.selectedSize) {
      _sliderValue = _calcInitialSliderVal();
    }
  }

  double _calcInitialSliderVal() {
    final sizes = widget.availableSizes;
    if (sizes.isEmpty) return 0.0;
    int idx = sizes.indexOf(widget.selectedSize);
    if (idx < 0) idx = 0;
    return sizes.length > 1 ? idx / (sizes.length - 1) : 0.0;
  }

  String _getDefaultVariant(String shape) {
    if ((shape.contains('Equal Angle') || shape.contains('Angle Equal')) && !shape.contains('Unequal')) return 'EQUAL';
    if (shape.contains('I-Beam')) return 'I-Beam (JIS)';
    if (shape.contains('H-Beam')) return 'H-Beam (JIS)';
    if (shape.contains('JIS') && (shape.contains('Beam') || shape.contains('H-Beam'))) return 'H-Beam (JIS)';
    if (shape.contains('JIS') && shape.contains('Channel')) return 'JIS';
    if (shape.contains('UPE')) return 'UPE';
    if (shape.contains('UPN')) return 'UPN';
    if (shape.contains('Channel')) return 'UPN';
    if (shape.contains('Universal Beam') || shape.contains('UB')) return 'UB';
    if (shape.contains('Universal Column') || shape.contains('UC')) return 'UC';
    if (shape.contains('W-Beam')) return 'W-Beam';
    if (shape.contains('IPE-AA')) return 'IPE-AA';
    if (shape.contains('IPE')) return 'IPE';
    if (shape.contains('HEA')) return 'HEA';
    if (shape.contains('HEB')) return 'HEB';
    if (shape.contains('Beam')) return 'HEA';
    if (shape.contains('Angle')) return 'Angle';
    if (shape.contains('Sheet')) return 'Sheet';
    return shape;
  }

  List<String> _getAvailableVariants(String shape) {
    if (shape.contains('(') && shape.contains('/')) {
      if (shape.contains('Channel')) {
        return ['UPN', 'UPE', 'JIS'];
      } else if (shape.contains('Universal')) {
        return ['UB', 'UC'];
      } else if (shape.contains('Beam')) {
        return ['HEA', 'HEB', 'JIS', 'IPE', 'IPE-AA'];
      }
    }
    return [];
  }

  void _onVariantTap(String variant) {
    setState(() {
      _currentVariant = variant;
      _sliderValue = 0.0;
    });
    widget.onVariantChanged?.call(variant);
  }

  void _onSliderSlide(double val) {
    final sizes = widget.availableSizes;
    if (sizes.isEmpty) return;

    // Strict snapping to discrete indices: NO intermediate 81, 82, 101, 102
    int idx = (val * (sizes.length - 1)).round().clamp(0, sizes.length - 1);
    final String targetSize = sizes[idx];

    setState(() {
      _sliderValue = sizes.length > 1 ? idx / (sizes.length - 1) : 0.0;
    });

    if (targetSize != widget.selectedSize) {
      widget.onSizeChanged?.call(targetSize);
    }
  }

  @override
  Widget build(BuildContext context) {
    final DiagramData data = DiagramData.calculate(
      shapeType: widget.shapeType,
      variant: _currentVariant,
      sizeStr: widget.selectedSize,
      thickStr: widget.selectedThickness,
      lengthMeters: widget.lengthMeters,
      overrideWeight: widget.overrideWeight,
      overrideSectionArea: widget.overrideSectionArea,
    );

    final List<String> availableVariants = _getAvailableVariants(widget.shapeType);
    final int divisions = math.max(1, widget.availableSizes.length - 1);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.blueprintBlue.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppColors.blueprintAccent.withValues(alpha: 0.15),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Bar matching industrial deep blue
          Container(
            decoration: const BoxDecoration(
              color: AppColors.blueprintBlue,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    data.headerTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '2D BLUEPRINT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Sub-variants tabs row (e.g. UPN | UPE | JIS or HEA | HEB | JIS | IPE | IPE-AA)
          if (availableVariants.isNotEmpty)
            Container(
              color: AppColors.blueprintBlue,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final bool useScroll = constraints.maxWidth < (availableVariants.length * 64);
                  if (useScroll) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: availableVariants.map((v) {
                          final bool isSelected = (v == _currentVariant);
                          return GestureDetector(
                            onTap: () => _onVariantTap(v),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: isSelected ? Colors.white : Colors.transparent,
                                    width: 3.0,
                                  ),
                                ),
                              ),
                              child: Text(
                                v,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.white70,
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }
                  return Row(
                    children: availableVariants.map((v) {
                      final bool isSelected = (v == _currentVariant);
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => _onVariantTap(v),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: isSelected ? Colors.white : Colors.transparent,
                                  width: 3.0,
                                ),
                              ),
                            ),
                            child: Text(
                              v,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.white70,
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),

          // Main 2D Blueprint Canvas
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
            child: SizedBox(
              height: 265,
              width: double.infinity,
              child: TweenAnimationBuilder<DiagramData>(
                tween: DiagramDataTween(begin: data, end: data),
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                builder: (context, animData, child) {
                  return CustomPaint(
                    size: const Size(double.infinity, 265),
                    painter: Section2DPainter(data: animData),
                  );
                },
              ),
            ),
          ),

          // Discrete Snapping Slider (snaps strictly across standard sizes)
          if (widget.availableSizes.length > 1)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                children: [
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: AppColors.blueprintAccent.withValues(alpha: 0.4),
                      inactiveTrackColor: Colors.grey.shade200,
                      thumbColor: AppColors.blueprintAccent,
                      overlayColor: AppColors.blueprintAccent.withValues(alpha: 0.12),
                      trackHeight: 6.0,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9.0),
                    ),
                    child: Slider(
                      value: _sliderValue.clamp(0.0, 1.0),
                      divisions: divisions,
                      onChanged: _onSliderSlide,
                    ),
                  ),
                  Text(
                    widget.shapeType.contains('Sheet')
                        ? 'Thickness: ${widget.selectedSize} mm  (Slide to standard thickness)'
                        : (widget.shapeType.contains('Flat')
                            ? 'Width: ${widget.selectedSize} mm  (Slide to standard width)'
                            : (widget.shapeType.contains('Round')
                                ? 'Diameter: ${widget.selectedSize} mm  (Slide to standard diameter)'
                                : 'Size: ${widget.selectedSize}  (Slide to standard profile)')),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class DiagramData {
  final String headerTitle;
  final String shapeCategory; // 'U_CHANNEL', 'ANGLE', 'BEAM', 'BAR', 'TUBE', 'SHEET', 'FLAT'
  final String displayName;
  final String variantTag;
  final String sizeTag;
  final String standardTag;
  final double heightVal;
  final double widthVal;
  final double webThickVal;
  final double flangeThickVal;
  final double diameterVal;
  final double weightVal;
  final double sectionAreaVal;
  final double lengthMeters;

  DiagramData({
    required this.headerTitle,
    required this.shapeCategory,
    required this.displayName,
    this.variantTag = 'IPE',
    this.sizeTag = '140',
    this.standardTag = 'Standard',
    required this.heightVal,
    required this.widthVal,
    required this.webThickVal,
    required this.flangeThickVal,
    required this.diameterVal,
    required this.weightVal,
    required this.sectionAreaVal,
    required this.lengthMeters,
  });

  factory DiagramData.calculate({
    required String shapeType,
    required String variant,
    required String sizeStr,
    required String thickStr,
    required double lengthMeters,
    double? overrideWeight,
    double? overrideSectionArea,
  }) {
    double sizeNum = double.tryParse(sizeStr) ?? 80.0;
    double thickNum = double.tryParse(thickStr) ?? 5.0;

    String category = 'U_CHANNEL';
    String title = shapeType;
    String dispName = variant.isNotEmpty ? variant : shapeType;
    String variantTag = variant.isNotEmpty ? variant : 'IPE';
    String sizeTag = sizeStr;
    String standardTag = 'Standard';

    double h = 80;
    double b = 45;
    double tw = 6.0;
    double tf = 8.0;
    double d = 0;
    double w = 8.64;
    double area = 11.0;

    if (shapeType.contains('Channel') || shapeType.contains('UPN') || shapeType.contains('UPE')) {
      category = 'U_CHANNEL';
      String effVariant = 'UPN';
      if (shapeType.contains('JIS')) {
        effVariant = 'JIS';
      } else if (shapeType.contains('UPE')) {
        effVariant = 'UPE';
      } else if (shapeType.contains('UPN')) {
        effVariant = 'UPN';
      } else {
        effVariant = variant.isNotEmpty ? variant : 'UPN';
      }

      if (effVariant == 'JIS') {
        title = 'U CHANNEL';
        dispName = 'U Channel';
        variantTag = 'U Channel';
        standardTag = 'JIS G 3192';
      } else {
        title = '$effVariant CHANNEL';
        dispName = effVariant;
        variantTag = effVariant;
        standardTag = effVariant == 'UPE' ? 'DIN 1026-2' : 'DIN 1026-1';
      }
      sizeTag = sizeStr;

      if (effVariant == 'JIS' && StandardData.jisChannels.containsKey(sizeStr)) {
        final spec = StandardData.jisChannels[sizeStr]!;
        h = spec.h;
        b = spec.b;
        tw = spec.tw;
        tf = spec.tf;
        w = spec.weight;
        area = spec.area;
      } else if (effVariant == 'UPE' && StandardData.upeChannels.containsKey(sizeStr)) {
        final spec = StandardData.upeChannels[sizeStr]!;
        h = spec.h;
        b = spec.b;
        tw = spec.tw;
        tf = spec.tf;
        w = spec.weight;
        area = spec.area;
      } else if (StandardData.upnChannels.containsKey(sizeStr)) {
        final spec = StandardData.upnChannels[sizeStr]!;
        h = spec.h;
        b = spec.b;
        tw = spec.tw;
        tf = spec.tf;
        w = spec.weight;
        area = spec.area;
      }
    } else if (shapeType.contains('Angle')) {
      category = 'ANGLE';
      final bool isSS = shapeType.contains('SS') || shapeType.contains('Stainless');
      final bool isAl = shapeType.contains('Aluminum');
      final bool isUnequal = shapeType.contains('Unequal') || shapeType.contains('Angle Unequal');

      if (isSS) {
        title = 'STAINLESS STEEL ANGLE';
        dispName = 'SS L $sizeStr';
        variantTag = 'SS 304/316';
        standardTag = 'ASTM A276';
      } else if (isAl) {
        title = 'ALUMINUM ANGLE';
        dispName = 'AL L $sizeStr';
        variantTag = '6063-T6';
        standardTag = 'EN 755-9';
      } else if (isUnequal) {
        title = 'UNEQUAL ANGLE';
        dispName = 'L $sizeStr';
        variantTag = 'UNEQUAL';
        standardTag = 'EN 10056-1';
      } else {
        title = 'EQUAL ANGLE';
        dispName = 'L $sizeStr';
        variantTag = variant.isNotEmpty ? variant : 'EQUAL';
        standardTag = 'EN 10056-1';
      }
      sizeTag = sizeStr;

      if (isUnequal && sizeStr.contains('x')) {
        final parts = sizeStr.split('x');
        h = double.tryParse(parts[0]) ?? 60.0;
        b = double.tryParse(parts[1]) ?? 40.0;
      } else {
        h = sizeNum;
        b = sizeNum;
      }
      tw = thickNum;
      tf = thickNum;

      final double baseSteelW = isUnequal
          ? (StandardData.unequalAngles[sizeStr]?[thickStr] ??
              ((h + b - thickNum) * thickNum * 0.00785))
          : (StandardData.equalAngles[sizeStr]?[thickStr] ??
              ((h + b - thickNum) * thickNum * 0.00785));

      if (isSS) {
        w = baseSteelW * (8.00 / 7.85);
        area = baseSteelW / 0.785;
      } else if (isAl) {
        w = baseSteelW * (2.70 / 7.85);
        area = baseSteelW / 0.785;
      } else {
        w = baseSteelW;
        area = baseSteelW / 0.785;
      }
    } else if (shapeType.contains('Beam') ||
        shapeType.contains('Universal') ||
        shapeType.contains('IPE') ||
        shapeType.contains('HEA') ||
        shapeType.contains('HEB') ||
        shapeType.contains('UB') ||
        shapeType.contains('UC')) {
      category = 'BEAM';
      String effVariant = 'IPE';
      if (shapeType.contains('Universal Column') || shapeType.contains('UC') || variant == 'UC') {
        effVariant = 'UC';
      } else if (shapeType.contains('Universal Beam') || shapeType.contains('UB') || variant == 'UB') {
        effVariant = 'UB';
      } else if (shapeType.contains('W-Beam') || shapeType.contains('Wide Flange')) {
        effVariant = 'W-Beam';
      } else if (shapeType.contains('IPE-AA')) {
        effVariant = 'IPE-AA';
      } else if (shapeType.contains('HEA')) {
        effVariant = 'HEA';
      } else if (shapeType.contains('HEB')) {
        effVariant = 'HEB';
      } else if (shapeType == 'I-Beam (JIS)' || shapeType == 'I-Beam' || shapeType.contains('I-Beam')) {
        effVariant = 'I-Beam (JIS)';
      } else if (shapeType == 'H-Beam (JIS)' || shapeType == 'H-Beam' || shapeType.contains('H-Beam')) {
        effVariant = 'H-Beam (JIS)';
      } else if (shapeType.contains('JIS')) {
        effVariant = (variant == 'I' || variant.contains('I-Beam')) ? 'I-Beam (JIS)' : 'H-Beam (JIS)';
      } else if (shapeType.contains('IPE')) {
        effVariant = 'IPE';
      } else {
        effVariant = variant.isNotEmpty ? variant : 'HEA';
      }

      if (effVariant == 'I-Beam (JIS)') {
        title = 'I-Beam (JIS)';
        dispName = 'I-Beam $sizeStr';
        variantTag = 'I-Beam (JIS)';
        standardTag = 'JIS G 3192';
      } else if (effVariant == 'H-Beam (JIS)') {
        title = 'H-Beam (JIS)';
        dispName = 'H-Beam $sizeStr';
        variantTag = 'H-Beam (JIS)';
        standardTag = 'JIS G 3192';
      } else if (effVariant == 'UC') {
        title = 'UC COLUMN';
        dispName = 'UC $sizeStr';
        variantTag = 'UC';
        standardTag = 'BS 4-1';
      } else if (effVariant == 'UB') {
        title = 'UB BEAM';
        dispName = 'UB $sizeStr';
        variantTag = 'UB';
        standardTag = 'BS 4-1';
      } else if (effVariant == 'W-Beam') {
        title = 'W-BEAM';
        dispName = 'W-Beam $sizeStr';
        variantTag = 'W-Beam';
        standardTag = 'ASTM A6';
      } else if (effVariant == 'IPE-AA') {
        title = 'IPE-AA BEAM';
        dispName = 'IPE-AA $sizeStr';
        variantTag = 'IPE-AA';
        standardTag = 'EN 10365';
      } else if (effVariant == 'IPE') {
        title = 'IPE BEAM';
        dispName = 'IPE $sizeStr';
        variantTag = 'IPE';
        standardTag = 'EN 10365';
      } else if (effVariant == 'HEA') {
        title = 'HEA BEAM';
        dispName = 'HEA $sizeStr';
        variantTag = 'HEA';
        standardTag = 'EN 10025';
      } else if (effVariant == 'HEB') {
        title = 'HEB BEAM';
        dispName = 'HEB $sizeStr';
        variantTag = 'HEB';
        standardTag = 'EN 10025';
      } else {
        title = effVariant.toUpperCase().contains('BEAM') ? effVariant.toUpperCase() : '$effVariant BEAM';
        dispName = '$effVariant $sizeStr';
        variantTag = effVariant;
      }
      sizeTag = sizeStr;

      StandardProfileSpec? spec;
      if (effVariant == 'I-Beam (JIS)') {
        spec = StandardData.clientIBeams[sizeStr] ?? StandardData.jisBeams[sizeStr];
      } else if (effVariant == 'H-Beam (JIS)') {
        spec = StandardData.clientHBeams[sizeStr] ?? StandardData.jisBeams[sizeStr];
      } else if (effVariant == 'JIS') {
        spec = StandardData.jisBeams[sizeStr];
      } else if (effVariant == 'IPE') {
        spec = StandardData.ipeBeams[sizeStr];
      } else if (effVariant == 'IPE-AA') {
        spec = StandardData.ipeAaBeams[sizeStr];
      } else if (effVariant == 'HEA') {
        spec = StandardData.heaBeams[sizeStr];
      } else if (effVariant == 'HEB') {
        spec = StandardData.hebBeams[sizeStr];
      } else if (effVariant == 'UB') {
        spec = StandardData.ubBeams[sizeStr];
      } else if (effVariant == 'UC') {
        spec = StandardData.ucBeams[sizeStr];
      } else if (effVariant == 'W-Beam') {
        spec = StandardData.wBeams[sizeStr] ?? StandardData.findWBeam(sizeStr);
      }

      // Catalog cross-fallback if variant wasn't strictly resolved
      spec ??= StandardData.clientIBeams[sizeStr] ??
          StandardData.clientHBeams[sizeStr] ??
          StandardData.ubBeams[sizeStr] ??
          StandardData.ucBeams[sizeStr] ??
          StandardData.wBeams[sizeStr] ??
          StandardData.findWBeam(sizeStr) ??
          StandardData.ipeBeams[sizeStr] ??
          StandardData.heaBeams[sizeStr] ??
          StandardData.hebBeams[sizeStr] ??
          StandardData.jisBeams[sizeStr];

      if (spec != null) {
        h = spec.h;
        b = spec.b;
        tw = spec.tw;
        tf = spec.tf;
        w = spec.weight;
        area = spec.area;
      } else {
        h = sizeNum;
        b = sizeNum * 0.55;
        tw = 5.0;
        tf = 8.0;
        w = sizeNum * 0.16;
        area = w * 1.27;
      }
    } else if (shapeType.contains('Tube') || shapeType.contains('SHS') || shapeType.contains('RHS')) {
      category = 'TUBE';
      final bool isRect = shapeType.contains('Rectangular') || shapeType.contains('RHS');
      final bool isSS = shapeType.contains('SS') || shapeType.contains('Stainless');
      title = isRect
          ? (isSS ? 'SS RECTANGULAR TUBE' : 'RECTANGULAR TUBE (RHS)')
          : (isSS ? 'SS SQUARE TUBE' : 'SQUARE TUBE (SHS)');
      dispName = '$sizeStr mm';
      variantTag = isRect ? 'RHS' : 'SHS';
      sizeTag = sizeStr;
      if (sizeStr.contains('x')) {
        final parts = sizeStr.split('x');
        h = double.tryParse(parts[0]) ?? 50.0;
        b = double.tryParse(parts[1]) ?? (isRect ? 30.0 : 50.0);
      } else {
        h = sizeNum;
        b = sizeNum;
      }
      tw = thickNum;
      tf = thickNum;
      if (isRect) {
        final double baseW = StandardData.rectangularTubes[sizeStr]?[thickStr] ??
            ((2 * (h + b) - 4 * thickNum) * thickNum * 0.00785);
        w = isSS ? baseW * (8.00 / 7.85) : baseW;
      } else {
        final double baseW = StandardData.squareTubes[sizeStr]?[thickStr] ??
            ((4 * h - 4 * thickNum) * thickNum * 0.00785);
        w = isSS ? baseW * (8.00 / 7.85) : baseW;
      }
      area = w * 1.27;
    } else if (shapeType.contains('Pipe')) {
      category = 'PIPE';
      final bool isSS = shapeType.contains('SS') || shapeType.contains('Stainless');
      title = isSS ? 'STAINLESS STEEL PIPE' : 'STEEL PIPE (ERW / SEAMLESS)';
      dispName = '$sizeStr ($thickStr)';
      variantTag = 'PIPE';
      sizeTag = sizeStr;
      double parsedOd = 60.3;
      if (sizeStr.contains('(') && sizeStr.contains('mm')) {
        final start = sizeStr.indexOf('(') + 1;
        final end = sizeStr.indexOf('mm');
        parsedOd = double.tryParse(sizeStr.substring(start, end).trim()) ?? 60.3;
      }
      d = parsedOd;
      h = d;
      b = d;
      double parsedWall = 3.91;
      if (thickStr.contains('(') && thickStr.contains('mm')) {
        final start = thickStr.indexOf('(') + 1;
        final end = thickStr.indexOf('mm');
        parsedWall = double.tryParse(thickStr.substring(start, end).trim()) ?? 3.91;
      }
      tw = parsedWall;
      tf = parsedWall;
      final double? baseW = StandardData.steelPipes[sizeStr]?[thickStr];
      if (baseW != null) {
        w = isSS ? baseW * (8.00 / 7.85) : baseW;
      } else {
        w = (d - tw) * tw * (isSS ? 0.02491 : 0.02466);
      }
      area = w * 1.27;
    } else if (shapeType.contains('Flat')) {
      category = 'FLAT';
      title = 'FLAT BAR';
      dispName = '${sizeStr}x$thickStr mm';
      variantTag = 'FLAT';
      sizeTag = sizeStr;
      b = sizeNum;
      h = thickNum;
      tw = thickNum;
      w = (b * h * 0.00785);
      area = (b * h / 100.0);
    } else if (shapeType.contains('Round')) {
      category = 'BAR';
      variantTag = 'ROUND';
      sizeTag = sizeStr;
      d = sizeNum;
      h = sizeNum;
      b = sizeNum;
      area = (math.pi * (sizeNum / 2) * (sizeNum / 2) / 100.0);

      if (shapeType.contains('SS') || shapeType.contains('Stainless')) {
        title = 'STAINLESS STEEL ROUND BAR';
        dispName = 'SS Ø $sizeStr mm';
        w = area * 0.800;
      } else if (shapeType.contains('Aluminum')) {
        title = 'ALUMINUM ROUND BAR';
        dispName = 'Al Ø $sizeStr mm';
        w = area * 0.270;
      } else if (shapeType.contains('Brass')) {
        title = 'BRASS ROUND BAR';
        dispName = 'Brass Ø $sizeStr mm';
        w = area * 0.850;
      } else if (shapeType.contains('Copper')) {
        title = 'COPPER ROUND BAR';
        dispName = 'Copper Ø $sizeStr mm';
        w = area * 0.896;
      } else {
        title = 'ROUND BAR';
        dispName = 'Ø $sizeStr mm';
        w = area * 0.785;
      }
    } else if (shapeType.contains('Sheet') || shapeType.contains('Plate')) {
      category = 'SHEET';
      variantTag = 'SHEET';
      sizeTag = sizeStr;
      standardTag = 'Plate';
      // For Sheets, sizeStr contains the selected thickness (e.g. '0.5' to '30')
      final double sheetThick = double.tryParse(sizeStr) ?? (double.tryParse(thickStr) ?? 2.0);
      tw = sheetThick;
      h = sheetThick;
      b = 1000;

      if (shapeType.contains('HR Checkered') || (shapeType.contains('Checkered') && !shapeType.contains('Aluminum'))) {
        final bool isSS = shapeType.contains('Stainless') || shapeType.contains('SS');
        title = isSS ? 'STAINLESS STEEL CHECKERED SHEET' : 'HR CHECKERED SHEET';
        dispName = '$sizeStr mm Chequered Plate';
        final double baseW = StandardData.hrCheckeredWeights[sizeStr] ?? ((sheetThick * 7.85) + 3.0);
        w = isSS ? baseW * (8.00 / 7.85) : baseW;
        area = (sheetThick * 10.0);
      } else if (shapeType.contains('Checkered')) {
        title = 'ALUMINUM CHECKERED SHEET';
        dispName = '$sizeStr mm 5-Bar Tread Plate';
        w = StandardData.aluminumCheckeredWeights[sizeStr] ?? ((sheetThick * 2.70) + 1.60);
        area = (sheetThick * 10.0);
      } else {
        double density = 7.85;
        if (shapeType.contains('Stainless')) {
          title = 'STAINLESS STEEL SHEET';
          dispName = '$sizeStr mm (SS 304/316)';
          density = 8.00;
        } else if (shapeType.contains('Aluminum') || shapeType.contains('Aloominium')) {
          title = 'ALUMINUM SHEET';
          dispName = '$sizeStr mm (Al Alloy)';
          density = 2.70;
        } else if (shapeType.contains('Brass')) {
          title = 'BRASS SHEET';
          dispName = '$sizeStr mm (CuZn Alloy)';
          density = 8.50;
        } else if (shapeType.contains('Copper')) {
          title = 'COPPER SHEET';
          dispName = '$sizeStr mm (Pure Copper)';
          density = 8.96;
        } else if (shapeType.contains('HR') || shapeType.contains('Hot Rolled')) {
          title = 'HR SHEET / PLATE';
          dispName = '$sizeStr mm HR Sheet';
          density = 7.85;
        } else {
          title = 'STEEL SHEET';
          dispName = '$sizeStr mm Sheet';
          density = 7.85;
        }

        w = (sheetThick * density); // kg/m2
        area = (sheetThick * 10.0);
      }
    }

    return DiagramData(
      headerTitle: title,
      shapeCategory: category,
      displayName: dispName,
      variantTag: variantTag,
      sizeTag: sizeTag,
      standardTag: standardTag,
      heightVal: h,
      widthVal: b,
      webThickVal: tw,
      flangeThickVal: tf,
      diameterVal: d,
      weightVal: (overrideWeight != null && overrideWeight > 0) ? overrideWeight : w,
      sectionAreaVal: (overrideSectionArea != null && overrideSectionArea > 0) ? overrideSectionArea : area,
      lengthMeters: lengthMeters,
    );
  }

  static DiagramData lerp(DiagramData a, DiagramData b, double t) {
    return DiagramData(
      headerTitle: b.headerTitle,
      shapeCategory: b.shapeCategory,
      displayName: b.displayName,
      variantTag: b.variantTag,
      sizeTag: b.sizeTag,
      standardTag: b.standardTag,
      heightVal: lerpDouble(a.heightVal, b.heightVal, t),
      widthVal: lerpDouble(a.widthVal, b.widthVal, t),
      webThickVal: lerpDouble(a.webThickVal, b.webThickVal, t),
      flangeThickVal: lerpDouble(a.flangeThickVal, b.flangeThickVal, t),
      diameterVal: lerpDouble(a.diameterVal, b.diameterVal, t),
      weightVal: lerpDouble(a.weightVal, b.weightVal, t),
      sectionAreaVal: lerpDouble(a.sectionAreaVal, b.sectionAreaVal, t),
      lengthMeters: lerpDouble(a.lengthMeters, b.lengthMeters, t),
    );
  }

  static double lerpDouble(double a, double b, double t) {
    return a + (b - a) * t;
  }
}

class DiagramDataTween extends Tween<DiagramData> {
  DiagramDataTween({super.begin, super.end});

  @override
  DiagramData lerp(double t) {
    return DiagramData.lerp(begin!, end!, t);
  }
}

class Section2DPainter extends CustomPainter {
  final DiagramData data;

  Section2DPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;

    // Background
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), Paint()..color = Colors.white);

    // Subtle CAD Blueprint grid
    _drawEngineeringGrid(canvas, size);

    // Shape drawing with integrated spec table & ISO blueprint styling
    switch (data.shapeCategory) {
      case 'U_CHANNEL':
        _drawUChannel2D(canvas, size);
        break;
      case 'ANGLE':
        _drawAngle2D(canvas, size);
        break;
      case 'BEAM':
        _drawBeam2D(canvas, size);
        break;
      case 'BAR':
        _drawBar2D(canvas, size);
        break;
      case 'TUBE':
        _drawTube2D(canvas, size);
        break;
      case 'PIPE':
        _drawPipe2D(canvas, size);
        break;
      case 'SHEET':
      case 'FLAT':
        _drawSheetOrFlat2D(canvas, size);
        break;
      default:
        _drawUChannel2D(canvas, size);
        break;
    }
  }

  void _drawEngineeringGrid(Canvas canvas, Size size) {
    final Paint gridPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..strokeWidth = 0.5;
    for (double x = 12.0; x < size.width; x += 18.0) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 8.0; y < size.height; y += 18.0) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  /// 3-Row Technical Specification Table matching standard engineering catalogs
  void _drawSpecTable(Canvas canvas, Offset origin, DiagramData data) {
    final double startX = origin.dx;
    final double startY = origin.dy;
    const double rowHeight = 25.0;

    final String variantStr = data.variantTag.isNotEmpty ? data.variantTag : 'IPE';
    final String rawSize = data.sizeTag.isNotEmpty ? data.sizeTag : data.heightVal.toStringAsFixed(0);
    final String sizeStr = rawSize.contains('(') ? rawSize.split('(').first.trim() : rawSize;
    final String stdStr = data.standardTag.isNotEmpty ? data.standardTag : 'Standard';

    final String weightStr = (data.weightVal == data.weightVal.roundToDouble() && data.weightVal >= 100)
        ? data.weightVal.toStringAsFixed(1)
        : data.weightVal.toStringAsFixed(2);
    final String weightUnitStr = data.shapeCategory == 'SHEET' ? 'Kg/m²' : 'Kg/m';

    final String sectionStr = data.sectionAreaVal.toStringAsFixed(2);
    const String sectionUnitStr = 'cm2';

    final bool isEqualAngle = data.headerTitle == 'ANGLE EQUAL' ||
        (data.shapeCategory == 'ANGLE' && !data.headerTitle.contains('UNEQUAL'));

    final List<List<String>> rows = isEqualAngle
        ? [
            ['weight', weightStr, weightUnitStr],
            ['section', sectionStr, sectionUnitStr],
          ]
        : [
            [variantStr, sizeStr, stdStr],
            ['weight', weightStr, weightUnitStr],
            ['section', sectionStr, sectionUnitStr],
          ];

    // Compute uniform box width dynamically so values never overflow or collide
    double maxValW = 36.0;
    for (final row in rows) {
      final tp = TextPainter(
        text: TextSpan(
          text: row[1],
          style: const TextStyle(
            fontSize: 11.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      if (tp.width > maxValW) {
        maxValW = tp.width;
      }
    }
    final double boxW = math.max(48.0, maxValW + 12.0);
    const double boxH = 20.0;
    double maxLabelW = 44.0;
    for (final row in rows) {
      final lp = TextPainter(
        text: TextSpan(
          text: row[0],
          style: const TextStyle(
            fontSize: 12.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      if (lp.width > maxLabelW) {
        maxLabelW = lp.width;
      }
    }
    final double boxStartX = startX + maxLabelW + 8.0;

    for (int i = 0; i < rows.length; i++) {
      final double rowY = startY + (i * rowHeight);
      final String col1 = rows[i][0];
      final String col2 = rows[i][1];
      final String col3 = rows[i][2];

      // Col 1: Label
      final TextPainter p1 = TextPainter(
        text: TextSpan(
          text: col1,
          style: const TextStyle(
            fontSize: 12.0,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      p1.paint(canvas, Offset(startX, rowY + 3.0));

      // Col 2: Boxed Value with Royal Blue Border
      final TextPainter p2 = TextPainter(
        text: TextSpan(
          text: col2,
          style: const TextStyle(
            fontSize: 11.0,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D5C9D),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final Rect boxRect = Rect.fromLTWH(boxStartX, rowY + 1.0, boxW, boxH);
      canvas.drawRect(boxRect, Paint()..color = Colors.white);
      canvas.drawRect(
        boxRect,
        Paint()
          ..color = const Color(0xFF0D5C9D)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
      p2.paint(
        canvas,
        Offset(boxRect.left + (boxW - p2.width) / 2, boxRect.top + (boxH - p2.height) / 2),
      );

      // Col 3: Unit / Standard text positioned safely to the right of box
      final TextPainter p3 = TextPainter(
        text: TextSpan(
          text: col3,
          style: const TextStyle(
            fontSize: 11.0,
            fontWeight: FontWeight.w500,
            color: Color(0xFF475569),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      p3.paint(canvas, Offset(boxRect.right + 8.0, rowY + 4.0));
    }
  }

  void _drawUChannel2D(Canvas canvas, Size size) {
    _drawSpecTable(canvas, const Offset(12.0, 172.0), data);

    const double h = 138.0;
    const double b = 58.0;
    const double tf = 13.0;
    const double tw = 10.0;
    const double r = 7.0; // root fillet
    const double topY = 18.0;

    final double diagramRight = size.width - 12.0;
    const double rightDimReserve = 48.0;
    final double startX = diagramRight - rightDimReserve - b;

    final Path path = Path();
    path.moveTo(startX, topY);
    path.lineTo(startX + b, topY);
    path.lineTo(startX + b, topY + tf);
    path.lineTo(startX + tw + r, topY + tf);
    path.arcToPoint(
      Offset(startX + tw, topY + tf + r),
      radius: const Radius.circular(r),
      clockwise: false,
    );
    path.lineTo(startX + tw, topY + h - tf - r);
    path.arcToPoint(
      Offset(startX + tw + r, topY + h - tf),
      radius: const Radius.circular(r),
      clockwise: false,
    );
    path.lineTo(startX + b, topY + h - tf);
    path.lineTo(startX + b, topY + h);
    path.lineTo(startX, topY + h);
    path.close();

    canvas.drawPath(path, Paint()..color = const Color(0xFF0D5C9D));
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFBDC3C7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // Profile designation text (e.g. "UPN", "UPE", "U")
    final String profileLabel = (data.variantTag.toLowerCase().contains('channel'))
        ? 'U'
        : (data.variantTag.isNotEmpty ? data.variantTag : 'UPN');
    final TextPainter lp = TextPainter(
      text: TextSpan(
        text: profileLabel,
        style: const TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.w900,
          color: Color(0xFF1E293B),
          letterSpacing: 0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final double pocketW = b - tw;
    final double labelX = startX + tw + (pocketW - lp.width) / 2;
    final double labelY = topY + (h - lp.height) / 2;
    lp.paint(canvas, Offset(labelX, labelY));

    final Paint extPaint = Paint()
      ..color = const Color(0xFF7F8C8D)
      ..strokeWidth = 0.8;
    final Paint dimPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 1.1;

    // Height Dim (Right) - vertical line with centered boxed dimension matching engineering slide rule standard
    final double hDimX = startX + b + 20.0;
    canvas.drawLine(Offset(startX + b, topY), Offset(hDimX + 8.0, topY), extPaint);
    canvas.drawLine(Offset(startX + b, topY + h), Offset(hDimX + 8.0, topY + h), extPaint);
    canvas.drawLine(Offset(hDimX, topY), Offset(hDimX, topY + h), dimPaint);
    _drawArrowHead(canvas, Offset(hDimX, topY), math.pi / 2, size: 5.5);
    _drawArrowHead(canvas, Offset(hDimX, topY + h), -math.pi / 2, size: 5.5);
    _drawBoxedDimension(canvas, Offset(hDimX, topY + h / 2), data.heightVal.toStringAsFixed(0));

    // Width Dim (Bottom)
    const double bDimY = topY + h + 22.0;
    canvas.drawLine(Offset(startX, topY + h), Offset(startX, bDimY + 8.0), extPaint);
    canvas.drawLine(Offset(startX + b, topY + h), Offset(startX + b, bDimY + 8.0), extPaint);
    canvas.drawLine(Offset(startX, bDimY), Offset(startX + b, bDimY), dimPaint);
    _drawArrowHead(canvas, Offset(startX, bDimY), 0, size: 5.5);
    _drawArrowHead(canvas, Offset(startX + b, bDimY), math.pi, size: 5.5);
    _drawBoxedDimension(canvas, Offset(startX + b / 2, bDimY), data.widthVal.toStringAsFixed(0));

    // Flange thickness tf (Inward opposing vertical arrows, matching engineering slide rule standard)
    final double flangeX = startX + tw + (b - tw) * 0.50;
    canvas.drawLine(Offset(flangeX, topY - 14.0), Offset(flangeX, topY), dimPaint);
    _drawArrowHead(canvas, Offset(flangeX, topY), -math.pi / 2, size: 4.8);
    canvas.drawLine(Offset(flangeX, topY + tf + 12.0), Offset(flangeX, topY + tf), dimPaint);
    _drawArrowHead(canvas, Offset(flangeX, topY + tf), math.pi / 2, size: 4.8);
    _drawBoxedDimension(canvas, Offset(flangeX, topY + tf + 22.0), data.flangeThickVal.toStringAsFixed(1));

    // Web thickness tw (Inward opposing horizontal arrows, matching engineering slide rule standard)
    _drawWebThickCallout(
      canvas: canvas,
      webLeft: startX,
      webRight: startX + tw,
      centerY: topY + h * 0.72,
      valStr: data.webThickVal.toStringAsFixed(1),
    );
  }

  void _drawAngle2D(Canvas canvas, Size size) {
    final bool isEqualAngle = data.headerTitle == 'ANGLE EQUAL' ||
        (data.shapeCategory == 'ANGLE' && !data.headerTitle.contains('UNEQUAL'));

    if (isEqualAngle) {
      _drawEqualAngle2D(canvas, size);
    } else {
      _drawUnequalAngle2D(canvas, size);
    }
  }

  void _drawEqualAngle2D(Canvas canvas, Size size) {
    _drawSpecTable(canvas, const Offset(12.0, 186.0), data);

    const double leg = 118.0;
    const double legH = leg;
    const double legB = leg;
    final double thick = (10.0 + (data.webThickVal / 20.0 * 10.0)).clamp(12.0, 20.0);
    const double r1 = 12.0; // concave inner root radius
    const double r2 = 3.5;  // toe rounding radius
    const double topY = 18.0;

    // Position angle on the right side of the canvas
    final double startX = (size.width - 56.0 - legB).clamp(120.0, 240.0);

    // 1. Equal Angle Path with rounded toes and inner concave fillet
    final Path path = Path();
    path.moveTo(startX, topY + legH); // Outer heel
    path.lineTo(startX, topY + r2); // Up left edge of vertical leg
    path.arcToPoint(Offset(startX + r2, topY), radius: const Radius.circular(r2)); // Top-left toe
    path.lineTo(startX + thick - r2, topY); // Across top tip
    path.arcToPoint(Offset(startX + thick, topY + r2), radius: const Radius.circular(r2)); // Top-right toe
    path.lineTo(startX + thick, topY + legH - thick - r1); // Down inside face of vertical leg
    path.arcToPoint(
      Offset(startX + thick + r1, topY + legH - thick),
      radius: const Radius.circular(r1),
      clockwise: false,
    ); // Smooth concave root fillet
    path.lineTo(startX + legB - r2, topY + legH - thick); // Across inside face of horizontal leg
    path.arcToPoint(Offset(startX + legB, topY + legH - thick + r2), radius: const Radius.circular(r2)); // Upper-right toe
    path.lineTo(startX + legB, topY + legH - r2); // Down toe edge
    path.arcToPoint(Offset(startX + legB - r2, topY + legH), radius: const Radius.circular(r2)); // Lower-right toe
    path.lineTo(startX, topY + legH); // Bottom edge back to heel
    path.close();

    // Solid Blueprint Fill
    canvas.drawPath(path, Paint()..color = const Color(0xFF0D5C9D));

    // Outer Crisp CAD Stroke
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFBDC3C7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // 2. Left Height Dimension (Spanning full height on the left, matching Image 1)
    final double hDimX = startX - 24.0;
    _drawExtensionLine(canvas, Offset(startX, topY), Offset(hDimX - 8.0, topY));
    _drawExtensionLine(canvas, Offset(startX, topY + legH), Offset(hDimX - 8.0, topY + legH));
    _drawDoubleArrowLine(
      canvas,
      Offset(hDimX, topY),
      Offset(hDimX, topY + legH),
      data.heightVal.toStringAsFixed(0),
    );

    // 3. Center Size Range Text (e.g. "20 x 20 to 200 x 200")
    final String rangeStr = '20 x 20 to 200 x 200';
    final TextPainter tpCenter = TextPainter(
      text: TextSpan(
        text: rangeStr,
        style: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E293B),
          letterSpacing: 0.3,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final double centerTextX = startX + thick + 12.0;
    final double centerTextY = topY + (legH - thick) / 2 - tpCenter.height / 2;
    tpCenter.paint(canvas, Offset(centerTextX, centerTextY));

    // 4. Right Thickness Dimension (Inward-pointing arrows with boxed value, matching Image 1)
    final double tArrowX = startX + legB + 16.0;
    final double tTopY = topY + legH - thick;
    final double tBottomY = topY + legH;

    _drawExtensionLine(canvas, Offset(startX + legB, tTopY), Offset(tArrowX + 8.0, tTopY));
    _drawExtensionLine(canvas, Offset(startX + legB, tBottomY), Offset(tArrowX + 8.0, tBottomY));

    final Paint dimPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 1.1;

    // Upper arrow pointing down into horizontal leg
    canvas.drawLine(Offset(tArrowX, tTopY - 14.0), Offset(tArrowX, tTopY), dimPaint);
    _drawArrowHead(canvas, Offset(tArrowX, tTopY), -math.pi / 2, size: 5.0);

    // Lower arrow pointing up into horizontal leg
    canvas.drawLine(Offset(tArrowX, tBottomY + 14.0), Offset(tArrowX, tBottomY), dimPaint);
    _drawArrowHead(canvas, Offset(tArrowX, tBottomY), math.pi / 2, size: 5.0);

    // Boxed Thickness Value to the right of arrows
    final String tStr = data.webThickVal % 1 == 0
        ? data.webThickVal.toInt().toString()
        : data.webThickVal.toStringAsFixed(1);
    final double tBoxX = tArrowX + 20.0;
    final double tBoxY = (tTopY + tBottomY) / 2;
    _drawBoxedDimension(canvas, Offset(tBoxX, tBoxY), tStr);
  }

  void _drawUnequalAngle2D(Canvas canvas, Size size) {
    _drawSpecTable(canvas, const Offset(12.0, 172.0), data);

    final double diagramZoneEnd = size.width - 12.0;
    const double dimRightReserve = 34.0;
    final double rawAspect = data.widthVal / (data.heightVal > 0 ? data.heightVal : 100.0);
    const double legH = 136.0;
    final double legB = (legH * rawAspect.clamp(0.40, 0.90)).clamp(56.0, 95.0);
    final double thick = (10.0 + (data.webThickVal / 20.0 * 5.0)).clamp(11.0, 16.0);
    const double r = 6.0;
    const double topY = 18.0;

    final double startX = diagramZoneEnd - dimRightReserve - legB;

    final Path path = Path();
    path.moveTo(startX, topY);
    path.lineTo(startX + thick, topY);
    path.lineTo(startX + thick, topY + legH - thick - r);
    path.arcToPoint(
      Offset(startX + thick + r, topY + legH - thick),
      radius: const Radius.circular(r),
      clockwise: false,
    );
    path.lineTo(startX + legB, topY + legH - thick);
    path.lineTo(startX + legB, topY + legH);
    path.lineTo(startX, topY + legH);
    path.close();

    canvas.drawPath(path, Paint()..color = const Color(0xFF0D5C9D));
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFBDC3C7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // Height H (Right)
    final double hDimX = startX + legB + 16.0;
    _drawExtensionLine(canvas, Offset(startX, topY), Offset(hDimX + 8, topY));
    _drawExtensionLine(canvas, Offset(startX, topY + legH), Offset(hDimX + 8, topY + legH));
    _drawDoubleArrowLine(canvas, Offset(hDimX, topY), Offset(hDimX, topY + legH), data.heightVal.toStringAsFixed(0));

    // Width B (Bottom)
    const double bDimY = topY + legH + 22.0;
    _drawExtensionLine(canvas, Offset(startX, topY + legH), Offset(startX, bDimY + 8));
    _drawExtensionLine(canvas, Offset(startX + legB, topY + legH), Offset(startX + legB, bDimY + 8));
    _drawDoubleArrowLine(canvas, Offset(startX, bDimY), Offset(startX + legB, bDimY), data.widthVal.toStringAsFixed(0));

    // Thickness callout
    _drawCalloutArrow(
      canvas,
      Offset(startX + thick * 0.5, topY + 28),
      Offset(startX + thick + 26, topY + 28),
      data.webThickVal.toStringAsFixed(1),
    );
  }

  void _drawBeam2D(Canvas canvas, Size size) {
    // 1. Draw Specification Table at bottom-left
    _drawSpecTable(canvas, const Offset(12.0, 168.0), data);

    // 2. Identify if this profile is an H-Beam / Wide Flange profile (b ≈ h) or Deep I-Beam (h >> b)
    final double rawAspect = data.widthVal / (data.heightVal > 0 ? data.heightVal : 140.0);
    final String combinedName = '${data.variantTag} ${data.headerTitle} ${data.displayName}'.toUpperCase();
    final bool isHBeam = !combinedName.contains('I-BEAM') &&
        (combinedName.contains('HEA') ||
            combinedName.contains('HEB') ||
            combinedName.contains('UC') ||
            combinedName.contains('H-BEAM') ||
            (combinedName.contains('JIS') && !combinedName.contains('I-BEAM')) ||
            rawAspect >= 0.70);

    // 3. Beam geometry:
    // Wide-Flange H-Beams / Columns (HEA, HEB, UC, square W-Beams) have equal or near-equal width & height (b ≈ h)
    // Universal Beams and deep W-Beams (UB, IPE, IPE-AA, deep W-Beams, I-Beams) are deep and narrow (h >> b)
    final double h = isHBeam ? 124.0 : 144.0;
    final double b = isHBeam
        ? (h * rawAspect.clamp(0.85, 1.15)).clamp(104.0, 126.0)
        : (h * rawAspect.clamp(0.40, 0.55)).clamp(52.0, 72.0);

    final double tf = isHBeam
        ? (12.0 + (data.flangeThickVal / 25.0 * 4.0)).clamp(12.5, 16.0)
        : (9.0 + (data.flangeThickVal / 25.0 * 3.5)).clamp(9.5, 12.0);
    final double tw = isHBeam
        ? (8.5 + (data.webThickVal / 15.0 * 3.5)).clamp(9.0, 12.0)
        : (6.0 + (data.webThickVal / 15.0 * 2.5)).clamp(6.5, 8.5);
    final double r = isHBeam ? 8.0 : 5.0; // root fillet radius
    final double topY = isHBeam ? 19.0 : 13.0;

    final double diagramRight = size.width - 10.0;
    const double rightDimReserve = 44.0;
    final double centerX = diagramRight - rightDimReserve - (b / 2);

    // 4. I/H-Beam Vector Path with smooth inner root fillets
    final Path path = Path();
    path.moveTo(centerX - b / 2, topY);
    path.lineTo(centerX + b / 2, topY);
    path.lineTo(centerX + b / 2, topY + tf);
    path.lineTo(centerX + tw / 2 + r, topY + tf);
    path.arcToPoint(
      Offset(centerX + tw / 2, topY + tf + r),
      radius: Radius.circular(r),
      clockwise: false,
    );
    path.lineTo(centerX + tw / 2, topY + h - tf - r);
    path.arcToPoint(
      Offset(centerX + tw / 2 + r, topY + h - tf),
      radius: Radius.circular(r),
      clockwise: false,
    );
    path.lineTo(centerX + b / 2, topY + h - tf);
    path.lineTo(centerX + b / 2, topY + h);
    path.lineTo(centerX - b / 2, topY + h);
    path.lineTo(centerX - b / 2, topY + h - tf);
    path.lineTo(centerX - tw / 2 - r, topY + h - tf);
    path.arcToPoint(
      Offset(centerX - tw / 2, topY + h - tf - r),
      radius: Radius.circular(r),
      clockwise: false,
    );
    path.lineTo(centerX - tw / 2, topY + tf + r);
    path.arcToPoint(
      Offset(centerX - tw / 2 - r, topY + tf),
      radius: Radius.circular(r),
      clockwise: false,
    );
    path.lineTo(centerX - b / 2, topY + tf);
    path.close();

    // Solid Blueprint Fill (#0D5C9D)
    canvas.drawPath(path, Paint()..color = const Color(0xFF0D5C9D));

    // Crisp Light Outline Stroke (#BDC3C7)
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFBDC3C7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // 5. Large profile designation text (e.g. "HEA", "HEB", "UC", "UB", "W", "H", "I") situated in the left pocket
    String profileLabel = data.variantTag.isNotEmpty ? data.variantTag : (isHBeam ? 'H' : 'I');
    if (combinedName.contains('I-BEAM') || profileLabel.toUpperCase() == 'I-BEAM' || profileLabel.toUpperCase() == 'I') {
      profileLabel = 'I';
    } else if (combinedName.contains('H-BEAM') || profileLabel.toUpperCase() == 'H-BEAM' || profileLabel.toUpperCase() == 'H') {
      profileLabel = 'H';
    } else if (profileLabel.toUpperCase().contains('W-BEAM') || profileLabel.toUpperCase() == 'W') {
      profileLabel = 'W';
    }

    final double pocketLeft = centerX - b / 2 + 4.0;
    final double pocketRight = centerX - tw / 2 - 4.0;
    final double pocketWidth = (pocketRight - pocketLeft).clamp(10.0, 100.0);

    double fSize = 18.0;
    TextPainter lp = TextPainter(
      text: TextSpan(
        text: profileLabel,
        style: TextStyle(
          fontSize: fSize,
          fontWeight: FontWeight.w900,
          color: const Color(0xFF1E293B),
          letterSpacing: 0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // Dynamically scale down font if text is too wide for the pocket
    while (lp.width > pocketWidth && fSize > 8.0) {
      fSize -= 1.0;
      lp = TextPainter(
        text: TextSpan(
          text: profileLabel,
          style: TextStyle(
            fontSize: fSize,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF1E293B),
            letterSpacing: 0.5,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
    }

    final double labelX = pocketLeft + (pocketWidth - lp.width) / 2;
    final double labelY = topY + (h - lp.height) / 2;
    lp.paint(canvas, Offset(labelX, labelY));

    // 6. Flange thickness tf callout (Top-Left)
    _drawFlangeThickCallout(
      canvas: canvas,
      flangeLeft: centerX - b / 2,
      topY: topY,
      tf: tf,
      valStr: data.flangeThickVal.toStringAsFixed(1),
    );

    // 7. Web thickness tw callout (Upper-Right)
    _drawWebThickCallout(
      canvas: canvas,
      webLeft: centerX - tw / 2,
      webRight: centerX + tw / 2,
      centerY: topY + h * 0.28,
      valStr: data.webThickVal.toStringAsFixed(1),
    );

    // 8. Height H Dimension (Right) - vertical line with centered boxed number
    final double hDimX = centerX + b / 2 + 18.0;
    final Paint extPaint = Paint()
      ..color = const Color(0xFF7F8C8D)
      ..strokeWidth = 0.8;
    canvas.drawLine(Offset(centerX + b / 2, topY), Offset(hDimX + 8.0, topY), extPaint);
    canvas.drawLine(Offset(centerX + b / 2, topY + h), Offset(hDimX + 8.0, topY + h), extPaint);

    final Paint dimPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 1.1;
    canvas.drawLine(Offset(hDimX, topY), Offset(hDimX, topY + h), dimPaint);
    _drawArrowHead(canvas, Offset(hDimX, topY), math.pi / 2, size: 5.5);
    _drawArrowHead(canvas, Offset(hDimX, topY + h), -math.pi / 2, size: 5.5);
    _drawBoxedDimension(canvas, Offset(hDimX, topY + h * 0.48), data.heightVal.toStringAsFixed(0));

    // 9. Flange Width B Dimension (Bottom)
    final double bDimY = topY + h + 20.0;
    canvas.drawLine(Offset(centerX - b / 2, topY + h), Offset(centerX - b / 2, bDimY + 8.0), extPaint);
    canvas.drawLine(Offset(centerX + b / 2, topY + h), Offset(centerX + b / 2, bDimY + 8.0), extPaint);

    canvas.drawLine(Offset(centerX - b / 2, bDimY), Offset(centerX + b / 2, bDimY), dimPaint);
    _drawArrowHead(canvas, Offset(centerX - b / 2, bDimY), 0, size: 5.5);
    _drawArrowHead(canvas, Offset(centerX + b / 2, bDimY), math.pi, size: 5.5);
    _drawBoxedDimension(canvas, Offset(centerX, bDimY), data.widthVal.toStringAsFixed(0));
  }

  void _drawBar2D(Canvas canvas, Size size) {
    _drawSpecTable(canvas, const Offset(12.0, 172.0), data);

    final double diagramZoneEnd = size.width - 12.0;
    final double centerX = diagramZoneEnd - 55.0;
    const double centerY = 78.0;
    const double radius = 48.0;

    final Offset center = Offset(centerX, centerY);

    canvas.drawCircle(center, radius, Paint()..color = const Color(0xFF0D5C9D));
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0xFFBDC3C7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // Crosshairs
    final Paint crossPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(center.dx - radius - 8, center.dy), Offset(center.dx + radius + 8, center.dy), crossPaint);
    canvas.drawLine(Offset(center.dx, center.dy - radius - 8), Offset(center.dx, center.dy + radius + 8), crossPaint);

    _drawDoubleArrowLine(
      canvas,
      Offset(center.dx - radius, center.dy + radius + 22),
      Offset(center.dx + radius, center.dy + radius + 22),
      'Ø ${data.diameterVal.toStringAsFixed(0)}',
    );
  }

  void _drawTube2D(Canvas canvas, Size size) {
    _drawSpecTable(canvas, const Offset(12.0, 172.0), data);

    final bool isRect = data.shapeCategory == 'TUBE' && data.heightVal != data.widthVal;
    final double h = isRect ? 136.0 : 96.0;
    final double w = isRect
        ? (h * (data.widthVal / (data.heightVal > 0 ? data.heightVal : 80))).clamp(48.0, 78.0)
        : 96.0;
    const double t = 10.0;
    const double topY = 18.0;

    final double diagramRight = size.width - 12.0;
    const double rightDimReserve = 34.0;
    final double startX = diagramRight - rightDimReserve - w;

    final RRect outer = RRect.fromRectAndRadius(
      Rect.fromLTWH(startX, topY, w, h),
      const Radius.circular(5.0),
    );
    final RRect inner = RRect.fromRectAndRadius(
      Rect.fromLTWH(startX + t, topY + t, w - 2 * t, h - 2 * t),
      const Radius.circular(3.0),
    );

    final Path tubePath = Path()
      ..addRRect(outer)
      ..addRRect(inner)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(tubePath, Paint()..color = const Color(0xFF0D5C9D));
    canvas.drawRRect(
      outer,
      Paint()
        ..color = const Color(0xFFBDC3C7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
    canvas.drawRRect(
      inner,
      Paint()
        ..color = const Color(0xFFBDC3C7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // Height H (Right)
    final double hDimX = startX + w + 16.0;
    _drawExtensionLine(canvas, Offset(startX + w, topY), Offset(hDimX + 8, topY));
    _drawExtensionLine(canvas, Offset(startX + w, topY + h), Offset(hDimX + 8, topY + h));
    _drawDoubleArrowLine(canvas, Offset(hDimX, topY), Offset(hDimX, topY + h), data.heightVal.toStringAsFixed(0));

    // Width B (Bottom)
    final double bDimY = topY + h + 22.0;
    _drawExtensionLine(canvas, Offset(startX, topY + h), Offset(startX, bDimY + 8));
    _drawExtensionLine(canvas, Offset(startX + w, topY + h), Offset(startX + w, bDimY + 8));
    _drawDoubleArrowLine(canvas, Offset(startX, bDimY), Offset(startX + w, bDimY), data.widthVal.toStringAsFixed(0));

    // Thickness callout
    _drawCalloutArrow(
      canvas,
      Offset(startX + t / 2, topY + h * 0.44),
      Offset(startX - 24, topY + h * 0.44),
      't=${data.webThickVal.toStringAsFixed(1)}',
    );
  }

  void _drawPipe2D(Canvas canvas, Size size) {
    _drawSpecTable(canvas, const Offset(12.0, 172.0), data);

    final double diagramZoneEnd = size.width - 12.0;
    final double centerX = diagramZoneEnd - 55.0;
    const double centerY = 78.0;
    const double outerR = 52.0;
    const double innerR = 38.0;

    final Offset center = Offset(centerX, centerY);

    final Path path = Path()
      ..addOval(Rect.fromCircle(center: center, radius: outerR))
      ..addOval(Rect.fromCircle(center: center, radius: innerR))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, Paint()..color = const Color(0xFF0D5C9D));
    canvas.drawCircle(
      center,
      outerR,
      Paint()
        ..color = const Color(0xFFBDC3C7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
    canvas.drawCircle(
      center,
      innerR,
      Paint()
        ..color = const Color(0xFFBDC3C7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // Crosshairs
    final Paint crossPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(center.dx - outerR - 8, center.dy), Offset(center.dx + outerR + 8, center.dy), crossPaint);
    canvas.drawLine(Offset(center.dx, center.dy - outerR - 8), Offset(center.dx, center.dy + outerR + 8), crossPaint);

    // Diameter Dim
    _drawDoubleArrowLine(
      canvas,
      Offset(center.dx - outerR, center.dy + outerR + 22),
      Offset(center.dx + outerR, center.dy + outerR + 22),
      'OD ${data.diameterVal.toStringAsFixed(1)}',
    );

    // Wall thickness callout
    _drawCalloutArrow(
      canvas,
      Offset(center.dx - (outerR + innerR) * 0.5, center.dy),
      Offset(center.dx - outerR - 22, center.dy - 20),
      't=${data.webThickVal.toStringAsFixed(1)}',
    );
  }

  void _drawSheetOrFlat2D(Canvas canvas, Size size) {
    _drawSpecTable(canvas, const Offset(12.0, 172.0), data);

    const double topY = 52.0;
    const double plateW = 130.0;
    const double plateH = 26.0;
    final double diagramZoneEnd = size.width - 12.0;
    // Ample reserve on the right so thickness dimension & badge never overlap plate or screen edge
    const double rightReserve = 64.0;
    final double startX = diagramZoneEnd - rightReserve - plateW;

    final Rect plateRect = Rect.fromLTWH(startX, topY, plateW, plateH);
    canvas.drawRect(plateRect, Paint()..color = const Color(0xFF0D5C9D));
    canvas.drawRect(
      plateRect,
      Paint()
        ..color = const Color(0xFFBDC3C7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // If Checkered / Tread sheet, render subtle CAD tread marks on the top surface
    final bool isCheckered = data.headerTitle.contains('CHECKERED') ||
        data.displayName.contains('Chequered') ||
        data.displayName.contains('Tread');
    if (isCheckered) {
      final Paint patternPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      for (double px = startX + 14.0; px < startX + plateW - 10.0; px += 18.0) {
        canvas.drawLine(Offset(px - 4, topY + 8), Offset(px + 4, topY + 16), patternPaint);
        canvas.drawLine(Offset(px + 4, topY + 8), Offset(px - 4, topY + 16), patternPaint);
      }
    }

    // Thickness dimension (Right) - placed with clean clearance from the plate
    final double dimX = startX + plateW + 30.0;
    _drawExtensionLine(canvas, Offset(startX + plateW, topY), Offset(dimX + 10, topY));
    _drawExtensionLine(canvas, Offset(startX + plateW, topY + plateH), Offset(dimX + 10, topY + plateH));
    _drawDoubleArrowLine(
      canvas,
      Offset(dimX, topY),
      Offset(dimX, topY + plateH),
      't=${data.webThickVal.toStringAsFixed(1)}',
    );

    // Width dimension (Bottom)
    const double dimY = topY + plateH + 24.0;
    _drawExtensionLine(canvas, Offset(startX, topY + plateH), Offset(startX, dimY + 8));
    _drawExtensionLine(canvas, Offset(startX + plateW, topY + plateH), Offset(startX + plateW, dimY + 8));
    _drawDoubleArrowLine(
      canvas,
      Offset(startX, dimY),
      Offset(startX + plateW, dimY),
      '${data.widthVal.toStringAsFixed(0)} mm',
    );
  }

  void _drawFlangeThickCallout({
    required Canvas canvas,
    required double flangeLeft,
    required double topY,
    required double tf,
    required String valStr,
  }) {
    final double dimLineX = flangeLeft - 18.0;
    final Paint witPaint = Paint()
      ..color = const Color(0xFF7F8C8D)
      ..strokeWidth = 0.8;
    canvas.drawLine(Offset(flangeLeft, topY), Offset(dimLineX - 6.0, topY), witPaint);
    canvas.drawLine(Offset(flangeLeft, topY + tf), Offset(dimLineX - 6.0, topY + tf), witPaint);

    final Paint dimPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(dimLineX, topY - 12.0), Offset(dimLineX, topY), dimPaint);
    _drawArrowHead(canvas, Offset(dimLineX, topY), -math.pi / 2, size: 4.8);

    canvas.drawLine(Offset(dimLineX, topY + tf + 12.0), Offset(dimLineX, topY + tf), dimPaint);
    _drawArrowHead(canvas, Offset(dimLineX, topY + tf), math.pi / 2, size: 4.8);

    _drawBoxedDimension(canvas, Offset(dimLineX - 22.0, topY + tf / 2), valStr);
  }

  void _drawWebThickCallout({
    required Canvas canvas,
    required double webLeft,
    required double webRight,
    required double centerY,
    required String valStr,
  }) {
    final Paint dimPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 1.0;

    canvas.drawLine(Offset(webLeft - 10.0, centerY), Offset(webLeft, centerY), dimPaint);
    _drawArrowHead(canvas, Offset(webLeft, centerY), math.pi, size: 4.5);

    canvas.drawLine(Offset(webRight + 10.0, centerY), Offset(webRight, centerY), dimPaint);
    _drawArrowHead(canvas, Offset(webRight, centerY), 0, size: 4.5);

    const double leaderEnd = 16.0;
    canvas.drawLine(Offset(webRight + 10.0, centerY), Offset(webRight + leaderEnd, centerY), dimPaint);

    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: valStr,
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0D5C9D),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final double boxWidth = tp.width + 10.0;
    final double boxCenterX = webRight + leaderEnd + boxWidth / 2;
    _drawBoxedDimension(canvas, Offset(boxCenterX, centerY), valStr);
  }

  void _drawExtensionLine(Canvas canvas, Offset p1, Offset p2) {
    canvas.drawLine(p1, p2, Paint()..color = const Color(0xFF7F8C8D)..strokeWidth = 0.8);
  }

  void _drawDoubleArrowLine(Canvas canvas, Offset p1, Offset p2, String label) {
    canvas.drawLine(p1, p2, Paint()..color = const Color(0xFF1E293B)..strokeWidth = 1.2);

    const double arrowSize = 5.5;
    final double angle = math.atan2(p2.dy - p1.dy, p2.dx - p1.dx);

    _drawArrowHead(canvas, p1, angle, size: arrowSize);
    _drawArrowHead(canvas, p2, angle + math.pi, size: arrowSize);

    final Offset midPoint = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
    _drawBoxedDimension(canvas, midPoint, label);
  }

  void _drawArrowHead(Canvas canvas, Offset tip, double angle, {double size = 5.5}) {
    final Path path = Path();
    path.moveTo(tip.dx, tip.dy);
    path.lineTo(
      tip.dx + size * math.cos(angle + math.pi / 6),
      tip.dy + size * math.sin(angle + math.pi / 6),
    );
    path.lineTo(
      tip.dx + size * math.cos(angle - math.pi / 6),
      tip.dy + size * math.sin(angle - math.pi / 6),
    );
    path.close();
    canvas.drawPath(path, Paint()..color = const Color(0xFF1E293B));
  }

  void _drawCalloutArrow(Canvas canvas, Offset target, Offset labelPos, String label) {
    canvas.drawLine(target, labelPos, Paint()..color = const Color(0xFF1E293B)..strokeWidth = 1.0);
    final double angle = math.atan2(target.dy - labelPos.dy, target.dx - labelPos.dx);
    _drawArrowHead(canvas, target, angle + math.pi, size: 5.0);
    _drawBoxedDimension(canvas, labelPos, label);
  }

  void _drawBoxedDimension(Canvas canvas, Offset center, String text) {
    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0D5C9D), // Royal Blueprint Blue
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final Rect boxRect = Rect.fromCenter(
      center: center,
      width: tp.width + 10.0,
      height: tp.height + 4.0,
    );
    canvas.drawRect(boxRect, Paint()..color = Colors.white);
    canvas.drawRect(
      boxRect,
      Paint()
        ..color = const Color(0xFF0D5C9D)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant Section2DPainter oldDelegate) {
    return oldDelegate.data.heightVal != data.heightVal ||
        oldDelegate.data.widthVal != data.widthVal ||
        oldDelegate.data.webThickVal != data.webThickVal ||
        oldDelegate.data.flangeThickVal != data.flangeThickVal ||
        oldDelegate.data.weightVal != data.weightVal ||
        oldDelegate.data.sectionAreaVal != data.sectionAreaVal ||
        oldDelegate.data.displayName != data.displayName ||
        oldDelegate.data.variantTag != data.variantTag ||
        oldDelegate.data.sizeTag != data.sizeTag;
  }
}
