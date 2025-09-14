import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Pagina di test minimale senza provider per isolare il problema
class MinimalTestPage extends StatefulWidget {
  const MinimalTestPage({super.key});

  @override
  State<MinimalTestPage> createState() => _MinimalTestPageState();
}

class _MinimalTestPageState extends State<MinimalTestPage> {
  List<String> users = [];
  List<String> agendas = [];
  List<Map<String, dynamic>> activities = [];
  String? selectedUser;
  String? selectedAgenda;
  String status = 'Pronto';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Minimale - Nessun Provider'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Status: $status',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Test caricamento dati
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🔧 Test API', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: _testLoadData,
                          child: const Text('Carica Dati'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _testSaveData,
                          child: const Text('Salva Test'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _testAddActivity,
                          child: const Text('Test ARASAAC'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Dati caricati
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('📊 Dati', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Utenti: ${users.join(", ")}'),
                      Text('Agende: ${agendas.join(", ")}'),
                      Text('Attività: ${activities.length}'),
                      const SizedBox(height: 8),
                      if (activities.isNotEmpty) ...[
                        const Text('Ultime attività:', style: TextStyle(fontWeight: FontWeight.bold)),
                        ...activities.take(3).map((a) => Text('- ${a['name']} (${a['image_path']})')),
                      ],
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

  /// Test caricamento dati dall'API
  Future<void> _testLoadData() async {
    setState(() => status = 'Caricamento dati...');
    
    try {
      final response = await http.get(Uri.parse('./api/save_data.php'));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        setState(() {
          users = List<String>.from(data['users'] ?? []);
          agendas = (data['agendas'] as Map<String, dynamic>? ?? {}).values.expand((x) => x).cast<String>().toList();
          activities = List<Map<String, dynamic>>.from(data['activities'] ?? []);
          status = 'Dati caricati ✅';
        });
      } else {
        setState(() => status = 'Errore HTTP: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => status = 'Errore: $e');
    }
  }

  /// Test salvataggio dati
  Future<void> _testSaveData() async {
    setState(() => status = 'Salvando dati test...');
    
    final testData = {
      'users': ['TestUser'],
      'agendas': {'TestUser': ['TestAgenda']},
      'activities': [
        {
          'id': DateTime.now().millisecondsSinceEpoch,
          'user': 'TestUser',
          'agenda': 'TestAgenda',
          'name': 'test_activity',
          'image_path': 'https://api.arasaac.org/api/pictograms/2457',
          'phrase': 'Test phrase',
          'position': 1,
          'type': 'pittogramma',
        }
      ],
    };

    try {
      final response = await http.post(
        Uri.parse('./api/save_data.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(testData),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['success'] == true) {
          setState(() => status = 'Dati salvati ✅');
          await _testLoadData(); // Ricarica per vedere i cambiamenti
        } else {
          setState(() => status = 'Errore salvataggio: ${result['message']}');
        }
      } else {
        setState(() => status = 'Errore HTTP salvataggio: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => status = 'Errore salvataggio: $e');
    }
  }

  /// Test aggiunta attività ARASAAC
  Future<void> _testAddActivity() async {
    setState(() => status = 'Testando ARASAAC...');
    
    try {
      // Prima verifica che ARASAAC sia raggiungibile
      final arasaacResponse = await http.get(Uri.parse('https://api.arasaac.org/api/pictograms/2457'));
      
      if (arasaacResponse.statusCode == 200) {
        setState(() => status = 'ARASAAC OK ✅ - Immagine ${arasaacResponse.bodyBytes.length} bytes');
        
        // Aggiungi l'attività ai dati locali
        setState(() {
          activities.add({
            'id': DateTime.now().millisecondsSinceEpoch,
            'user': 'TestUser',
            'agenda': 'TestAgenda', 
            'name': 'mangiare',
            'image_path': 'https://api.arasaac.org/api/pictograms/2457',
            'phrase': 'È ora di mangiare!',
            'position': activities.length + 1,
            'type': 'pittogramma',
          });
        });
      } else {
        setState(() => status = 'ARASAAC errore: ${arasaacResponse.statusCode}');
      }
    } catch (e) {
      setState(() => status = 'Errore ARASAAC: $e');
    }
  }
}