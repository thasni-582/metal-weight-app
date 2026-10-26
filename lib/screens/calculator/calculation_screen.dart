import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:metal_weight/core/constants/app_colors.dart';
import 'package:metal_weight/core/constants/catalog_data.dart';
import 'package:metal_weight/core/constants/standard_data.dart';
import 'package:metal_weight/core/providers/app_settings_provider.dart';
import 'package:metal_weight/models/calculation_model.dart';
import 'package:metal_weight/models/profile_spec.dart';
import 'package:metal_weight/screens/home/widgets/section_diagram_2d.dart';
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
  String _selectedProduct = 'I-Beam (JIS)';
  String _selectedShape = 'I-Beam';
  String _selectedSize = '200x100';
  String _selectedThickness = '';
  String _activeVariant = 'I-Beam (JIS)';
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
    'SS Chequered Sheet': 8.30,
    'Aluminum': 2.70,
    'Aluminum Sheet': 2.74,
    'Aluminum Chequered Sheet': 3.10,
    'Copper': 9.10,
    'Brass': 8.60,
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

    // 4. Product, Size, Variant
    String normProduct = p.shape;
    if (normProduct == 'H-Beam') normProduct = 'H-Beam (JIS)';
    if (normProduct == 'I-Beam') normProduct = 'I-Beam (JIS)';
    if (normProduct.contains('Universal Column') || normProduct == 'UC') normProduct = 'UC (Universal Columns)';
    if (normProduct.contains('Universal Beam') || normProduct == 'UB') normProduct = 'UB (Universal Beam)';
    if (normProduct.contains('W-Beam') || normProduct.contains('Wide Flange')) normProduct = 'W-Beam (Wide Flange)';

    _selectedProduct = normProduct;
    _selectedSize = p.size;
    _selectedBeamPreset = p.size;
    _selectedThickness = p.thickness;
    _activeVariant = p.variant;
    _lastUnitWeightPerM = p.weightPerM;
    _lastSectionAreaCm2 = p.sectionArea;

    _applyDimensionsForProductSize(_selectedProduct, _selectedSize, preferredThickness: p.thickness);
    if (p.weightPerM > 0) {
      _lastUnitWeightPerM = p.weightPerM;
    }
    if (p.sectionArea > 0) {
      _lastSectionAreaCm2 = p.sectionArea;
    }
    _performCalculation();
  }

  void _onProductSelected(String newProduct) {
    setState(() {
      _selectedProduct = newProduct;
      // Derive activeVariant
      if (newProduct == 'IPE Beam') {
        _activeVariant = 'IPE';
      } else if (newProduct == 'IPE-AA Beam') {
        _activeVariant = 'IPE-AA';
      } else if (newProduct == 'HEA Beam') {
        _activeVariant = 'HEA';
      } else if (newProduct == 'HEB Beam') {
        _activeVariant = 'HEB';
      } else if (newProduct == 'H-Beam (JIS)' || newProduct == 'H-Beam') {
        _activeVariant = 'H-Beam (JIS)';
      } else if (newProduct == 'I-Beam (JIS)' || newProduct == 'I-Beam') {
        _activeVariant = 'I-Beam (JIS)';
      } else if (newProduct == 'UB (Universal Beam)') {
        _activeVariant = 'UB';
      } else if (newProduct == 'UC (Universal Columns)') {
        _activeVariant = 'UC';
      } else if (newProduct == 'W-Beam (Wide Flange)') {
        _activeVariant = 'W-Beam';
      } else if (newProduct == 'UPN Channel') {
        _activeVariant = 'UPN';
      } else if (newProduct == 'UPE Channel') {
        _activeVariant = 'UPE';
      } else if (newProduct == 'U-Channel (JIS)') {
        _activeVariant = 'JIS';
      } else if (newProduct.contains('Angle') && !newProduct.contains('Unequal')) {
        _activeVariant = 'EQUAL';
      }

      // Infer metal if product specifies it
      if (newProduct.contains('Aluminum')) {
        _selectedMetal = 'Aluminum';
      } else if (newProduct.contains('Stainless') || newProduct.contains('SS')) {
        _selectedMetal = 'Stainless Steel';
      } else if (newProduct.contains('Brass')) {
        _selectedMetal = 'Brass';
      } else if (newProduct.contains('Copper')) {
        _selectedMetal = 'Copper';
      } else {
        _selectedMetal = 'Steel';
      }

      final sizes = _getAvailableSizesForProduct(newProduct);
      if (sizes.isNotEmpty) {
        _selectedSize = sizes.first;
        _selectedBeamPreset = sizes.first;
      }
      _applyDimensionsForProductSize(newProduct, _selectedSize);
      _performCalculation();
    });
  }

  List<String> _getAvailableSizesForProduct(String product) {
    switch (product) {
      // Angles
      case 'Equal Angle':
      case 'Angle Equal':
      case 'SS Angle (Stainless Steel)':
      case 'Aluminum Angle':
        return StandardData.equalAngles.keys.toList();
      case 'Unequal Angle':
      case 'Angle Unequal':
        return StandardData.unequalAngles.keys.toList();

      // Channels
      case 'UPN Channel':
        return StandardData.upnChannels.keys.toList();
      case 'UPE Channel':
        return StandardData.upeChannels.keys.toList();
      case 'U-Channel (JIS)':
        return StandardData.jisChannels.keys.toList();

      // Beams & Columns
      case 'IPE Beam':
        return StandardData.ipeBeams.keys.toList();
      case 'IPE-AA Beam':
        return StandardData.ipeAaBeams.keys.toList();
      case 'HEA Beam':
        return StandardData.heaBeams.keys.toList();
      case 'HEB Beam':
        return StandardData.hebBeams.keys.toList();
      case 'H-Beam (JIS)':
      case 'H-Beam':
        return StandardData.clientHBeams.keys.toList();
      case 'I-Beam (JIS)':
      case 'I-Beam':
        return StandardData.clientIBeams.keys.toList();
      case 'UB (Universal Beam)':
        return StandardData.ubBeams.keys.toList();
      case 'UC (Universal Columns)':
        return StandardData.ucBeams.keys.toList();
      case 'W-Beam (Wide Flange)':
        return StandardData.wBeams.keys.toList();

      // Hollow Sections / Tubes
      case 'Square Tube (SHS)':
      case 'Stainless Steel Square Tube':
        return StandardData.squareTubes.keys.toList();
      case 'Rectangular Tube (RHS)':
      case 'Stainless Steel Rectangular Tube':
        return StandardData.rectangularTubes.keys.toList();

      // Pipes
      case 'Pipe ERW':
      case 'Pipe Seamless':
      case 'Stainless Steel Pipe':
        return StandardData.steelPipes.keys.toList();

      // Solid Bars
      case 'Flat Bar':
        return StandardData.flatBarWidths;
      case 'MS Round Bar':
      case 'SS Round Bar':
      case 'SS Round Bar (Stainless Steel)':
      case 'Aluminum Round Bar':
      case 'Brass Round Bar':
      case 'Copper Round Bar':
      case 'Rebar / Deformed Bar':
      case 'Round Bar':
        return StandardData.roundBarDiameters;
      case 'Square Bar':
        return StandardData.roundBarDiameters;
      case 'Hexagonal Bar':
        return StandardData.roundBarDiameters;

      // Sheets & Plates
      case 'HR Checkered Sheet':
      case 'Stainless Steel Checkered Sheet':
        return StandardData.hrCheckeredWeights.keys.toList();
      case 'Aluminum Checkered Sheet':
        return StandardData.checkeredSheetThicknesses;
      case 'HR Sheet / HR Plate':
      case 'Stainless Steel Sheet':
      case 'Aluminum Sheet':
      case 'Brass Sheet':
      case 'Copper Sheet':
        return StandardData.sheetThicknesses;

      default:
        return ['100'];
    }
  }

  Map<String, StandardProfileSpec> _getBeamCatalogMap() {
    if (_selectedProduct.contains('I-Beam')) {
      return StandardData.clientIBeams;
    } else if (_selectedProduct.contains('H-Beam')) {
      return StandardData.clientHBeams;
    } else if (_selectedProduct.contains('IPE-AA')) {
      return StandardData.ipeAaBeams;
    } else if (_selectedProduct.contains('IPE')) {
      return StandardData.ipeBeams;
    } else if (_selectedProduct.contains('HEA')) {
      return StandardData.heaBeams;
    } else if (_selectedProduct.contains('HEB')) {
      return StandardData.hebBeams;
    } else if (_selectedProduct.contains('UB') || _selectedProduct.contains('Universal Beam')) {
      return StandardData.ubBeams;
    } else if (_selectedProduct.contains('UC') || _selectedProduct.contains('Universal Column') || _selectedProduct.contains('Columns')) {
      return StandardData.ucBeams;
    } else if (_selectedProduct.contains('W-Beam') || _selectedProduct.contains('Wide Flange')) {
      return StandardData.wBeams;
    }
    return _selectedShape == 'I-Beam'
        ? StandardData.clientIBeams
        : StandardData.clientHBeams;
  }

  void _applyDimensionsForProductSize(String product, String size, {String? preferredThickness}) {
    if (product.contains('Angle')) {
      _selectedShape = 'Angle (L-Profile)';
      if (product.contains('Unequal') || size.contains('x')) {
        final parts = size.split('x');
        _widthController.text = parts[0].trim();
        _heightController.text = parts.length > 1 ? parts[1].trim() : parts[0].trim();
      } else {
        _widthController.text = size;
        _heightController.text = size;
      }
      final availThick = (product.contains('Unequal')
              ? StandardData.unequalAngles[size]?.keys.toList()
              : StandardData.equalAngles[size]?.keys.toList()) ??
          ['5'];
      if (preferredThickness != null && availThick.contains(preferredThickness)) {
        _thicknessController.text = preferredThickness;
      } else {
        _thicknessController.text = availThick.isNotEmpty ? availThick.first : '5';
      }
      _selectedThickness = _thicknessController.text;
      final String tClean = (double.tryParse(_thicknessController.text.trim()) ?? 0)
          .toString()
          .replaceAll(RegExp(r'\.0$'), '');
      final double? w;
      if (product.contains('Unequal')) {
        w = StandardData.unequalAngles[size]?[_thicknessController.text] ??
            StandardData.unequalAngles[size]?[tClean];
      } else {
        w = StandardData.equalAngles[size]?[_thicknessController.text] ??
            StandardData.equalAngles[size]?[tClean];
      }
      if (w != null) {
        final double density = _getEffectiveDensity();
        _lastUnitWeightPerM = w * (density / 7.85);
        _lastSectionAreaCm2 = (w / 0.785);
      }
    } else if (product.contains('Channel')) {
      _selectedShape = 'U-Channel / Channel (C-Profile)';
      StandardProfileSpec? spec;
      if (product.contains('UPE')) {
        spec = StandardData.upeChannels[size];
      } else if (product.contains('JIS')) {
        spec = StandardData.jisChannels[size];
      } else {
        spec = StandardData.upnChannels[size];
      }
      if (spec != null) {
        _heightController.text = spec.h.toStringAsFixed(spec.h % 1 == 0 ? 0 : 1);
        _widthController.text = spec.b.toStringAsFixed(spec.b % 1 == 0 ? 0 : 1);
        _webThicknessController.text = spec.tw.toStringAsFixed(1);
        _flangeThicknessController.text = spec.tf.toStringAsFixed(1);
        final double density = _getEffectiveDensity();
        _lastUnitWeightPerM = spec.weight * (density / 7.85);
        _lastSectionAreaCm2 = spec.area;
      }
    } else if (product.contains('Tube')) {
      _selectedShape = 'Square / Rectangular Tube';
      if (size.contains('x')) {
        final parts = size.split('x');
        _widthController.text = parts[0].trim();
        _heightController.text = parts.length > 1 ? parts[1].trim() : parts[0].trim();
      } else {
        _widthController.text = size;
        _heightController.text = size;
      }
      final isRect = product.contains('Rectangular') || product.contains('RHS');
      final map = isRect ? StandardData.rectangularTubes[size] : StandardData.squareTubes[size];
      final thicks = map?.keys.toList() ?? ['2.0'];
      if (preferredThickness != null && thicks.contains(preferredThickness)) {
        _thicknessController.text = preferredThickness;
      } else {
        _thicknessController.text = thicks.isNotEmpty ? thicks.first : '2.0';
      }
      final double? w = map?[_thicknessController.text];
      if (w != null) {
        final double density = _getEffectiveDensity();
        _lastUnitWeightPerM = w * (density / 7.85);
        _lastSectionAreaCm2 = (w / 0.785);
      }
    } else if (product.contains('Pipe')) {
      _selectedShape = 'Round Tube / Pipe';
      final m = RegExp(r'\((\d+(?:\.\d+)?)\s*mm\)').firstMatch(size);
      if (m != null) {
        _outerDiaController.text = m.group(1)!;
      } else {
        _outerDiaController.text = '50';
      }
      final map = StandardData.steelPipes[size];
      final thicks = map?.keys.toList() ?? ['Sch 40 (3.91mm)'];
      String chosenThick = thicks.first;
      if (preferredThickness != null && thicks.contains(preferredThickness)) {
        chosenThick = preferredThickness;
      }
      final mt = RegExp(r'\((\d+(?:\.\d+)?)\s*mm\)').firstMatch(chosenThick);
      _thicknessController.text = mt != null ? mt.group(1)! : '3.91';
      final double? w = map?[chosenThick];
      if (w != null) {
        final double density = _getEffectiveDensity();
        _lastUnitWeightPerM = w * (density / 7.85);
        _lastSectionAreaCm2 = (w / 0.785);
      }
    } else if (product.contains('Round') || product.contains('Shaft') || product.contains('Rebar')) {
      _selectedShape = 'Round Bar';
      _outerDiaController.text = size.replaceAll(RegExp(r'[^0-9.]'), '');
      final d = double.tryParse(_outerDiaController.text) ?? 20.0;
      final double density = _getEffectiveDensity();
      _lastUnitWeightPerM = (d * d * 0.006165) * (density / 7.85);
      _lastSectionAreaCm2 = (math.pi * d * d / 400.0);
    } else if (product.contains('Square Bar')) {
      _selectedShape = 'Square Bar';
      _widthController.text = size.replaceAll(RegExp(r'[^0-9.]'), '');
      final s = double.tryParse(_widthController.text) ?? 20.0;
      final double density = _getEffectiveDensity();
      _lastUnitWeightPerM = (s * s * 0.00785) * (density / 7.85);
      _lastSectionAreaCm2 = (s * s / 100.0);
    } else if (product.contains('Flat Bar')) {
      _selectedShape = 'Flat Bar';
      _widthController.text = size.replaceAll(RegExp(r'[^0-9.]'), '');
      if (preferredThickness != null && preferredThickness.isNotEmpty) {
        _thicknessController.text = preferredThickness;
      } else {
        _thicknessController.text = '6';
      }
      final w = double.tryParse(_widthController.text) ?? 50.0;
      final t = double.tryParse(_thicknessController.text) ?? 6.0;
      final double density = _getEffectiveDensity();
      _lastUnitWeightPerM = (w * t * 0.00785) * (density / 7.85);
      _lastSectionAreaCm2 = (w * t / 100.0);
    } else if (product.contains('Hexagonal')) {
      _selectedShape = 'Hexagonal Bar';
      _widthController.text = size.replaceAll(RegExp(r'[^0-9.]'), '');
      final s = double.tryParse(_widthController.text) ?? 20.0;
      final double density = _getEffectiveDensity();
      _lastUnitWeightPerM = (s * s * 0.006798) * (density / 7.85);
      _lastSectionAreaCm2 = (math.sqrt(3) / 2 * s * s / 100.0);
    } else if (product.contains('Sheet') || product.contains('Plate')) {
      _selectedShape = 'Sheet / Plate';
      _thicknessController.text = size.replaceAll(RegExp(r'[^0-9.]'), '');
      final t = double.tryParse(_thicknessController.text) ?? 5.0;
      final double density = _getEffectiveDensity();
      if (product.contains('Checkered')) {
        if (product.contains('Aluminum')) {
          _selectedMetal = 'Aluminum Chequered Sheet';
          _lastUnitWeightPerM = StandardData.aluminumCheckeredWeights[size] ?? ((t * 2.74) + 1.60);
        } else if (product.contains('Stainless')) {
          _selectedMetal = 'SS Chequered Sheet';
          _lastUnitWeightPerM = StandardData.ssCheckeredWeights[size] ?? (t * 8.30);
        } else {
          _selectedMetal = 'HR Chequered Sheet';
          _lastUnitWeightPerM = StandardData.hrCheckeredWeights[size] ?? (t * 8.50);
        }
      } else {
        _lastUnitWeightPerM = t * density;
      }
      _lastSectionAreaCm2 = t * 10.0;
    } else if (product.contains('Beam') || product.contains('Columns') || product.contains('Universal')) {
      StandardProfileSpec? spec;
      bool isH = false;

      if (product.contains('I-Beam')) {
        spec = StandardData.clientIBeams[size] ?? StandardData.jisBeams[size];
        isH = false;
        _selectedShape = 'I-Beam';
      } else if (product.contains('H-Beam')) {
        spec = StandardData.clientHBeams[size] ?? StandardData.jisBeams[size];
        isH = true;
        _selectedShape = 'H-Beam';
      } else if (product.contains('IPE-AA')) {
        spec = StandardData.ipeAaBeams[size];
        isH = false;
        _selectedShape = 'I-Beam';
      } else if (product.contains('IPE')) {
        spec = StandardData.ipeBeams[size];
        isH = false;
        _selectedShape = 'I-Beam';
      } else if (product.contains('HEA')) {
        spec = StandardData.heaBeams[size];
        isH = true;
        _selectedShape = 'H-Beam';
      } else if (product.contains('HEB')) {
        spec = StandardData.hebBeams[size];
        isH = true;
        _selectedShape = 'H-Beam';
      } else if (product.contains('UB') || product.contains('Universal Beam')) {
        spec = StandardData.ubBeams[size];
        isH = false;
        _selectedShape = 'I-Beam';
      } else if (product.contains('UC') || product.contains('Universal Column') || product.contains('Columns')) {
        spec = StandardData.ucBeams[size];
        isH = true;
        _selectedShape = 'H-Beam';
      } else if (product.contains('W-Beam') || product.contains('Wide Flange')) {
        spec = StandardData.wBeams[size] ?? StandardData.findWBeam(size);
        isH = spec != null && (spec.b / spec.h) >= 0.70;
        _selectedShape = isH ? 'H-Beam' : 'I-Beam';
      } else {
        spec = StandardData.clientIBeams[size] ?? StandardData.clientHBeams[size];
        isH = spec != null && (spec.b / spec.h) >= 0.70;
        _selectedShape = isH ? 'H-Beam' : 'I-Beam';
      }

      _selectedBeamPreset = size;
      if (spec != null) {
        _heightController.text = spec.h.toStringAsFixed(spec.h % 1 == 0 ? 0 : 1);
        _widthController.text = spec.b.toStringAsFixed(spec.b % 1 == 0 ? 0 : 1);
        _webThicknessController.text = spec.tw.toStringAsFixed(1);
        _flangeThicknessController.text = spec.tf.toStringAsFixed(1);
        final double density = _getEffectiveDensity();
        _lastUnitWeightPerM = spec.weight * (density / 7.85);
        _lastSectionAreaCm2 = spec.area;
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
        double areaCross = 0.0;
        double unitWeightPerM = 0.0;

        final String tText = _thicknessController.text.trim();
        final double? tNum = double.tryParse(tText);
        final String tClean = tNum != null
            ? (tNum == tNum.roundToDouble()
                ? tNum.toInt().toString()
                : tNum.toString())
            : tText;

        final double? angleW;
        if (_selectedProduct.contains('Unequal')) {
          angleW = StandardData.unequalAngles[_selectedSize]?[tText] ??
              StandardData.unequalAngles[_selectedSize]?[tClean] ??
              StandardData.unequalAngles['${legA.round()}x${legB.round()}']?[tText] ??
              StandardData.unequalAngles['${legA.round()}x${legB.round()}']?[tClean] ??
              StandardData.unequalAngles['${legB.round()}x${legA.round()}']?[tText] ??
              StandardData.unequalAngles['${legB.round()}x${legA.round()}']?[tClean];
        } else {
          angleW = StandardData.equalAngles[_selectedSize]?[tText] ??
              StandardData.equalAngles[_selectedSize]?[tClean] ??
              StandardData.equalAngles['${legA.round()}']?[tText] ??
              StandardData.equalAngles['${legA.round()}']?[tClean];
        }

        if (angleW != null) {
          unitWeightPerM = angleW * (density / 7.85);
          areaCross = (angleW / 0.785) * 100.0;
        } else if (legA > t && legB > t) {
          areaCross = t * (legA + legB - t);
          unitWeightPerM = (areaCross * density) / 1000.0;
        }

        if (legA > t && legB > t) {
          volume = (areaCross > 0 ? areaCross : t * (legA + legB - t)) * l;
          final double perim = 2 * (legA + legB);
          surfaceArea = perim * l + 2 * (areaCross > 0 ? areaCross : t * (legA + legB - t));
        }
        _lastUnitWeightPerM = unitWeightPerM;
        _lastSectionAreaCm2 = areaCross / 100.0;
        break;

      case 'U-Channel / Channel (C-Profile)':
      case 'Channel (C-Profile)':
        final double heightC = h > 0 ? h : 100;
        final double widthC = w > 0 ? w : 50;
        final double tWeb = tw > 0 ? tw : t;
        final double tFlange = tf > 0 ? tf : t;

        StandardProfileSpec? chSpec;
        if (_selectedProduct.contains('UPE')) {
          chSpec = StandardData.upeChannels[_selectedSize];
        } else if (_selectedProduct.contains('JIS')) {
          chSpec = StandardData.jisChannels[_selectedSize];
        } else {
          chSpec = StandardData.upnChannels[_selectedSize];
        }

        double areaCross;
        double unitWeightPerM;
        if (chSpec != null && (chSpec.h - heightC).abs() < 1.5 && (chSpec.b - widthC).abs() < 1.5) {
          areaCross = chSpec.area * 100.0;
          unitWeightPerM = chSpec.weight * (density / 7.85);
        } else {
          areaCross = (heightC * tWeb) + (2 * widthC * tFlange) - (2 * tWeb * tFlange);
          unitWeightPerM = (areaCross * density) / 1000.0;
        }

        volume = math.max(0.0, areaCross * l);
        final double perim = 4 * widthC + 2 * heightC - 2 * tWeb;
        surfaceArea = perim * l + 2 * math.max(0.0, areaCross);
        _lastUnitWeightPerM = unitWeightPerM;
        _lastSectionAreaCm2 = areaCross / 100.0;
        break;

      case 'H-Beam':
      case 'I-Beam':
      case 'I-Beam / H-Beam':
        final double heightB = h > 0 ? h : 100;
        final double widthB = w > 0 ? w : 100;
        final double tWebB = tw > 0 ? tw : t;
        final double tFlangeB = tf > 0 ? tf : t;

        final beamMap = _getBeamCatalogMap();
        StandardProfileSpec? spec;
        if (beamMap.containsKey(_selectedBeamPreset)) {
          spec = beamMap[_selectedBeamPreset];
        }
        spec ??= beamMap[_selectedSize];
        spec ??= StandardData.findWBeam(_selectedBeamPreset) ??
            StandardData.findWBeam(_selectedSize);
        spec ??= beamMap.values.cast<StandardProfileSpec?>().firstWhere(
          (s) => s != null && (s.h - heightB).abs() < 2.0 && (s.b - widthB).abs() < 2.0,
          orElse: () => null,
        );
        spec ??= StandardData.findClientIBeam(heightB, widthB, tWebB, tFlangeB) ??
            StandardData.findClientHBeam(heightB, widthB, tWebB, tFlangeB);

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

    if (_selectedProduct.contains('Checkered')) {
      double checkW = 0.0;
      final String tClean = (double.tryParse(_thicknessController.text.trim()) ?? t).toString();
      final String tInt = (double.tryParse(_thicknessController.text.trim()) ?? t).toInt().toString();
      final String tFixed1 = (double.tryParse(_thicknessController.text.trim()) ?? t).toStringAsFixed(1);

      if (_selectedProduct.contains('Aluminum')) {
        checkW = StandardData.aluminumCheckeredWeights[tFixed1] ??
            StandardData.aluminumCheckeredWeights[tClean] ??
            StandardData.aluminumCheckeredWeights[tInt] ??
            ((t * 2.74) + 1.60);
        _lastUnitWeightPerM = checkW;
      } else if (_selectedProduct.contains('Stainless')) {
        // SS Checkered Sheet: Density 8.30 formula (Thickness x 8.3)
        checkW = StandardData.ssCheckeredWeights[tFixed1] ??
            StandardData.ssCheckeredWeights[tClean] ??
            StandardData.ssCheckeredWeights[tInt] ??
            (t * 8.30);
        _lastUnitWeightPerM = checkW;
      } else {
        // HR Checkered Sheet: Density 8.50 formula (Thickness x 8.5)
        checkW = StandardData.hrCheckeredWeights[tFixed1] ??
            StandardData.hrCheckeredWeights[tClean] ??
            StandardData.hrCheckeredWeights[tInt] ??
            (t * 8.50);
        _lastUnitWeightPerM = checkW;
      }
      _lastSectionAreaCm2 = (t > 0 ? t : 1.0) * 10.0;
    } else if (_lastUnitWeightPerM <= 0.0 && l > 0.0) {
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
      if (_selectedProduct.contains('Checkered') && _lastUnitWeightPerM > 0) {
        final double areaM2 = (l * w) / 1000000.0;
        weightPerPiece = areaM2 * _lastUnitWeightPerM;
      } else if (_selectedShape != 'Sheet / Plate' && _lastUnitWeightPerM > 0) {
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
    _checkAndApplyHomeSync(settings);
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select Product / Profile',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.primaryDark),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.secondaryOrange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '37 Products',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondaryOrange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            isExpanded: true,
            value: CatalogData.allShapeNames.contains(_selectedProduct)
                ? _selectedProduct
                : CatalogData.allShapeNames.first,
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
            items: CatalogData.profiles.map((CatalogProfile profile) {
              return DropdownMenuItem<String>(
                value: profile.name,
                child: Row(
                  children: [
                    Icon(profile.icon,
                        color: AppColors.secondaryOrange, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        profile.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : AppColors.primaryDark),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        profile.categoryLabel,
                        style: TextStyle(
                          fontSize: 9.5,
                          color: isDark ? Colors.white60 : Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                _onProductSelected(val);
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
    final double lM = (double.tryParse(_lengthController.text) ?? 1000.0) / 1000.0;
    final availSizes = _getAvailableSizesForProduct(_selectedProduct);

    return Section2DDiagramWidget(
      shapeType: _selectedProduct,
      selectedSize: _selectedSize.isNotEmpty ? _selectedSize : (availSizes.isNotEmpty ? availSizes.first : '100'),
      selectedThickness: _thicknessController.text.isNotEmpty ? _thicknessController.text : _selectedThickness,
      lengthMeters: lM > 0 ? lM : 1.0,
      availableSizes: availSizes,
      activeVariant: _activeVariant,
      overrideWeight: _lastUnitWeightPerM > 0 ? _lastUnitWeightPerM : null,
      overrideSectionArea: _lastSectionAreaCm2 > 0 ? _lastSectionAreaCm2 : null,
      onSizeChanged: (newSize) {
        setState(() {
          _selectedSize = newSize;
          _applyDimensionsForProductSize(_selectedProduct, newSize);
          _performCalculation();
        });
      },
      onVariantChanged: (variant) {
        setState(() {
          _activeVariant = variant;
          final sizes = _getAvailableSizesForProduct(_selectedProduct);
          if (sizes.isNotEmpty) {
            _selectedSize = sizes.first;
            _applyDimensionsForProductSize(_selectedProduct, _selectedSize);
            _performCalculation();
          }
        });
      },
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
        final Map<String, StandardProfileSpec> catalogMap = _getBeamCatalogMap();

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
                      _selectedSize = val;
                      if (catalogMap.containsKey(val)) {
                        final spec = catalogMap[val]!;
                        _heightController.text = spec.h.toStringAsFixed(spec.h % 1 == 0 ? 0 : 1);
                        _widthController.text = spec.b.toStringAsFixed(spec.b % 1 == 0 ? 0 : 1);
                        _webThicknessController.text = spec.tw.toStringAsFixed(1);
                        _flangeThicknessController.text = spec.tf.toStringAsFixed(1);
                        final double density = _getEffectiveDensity();
                        _lastUnitWeightPerM = spec.weight * (density / 7.85);
                        _lastSectionAreaCm2 = spec.area;
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
