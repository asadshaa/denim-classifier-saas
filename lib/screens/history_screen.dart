import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:denim_classifier/utils/fabric_taxonomy.dart';
import 'package:denim_classifier/widgets/animated_orb_background.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _allHistory = [];
  List<Map<String, dynamic>> _filtered = [];
  String _activeFilter = 'All';
  bool _isLoading = true;

  // Filter options: All + all 21 main classes
  final List<String> _filters = ['All', ...FabricTaxonomy.mainClasses];

  // Colors come from FabricTaxonomy.colorFor(label)

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('scan_history_json');
    List<Map<String, dynamic>> history = [];
    if (jsonStr != null) {
      try {
        final decoded = jsonDecode(jsonStr) as List<dynamic>;
        history = decoded.cast<Map<String, dynamic>>().reversed.toList();
      } catch (_) {}
    }
    setState(() {
      _allHistory = history;
      _isLoading = false;
    });
    _applyFilter(_activeFilter);
  }

  void _applyFilter(String filter) {
    setState(() {
      _activeFilter = filter;
      _filtered = filter == 'All'
          ? List.from(_allHistory)
          : _allHistory
              .where((e) {
                final lbl = (e['mainClass'] ?? e['label'] as String?) ?? '';
                return lbl == filter;
              }).toList();
    });
  }

  Future<void> _deleteItem(int filteredIndex) async {
    final item = _filtered[filteredIndex];
    final allIdx = _allHistory.indexWhere((e) {
      final lbl = (e['mainClass'] ?? e['label'] as String?) ?? '';
      final itemLbl = (item['mainClass'] ?? item['label'] as String?) ?? '';
      return e['timestamp'] == item['timestamp'] && lbl == itemLbl;
    });
    if (allIdx == -1) return;

    setState(() {
      _allHistory.removeAt(allIdx);
      _filtered.removeAt(filteredIndex);
    });

    final prefs = await SharedPreferences.getInstance();
    final toStore = _allHistory.reversed.toList();
    await prefs.setString('scan_history_json', jsonEncode(toStore));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Scan removed'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () async {
              setState(() {
                _allHistory.insert(allIdx, item);
                _applyFilter(_activeFilter);
              });
              final undoPrefs = await SharedPreferences.getInstance();
              final undoStore = _allHistory.reversed.toList();
              await undoPrefs.setString('scan_history_json', jsonEncode(undoStore));
            },
          ),
        ),
      );
    }
  }

  Future<void> _clearHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Clear All History?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('scan_history_json');
      setState(() {
        _allHistory = [];
        _filtered = [];
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('History cleared')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text('Scan History', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (_allHistory.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: _clearHistory,
              tooltip: 'Clear All',
            ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // ── Animated Orb Background ────────────────────────────────────
          AnimatedOrbBackground(
            orbs: Theme.of(context).brightness == Brightness.dark
                ? OrbConfig.dark
                : OrbConfig.light,
            speed: 0.7,
          ),

          // ── Content ───────────────────────────────────────────────────
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                  child: Column(
                    children: [
                      // Filter chips
                      SizedBox(
                        height: 52,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: _filters.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final filter = _filters[index];
                            final isSelected = _activeFilter == filter;
                            return ChoiceChip(
                              label: Text(filter, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : onSurface)),
                              selected: isSelected,
                              selectedColor: const Color(0xFF6366F1),
                              backgroundColor: onSurface.withOpacity(0.05),
                              onSelected: (_) => _applyFilter(filter),
                            );
                          },
                        ),
                      ),
                      
                      // List
                      Expanded(
                        child: _filtered.isEmpty
                            ? _buildEmpty(onSurface)
                            : ListView.separated(
                                padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                                itemCount: _filtered.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final item = _filtered[index];
                                  // Support both new (mainClass) and legacy (label) JSON keys
                                  final label = (item['mainClass'] ?? item['label'] as String?) ?? 'Unknown';
                                  final confidence = (item['mainConfidence'] ?? item['confidence'] as double?) ?? 0.0;
                                  final subclass = item['subclass'] as String?;
                                  final time = DateTime.fromMillisecondsSinceEpoch(item['timestamp'] as int? ?? 0);
                                  final timeStr = "${time.day}/${time.month} ${time.hour}:${time.minute.toString().padLeft(2, '0')}";
                                  final color = FabricTaxonomy.colorFor(label);

                                  return Dismissible(
                                    key: Key("${item['timestamp']}_$label"),
                                    direction: DismissDirection.endToStart,
                                    onDismissed: (_) => _deleteItem(index),
                                    background: Container(
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.only(right: 20),
                                      decoration: BoxDecoration(
                                        color: Colors.redAccent,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: const Icon(Icons.delete_outline, color: Colors.white),
                                    ),
                                    child: Card(
                                      elevation: 0,
                                      color: onSurface.withOpacity(0.04),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        side: BorderSide(color: onSurface.withOpacity(0.06)),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 44,
                                              height: 44,
                                              decoration: BoxDecoration(
                                                color: color.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Center(
                                                child: Icon(Icons.texture, color: color, size: 22),
                                              ),
                                            ),
                                            const SizedBox(width: 14),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    subclass != null ? subclass : FabricTaxonomy.descriptionFor(label),
                                                    style: TextStyle(fontSize: 12, color: onSurface.withOpacity(0.5)),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                  decoration: BoxDecoration(
                                                    color: color.withOpacity(0.12),
                                                    borderRadius: BorderRadius.circular(20),
                                                  ),
                                                  child: Text('${(confidence * 100).toInt()}%', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
                                                ),
                                                const SizedBox(height: 6),
                                                Text(timeStr, style: TextStyle(fontSize: 11, color: onSurface.withOpacity(0.45))),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildEmpty(Color onSurface) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🔍', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 20),
            Text(
              _activeFilter == 'All' ? 'No Scans Yet' : 'No "$_activeFilter" Scans',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              _activeFilter == 'All' ? 'Scan a fabric to see results here.' : 'Try a different filter.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: onSurface.withOpacity(0.6)),
            ),
          ],
        ),
      ),
    );
  }
}


