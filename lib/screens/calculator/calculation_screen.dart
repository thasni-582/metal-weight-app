import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:metal_weight/core/constants/app_colors.dart';
import 'package:metal_weight/core/constants/standard_data.dart';
import 'package:metal_weight/core/providers/app_settings_provider.dart';
import 'package:metal_weight/models/calculation_model.dart';
import 'package:metal_weight/models/profile_spec.dart';
import 'package:metal_weight/screens/calculator/widgets/custom_shape_diagram_2d.dart';
import 'package:metal_weight/services/history_service.dart';
import 'package:metal_weight/services/pdf_export_service.dart';

class CalculationScreen extends StatefulWidget {
  const CalculationScreen({super.key});

  @override
  State<CalculationScreen> createState() => _CalculationScreenState();
}

class _CalculationScreenState extends State<CalculationScreen> {
  // State variables
  String _selectedMetal = 'Steel';
  String _selectedShape = 'Sheet / Plate';
  bool _isMetric = true; // true = Metric (mm, kg), false = Imperial (in, lbs)

  // Controllers for dimensions
  final TextEditingController _lengthController =
      TextEditingController(text: '1000');
  final TextEditingController _widthController =
      TextEditingController(text: '500');
  final TextEditingController _thicknessController =
      TextEditingController(text: '12');
  final TextEditingController _outerDiaController =
      TextEditingController(text: '50');
  final TextEditingController _heightController =
      TextEditingController(text: '100');
  final TextEditingController _webThicknessController =
      TextEditingController(text: '6');
  final TextEditingController _flangeThicknessController =
      TextEditingController(text: '8');
  final TextEditingController _quantityController =
      TextEditingController(text: '1');
  final TextEditingController _priceController =
      TextEditingController(text: '4.50');
  final TextEditingController _customDensityController =
      TextEditingController(text: '7.85');

  // Computed Outputs
  double _calculatedWeightPerPiece = 0.0;
  double _calculatedTotalWeight = 0.0;
  double _calculatedCost = 0.0;
  double _calculatedVolume = 0.0;
  double _calculatedSurfaceArea = 0.0;
  double _lastUnitWeightPerM = 0.0;
  double _lastSectionAreaCm2 = 0.0;
  String _selectedBeamPreset = 'Custom';
  bool _isExportingPdf = false;

  final HistoryService _historyService = HistoryService();

  // Metal densities (g/cm³)
  final Map<String, double> _metalDensities = {
    'Steel': 7.85,
    'Stainless Steel': 8.00,
    'Galvanized Sheet': 8.10,
    'HR Chequered Sheet': 8.50,
    'Aluminum': 2.70,
    'Copper': 8.96,
    'Brass': 8.73,
    'Bronze': 8.80,
    'Titanium': 4.51,
    'Cast Iron': 7.20,
    'Lead': 11.34,
    'Zinc': 7.13,
    'Custom': 7.85,
  };

  final List<String> _shapes = [
    'Sheet / Plate',
    'Round Bar',
    'Square Bar',
    'Flat Bar',
    'Hexagonal Bar',
    'Round Tube / Pipe',
    'Square / Rectangular Tube',
    'Angle (L-Profile)',
    'U-Channel / Channel (C-Profile)',
    'H-Beam',
    'I-Beam',
  ];

  int _lastAppliedSyncVersion = 0;

  @override
  void initState() {
    super.initState();
    _performCalculation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final settings = Provider.of<AppSettingsProvider>(context);
    _checkAndApplyHomeSync(settings);
  }

  void _checkAndApplyHomeSync(AppSettingsProvider settings) {
    final payload = settings.syncedProfileFromHome;
    if (payload != null && settings.syncVersion != _lastAppliedSyncVersion) {
      _lastAppliedSyncVersion = settings.syncVersion;
      _applyHomeSyncPayload(payload);
    }
  }

