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
  String _selectedWatch = '2000 - 2400';
  bool _isAdvance = true; 
  bool _isSplit = true;   

  // Nililitaaw lang ang mga watches na sakop ng midnight adjustment at ang turnover sa umaga
  final List<String> _watches = [
    '2000 - 2400',
    '0000 - 0400',
    '0400 - 0800',
    '0800 - 1200',
  ];

  Map<String, String> _calculateSchedule() {
    String totalDuty = '4 Hours (Normal)';
    String bridgeTime = '';
    String adjustmentNote = 'Walang pagbabago sa shift na ito.';

    if (_isAdvance) {
      if (_isSplit) {
        if (_selectedWatch == '2000 - 2400') {
          totalDuty = '3 Hours & 40 Minutes (Bawas 20m)';
          bridgeTime = '19:45';
          adjustmentNote = 'Bawas ang shift mo ng 20m. Bababa ka ng maaga sa bridge ng 23:40 dahil aakyat na ang 12-4 watch para saluhin ang split advance.';
        } else if (_selectedWatch == '0000 - 0400') {
          totalDuty = '3 Hours & 40 Minutes (Bawas 20m)';
          bridgeTime = '23:40 (Old Time)';
          adjustmentNote = 'Aakyat ng 23:40 sa Lumang Oras. Pagpatak ng 2400, lalaktaw ang relo sa 01:00. Bababa ka ng 04:20 sa Bagong Oras.';
        } else if (_selectedWatch == '0400 - 0800') {
          totalDuty = '3 Hours & 40 Minutes (Bawas 20m)';
          bridgeTime = '04:20 (New Time)';
          adjustmentNote = 'Aakyat ng 04:20 sa Bagong Oras pagkatapos ka irelieve ng 12-4. Bababa ka ng eksaktong 08:00 para sakto sa susunod na duty.';
        } else if (_selectedWatch == '0800 - 1200') {
          totalDuty = '4 Hours (Normal)';
          bridgeTime = '07:45';
          adjustmentNote = 'Back to normal duty. Eksaktong 07:45 ang akyat mo para i-relieve ang 4-8 watch na bababa ng 08:00.';
        }
      } else {
        // Straight 1-Hour Advance
        totalDuty = _selectedWatch == '0000 - 0400' ? '3 Hours (Bawas 1hr)' : '4 Hours (Normal)';
        bridgeTime = _getNormalAkyatTime(_selectedWatch);
        adjustmentNote = _selectedWatch == '0000 - 0400' 
            ? 'Pagpatak ng 12 Midnight (2400), i-talon agad ang opisyal na oras ng barko patungong 01:00.'
            : 'Normal duty sa ilalim ng bagong takbo ng oras ng barko.';
      }
    } else {
      // --- REVERSE LOGIC PARA SA RETARD (ATRAS-ORAS) ---
      if (_isSplit) {
        if (_selectedWatch == '2000 - 2400') {
          totalDuty = '4 Hours & 20 Minutes (Dagdag 20m)';
          bridgeTime = '19:45';
          adjustmentNote = 'Mag-eextend ang duty mo sa gabi hanggang 00:20 (Bagong Oras) para makuha ang dagdag na 20 minutes bago ka i-relieve ng 12-4.';
        } else if (_selectedWatch == '0000 - 0400') {
          totalDuty = '4 Hours & 20 Minutes (Dagdag 20m)';
          bridgeTime = '00:20 (New Time)';
          adjustmentNote = 'Umatras ang akyat mo sa 00:20 dahil nag-extend ang naunang watch. Bababa ka sa bridge ng 04:40.';
        } else if (_selectedWatch == '0400 - 0800') {
          totalDuty = '4 Hours & 20 Minutes (Dagdag 20m)';
          bridgeTime = '04:40 (New Time)';
          adjustmentNote = 'Umatras ang akyat mo sa 04:40. Bababa ka sa bridge ng 09:00 sa Bagong Oras para makumpleto ang dagdag na oras.';
        } else if (_selectedWatch == '0800 - 1200') {
          totalDuty = '4 Hours (Normal)';
          bridgeTime = '08:45'; // Naurong ang akyat dahil sa dulo ng retard ng 4-8 watch
          adjustmentNote = 'Back to normal duty length. Aakyat ng 08:45 para irelieve ang 4-8 watch na bababa ng 09:00 sa bagong takbo ng oras.';
        }
      } else {
        // Straight 1-Hour Retard
        totalDuty = _selectedWatch == '0000 - 0400' ? '5 Hours (Dagdag 1hr)' : '4 Hours (Normal)';
        bridgeTime = _getNormalAkyatTime(_selectedWatch);
        adjustmentNote = _selectedWatch == '0000 - 0400'
            ? 'Pagpatak ng Midnight, i-retard ang oras. Dagdag 1 oras sa gwardya.'
            : 'Normal duty sa ilalim ng inatras na oras ng barko.';
      }
    }

    return {
      'duty': totalDuty,
      'bridge': bridgeTime,
      'note': adjustmentNote,
    };
  }

  String _getNormalAkyatTime(String watch) {
    if (watch == '2000 - 2400') return '19:45';
    if (watch == '0000 - 0400') return '23:45';
    if (watch == '0400 - 0800') return '03:45';
    if (watch == '0800 - 1200') return '07:45';
    return '';
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
