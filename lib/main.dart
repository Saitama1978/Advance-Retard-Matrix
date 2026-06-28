import 'package:flutter/material.dart';

void main() {
  runApp(const ShipWatchApp());
}

class ShipWatchApp extends StatelessWidget {
  const ShipWatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowColoredBoxes: false,
      debugShowCheckedModeBanner: false,
      title: 'Seaman Clock Adjuster',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.blueAccent,
        scaffoldBackgroundColor: const Color(0xFF121212),
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
  String _selectedWatch = '0000 - 0400';
  bool _isAdvance = true; 
  bool _isSplit = true;   

  final List<String> _watches = [
    '0000 - 0400',
    '0400 - 0800',
    '0800 - 1200',
    '1200 - 1600',
    '1600 - 2000',
    '2000 - 2400',
  ];

  Map<String, String> _calculateSchedule() {
    String totalDuty = '4 Hours (Normal)';
    String bridgeTime = '';
    String adjustmentNote = 'Walang pagbabago sa shift na ito.';

    // Base bridge time (Standard 15 mins early rule / Quarter to)
    if (_selectedWatch == '0000 - 0400') bridgeTime = '23:45';
    if (_selectedWatch == '0400 - 0800') bridgeTime = '03:45';
    if (_selectedWatch == '0800 - 1200') bridgeTime = '07:45';
    if (_selectedWatch == '1200 - 1600') bridgeTime = '11:45';
    if (_selectedWatch == '1600 - 2000') bridgeTime = '15:45';
    if (_selectedWatch == '2000 - 2400') bridgeTime = '19:45';

    if (_isAdvance) {
      if (_isSplit) {
        totalDuty = '3 Hours & 40 Minutes (Bawas 20m)';
        if (_selectedWatch == '0000 - 0400') {
          bridgeTime = '23:40 (20m Bago mag-Midnight)';
          adjustmentNote = 'Maagang akyat sa Bridge para sa transition ng split advance at 12 Midnight clock change.';
        } else if (_selectedWatch == '0400 - 0800') {
          bridgeTime = '03:40 (20m Bago mag-04:00)';
          adjustmentNote = 'Maagang akyat sa Bridge dahil sa epekto ng split advance adjustment.';
        } else if (_selectedWatch == '0800 - 1200') {
          bridgeTime = '07:40 (20m Bago mag-08:00)';
          adjustmentNote = 'Maagang akyat sa Bridge para sa huling bahagi ng 3-way split advance.';
        } else if (_selectedWatch == '2000 - 2400') {
          totalDuty = '4 Hours (Normal)';
          bridgeTime = '19:45';
          adjustmentNote = 'Pagpatak ng 12 Midnight (2400), i-advance ang opisyal na oras ng barko ng 1 oras patungong 01:00.';
        } else {
          totalDuty = '4 Hours (Normal)';
          adjustmentNote = 'Normal duty. Walang bawas sa shift na ito (00-04, 04-08, at 08-12 lamang ang apektado ng split).';
        }
      } else {
        if (_selectedWatch == '0000 - 0400') {
          totalDuty = '3 Hours (Patay-Oras / Bawas 1hr)';
          bridgeTime = '23:45';
          adjustmentNote = 'Pagpatak ng 12 Midnight, i-talon agad ang oras ng barko patungong 01:00.';
        }
      }
    } else {
      // --- REVERSE LOGIC PARA SA RETARD (ATRAS-ORAS) ---
      if (_isSplit) {
        totalDuty = '4 Hours & 20 Minutes (Dagdag 20m)';
        if (_selectedWatch == '0000 - 0400') {
          bridgeTime = '00:05 (Inatras ng 20m)';
          adjustmentNote = 'Buhay-oras! Extend ng 20 mins ang duty dahil pabaligtad (reverse) ang split adjustment ng gabi.';
        } else if (_selectedWatch == '0400 - 0800') {
          bridgeTime = '04:05 (Inatras ng 20m)';
          adjustmentNote = 'Extend ng 20 mins ang duty. Umatras ang akyat para maging patas ang hatian ng oras.';
        } else if (_selectedWatch == '0800 - 1200') {
          bridgeTime = '08:05 (Inatras ng 20m)';
          adjustmentNote = 'Huling bahagi ng 3-way split retard. Dagdag na 20 minutes sa gwardya.';
        } else if (_selectedWatch == '2000 - 2400') {
          totalDuty = '4 Hours (Normal)';
          bridgeTime = '19:45';
          adjustmentNote = 'Normal akyat. Pagpatak ng 2400/Midnight, ibalik ang opisyal na oras sa 23:00 base sa utos ng kapitan.';
        } else {
          totalDuty = '4 Hours (Normal)';
          adjustmentNote = 'Normal duty. Walang dagdag sa shift na ito tuwing gabi.';
        }
      } else {
        // Straight 1-Hour Retard
        if (_selectedWatch == '0000 - 0400') {
          totalDuty = '5 Hours (Buhay-Oras / Dagdag 1hr)';
          bridgeTime = '23:45';
          adjustmentNote = 'Pagpatak ng 02:00, ibalik ang relo sa 01:00. Mahabang gabi sa gwardya!';
        }
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
              const SizedBox(height: 16),

              const Text('Anong Klaseng Pagbabago?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('Advance', style: TextStyle(fontSize: 14)),
                      value: true,
                      groupValue: _isAdvance,
                      onChanged: (val) => setState(() => _isAdvance = val!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('Retard', style: TextStyle(fontSize: 14)),
                      value: false,
                      groupValue: _isAdvance,
                      onChanged: (val) => setState(() => _isAdvance = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              const Text('Paraan ng Pagbabago:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('3-Way Split (20m)', style: TextStyle(fontSize: 13)),
                      value: true,
                      groupValue: _isSplit,
                      onChanged: (val) => setState(() => _isSplit = val!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('Straight 1 Hr', style: TextStyle(fontSize: 13)),
                      value: false,
                      groupValue: _isSplit,
                      onChanged: (val) => setState(() => _isSplit = val!),
                    ),
                  ),
                ],
              ),
              const Divider(height: 30, color: Colors.grey),

              Expanded(
                child: Card(
                  color: _isAdvance ? const Color(0xFF1B2A47) : const Color(0xFF3E2723),
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
                        const SizedBox(height: 15),
                        _buildResultRow('Haba ng Duty mo:', results['duty']!),
                        const SizedBox(height: 15),
                        _buildResultRow('Akyat sa Bridge:', results['bridge']!, isHighlight: true),
                        const SizedBox(height: 15),
                        const Text('Gabay / Aksyon sa Oras:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                        const SizedBox(height: 5),
                        Text(results['note']!, style: const TextStyle(fontSize: 14, height: 1.4)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              
              // DEVELOPER BADGE
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.terminal, size: 16, color: Colors.blueAccent),
                    SizedBox(width: 8),
                    Text(
                      'Developer: Renante Fullo',
                      style: TextStyle(
                        fontSize: 14, 
                        fontWeight: FontWeight.bold, 
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value, {bool isHighlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
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