  void _applyHomeSyncPayload(ProfileSyncPayload p) {
    // 1. Material
    if (_metalDensities.containsKey(p.material)) {
      _selectedMetal = p.material;
    } else {
      _selectedMetal = 'Steel';
    }

    // 2. Quantity
    _quantityController.text = p.quantity.toString();

    // 3. Length (meters to mm)
    final int lenMm = (p.lengthInM * 1000).round();
    _lengthController.text = lenMm > 0 ? lenMm.toString() : '1000';

    // 4. Map Shape and Dimensions
    final String homeShape = p.shape;
    final String size = p.size;
    final String thick = p.thickness;

    if (homeShape.contains('Angle')) {
      _selectedShape = 'Angle (L-Profile)';
      if (homeShape.contains('Unequal') || size.contains('x')) {
        final parts = size.split('x');
        _widthController.text = parts[0].trim();
        _heightController.text = parts.length > 1 ? parts[1].trim() : parts[0].trim();
      } else {
        _widthController.text = size;
        _heightController.text = size;
      }
      _thicknessController.text = thick.isNotEmpty ? thick : '5';
    } else if (homeShape.contains('Channel')) {
      _selectedShape = 'U-Channel / Channel (C-Profile)';
      StandardProfileSpec? spec;
      if (p.variant == 'UPE') {
        spec = StandardData.upeChannels[size];
      } else if (p.variant == 'JIS' || homeShape.contains('JIS')) {
        spec = StandardData.jisChannels[size];
      } else {
        spec = StandardData.upnChannels[size];
      }
      if (spec != null) {
        _heightController.text = spec.h.toStringAsFixed(spec.h % 1 == 0 ? 0 : 1);
        _widthController.text = spec.b.toStringAsFixed(spec.b % 1 == 0 ? 0 : 1);
        _webThicknessController.text = spec.tw.toStringAsFixed(1);
        _flangeThicknessController.text = spec.tf.toStringAsFixed(1);
      }
    } else if (homeShape.contains('Tube')) {
      _selectedShape = 'Square / Rectangular Tube';
      if (size.contains('x')) {
        final parts = size.split('x');
        _widthController.text = parts[0].trim();
        _heightController.text = parts.length > 1 ? parts[1].trim() : parts[0].trim();
      } else {
        _widthController.text = size;
        _heightController.text = size;
      }
      _thicknessController.text = thick.isNotEmpty ? thick : '2.0';
    } else if (homeShape.contains('Pipe')) {
      _selectedShape = 'Round Tube / Pipe';
      final m = RegExp(r'\((\d+(?:\.\d+)?)\s*mm\)').firstMatch(size);
      if (m != null) {
        _outerDiaController.text = m.group(1)!;
      } else {
        _outerDiaController.text = '50';
      }
      final mt = RegExp(r'\((\d+(?:\.\d+)?)\s*mm\)').firstMatch(thick);
      if (mt != null) {
        _thicknessController.text = mt.group(1)!;
      } else {
        _thicknessController.text = '3.5';
      }
    } else if (homeShape.contains('Round') || homeShape.contains('Shaft')) {
      _selectedShape = 'Round Bar';
      _outerDiaController.text = size.replaceAll(RegExp(r'[^0-9.]'), '');
    } else if (homeShape.contains('Square Bar')) {
      _selectedShape = 'Square Bar';
      _widthController.text = size.replaceAll(RegExp(r'[^0-9.]'), '');
    } else if (homeShape.contains('Flat')) {
      _selectedShape = 'Flat Bar';
      _widthController.text = size.replaceAll(RegExp(r'[^0-9.]'), '');
      _thicknessController.text = thick.isNotEmpty ? thick : '6';
    } else if (homeShape.contains('Sheet') || homeShape.contains('Plate')) {
      _selectedShape = 'Sheet / Plate';
      _thicknessController.text = size.replaceAll(RegExp(r'[^0-9.]'), '');
    } else if (homeShape.contains('Beam') || homeShape.contains('Columns') || homeShape.contains('Universal')) {
      StandardProfileSpec? spec;
      bool isH = false;

      if (StandardData.clientIBeams.containsKey(size)) {
        spec = StandardData.clientIBeams[size];
        isH = false;
      } else if (StandardData.clientHBeams.containsKey(size)) {
        spec = StandardData.clientHBeams[size];
        isH = true;
      } else if (StandardData.jisBeams.containsKey(size)) {
        spec = StandardData.jisBeams[size];
        isH = spec != null && (spec.b / spec.h) >= 0.70;
      } else if (p.variant == 'UC' && StandardData.ucBeams.containsKey(size)) {
        spec = StandardData.ucBeams[size];
        isH = true;
      } else if (p.variant == 'UB' && StandardData.ubBeams.containsKey(size)) {
        spec = StandardData.ubBeams[size];
        isH = false;
      } else if (p.variant == 'HEA' && StandardData.heaBeams.containsKey(size)) {
        spec = StandardData.heaBeams[size];
        isH = true;
      } else if (p.variant == 'HEB' && StandardData.hebBeams.containsKey(size)) {
        spec = StandardData.hebBeams[size];
        isH = true;
      } else if (p.variant == 'IPE-AA' && StandardData.ipeAaBeams.containsKey(size)) {
        spec = StandardData.ipeAaBeams[size];
        isH = false;
      } else if (StandardData.ipeBeams.containsKey(size)) {
        spec = StandardData.ipeBeams[size];
        isH = false;
      } else if (StandardData.wBeams.containsKey(size) || StandardData.findWBeam(size) != null) {
        spec = StandardData.wBeams[size] ?? StandardData.findWBeam(size);
        isH = spec != null && (spec.b / spec.h) >= 0.70;
      }

      if (homeShape == 'H-Beam' || (homeShape.contains('H-Beam') && isH)) {
        _selectedShape = 'H-Beam';
      } else if (homeShape == 'I-Beam' || (!isH)) {
        _selectedShape = 'I-Beam';
      } else {
        _selectedShape = isH ? 'H-Beam' : 'I-Beam';
      }

      _selectedBeamPreset = size;
      if (spec != null) {
        _heightController.text = spec.h.toStringAsFixed(spec.h % 1 == 0 ? 0 : 1);
        _widthController.text = spec.b.toStringAsFixed(spec.b % 1 == 0 ? 0 : 1);
        _webThicknessController.text = spec.tw.toStringAsFixed(1);
        _flangeThicknessController.text = spec.tf.toStringAsFixed(1);
      }
    }

    _performCalculation();
  }

  @override
  void dispose() {
    _lengthController.dispose();
    _widthController.dispose();
    _thicknessController.dispose();
    _outerDiaController.dispose();
    _heightController.dispose();
    _webThicknessController.dispose();
    _flangeThicknessController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _customDensityController.dispose();
    super.dispose();
  }

