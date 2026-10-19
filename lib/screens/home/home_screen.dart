import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:metal_weight/core/constants/app_colors.dart';
import 'package:metal_weight/core/constants/catalog_data.dart';
import 'package:metal_weight/core/constants/standard_data.dart';
import 'package:metal_weight/core/providers/app_settings_provider.dart';
import 'package:metal_weight/models/calculation_model.dart';
import 'package:metal_weight/screens/home/widgets/section_diagram_2d.dart';
import 'package:metal_weight/services/history_service.dart';
import 'package:metal_weight/services/pdf_export_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Selected state
  String _selectedCategory = 'all';
  String _selectedShape = 'IPE Beam';
  String _activeVariant = 'IPE';
  String _selectedSize = '140';
  String _selectedThickness = '';
  double _pieceLength = 6.0;
  int _quantity = 1;
  bool _isExportingPdf = false;

  // Output controllers
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _sectionController = TextEditingController();
  final HistoryService _historyService = HistoryService();

  @override
  void initState() {
    super.initState();
    _initForSelectedShape();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _sectionController.dispose();
    super.dispose();
  }

  void _initForSelectedShape() {
    final sizes = _getAvailableSizes();
    if (sizes.isNotEmpty) {
      if (!sizes.contains(_selectedSize)) {
        _selectedSize = sizes.first;
      }
    }
    final thicknesses = _getAvailableThicknesses();
    if (thicknesses.isNotEmpty) {
      if (!thicknesses.contains(_selectedThickness)) {
        _selectedThickness = thicknesses.first;
      }
    } else {
      _selectedThickness = '';
    }
    _updateResults();
  }

  void _onCategorySelected(String catId) {
    setState(() {
      _selectedCategory = catId;
      final availableInCat = CatalogData.getProfilesForCategory(catId);
      final bool currentInCat = availableInCat.any((p) => p.name == _selectedShape);
      if (!currentInCat && availableInCat.isNotEmpty) {
        _onShapeSelected(availableInCat.first.name);
      }
    });
  }

  void _onShapeSelected(String newShape) {
    setState(() {
      _selectedShape = newShape;
      _selectedCategory = CatalogData.getCategoryForShape(newShape);
      if (newShape == 'IPE Beam') {
        _activeVariant = 'IPE';
      } else if (newShape == 'IPE-AA Beam') {
        _activeVariant = 'IPE-AA';
      } else if (newShape == 'HEA Beam') {
        _activeVariant = 'HEA';
      } else if (newShape == 'HEB Beam') {
        _activeVariant = 'HEB';
      } else if (newShape == 'H-Beam (JIS)') {
        _activeVariant = 'JIS';
      } else if (newShape == 'UB (Universal Beam)') {
        _activeVariant = 'UB';
      } else if (newShape == 'UC (Universal Columns)') {
        _activeVariant = 'UC';
      } else if (newShape == 'W-Beam (Wide Flange)') {
        _activeVariant = 'W-Beam';
      } else if (newShape == 'UPN Channel') {
        _activeVariant = 'UPN';
      } else if (newShape == 'UPE Channel') {
        _activeVariant = 'UPE';
      } else if (newShape == 'U-Channel (JIS)') {
        _activeVariant = 'JIS';
      } else if (newShape.contains('Channel')) {
        _activeVariant = 'UPN';
      } else if (newShape.contains('Universal Beams')) {
        _activeVariant = 'UB';
      } else if (newShape.contains('Beam')) {
        _activeVariant = 'IPE';
      }
      _initForSelectedShape();
    });
  }

  List<String> _getAvailableSizes() {
    switch (_selectedShape) {
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
      case 'U-Channel (UPN / UPE / JIS)':
      case 'U-Channel (UPN / UPE)':
      case 'Channels (UPN / UPE)':
        if (_activeVariant == 'JIS') return StandardData.jisChannels.keys.toList();
        if (_activeVariant == 'UPE') return StandardData.upeChannels.keys.toList();
        return StandardData.upnChannels.keys.toList();

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
        return StandardData.jisBeams.keys.toList();
      case 'UB (Universal Beam)':
        return StandardData.ubBeams.keys.toList();
      case 'UC (Universal Columns)':
        return StandardData.ucBeams.keys.toList();
      case 'Universal Beams & Columns (UB / UC)':
        if (_activeVariant == 'UC') return StandardData.ucBeams.keys.toList();
        return StandardData.ubBeams.keys.toList();
      case 'W-Beam (Wide Flange)':
        return StandardData.wBeams.keys.toList();
      case 'H-Beam & I-Beam (HEA / HEB / JIS / IPE)':
      case 'H-Beam & I-Beam (HEA / HEB / IPE)':
      case 'Beams (IPE / IPE-AA / HEA / HEB)':
        if (_activeVariant == 'HEA') return StandardData.heaBeams.keys.toList();
        if (_activeVariant == 'HEB') return StandardData.hebBeams.keys.toList();
        if (_activeVariant == 'JIS') return StandardData.jisBeams.keys.toList();
        if (_activeVariant == 'IPE-AA') return StandardData.ipeAaBeams.keys.toList();
        return StandardData.ipeBeams.keys.toList();

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
      case 'Steel Pipes (ERW / Seamless)':
        return StandardData.steelPipes.keys.toList();

      // Solid Bars
      case 'Flat Bar':
      case 'Flat Bars':
        return StandardData.flatBarWidths;
      case 'MS Round Bar':
      case 'Round Bar':
      case 'Round Bars (Steel)':
      case 'Round Bars':
      case 'SS Round Bar (Stainless Steel)':
      case 'Aluminum Round Bar':
      case 'Brass Round Bar':
      case 'Copper Round Bar':
        return StandardData.roundBarDiameters;

      // Sheets & Plates
      case 'HR Checkered Sheet':
      case 'Stainless Steel Checkered Sheet':
        return StandardData.hrCheckeredWeights.keys.toList();
      case 'Aluminum Checkered Sheet':
        return StandardData.checkeredSheetThicknesses;
      case 'HR Sheet / HR Plate':
      case 'HR Sheet / Plate':
      case 'Steel Sheets':
      case 'Stainless Steel Sheet':
      case 'Aluminum Sheet':
      case 'Brass Sheet':
      case 'Copper Sheet':
        return StandardData.sheetThicknesses;

      default:
        return ['50'];
    }
  }

  List<String> _getAvailableThicknesses() {
    if (_selectedShape == 'Equal Angle' ||
        _selectedShape == 'Angle Equal' ||
        _selectedShape.contains('SS Angle') ||
        _selectedShape.contains('Aluminum Angle')) {
      return StandardData.equalAngles[_selectedSize]?.keys.toList() ?? ['5'];
    } else if (_selectedShape == 'Unequal Angle' || _selectedShape == 'Angle Unequal') {
      return StandardData.unequalAngles[_selectedSize]?.keys.toList() ?? ['5'];
    } else if (_selectedShape.contains('Square Tube') || _selectedShape.contains('SHS')) {
      return StandardData.squareTubes[_selectedSize]?.keys.toList() ?? ['2.0'];
    } else if (_selectedShape.contains('Rectangular Tube') || _selectedShape.contains('RHS')) {
      return StandardData.rectangularTubes[_selectedSize]?.keys.toList() ?? ['2.0'];
    } else if (_selectedShape.contains('Pipe')) {
      return StandardData.steelPipes[_selectedSize]?.keys.toList() ?? ['Sch 40 (3.91mm)'];
    } else if (_selectedShape.contains('Flat')) {
      return StandardData.flatBarThicknesses;
    }
    return [];
  }

  void _updateResults() {
    double weightKgPerM = 0.0;
    double sectionAreaCm2 = 0.0;

    switch (_selectedShape) {
      // Angles
      case 'Equal Angle':
      case 'Angle Equal':
        final double? w = StandardData.equalAngles[_selectedSize]?[_selectedThickness];
        weightKgPerM = w ?? 3.77;
        sectionAreaCm2 = weightKgPerM * 1.27;
        break;

      case 'Unequal Angle':
      case 'Angle Unequal':
        final double? w = StandardData.unequalAngles[_selectedSize]?[_selectedThickness];
        weightKgPerM = w ?? 3.76;
        sectionAreaCm2 = weightKgPerM * 1.27;
        break;

      case 'SS Angle (Stainless Steel)':
        final double? w = StandardData.equalAngles[_selectedSize]?[_selectedThickness];
        final double steelW = w ?? 3.77;
        weightKgPerM = steelW * (8.00 / 7.85);
        sectionAreaCm2 = steelW * 1.27;
        break;

      case 'Aluminum Angle':
        final double? w = StandardData.equalAngles[_selectedSize]?[_selectedThickness];
        final double steelW = w ?? 3.77;
        weightKgPerM = steelW * (2.70 / 7.85);
        sectionAreaCm2 = steelW * 1.27;
        break;

      // Channels
      case 'UPN Channel':
        final spec = StandardData.upnChannels[_selectedSize];
        if (spec != null) {
          weightKgPerM = spec.weight;
          sectionAreaCm2 = spec.area;
        }
        break;

      case 'UPE Channel':
        final spec = StandardData.upeChannels[_selectedSize];
        if (spec != null) {
          weightKgPerM = spec.weight;
          sectionAreaCm2 = spec.area;
        }
        break;

      case 'U-Channel (JIS)':
        final spec = StandardData.jisChannels[_selectedSize];
        if (spec != null) {
          weightKgPerM = spec.weight;
          sectionAreaCm2 = spec.area;
        }
        break;

      case 'U-Channel (UPN / UPE / JIS)':
      case 'U-Channel (UPN / UPE)':
      case 'Channels (UPN / UPE)':
        if (_activeVariant == 'JIS') {
          final spec = StandardData.jisChannels[_selectedSize];
          if (spec != null) {
            weightKgPerM = spec.weight;
            sectionAreaCm2 = spec.area;
          }
        } else if (_activeVariant == 'UPE') {
          final spec = StandardData.upeChannels[_selectedSize];
          if (spec != null) {
            weightKgPerM = spec.weight;
            sectionAreaCm2 = spec.area;
          }
        } else {
          final spec = StandardData.upnChannels[_selectedSize];
          if (spec != null) {
            weightKgPerM = spec.weight;
            sectionAreaCm2 = spec.area;
          }
        }
        break;

      // Beams & Columns
      case 'IPE Beam':
        final spec = StandardData.ipeBeams[_selectedSize];
        if (spec != null) {
          weightKgPerM = spec.weight;
          sectionAreaCm2 = spec.area;
        }
        break;

      case 'IPE-AA Beam':
        final spec = StandardData.ipeAaBeams[_selectedSize];
        if (spec != null) {
          weightKgPerM = spec.weight;
          sectionAreaCm2 = spec.area;
        }
        break;

      case 'HEA Beam':
        final spec = StandardData.heaBeams[_selectedSize];
        if (spec != null) {
          weightKgPerM = spec.weight;
          sectionAreaCm2 = spec.area;
        }
        break;

      case 'HEB Beam':
        final spec = StandardData.hebBeams[_selectedSize];
        if (spec != null) {
          weightKgPerM = spec.weight;
          sectionAreaCm2 = spec.area;
        }
        break;

      case 'H-Beam (JIS)':
        final spec = StandardData.jisBeams[_selectedSize];
        if (spec != null) {
          weightKgPerM = spec.weight;
          sectionAreaCm2 = spec.area;
        }
        break;

      case 'UB (Universal Beam)':
        final spec = StandardData.ubBeams[_selectedSize];
        if (spec != null) {
          weightKgPerM = spec.weight;
          sectionAreaCm2 = spec.area;
        }
        break;

      case 'UC (Universal Columns)':
        final spec = StandardData.ucBeams[_selectedSize];
        if (spec != null) {
          weightKgPerM = spec.weight;
          sectionAreaCm2 = spec.area;
        }
        break;

      case 'Universal Beams & Columns (UB / UC)':
        if (_activeVariant == 'UC') {
          final spec = StandardData.ucBeams[_selectedSize];
          if (spec != null) {
            weightKgPerM = spec.weight;
            sectionAreaCm2 = spec.area;
          }
        } else {
          final spec = StandardData.ubBeams[_selectedSize];
          if (spec != null) {
            weightKgPerM = spec.weight;
            sectionAreaCm2 = spec.area;
          }
        }
        break;

      case 'W-Beam (Wide Flange)':
        final spec = StandardData.wBeams[_selectedSize];
        if (spec != null) {
          weightKgPerM = spec.weight;
          sectionAreaCm2 = spec.area;
        }
        break;

      case 'H-Beam & I-Beam (HEA / HEB / JIS / IPE)':
      case 'H-Beam & I-Beam (HEA / HEB / IPE)':
      case 'Beams (IPE / IPE-AA / HEA / HEB)':
        if (_activeVariant == 'HEA') {
          final spec = StandardData.heaBeams[_selectedSize];
          if (spec != null) {
            weightKgPerM = spec.weight;
            sectionAreaCm2 = spec.area;
          }
        } else if (_activeVariant == 'HEB') {
          final spec = StandardData.hebBeams[_selectedSize];
          if (spec != null) {
            weightKgPerM = spec.weight;
            sectionAreaCm2 = spec.area;
          }
        } else if (_activeVariant == 'JIS') {
          final spec = StandardData.jisBeams[_selectedSize];
          if (spec != null) {
            weightKgPerM = spec.weight;
            sectionAreaCm2 = spec.area;
          }
        } else if (_activeVariant == 'IPE-AA') {
          final spec = StandardData.ipeAaBeams[_selectedSize];
          if (spec != null) {
            weightKgPerM = spec.weight;
            sectionAreaCm2 = spec.area;
          }
        } else {
          final spec = StandardData.ipeBeams[_selectedSize];
          if (spec != null) {
            weightKgPerM = spec.weight;
            sectionAreaCm2 = spec.area;
          }
        }
        break;

      // Tubes
      case 'Square Tube (SHS)':
        final double? w = StandardData.squareTubes[_selectedSize]?[_selectedThickness];
        weightKgPerM = w ?? 3.5;
        sectionAreaCm2 = weightKgPerM * 1.27;
        break;

      case 'Rectangular Tube (RHS)':
        final double? w = StandardData.rectangularTubes[_selectedSize]?[_selectedThickness];
        weightKgPerM = w ?? 4.5;
        sectionAreaCm2 = weightKgPerM * 1.27;
        break;

      case 'Stainless Steel Square Tube':
        final double? w = StandardData.squareTubes[_selectedSize]?[_selectedThickness];
        final double steelW = w ?? 3.5;
        weightKgPerM = steelW * (8.00 / 7.85);
        sectionAreaCm2 = steelW * 1.27;
        break;

      case 'Stainless Steel Rectangular Tube':
        final double? w = StandardData.rectangularTubes[_selectedSize]?[_selectedThickness];
        final double steelW = w ?? 4.5;
        weightKgPerM = steelW * (8.00 / 7.85);
        sectionAreaCm2 = steelW * 1.27;
        break;

      // Pipes
      case 'Pipe ERW':
      case 'Pipe Seamless':
      case 'Steel Pipes (ERW / Seamless)':
        final double? w = StandardData.steelPipes[_selectedSize]?[_selectedThickness];
        weightKgPerM = w ?? 5.0;
        sectionAreaCm2 = weightKgPerM * 1.27;
        break;

      case 'Stainless Steel Pipe':
        final double? w = StandardData.steelPipes[_selectedSize]?[_selectedThickness];
        final double steelW = w ?? 5.0;
        weightKgPerM = steelW * (8.00 / 7.85);
        sectionAreaCm2 = steelW * 1.27;
        break;

      // Bars
      case 'Flat Bar':
      case 'Flat Bars':
        final double width = double.tryParse(_selectedSize) ?? 50.0;
        final double thick = double.tryParse(_selectedThickness) ?? 5.0;
        sectionAreaCm2 = (width * thick) / 100.0;
        weightKgPerM = sectionAreaCm2 * 0.785;
        break;

      case 'MS Round Bar':
      case 'Round Bar':
      case 'Round Bars (Steel)':
      case 'Round Bars':
        final double dia = double.tryParse(_selectedSize) ?? 20.0;
        sectionAreaCm2 = (3.14159265 * dia * dia) / 400.0;
        weightKgPerM = sectionAreaCm2 * 0.785;
        break;

      case 'SS Round Bar (Stainless Steel)':
        final double dia = double.tryParse(_selectedSize) ?? 20.0;
        sectionAreaCm2 = (3.14159265 * dia * dia) / 400.0;
        weightKgPerM = sectionAreaCm2 * 0.800;
        break;

      case 'Aluminum Round Bar':
        final double dia = double.tryParse(_selectedSize) ?? 20.0;
        sectionAreaCm2 = (3.14159265 * dia * dia) / 400.0;
        weightKgPerM = sectionAreaCm2 * 0.270;
        break;

      case 'Brass Round Bar':
        final double dia = double.tryParse(_selectedSize) ?? 20.0;
        sectionAreaCm2 = (3.14159265 * dia * dia) / 400.0;
        weightKgPerM = sectionAreaCm2 * 0.850;
        break;

      case 'Copper Round Bar':
        final double dia = double.tryParse(_selectedSize) ?? 20.0;
        sectionAreaCm2 = (3.14159265 * dia * dia) / 400.0;
        weightKgPerM = sectionAreaCm2 * 0.896;
        break;

      // Sheets
      case 'HR Sheet / HR Plate':
      case 'HR Sheet / Plate':
      case 'Steel Sheets':
        final double t = double.tryParse(_selectedSize) ?? 2.0;
        weightKgPerM = t * 7.85;
        sectionAreaCm2 = t * 10.0;
        break;

      case 'HR Checkered Sheet':
        weightKgPerM = StandardData.hrCheckeredWeights[_selectedSize] ?? 36.5;
        sectionAreaCm2 = (double.tryParse(_selectedSize) ?? 4.5) * 10.0;
        break;

      case 'Stainless Steel Sheet':
        final double t = double.tryParse(_selectedSize) ?? 2.0;
        weightKgPerM = t * 8.00;
        sectionAreaCm2 = t * 10.0;
        break;

      case 'Stainless Steel Checkered Sheet':
        final double baseW = StandardData.hrCheckeredWeights[_selectedSize] ?? 36.5;
        weightKgPerM = baseW * (8.00 / 7.85);
        sectionAreaCm2 = (double.tryParse(_selectedSize) ?? 4.5) * 10.0;
        break;

      case 'Aluminum Sheet':
        final double t = double.tryParse(_selectedSize) ?? 2.0;
        weightKgPerM = t * 2.70;
        sectionAreaCm2 = t * 10.0;
        break;

      case 'Aluminum Checkered Sheet':
        final double t = double.tryParse(_selectedSize) ?? 2.0;
        weightKgPerM = StandardData.aluminumCheckeredWeights[_selectedSize] ?? ((t * 2.70) + 1.60);
        sectionAreaCm2 = t * 10.0;
        break;

      case 'Brass Sheet':
        final double t = double.tryParse(_selectedSize) ?? 2.0;
        weightKgPerM = t * 8.50;
        sectionAreaCm2 = t * 10.0;
        break;

      case 'Copper Sheet':
        final double t = double.tryParse(_selectedSize) ?? 2.0;
        weightKgPerM = t * 8.96;
        sectionAreaCm2 = t * 10.0;
        break;
    }

    _weightController.text = weightKgPerM.toStringAsFixed(2);
    _sectionController.text = sectionAreaCm2.toStringAsFixed(2);
  }

  CalculationModel _createCalculationModel() {
    final double weightPerM = double.tryParse(_weightController.text) ?? 0.0;
    final double totalKg = weightPerM * _pieceLength * _quantity;
    final now = DateTime.now();
    final timeStr =
        '${now.day}/${now.month}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    String iconName = 'beam';
    if (_selectedShape.contains('Angle')) {
      iconName = 'angle';
    } else if (_selectedShape.contains('Channel')) {
      iconName = 'channel';
    } else if (_selectedShape.contains('Flat')) {
      iconName = 'flat_bar';
    } else if (_selectedShape.contains('Round')) {
      iconName = 'round_bar';
    } else if (_selectedShape.contains('Tube')) {
      iconName = 'tube';
    } else if (_selectedShape.contains('Pipe')) {
      iconName = 'pipe';
    } else if (_selectedShape.contains('Sheet')) {
      iconName = 'sheet';
    }

    final dimStr =
        '$_selectedSize${_selectedThickness.isNotEmpty ? ' x $_selectedThickness' : ''} | L=${_pieceLength.toStringAsFixed(1)}m x $_quantity pcs';

    return CalculationModel(
      title: '$_selectedShape $_selectedSize',
      subtitle: dimStr,
      weight: '${totalKg.toStringAsFixed(2)} kg',
      time: timeStr,
      iconName: iconName,
      bgColor: const Color(0xFFE8F0FE),
      iconColor: const Color(0xFF1A73E8),
      weightValue: totalKg,
      details: {
        'material': _selectedShape.contains('Aluminum')
            ? 'Aluminum'
            : (_selectedShape.contains('Brass')
                ? 'Brass'
                : (_selectedShape.contains('Copper')
                    ? 'Copper'
                    : (_selectedShape.contains('Stainless') || _selectedShape.contains('SS')
                        ? 'Stainless Steel'
                        : 'Steel'))),
        'shape': _selectedShape,
        'dimensions': dimStr,
        'quantity': '$_quantity',
        'weightPerPiece': _selectedShape.contains('Sheet')
            ? '${weightPerM.toStringAsFixed(2)} kg/m²'
            : '${weightPerM.toStringAsFixed(2)} kg/m',
        'totalWeight': '${totalKg.toStringAsFixed(2)} kg',
        'sectionArea': '${_sectionController.text} cm²',
      },
    );
  }

  Future<void> _saveCurrentProfileToHistory(AppSettingsProvider settings) async {
    final model = _createCalculationModel();
    await _historyService.addCalculation(model);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(settings.strings.get('saved_to_history')),
          backgroundColor: AppColors.primaryDark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _exportPdfQuotation() async {
    if (_isExportingPdf) return;
    setState(() => _isExportingPdf = true);

    try {
      final model = _createCalculationModel();
      await PdfExportService.exportSingleCalculation(model, context: context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting PDF: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExportingPdf = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(settings.strings.get('app_title')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildShapeCard(settings),
            const SizedBox(height: 14),
            _buildDimensionSelectorsCard(settings),
            const SizedBox(height: 14),
            _buildBlueprintDiagram(),
            const SizedBox(height: 14),
            _buildLengthAndTotalWeightCard(settings),
            const SizedBox(height: 14),
            _buildPropertiesInfoCard(settings),
          ],
        ),
      ),
    );
  }

  Widget _buildShapeCard(AppSettingsProvider settings) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = settings.isArabic;
    final filteredProfiles = CatalogData.getProfilesForCategory(_selectedCategory);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with category label
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.category_outlined, color: AppColors.secondaryOrange, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    settings.strings.get('select_category'),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.secondaryOrange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '36 PRODUCTS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondaryOrange,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Horizontal Category Filter Pills
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: CatalogData.categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, idx) {
                final cat = CatalogData.categories[idx];
                final bool isSelected = (cat.id == _selectedCategory);
                final String label = isArabic ? cat.arLabel : cat.label;

                return GestureDetector(
                  onTap: () => _onCategorySelected(cat.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryDark
                          : (isDark ? Colors.white10 : const Color(0xFFF1F5F9)),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.secondaryOrange
                            : (isDark ? Colors.white12 : Colors.grey.shade300),
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          cat.icon,
                          size: 14,
                          color: isSelected
                              ? AppColors.secondaryOrange
                              : (isDark ? Colors.white70 : Colors.grey.shade700),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : (isDark ? Colors.white70 : AppColors.primaryDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),

          // Profile Selection Label
          Text(
            settings.strings.get('select_profile'),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white60 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 6),

          // Shape Dropdown Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
            decoration: BoxDecoration(
              border: Border.all(
                color: isDark ? Colors.white24 : AppColors.borderLight,
                width: 1.2,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: filteredProfiles.any((p) => p.name == _selectedShape)
                    ? _selectedShape
                    : (filteredProfiles.isNotEmpty ? filteredProfiles.first.name : null),
                isExpanded: true,
                dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                icon: const Icon(Icons.arrow_drop_down, color: AppColors.secondaryOrange),
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.primaryDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                items: filteredProfiles.map((CatalogProfile profile) {
                  return DropdownMenuItem<String>(
                    value: profile.name,
                    child: Row(
                      children: [
                        Icon(profile.icon, color: AppColors.secondaryOrange, size: 19),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            profile.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : AppColors.primaryDark,
                            ),
                          ),
                        ),
                        if (_selectedCategory == 'all')
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
                onChanged: (String? val) {
                  if (val != null && val != _selectedShape) {
                    _onShapeSelected(val);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDimensionSelectorsCard(AppSettingsProvider settings) {
    final availableSizes = _getAvailableSizes();
    final availableThicknesses = _getAvailableThicknesses();
    final bool hasThickness = availableThicknesses.isNotEmpty;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedShape == 'Flat Bars'
                          ? settings.strings.get('width')
                          : (_selectedShape.contains('Pipe')
                              ? 'Pipe Size (NPS)'
                              : (_selectedShape.contains('Tube')
                                  ? 'Outer Dimension'
                                  : (_selectedShape.contains('Sheet')
                                      ? settings.strings.get('thickness')
                                      : (_selectedShape.contains('Round')
                                          ? settings.strings.get('diameter')
                                          : settings.strings.get('standard_size'))))),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: isDark ? Colors.white24 : AppColors.borderLight),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: availableSizes.contains(_selectedSize)
                              ? _selectedSize
                              : (availableSizes.isNotEmpty ? availableSizes.first : null),
                          isExpanded: true,
                          dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                          style: TextStyle(
                            color: isDark ? Colors.white : AppColors.primaryDark,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          items: availableSizes.map((s) {
                            return DropdownMenuItem<String>(
                              value: s,
                              child: Text(
                                s,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedSize = val;
                                final newThicks = _getAvailableThicknesses();
                                if (newThicks.isNotEmpty &&
                                    !newThicks.contains(_selectedThickness)) {
                                  _selectedThickness = newThicks.first;
                                }
                                _updateResults();
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (hasThickness) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedShape.contains('Pipe') ? 'Wall / Schedule' : settings.strings.get('thickness'),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: isDark ? Colors.white24 : AppColors.borderLight),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: availableThicknesses.contains(_selectedThickness)
                                ? _selectedThickness
                                : (availableThicknesses.isNotEmpty
                                    ? availableThicknesses.first
                                    : null),
                            isExpanded: true,
                            dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                            style: TextStyle(
                              color: isDark ? Colors.white : AppColors.primaryDark,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            items: availableThicknesses.map((t) {
                              return DropdownMenuItem<String>(
                                value: t,
                                child: Text(_selectedShape.contains('Pipe') ? t : '$t mm'),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedThickness = val;
                                  _updateResults();
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBlueprintDiagram() {
    double? wVal = double.tryParse(_weightController.text);
    double? sVal = double.tryParse(_sectionController.text);

    return Section2DDiagramWidget(
      shapeType: _selectedShape,
      selectedSize: _selectedSize,
      selectedThickness: _selectedThickness,
      lengthMeters: _pieceLength,
      availableSizes: _getAvailableSizes(),
      activeVariant: _activeVariant,
      overrideWeight: wVal,
      overrideSectionArea: sVal,
      onSizeChanged: (newSize) {
        setState(() {
          _selectedSize = newSize;
          final thicks = _getAvailableThicknesses();
          if (thicks.isNotEmpty && !thicks.contains(_selectedThickness)) {
            _selectedThickness = thicks.first;
          }
          _updateResults();
        });
      },
      onVariantChanged: (variant) {
        setState(() {
          _activeVariant = variant;
          final sizes = _getAvailableSizes();
          if (sizes.isNotEmpty) {
            _selectedSize = sizes.first;
          }
          _updateResults();
        });
      },
    );
  }

  Widget _buildLengthAndTotalWeightCard(AppSettingsProvider settings) {
    final double weightPerM = double.tryParse(_weightController.text) ?? 0.0;
    final double totalKg = weightPerM * _pieceLength * _quantity;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${settings.strings.get('length')}:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.primaryDark,
                ),
              ),
              Text(
                '${_pieceLength.toStringAsFixed(1)} m',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondaryOrange,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.secondaryOrange,
              inactiveTrackColor: Colors.grey.shade200,
              thumbColor: AppColors.secondaryOrange,
              trackHeight: 4,
            ),
            child: Slider(
              value: _pieceLength,
              min: 0.5,
              max: 12.0,
              divisions: 23,
              onChanged: (val) {
                setState(() {
                  _pieceLength = val;
                });
              },
            ),
          ),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quantity (Pieces):',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.primaryDark,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: AppColors.secondaryOrange, size: 22),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: isDark ? Colors.white24 : AppColors.borderLight),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$_quantity',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.primaryDark,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: AppColors.secondaryOrange, size: 22),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => setState(() => _quantity++),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _selectedShape.contains('Sheet')
                      ? '${settings.strings.get('weight_per_m2')}: ${_weightController.text} kg/m²'
                      : '${settings.strings.get('weight_per_m')}: ${_weightController.text} kg/m',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.primaryDark,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${settings.strings.get('total_weight')}: ${totalKg.toStringAsFixed(2)} kg',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _saveCurrentProfileToHistory(settings),
                  icon: const Icon(Icons.bookmark_add_outlined, color: Colors.white, size: 20),
                  label: Text(
                    settings.strings.get('save_to_history'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.secondaryOrange),
                        )
                      : const Icon(Icons.picture_as_pdf, color: AppColors.secondaryOrange, size: 20),
                  label: Text(
                    _isExportingPdf ? 'Exporting...' : settings.strings.get('share_quotation_pdf'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.secondaryOrange,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    side: const BorderSide(color: AppColors.secondaryOrange, width: 1.8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPropertiesInfoCard(AppSettingsProvider settings) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.blueprintBlue.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.blueprintBlue.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.secondaryOrange.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.info_outline, color: AppColors.secondaryOrange, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Standard Engineering Profile Properties',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Selected: $_selectedShape ($_selectedSize mm${_selectedThickness.isNotEmpty ? ' x $_selectedThickness' : ''})',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
                Text(
                  '${settings.strings.get('section_area')}: ${_sectionController.text} cm²',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.blueprintAccent,
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
