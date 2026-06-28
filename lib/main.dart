import 'package:flutter/material.dart';

void main() {
  runApp(const ShipWatchApp());
}

class ShipWatchApp extends StatelessWidget {
  const ShipWatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Seaman Clock Adjuster',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.blueAccent,
        scaffoldBackgroundColor: const Color(0细121212),
      ),
      home: const WatchCalculatorScreen(),
    );
  }
}

class WatchCalculatorScreen extends StatefulWidget {
  const WatchCalculatorScreen({super.key});

  @override
  State<WatchCalculatorScreen> createState() => _WatchCalculatorScreenState();
}

class _WatchCalculatorScreenState extends State<WatchCalculatorScreen> {
  // States
  String _selectedWatch = '0000 - 0400';
  bool _isAdvance = true; // true = Advance, false = Retard
  bool _isSplit = true;   // true = 20-min Split, false = Straight 1-Hour

  final List<String> _watches = [
    '0000 - 0400',
    '0400 - 0800',
    '0800 - 1200',
    '1200 - 1600',
    '1600 - 2000',
    '2000 - 2400',
  ];

  // Logic to calculate details
  Map<String, String> _calculateSchedule() {
    String totalDuty = '4 Hours (Normal)';
    String bridgeTime = '';
    String adjustmentNote = 'Walang pagbabago sa shift na ito.';

    // Base bridge time (15 mins early rule)
    if (_selectedWatch == '0000 - 0400') bridgeTime = '23:45';
    if (_selectedWatch == '0400 - 0800') bridgeTime = '03:45';
    if (_selectedWatch == '0800 - 1200') bridgeTime = '07:45';
    if (_selectedWatch == '1200 - 1600') bridgeTime = '11:45';
    if (_selectedWatch == '1600 - 2000') bridgeTime = '15:45';
    if (_selectedWatch == '2000 - 2400') bridgeTime = '19:45';

    if (_isAdvance) {
      if (_isSplit) {
        // 3-Way Split Advance (20 mins each for 8-12, 12-4, 4-8)
        totalDuty = '3 Hours & 40 Minutes (Bawas 20m)';
        
        if (_selectedWatch == '2000 - 2400') {
          bridgeTime = '19:45 (Normal akyat)';
          adjustmentNote = 'Pagpatak ng 23:00, i-advance ang relo sa 23:20.';
        } else if (_selectedWatch == '0000 - 0400') {
          bridgeTime = '23:45 (Bagong Oras)';
          adjustmentNote = 'Pagpatak ng 02:00, i-advance ang relo sa 02:20.';
        } else if (_selectedWatch == '0400 - 0800') {
          bridgeTime = '03:45 (Bagong Oras - Maaga Gising!)';
          adjustmentNote = 'Pagpatak ng 06:00, i-advance ang relo sa 06:20.';
        } else {
          totalDuty = '4 Hours (Normal)';
          adjustmentNote = 'Walang bawas sa shift na ito. Day-workers/ibang watch ang apektado.';
        }
      } else {
        // Straight 1-Hour Advance (Karaniwang sa 12-4 night watch ginagawa)
        if (_selectedWatch == '0000 - 0400') {
          totalDuty = '3 Hours (Patay-Oras / Bawas 1hr)';
          bridgeTime = '23:45 (Normal akyat)';
          adjustmentNote = 'Pagpatak ng 01:00, i-talon agad sa 02:00.';
        } else if (_selectedWatch == '0400 - 0800') {
          bridgeTime = '03:45 (Bagong Oras - Puyat!)';
          adjustmentNote = 'Direktang akyat sa bagong takbo ng oras.';
        }
      }
    } else {
      // Retard Logic
      if (_selectedWatch == '1200 - 1600' && !_isSplit) {
        totalDuty = '5 Hours (Buhay-Oras / Dagdag 1hr)';
        adjustmentNote = 'Pagpatak ng 16:00, ibalik ang relo sa 15:00. Dagdag pwesto!';
      } else if (_selectedWatch == '0000 - 0400' && !_isSplit) {
        totalDuty = '5 Hours (Dagdag 1hr sa gabi)';
        adjustmentNote = 'Pagpatak ng 02:00, ibalik sa 01:00. Mahabang gabi.';
      } else {
        adjustmentNote = 'Normal duty. Depende sa Night Orders kung saan isisingit ang +1hr.';
      }
    }

    return {
      'duty': totalDuty,
      'bridge': bridgeTime,
      'note': adjustmentNote,
    };
  }

  @override
  Widget build(BuildContext context) {
    final results = _calculateSchedule();

    return Scaffold(
      appBar: AppBar(
        title: const Text('⚓ Ship Watch Clock Adjuster'),
        centerTitle: true,
        backgroundColor: Colors.blueGrey[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. WATCH SELECTOR
            const Text('Piliin ang Iyong Duty Watch:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedWatch,
                  isExpanded: true,
                  dropdownColor: Colors.grey[900],
                  items: _watches.map((w) => DropdownMenuItem(value: w, child: Text(w))).toList(),
                  onChanged: (val) => setState(() => _selectedWatch = val!),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 2. ADVANCE OR RETARD
            const Text('Anong Klaseng Pagbabago?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('Advance (Sulong)'),
                    value: true,
                    groupValue: _isAdvance,
                    onChanged: (val) => setState(() => _isAdvance = val!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('Retard (Atras)'),
                    value: false,
                    groupValue: _isAdvance,
                    onChanged: (val) => setState(() => _isAdvance = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // 3. SPLIT OR STRAIGHT (Gagana lang kapag Advance para sa request mo)
            if (_isAdvance) ...[
              const Text('Paraan ng Pag-Advance:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('3-Way Split (20m bawat isa)'),
                      value: true,
                      groupValue: _isSplit,
                      onChanged: (val) => setState(() => _isSplit = val!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('Straight 1 Hour'),
                      value: false,
                      groupValue: _isSplit,
                      onChanged: (val) => setState(() => _isSplit = val!),
                    ),
                  ),
                ],
              ),
            ],
            const Divider(height: 40, color: Colors.grey),

            // 4. RESULTS CARD
            Expanded(
              child: Card(
                color: _isAdvance ? Colors.blueGrey[900] : Colors.brown[900],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isAdvance ? '📈 CLOCK ADVANCE INFO' : '📉 CLOCK RETARD INFO',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber),
                      ),
                      const SizedBox(height: 20),
                      _buildResultRow('Haba ng Duty mo:', results['duty']!),
                      const SizedBox(height: 15),
                      _buildResultRow('Akyat sa Bridge (15m early):', results['bridge']!, isHighlight: true),
                      const SizedBox(height: 15),
                      const Text('Gabay / Aksyon sa Oras:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 5),
                      Text(results['note']!, style: const TextStyle(fontSize: 15, height: 1.4)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value, {bool isHighlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isHighlight ? Colors.greenAccent : Colors.white,
          ),
        ),
      ],
    );
  }
}