  double _getEffectiveDensity() {
    if (_selectedMetal == 'Custom') {
      return double.tryParse(_customDensityController.text) ?? 7.85;
    }
    return _metalDensities[_selectedMetal] ?? 7.85;
  }

  void _onUnitSystemChanged(bool toMetric) {
    if (_isMetric == toMetric) return;
    setState(() {
      _isMetric = toMetric;
      final double factor = toMetric ? 25.4 : (1 / 25.4);
      _convertController(_lengthController, factor);
      _convertController(_widthController, factor);
      _convertController(_thicknessController, factor);
      _convertController(_outerDiaController, factor);
      _convertController(_heightController, factor);
      _convertController(_webThicknessController, factor);
      _convertController(_flangeThicknessController, factor);
      _performCalculation();
    });
  }

  void _convertController(TextEditingController controller, double factor) {
    final double? val = double.tryParse(controller.text);
    if (val != null && val > 0) {
      final double converted = val * factor;
      controller.text = converted >= 100
          ? converted.toStringAsFixed(0)
          : (converted >= 10
              ? converted.toStringAsFixed(1)
              : converted.toStringAsFixed(2));
    }
  }

  void _performCalculation() {
    final double l = double.tryParse(_lengthController.text) ?? 0.0;
    final double w = double.tryParse(_widthController.text) ?? 0.0;
    final double t = double.tryParse(_thicknessController.text) ?? 0.0;
    final double d = double.tryParse(_outerDiaController.text) ?? 0.0;
    final double h = double.tryParse(_heightController.text) ?? 0.0;
    final double tw = double.tryParse(_webThicknessController.text) ?? 0.0;
    final double tf = double.tryParse(_flangeThicknessController.text) ?? 0.0;
    final double q = double.tryParse(_quantityController.text) ?? 1.0;
    final double price = double.tryParse(_priceController.text) ?? 0.0;

    final double density = _getEffectiveDensity();

    double volume = 0.0;
    double surfaceArea = 0.0;
    _lastUnitWeightPerM = 0.0;
    _lastSectionAreaCm2 = 0.0;

    switch (_selectedShape) {
      case 'Sheet / Plate':
      case 'Flat Bar':
        volume = l * w * t;
        surfaceArea = 2 * (l * w + l * t + w * t);
        break;

      case 'Round Bar':
        final double r = d > 0 ? d / 2 : t / 2;
        volume = math.pi * r * r * l;
        surfaceArea = 2 * math.pi * r * (r + l);
        break;

      case 'Square Bar':
        final double side = w > 0 ? w : t;
        volume = side * side * l;
        surfaceArea = 2 * side * side + 4 * side * l;
        break;

      case 'Hexagonal Bar':
        final double acrossFlats = w > 0 ? w : t;
        final double areaCross = (math.sqrt(3) / 2) * acrossFlats * acrossFlats;
        volume = areaCross * l;
        final double sideHex = acrossFlats / math.sqrt(3);
        surfaceArea = 2 * areaCross + 6 * sideHex * l;
        break;

      case 'Round Tube / Pipe':
        final double outerRadius = (d > 0 ? d : w) / 2;
        final double innerRadius = outerRadius - t;
        if (innerRadius > 0) {
          final double areaCross =
              math.pi * (outerRadius * outerRadius - innerRadius * innerRadius);
          volume = areaCross * l;
          surfaceArea = 2 * math.pi * outerRadius * l +
              2 * math.pi * innerRadius * l +
              2 * areaCross;
        }
        break;

      case 'Square / Rectangular Tube':
        final double width = w > 0 ? w : d;
        final double height = h > 0 ? h : width;
        final double innerWidth = width - 2 * t;
        final double innerHeight = height - 2 * t;
        if (innerWidth > 0 && innerHeight > 0) {
          final double areaCross =
              (width * height) - (innerWidth * innerHeight);
          volume = areaCross * l;
          final double outerPerim = 2 * (width + height);
          final double innerPerim = 2 * (innerWidth + innerHeight);
          surfaceArea = outerPerim * l + innerPerim * l + 2 * areaCross;
        }
        break;

      case 'Angle (L-Profile)':
        final double legA = w > 0 ? w : h;
        final double legB = h > 0 ? h : legA;
        if (legA > t && legB > t) {
          final double areaCross = t * (legA + legB - t);
          volume = areaCross * l;
          final double perim = 2 * (legA + legB);
          surfaceArea = perim * l + 2 * areaCross;
        }
        break;

      case 'U-Channel / Channel (C-Profile)':
      case 'Channel (C-Profile)':
        final double heightC = h > 0 ? h : 100;
        final double widthC = w > 0 ? w : 50;
        final double tWeb = tw > 0 ? tw : t;
        final double tFlange = tf > 0 ? tf : t;
        final double areaCross =
            (heightC * tWeb) + (2 * widthC * tFlange) - (2 * tWeb * tFlange);
        volume = math.max(0.0, areaCross * l);
        final double perim = 4 * widthC + 2 * heightC - 2 * tWeb;
        surfaceArea = perim * l + 2 * math.max(0.0, areaCross);
        break;

      case 'H-Beam':
      case 'I-Beam':
      case 'I-Beam / H-Beam':
        final double heightB = h > 0 ? h : 100;
        final double widthB = w > 0 ? w : 100;
        final double tWebB = tw > 0 ? tw : t;
        final double tFlangeB = tf > 0 ? tf : t;

        StandardProfileSpec? spec;
        if (_selectedShape == 'H-Beam') {
          spec = StandardData.findClientHBeam(heightB, widthB, tWebB, tFlangeB);
        } else if (_selectedShape == 'I-Beam') {
          spec = StandardData.findClientIBeam(heightB, widthB, tWebB, tFlangeB);
        } else {
          spec = StandardData.findClientIBeam(heightB, widthB, tWebB, tFlangeB) ??
              StandardData.findClientHBeam(heightB, widthB, tWebB, tFlangeB);
        }

        double areaCross;
        double unitWeightPerM;
        if (spec != null) {
          areaCross = spec.area * 100.0;
          unitWeightPerM = spec.weight * (density / 7.85);
        } else {
          final double rApprox = math.max(0.0, tFlangeB * 0.8);
          final double rootFilletArea = 0.8584 * rApprox * rApprox;
          areaCross = (2 * widthB * tFlangeB) + ((heightB - 2 * tFlangeB) * tWebB) + rootFilletArea;
          unitWeightPerM = (areaCross * density) / 1000.0;
        }

        volume = math.max(0.0, areaCross * l);
        final double perim = 4 * widthB + 2 * heightB - 2 * tWebB;
        surfaceArea = perim * l + 2 * math.max(0.0, areaCross);
        _lastUnitWeightPerM = unitWeightPerM;
        _lastSectionAreaCm2 = areaCross / 100.0;
        break;

      default:
        volume = l * w * t;
        surfaceArea = 2 * (l * w + l * t + w * t);
    }

    if (_lastUnitWeightPerM <= 0.0 && l > 0.0) {
      if (_selectedShape == 'Sheet / Plate') {
        _lastUnitWeightPerM = (t > 0 ? t : 1.0) * density;
        _lastSectionAreaCm2 = (w > 0 ? w : 100.0) * (t > 0 ? t : 1.0) / 100.0;
      } else {
        _lastUnitWeightPerM = (volume / 1000000.0 * density) / (l / 1000.0);
        _lastSectionAreaCm2 = (volume / l) / 100.0;
      }
    }

    double weightPerPiece = 0.0;
    if (_isMetric) {
      if ((_selectedShape == 'H-Beam' ||
              _selectedShape == 'I-Beam' ||
              _selectedShape == 'I-Beam / H-Beam') &&
          _lastUnitWeightPerM > 0) {
        weightPerPiece = (l / 1000.0) * _lastUnitWeightPerM;
      } else {
        weightPerPiece = (volume / 1000000.0) * density;
      }
    } else {
      final double densityLbsIn3 = density * 0.03612729;
      weightPerPiece = volume * densityLbsIn3;
    }

    final double totalWeight = weightPerPiece * math.max(1.0, q);
    final double totalCost = totalWeight * price;

    setState(() {
      _calculatedVolume = volume;
      _calculatedSurfaceArea = surfaceArea;
      _calculatedWeightPerPiece = weightPerPiece;
      _calculatedTotalWeight = totalWeight;
      _calculatedCost = totalCost;
    });
  }

