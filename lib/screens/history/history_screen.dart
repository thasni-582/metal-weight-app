import 'dart:async';
import 'package:flutter/material.dart';
import 'package:metal_weight/core/constants/app_colors.dart';
import 'package:metal_weight/models/calculation_model.dart';
import 'package:metal_weight/services/history_service.dart';
import 'package:metal_weight/services/pdf_export_service.dart';
import 'package:share_plus/share_plus.dart';

class HistoryScreen extends StatefulWidget {
  final VoidCallback? onNavigateToCalculator;

  const HistoryScreen({super.key, this.onNavigateToCalculator});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final HistoryService _historyService = HistoryService();
  StreamSubscription? _boxSubscription;

  String _searchQuery = '';
  List<CalculationModel> _historyItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _listenToHiveBox();
  }

  void _listenToHiveBox() async {
    try {
      final box = await _historyService.getBox();
      _boxSubscription = box.watch().listen((_) {
        if (mounted) {
          _loadHistory();
        }
      });
    } catch (_) {}
  }

  Future<void> _loadHistory() async {
    try {
      final history = await _historyService.loadHistory();
      if (mounted) {
        setState(() {
          _historyItems = history;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackBar('Error loading history: $e');
      }
    }
  }

  @override
  void dispose() {
    _boxSubscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filteredItems = _historyItems.where((item) {
      final title = item.title.toLowerCase();
      final subtitle = item.subtitle.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return title.contains(query) || subtitle.contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Calculation History'),
        actions: [
          if (_historyItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.white),
              tooltip: 'Clear All',
              onPressed: _showClearAllDialog,
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadHistory,
        color: AppColors.secondaryOrange,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Input Field
              TextField(
                controller: _searchController,
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textDark,
                  fontSize: 14,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search material, shape, or dimensions...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white38 : AppColors.textMuted,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: isDark ? const Color(0xFF38BDF8) : AppColors.primaryDark,
                  ),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? Colors.white12 : Colors.transparent,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? Colors.white12 : Colors.transparent,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.secondaryOrange, width: 1.5),
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: isDark ? Colors.white54 : AppColors.textMuted),
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                              _searchController.clear();
                            });
                          },
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 16),

              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Saved Calculations (${filteredItems.length})',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.primaryDark,
                    ),
                  ),
                  if (_historyItems.isNotEmpty)
                    TextButton.icon(
                      onPressed: _showClearAllDialog,
                      icon: const Icon(Icons.delete_sweep, color: Colors.redAccent, size: 18),
                      label: const Text(
                        'Clear All',
                        style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // Loading / Empty / List State
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 60.0),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primaryDark),
                  ),
                )
              else if (filteredItems.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 60.0),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.history_toggle_off, size: 72, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'No calculations found matching "$_searchQuery"'
                              : 'No saved calculations yet',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        if (_searchQuery.isEmpty && widget.onNavigateToCalculator != null)
                          ElevatedButton.icon(
                            onPressed: widget.onNavigateToCalculator,
                            icon: const Icon(Icons.calculate, color: Colors.white),
                            label: const Text(
                              'Open Calculator',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.blueprintBlue,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: _buildHistoryCard(item),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard(CalculationModel item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showItemDetails(item),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryOrange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.icon, color: AppColors.secondaryOrange, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white70 : Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.time,
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? Colors.white38 : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      item.weight,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                      onPressed: () => _showDeleteConfirmation(item),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showItemDetails(CalculationModel item) {
    final details = item.details;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              _buildDetailRow('Material', details['material'] ?? 'N/A'),
              _buildDetailRow('Shape', details['shape'] ?? 'N/A'),
              _buildDetailRow('Dimensions', details['dimensions'] ?? item.subtitle),
              _buildDetailRow('Quantity', '${details['quantity'] ?? '1'} pcs'),
              if (details['weightPerPiece'] != null)
                _buildDetailRow('Weight / Piece', details['weightPerPiece']),
              _buildDetailRow('Total Weight', item.weight),
              if (details['totalCost'] != null)
                _buildDetailRow('Total Cost', '\$${details['totalCost']}'),
              if (details['volume'] != null)
                _buildDetailRow('Volume', details['volume']),
              if (details['surfaceArea'] != null)
                _buildDetailRow('Surface Area', details['surfaceArea']),
              _buildDetailRow('Calculated On', item.time),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        Navigator.pop(context);
                        await PdfExportService.exportSingleCalculation(item, context: context);
                      },
                      icon: const Icon(Icons.picture_as_pdf_outlined, color: AppColors.secondaryOrange),
                      label: const Text(
                        'Export PDF',
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondaryOrange),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: AppColors.secondaryOrange, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _shareCalculation(item);
                      },
                      icon: const Icon(Icons.share, color: Colors.white),
                      label: const Text(
                        'Share',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _shareCalculation(CalculationModel item) {
    final text = '''
═══════════════════════════════
       MILEN TRADING QUOTATION
═══════════════════════════════
Material / Profile: ${item.title}
Dimensions: ${item.subtitle}
Weight: ${item.weight}
Date: ${item.time}
═══════════════════════════════
Calculated with Milen Trading Calculator
''';
    Share.share(text, subject: 'Milen Trading - ${item.title}');
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(CalculationModel item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Calculation'),
        content: Text('Are you sure you want to delete "${item.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // Bug fix: delete strictly by unique ID!
              await _historyService.deleteById(item.id);
              await _loadHistory();
              _showSnackBar('Calculation deleted');
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('Are you sure you want to delete all saved calculations?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _historyService.clearHistory();
              await _loadHistory();
              _showSnackBar('All history cleared');
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.primaryDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
