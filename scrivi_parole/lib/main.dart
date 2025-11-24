import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  runApp(const ScriviConSillabeApp());
}

class ScriviConSillabeApp extends StatelessWidget {
  const ScriviConSillabeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scrivi con le sillabe',
      theme: ThemeData(useMaterial3: true),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Chiave per aprire il menu a scomparsa (drawer)
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FlutterTts _flutterTts = FlutterTts();
  final TextEditingController _alertController = TextEditingController(
    text: 'Fai attenzione!!!',
  );
  final TextEditingController _successController = TextEditingController(
    text: 'Molto bravo!!!',
  );

  bool isThreeSyllableMode = true; // true = 3 sillabe, false = 2 sillabe
  List<String> teacherSyllables = ['', '', '', '', '', ''];
  List<String> clickableSyllables = ['', '', '', '', '', ''];
  List<String> selectedSyllables = ['', '', ''];
  String? imageUrl;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeTts();
  }

  void _initializeTts() async {
    await _flutterTts.setLanguage("it-IT");
    await _flutterTts.setSpeechRate(0.5);
  }

  void _toggleSyllableMode() {
    setState(() {
      isThreeSyllableMode = !isThreeSyllableMode;
      if (!isThreeSyllableMode) {
        // Modalità 2 sillabe: resetta la terza sillaba
        selectedSyllables = ['', ''];
      } else {
        // Modalità 3 sillabe: espandi a 3 sillabe
        selectedSyllables = ['', '', ''];
      }
      _clearAll();
    });
  }

  void _onTeacherSyllableChanged(int index, String value) {
    setState(() {
      teacherSyllables[index] = value.toUpperCase();
      clickableSyllables[index] = value.toUpperCase();
    });
  }

  void _onClickableSyllableSelected(int index) {
    if (clickableSyllables[index].isEmpty) return;

    String syllable = clickableSyllables[index];

    // Pronuncia la sillaba quando viene cliccata
    _speak(syllable);

    setState(() {
      if (selectedSyllables[0].isEmpty) {
        selectedSyllables[0] = syllable;
        clickableSyllables[index] = '';
      } else if (selectedSyllables[1].isEmpty) {
        selectedSyllables[1] = syllable;
        clickableSyllables[index] = '';
        if (!isThreeSyllableMode) {
          // Modalità 2 sillabe: cerca immagine subito
          _searchImage();
        }
      } else if (isThreeSyllableMode && selectedSyllables[2].isEmpty) {
        selectedSyllables[2] = syllable;
        clickableSyllables[index] = '';
        _searchImage();
      } else {
        // Ripristina le sillabe precedenti
        for (int i = 0; i < 6; i++) {
          if (teacherSyllables[i].isNotEmpty) {
            clickableSyllables[i] = teacherSyllables[i];
          }
        }
        if (isThreeSyllableMode) {
          selectedSyllables = [syllable, '', ''];
        } else {
          selectedSyllables = [syllable, ''];
        }
        clickableSyllables[index] = '';
        imageUrl = null;
      }
    });
  }

  void _searchImage() async {
    setState(() {
      isLoading = true;
      imageUrl = null;
    });

    String word = isThreeSyllableMode
        ? (selectedSyllables[0] + selectedSyllables[1] + selectedSyllables[2])
              .toLowerCase()
        : (selectedSyllables[0] + selectedSyllables[1]).toLowerCase();

    try {
      final response = await http.get(
        Uri.parse('https://api.arasaac.org/api/pictograms/it/search/$word'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          int pictogramId = data[0]['_id'];
          setState(() {
            imageUrl = 'https://api.arasaac.org/api/pictograms/$pictogramId';
            isLoading = false;
          });
          // Vocalizza il testo di successo impostato dalla maestra
          _speak(_successController.text);
          // Aspetta 2 secondi dopo il messaggio di successo, poi leggi la parola
          Future.delayed(const Duration(seconds: 2), () {
            _readWord();
          });
        } else {
          setState(() {
            isLoading = false;
          });
          // Vocalizza il testo di alert se non viene trovata alcuna immagine
          _speak(_alertController.text);
        }
      } else {
        setState(() {
          isLoading = false;
        });
        _speak(_alertController.text);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _speak(_alertController.text);
    }
  }

  void _speak(String text) async {
    await _flutterTts.speak(text);
  }

  void _showLicenseDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.info, color: Colors.blue[700]),
              const SizedBox(width: 8),
              const Text('Pittogrammi ARASAAC'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Condizioni d\'uso',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 10),
                const Text(
                  'I pittogrammi utilizzati in questa applicazione sono proprietà del Governo di Aragona e sono stati creati da Sergio Palao per ARASAAC (http://www.arasaac.org), che li distribuisce sotto licenza Creative Commons BY-NC-SA.',
                ),
                const SizedBox(height: 15),
                const Text(
                  'Licenza Creative Commons:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                const Text('• BY: Attribuzione richiesta'),
                const Text('• NC: Solo uso non commerciale'),
                const Text('• SA: Condividi allo stesso modo'),
                const SizedBox(height: 15),
                const Text(
                  'Per maggiori informazioni:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                const Text('🌐 https://arasaac.org'),
                const Text('📧 arasaac@educa.aragon.es'),
                const SizedBox(height: 15),
                const Text(
                  'Questa app è destinata esclusivamente all\'uso educativo.',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('CHIUDI'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _clearAll() {
    setState(() {
      teacherSyllables = ['', '', '', '', '', ''];
      clickableSyllables = ['', '', '', '', '', ''];
      selectedSyllables = isThreeSyllableMode ? ['', '', ''] : ['', ''];
      imageUrl = null;
      isLoading = false;
    });
  }

  void _readWord() {
    String word = isThreeSyllableMode
        ? selectedSyllables[0] + selectedSyllables[1] + selectedSyllables[2]
        : selectedSyllables[0] + selectedSyllables[1];
    if (word.isNotEmpty) {
      _speak(word);
    }
  }

  void _clearSelectedSyllables() {
    setState(() {
      selectedSyllables = isThreeSyllableMode ? ['', '', ''] : ['', ''];
      imageUrl = null;
      isLoading = false;
      // Ripristina le sillabe cliccabili se ci sono sillabe della maestra
      for (int i = 0; i < 6; i++) {
        if (teacherSyllables[i].isNotEmpty) {
          clickableSyllables[i] = teacherSyllables[i];
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Scrivi con le sillabe',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue[700],
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          tooltip: 'Apri pannello maestra',
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isThreeSyllableMode ? Icons.looks_3 : Icons.looks_two,
              color: Colors.white,
              size: 28,
            ),
            onPressed: _toggleSyllableMode,
            tooltip: isThreeSyllableMode
                ? 'Passa a 2 sillabe'
                : 'Passa a 3 sillabe',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: _showLicenseDialog,
            tooltip: 'Informazioni sui pittogrammi',
          ),
        ],
      ),
      // Menu a scomparsa: contiene area gialla maestra + testi alert/successo
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.yellow[600],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Area Maestra - Inserisci sillabe',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildTeacherSyllableCard(0, '1° Sillaba')),
                  const SizedBox(width: 10),
                  Expanded(child: _buildTeacherSyllableCard(1, '2° Sillaba')),
                  const SizedBox(width: 10),
                  Expanded(child: _buildTeacherSyllableCard(2, '3° Sillaba')),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _buildTeacherSyllableCard(3, '4° Sillaba')),
                  const SizedBox(width: 10),
                  Expanded(child: _buildTeacherSyllableCard(4, '5° Sillaba')),
                  const SizedBox(width: 10),
                  Expanded(child: _buildTeacherSyllableCard(5, '6° Sillaba')),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Alert',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _alertController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Successo',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              TextField(
                controller: _successController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Modalità 3 sillabe'),
                value: isThreeSyllableMode,
                onChanged: (_) => _toggleSyllableMode(),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.check),
                label: const Text('Chiudi pannello'),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Area immagine centrale
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(
                          imageUrl!,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(Icons.error, size: 50),
                            );
                          },
                        ),
                      )
                    : const SizedBox(),
              ),
            ),

            const SizedBox(height: 20),

            // Sillabe selezionate (area verde)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[300],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildSelectedSyllableCard(selectedSyllables[0]),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildSelectedSyllableCard(selectedSyllables[1]),
                      ),
                      if (isThreeSyllableMode) ...[
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildSelectedSyllableCard(
                            selectedSyllables[2],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _clearSelectedSyllables,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink[400],
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 50),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: const Text('Cancella Sillabe Scelte'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Area sillabe cliccabili per l'alunno (azzurra)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.lightBlue[200],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  const Text(
                    'Clicca sulle sillabe per comporre la parola',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _buildClickableSyllableCard(0)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildClickableSyllableCard(1)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildClickableSyllableCard(2)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _buildClickableSyllableCard(3)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildClickableSyllableCard(4)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildClickableSyllableCard(5)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            const SizedBox(height: 20),

            // Bottoni finali
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _clearAll,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink[400],
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 60),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text('Cancella tutto'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _readWord,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 60),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text('Leggi Parola'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeacherSyllableCard(int index, String label) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: TextField(
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                onChanged: (value) => _onTeacherSyllableChanged(index, value),
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Sillaba',
                  hintStyle: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                maxLength: 4,
                buildCounter:
                    (
                      context, {
                      required currentLength,
                      maxLength,
                      required isFocused,
                    }) => null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClickableSyllableCard(int index) {
    return GestureDetector(
      onTap: () => _onClickableSyllableSelected(index),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey),
        ),
        child: Center(
          child: Text(
            clickableSyllables[index],
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedSyllableCard(String syllable) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey),
      ),
      child: Center(
        child: Text(
          syllable,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _alertController.dispose();
    _successController.dispose();
    super.dispose();
  }
}