  CalculationModel? _createCalculationModel() {
    if (_calculatedTotalWeight <= 0) {
      _showSnackBar('Please enter valid dimensions first!', Colors.red);
      return null;
    }

    final String unitWeight = _isMetric ? 'kg' : 'lbs';
    final String unitDim = _isMetric ? 'mm' : 'in';
    final String weightStr =
        '${_calculatedTotalWeight.toStringAsFixed(2)} $unitWeight';
    final String dimSummary = _getDimensionsSummary(unitDim);
    final String iconName = _getIconNameForShape(_selectedShape);

    return CalculationModel(
      title: '$_selectedMetal $_selectedShape',
      subtitle: '$dimSummary | Qty: ${_quantityController.text}',
      weight: weightStr,
      time: _getFormattedTime(),
      iconName: iconName,
      bgColor: const Color(0xFFE8F0FE),
      iconColor: const Color(0xFF1A73E8),
      weightValue: _calculatedTotalWeight,
      details: {
        'material': _selectedMetal,
        'shape': _selectedShape,
        'dimensions': dimSummary,
        'quantity': _quantityController.text,
        'weightPerPiece':
            '${_calculatedWeightPerPiece.toStringAsFixed(3)} $unitWeight',
        'unitWeightPerM': '${_lastUnitWeightPerM.toStringAsFixed(2)} kg/m',
        'sectionArea': '${_lastSectionAreaCm2.toStringAsFixed(2)} cm2',
        'variant': _selectedShape == 'H-Beam'
            ? 'H'
            : (_selectedShape == 'I-Beam' ? 'I' : null),
        'totalWeight': weightStr,
        'totalCost':
            _calculatedCost > 0 ? _calculatedCost.toStringAsFixed(2) : null,
        'volume': _formatVolume(_calculatedVolume),
        'surfaceArea': _formatSurfaceArea(_calculatedSurfaceArea),
        'unitSystem': _isMetric ? 'Metric' : 'Imperial',
        'width': _widthController.text.trim(),
        'height': _heightController.text.trim(),
        'thickness': _thicknessController.text.trim(),
        'length': _lengthController.text.trim(),
        'outerDia': _outerDiaController.text.trim(),
        'webThickness': _webThicknessController.text.trim(),
        'flangeThickness': _flangeThicknessController.text.trim(),
      },
    );
  }

  void _saveCalculationToHistory() async {
    final model = _createCalculationModel();
    if (model == null) return;
    await _historyService.addCalculation(model);
    _showSnackBar('Calculation saved to history!', AppColors.primaryDark);
  }

  Future<void> _exportPdfQuotation() async {
    if (_isExportingPdf) return;
    final model = _createCalculationModel();
    if (model == null) return;

    setState(() => _isExportingPdf = true);

    try {
      await PdfExportService.exportSingleCalculation(model, context: context);
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error exporting PDF: $e', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() => _isExportingPdf = false);
      }
    }
  }

  String _getIconNameForShape(String shape) {
    switch (shape) {
      case 'Round Bar':
        return 'round_bar';
      case 'Square Bar':
        return 'square_bar';
      case 'Sheet / Plate':
      case 'Flat Bar':
        return 'sheet';
      case 'Hexagonal Bar':
        return 'hexagon';
      case 'Round Tube / Pipe':
        return 'pipe';
      case 'Square / Rectangular Tube':
        return 'square';
      case 'Angle (L-Profile)':
        return 'angle';
      case 'U-Channel / Channel (C-Profile)':
      case 'Channel (C-Profile)':
        return 'channel';
      case 'I-Beam / H-Beam':
      case 'H-Beam':
      case 'I-Beam':
        return 'beam';
      default:
        return 'calculate';
    }
  }

  String _getDimensionsSummary(String unitDim) {
    final String l = _lengthController.text;
    final String w = _widthController.text;
    final String t = _thicknessController.text;
    final String d = _outerDiaController.text;
    final String h = _heightController.text;

    switch (_selectedShape) {
      case 'Round Bar':
        return 'Ø$d x L$l $unitDim';
      case 'Square Bar':
        return '$w x $w x L$l $unitDim';
      case 'Hexagonal Bar':
        return 'W$w x L$l $unitDim';
      case 'Round Tube / Pipe':
        return 'Ø$d x t$t x L$l $unitDim';
      case 'Square / Rectangular Tube':
        return '$w x $h x t$t x L$l $unitDim';
      case 'Angle (L-Profile)':
        return '$w x $h x t$t x L$l $unitDim';
      case 'U-Channel / Channel (C-Profile)':
      case 'Channel (C-Profile)':
      case 'I-Beam / H-Beam':
      case 'H-Beam':
      case 'I-Beam':
        return '$h x $w x L$l $unitDim';
      default:
        return '$l x $w x t$t $unitDim';
    }
  }

  String _getFormattedTime() {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String _formatVolume(double volume) {
    if (_isMetric) {
      if (volume >= 1e9) {
        return '${(volume / 1e9).toStringAsFixed(3)} m³';
      } else if (volume >= 1000) {
        return '${(volume / 1000).toStringAsFixed(2)} cm³';
      } else {
        return '${volume.toStringAsFixed(1)} mm³';
      }
    } else {
      if (volume >= 1728) {
        return '${(volume / 1728).toStringAsFixed(2)} ft³';
      } else {
        return '${volume.toStringAsFixed(2)} in³';
      }
    }
  }

  String _formatSurfaceArea(double sa) {
    if (_isMetric) {
      if (sa >= 1e6) {
        return '${(sa / 1e6).toStringAsFixed(3)} m²';
      } else if (sa >= 100) {
        return '${(sa / 100).toStringAsFixed(2)} cm²';
      } else {
        return '${sa.toStringAsFixed(1)} mm²';
      }
    } else {
      if (sa >= 144) {
        return '${(sa / 144).toStringAsFixed(2)} ft²';
      } else {
        return '${sa.toStringAsFixed(2)} in²';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettingsProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(settings.strings.get('calculator')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMaterialAndUnitCard(),
            const SizedBox(height: 16),
            _buildShapeSelectorCard(),
            const SizedBox(height: 16),
            _buildShapePreviewBox(),
            const SizedBox(height: 16),
            _buildDimensionInputCard(),
            const SizedBox(height: 16),
            _buildResultsCard(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saveCalculationToHistory,
                    icon: const Icon(Icons.bookmark_add_outlined,
                        color: Colors.white, size: 18),
                    label: Text(
                      settings.strings.get('save_to_history'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isExportingPdf ? null : _exportPdfQuotation,
                    icon: _isExportingPdf
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.secondaryOrange),
                          )
                        : const Icon(Icons.picture_as_pdf,
                            color: AppColors.secondaryOrange, size: 18),
                    label: Text(
                      _isExportingPdf
                          ? 'Exporting...'
                          : settings.strings.get('share_quotation_pdf'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: AppColors.secondaryOrange,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 8),
                      side: const BorderSide(
                          color: AppColors.secondaryOrange, width: 1.8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialAndUnitCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Unit System',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.primaryDark),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                height: 36,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFEDF2F7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark ? Colors.white12 : AppColors.borderLight,
                    width: 1.0,
                  ),
                ),
                padding: const EdgeInsets.all(3),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildUnitToggleButton(
                      label: 'Metric (mm)',
                      isSelected: _isMetric,
                      onTap: () => _onUnitSystemChanged(true),
                    ),
                    _buildUnitToggleButton(
                      label: 'Imperial (in)',
                      isSelected: !_isMetric,
                      onTap: () => _onUnitSystemChanged(false),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Divider(height: 24, color: isDark ? Colors.white12 : Colors.grey.shade200),
          Row(
            children: [
              Text(
                'Material',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.primaryDark),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _selectedMetal,
                  dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.primaryDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: isDark ? Colors.white24 : Colors.grey.shade400,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: isDark ? Colors.white24 : Colors.grey.shade400,
                      ),
                    ),
                  ),
                  items: _metalDensities.keys.map((String metal) {
                    return DropdownMenuItem<String>(
                      value: metal,
                      child: Text(
                        metal == 'Custom'
                            ? 'Custom Density'
                            : '$metal (${_metalDensities[metal]} g/cm³)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white : AppColors.primaryDark),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedMetal = val;
                        _performCalculation();
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          if (_selectedMetal == 'Custom') ...[
            const SizedBox(height: 12),
            TextField(
              controller: _customDensityController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.primaryDark,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                labelText: 'Custom Density (g/cm³)',
                labelStyle: TextStyle(
                  color: isDark ? Colors.white70 : Colors.blueGrey.shade700,
                ),
                prefixIcon: Icon(
                  Icons.fitness_center,
                  color: isDark ? const Color(0xFF38BDF8) : AppColors.primaryDark,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white24 : Colors.grey.shade400,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white24 : Colors.grey.shade400,
                  ),
                ),
              ),
              onChanged: (_) => _performCalculation(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUnitToggleButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.blueprintBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.blueprintBlue.withValues(alpha: 0.25),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? Colors.white : (isDark ? Colors.white60 : AppColors.textMuted),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShapeSelectorCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Shape / Profile',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.primaryDark),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: _selectedShape,
            dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.primaryDark,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isDark ? Colors.white24 : Colors.grey.shade400,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isDark ? Colors.white24 : Colors.grey.shade400,
                ),
              ),
            ),
            items: _shapes.map((String shape) {
              return DropdownMenuItem<String>(
                value: shape,
                child: Row(
                  children: [
                    Icon(_getIconForShape(shape),
                        color: AppColors.secondaryOrange, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        shape,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : AppColors.primaryDark),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _selectedShape = val;
                  if (val == 'H-Beam') {
                    _heightController.text = '200';
                    _widthController.text = '200';
                    _webThicknessController.text = '8';
                    _flangeThicknessController.text = '12';
                    _lengthController.text = '12000';
                    _selectedBeamPreset = '200x200';
                  } else if (val == 'I-Beam') {
                    _heightController.text = '250';
                    _widthController.text = '125';
                    _webThicknessController.text = '6';
                    _flangeThicknessController.text = '9';
                    _lengthController.text = '12000';
                    _selectedBeamPreset = '250x125';
                  }
                  _performCalculation();
                });
              }
            },
          ),
        ],
      ),
    );
  }

  IconData _getIconForShape(String shape) {
    switch (shape) {
      case 'Round Bar':
        return Icons.circle;
      case 'Square Bar':
        return Icons.crop_square;
      case 'Sheet / Plate':
      case 'Flat Bar':
        return Icons.layers;
      case 'Hexagonal Bar':
        return Icons.hexagon;
      case 'Round Tube / Pipe':
        return Icons.radio_button_unchecked;
      case 'Square / Rectangular Tube':
        return Icons.square;
      case 'Angle (L-Profile)':
        return Icons.timeline;
      case 'U-Channel / Channel (C-Profile)':
      case 'Channel (C-Profile)':
        return Icons.view_stream;
      case 'I-Beam / H-Beam':
      case 'H-Beam':
      case 'I-Beam':
        return Icons.view_column;
      default:
        return Icons.calculate;
    }
  }

  Widget _buildShapePreviewBox() {
    final String unitDim = _isMetric ? 'mm' : 'in';

    return CustomShape2DDiagram(
      shape: _selectedShape,
      unitDim: unitDim,
      lengthStr: _lengthController.text,
      widthStr: _widthController.text,
      thicknessStr: _thicknessController.text,
      outerDiaStr: _outerDiaController.text,
      heightStr: _heightController.text,
      webThickStr: _webThicknessController.text,
      flangeThickStr: _flangeThicknessController.text,
    );
  }

  Widget _buildDimensionInputCard() {
    final String unitDim = _isMetric ? 'mm' : 'in';
    final String unitLen = _isMetric ? 'mm' : 'in';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    List<Widget> fields = [];

    fields.add(
      _buildInputField(
        controller: _lengthController,
        label: 'Length (L)',
        suffix: unitLen,
        icon: Icons.straighten,
      ),
    );

    switch (_selectedShape) {
      case 'Sheet / Plate':
      case 'Flat Bar':
        fields.add(const SizedBox(height: 10));
        fields.add(_buildInputField(
            controller: _widthController,
            label: 'Width (W)',
            suffix: unitDim,
            icon: Icons.straighten));
        fields.add(const SizedBox(height: 10));
        fields.add(_buildInputField(
            controller: _thicknessController,
            label: 'Thickness (T)',
            suffix: unitDim,
            icon: Icons.line_weight));
        break;

      case 'Round Bar':
        fields.add(const SizedBox(height: 10));
        fields.add(_buildInputField(
            controller: _outerDiaController,
            label: 'Diameter (D)',
            suffix: unitDim,
            icon: Icons.circle_outlined));
        break;

      case 'Square Bar':
        fields.add(const SizedBox(height: 10));
        fields.add(_buildInputField(
            controller: _widthController,
            label: 'Side Width (S)',
            suffix: unitDim,
            icon: Icons.crop_square));
        break;

      case 'Hexagonal Bar':
        fields.add(const SizedBox(height: 10));
        fields.add(_buildInputField(
            controller: _widthController,
            label: 'Distance Across Flats (W)',
            suffix: unitDim,
            icon: Icons.hexagon_outlined));
        break;

      case 'Round Tube / Pipe':
        fields.add(const SizedBox(height: 10));
        fields.add(_buildInputField(
            controller: _outerDiaController,
            label: 'Outer Diameter (D)',
            suffix: unitDim,
            icon: Icons.radio_button_unchecked));
        fields.add(const SizedBox(height: 10));
        fields.add(_buildInputField(
            controller: _thicknessController,
            label: 'Wall Thickness (T)',
            suffix: unitDim,
            icon: Icons.line_weight));
        break;

      case 'Square / Rectangular Tube':
        fields.add(const SizedBox(height: 10));
        fields.add(_buildInputField(
            controller: _widthController,
            label: 'Outer Width (W)',
            suffix: unitDim,
            icon: Icons.straighten));
        fields.add(const SizedBox(height: 10));
        fields.add(_buildInputField(
            controller: _heightController,
            label: 'Outer Height (H)',
            suffix: unitDim,
            icon: Icons.height));
        fields.add(const SizedBox(height: 10));
        fields.add(_buildInputField(
            controller: _thicknessController,
            label: 'Wall Thickness (T)',
            suffix: unitDim,
            icon: Icons.line_weight));
        break;

      case 'Angle (L-Profile)':
        fields.add(const SizedBox(height: 10));
        fields.add(_buildInputField(
            controller: _widthController,
            label: 'Leg 1 Width (A)',
            suffix: unitDim,
            icon: Icons.straighten));
        fields.add(const SizedBox(height: 10));
        fields.add(_buildInputField(
            controller: _heightController,
            label: 'Leg 2 Width (B)',
            suffix: unitDim,
            icon: Icons.height));
        fields.add(const SizedBox(height: 10));
        fields.add(_buildInputField(
            controller: _thicknessController,
            label: 'Thickness (T)',
            suffix: unitDim,
            icon: Icons.line_weight));
        break;

      case 'H-Beam':
      case 'I-Beam':
        final isIBeam = _selectedShape == 'I-Beam';
        final Map<String, StandardProfileSpec> catalogMap =
            isIBeam ? StandardData.clientIBeams : StandardData.clientHBeams;

        fields.add(const SizedBox(height: 10));
        fields.add(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: catalogMap.containsKey(_selectedBeamPreset) ? _selectedBeamPreset : 'Custom',
                items: [
                  const DropdownMenuItem(
                    value: 'Custom',
                    child: Text('Custom (Manual Dimensions)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  ),
                  ...catalogMap.entries.map((e) {
                    return DropdownMenuItem(
                      value: e.key,
                      child: Text(
                        '${e.key}  (${e.value.weight.toStringAsFixed(2)} kg/m)',
                        style: const TextStyle(fontSize: 13),
                      ),
                    );
                  }).toList(),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedBeamPreset = val;
                      if (catalogMap.containsKey(val)) {
                        final spec = catalogMap[val]!;
                        _heightController.text = spec.h.toStringAsFixed(spec.h % 1 == 0 ? 0 : 1);
                        _widthController.text = spec.b.toStringAsFixed(spec.b % 1 == 0 ? 0 : 1);
                        _webThicknessController.text = spec.tw.toStringAsFixed(1);
                        _flangeThicknessController.text = spec.tf.toStringAsFixed(1);
                      }
                      _performCalculation();
                    });
                  }
                },
              ),
            ),
          ),
        );
        fields.add(const SizedBox(height: 10));
        fields.add(_buildInputField(
            controller: _heightController,
            label: 'Height (H)',
            suffix: unitDim,
            icon: Icons.height));
        fields.add(const SizedBox(height: 10));
        fields.add(_buildInputField(
            controller: _widthController,
            label: 'Flange Width (W)',
            suffix: unitDim,
            icon: Icons.straighten));
        fields.add(const SizedBox(height: 10));
        fields.add(_buildInputField(
            controller: _webThicknessController,
            label: 'Web Thickness (tw)',
            suffix: unitDim,
            icon: Icons.line_weight));
        fields.add(const SizedBox(height: 10));
        fields.add(_buildInputField(
            controller: _flangeThicknessController,
            label: 'Flange Thickness (tf)',
            suffix: unitDim,
            icon: Icons.line_weight));
        break;

      case 'U-Channel / Channel (C-Profile)':
      case 'Channel (C-Profile)':
      case 'I-Beam / H-Beam':
        fields.add(const SizedBox(height: 10));
        fields.add(_buildInputField(
            controller: _heightController,
            label: 'Height (H)',
            suffix: unitDim,
            icon: Icons.height));
        fields.add(const SizedBox(height: 10));
        fields.add(_buildInputField(
            controller: _widthController,
            label: 'Flange Width (W)',
            suffix: unitDim,
            icon: Icons.straighten));
        fields.add(const SizedBox(height: 10));
        fields.add(_buildInputField(
            controller: _webThicknessController,
            label: 'Web Thickness (tw)',
            suffix: unitDim,
            icon: Icons.line_weight));
        fields.add(const SizedBox(height: 10));
        fields.add(_buildInputField(
            controller: _flangeThicknessController,
            label: 'Flange Thickness (tf)',
            suffix: unitDim,
            icon: Icons.line_weight));
        break;

      default:
        fields.add(const SizedBox(height: 10));
        fields.add(_buildInputField(
            controller: _widthController,
            label: 'Width (W)',
            suffix: unitDim,
            icon: Icons.straighten));
        fields.add(const SizedBox(height: 10));
        fields.add(_buildInputField(
            controller: _thicknessController,
            label: 'Thickness (T)',
            suffix: unitDim,
            icon: Icons.line_weight));
    }

    fields.add(Divider(height: 24, color: isDark ? Colors.white12 : Colors.grey.shade200));
    fields.add(
      Row(
        children: [
          Expanded(
            child: _buildInputField(
              controller: _quantityController,
              label: 'Quantity (pcs)',
              suffix: 'pcs',
              icon: Icons.format_list_numbered,
              isInteger: true,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildInputField(
              controller: _priceController,
              label: 'Price per ${_isMetric ? 'kg' : 'lb'}',
              suffix: 'SAR',
              icon: Icons.payments_outlined,
            ),
          ),
        ],
      ),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dimensions & Parameters',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.primaryDark),
          ),
          const SizedBox(height: 12),
          ...fields,
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String suffix,
    required IconData icon,
    bool isInteger = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: !isInteger),
      style: TextStyle(
        color: isDark ? Colors.white : AppColors.primaryDark,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? Colors.white70 : Colors.blueGrey.shade700,
          fontSize: 13,
        ),
        floatingLabelStyle: const TextStyle(
          color: AppColors.secondaryOrange,
          fontWeight: FontWeight.bold,
        ),
        suffixText: suffix,
        suffixStyle: TextStyle(
          color: isDark ? Colors.white60 : Colors.blueGrey.shade600,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        isDense: true,
        filled: true,
        fillColor: isDark
            ? const Color(0xFF0F172A).withValues(alpha: 0.6)
            : Colors.grey.shade50,
        prefixIcon: Icon(
          icon,
          color: isDark ? const Color(0xFF38BDF8) : AppColors.primaryDark,
          size: 20,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isDark ? Colors.white24 : Colors.grey.shade400,
            width: 1.0,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isDark ? Colors.white24 : Colors.grey.shade400,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: AppColors.secondaryOrange, width: 1.8),
        ),
      ),
      onChanged: (_) => _performCalculation(),
    );
  }

  Widget _buildResultsCard() {
    final String unitWeight = _isMetric ? 'kg' : 'lbs';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, Color(0xFF1E2B37)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Calculation Results',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              Icon(Icons.check_circle_outline,
                  color: AppColors.secondaryOrange, size: 22),
            ],
          ),
          const Divider(color: Colors.white24, height: 20),
          Row(
            children: [
              Expanded(
                child: _buildResultStat(
                  _selectedShape.contains('Sheet')
                      ? (_isMetric ? 'Unit Weight (kg/m²)' : 'Unit Weight (lbs/ft²)')
                      : (_isMetric ? 'Unit Weight (kg/m)' : 'Unit Weight (lbs/ft)'),
                  _isMetric
                      ? '${_lastUnitWeightPerM.toStringAsFixed(2)} ${_selectedShape.contains('Sheet') ? 'kg/m²' : 'kg/m'}'
                      : '${(_lastUnitWeightPerM * 0.6719689).toStringAsFixed(2)} ${_selectedShape.contains('Sheet') ? 'lbs/ft²' : 'lbs/ft'}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildResultStat('Weight / Piece',
                    '${_calculatedWeightPerPiece.toStringAsFixed(2)} $unitWeight'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildResultStat('Total Weight',
                    '${_calculatedTotalWeight.toStringAsFixed(2)} $unitWeight',
                    isHighlight: true),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildResultStat(
                    'Section Area',
                    _isMetric
                        ? '${_lastSectionAreaCm2.toStringAsFixed(2)} cm²'
                        : '${(_lastSectionAreaCm2 * 0.1550003).toStringAsFixed(2)} in²'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildResultStat(
                    'Volume', _formatVolume(_calculatedVolume)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildResultStat(
                    'Surface Area', _formatSurfaceArea(_calculatedSurfaceArea)),
              ),
            ],
          ),
          if (_calculatedCost > 0) ...[
            const Divider(color: Colors.white24, height: 20),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Estimated Cost:',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
                const SizedBox(width: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${_calculatedCost.toStringAsFixed(2)} SAR',
                    style: const TextStyle(
                        color: AppColors.secondaryOrange,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultStat(String label, String value,
      {bool isHighlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, color: Colors.white60),
        ),
        const SizedBox(height: 3),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            maxLines: 1,
            style: TextStyle(
              fontSize: isHighlight ? 17 : 14,
              fontWeight: FontWeight.bold,
              color: isHighlight ? AppColors.secondaryOrange : Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
