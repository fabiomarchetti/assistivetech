import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import '../providers/providers.dart';
import '../models/attivita.dart';
import '../services/web_file_picker.dart';
import '../widgets/arasaac_image.dart';

/// Pagina dedicata per aggiungere una nuova attività
class AddActivityPage extends ConsumerStatefulWidget {
  const AddActivityPage({super.key});

  @override
  ConsumerState<AddActivityPage> createState() => _AddActivityPageState();
}

class _AddActivityPageState extends ConsumerState<AddActivityPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _queryController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _fraseVocaleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _queryController.dispose();
    _nomeController.dispose();
    _fraseVocaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nomeAgenda = ref.watch(agendaSelezionataProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aggiungi attività'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Campi di testo per nome e frase vocale
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Campo nome immagine
                TextField(
                  controller: _nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome immagine',
                    hintText: 'Inserisci un nome per l\'immagine...',
                    prefixIcon: Icon(Icons.label),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                // Campo frase vocale
                TextField(
                  controller: _fraseVocaleController,
                  decoration: const InputDecoration(
                    labelText: 'Frase da vocalizzare',
                    hintText: 'Inserisci la frase che sarà pronunciata...',
                    prefixIcon: Icon(Icons.record_voice_over),
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          // Schede per pittogramma e foto
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.image_outlined), text: 'Pittogramma'),
              Tab(icon: Icon(Icons.folder_open), text: 'Immagine'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _ArasaacTab(
                  queryController: _queryController,
                  onSelected: (data) async {
                    if (nomeAgenda == null) return;

                    // Crea l'attività includendo nome e frase vocale dai campi
                    final dataWithPhrase = NewActivityData(
                      nomeUtente: data.nomeUtente,
                      nomePittogramma: _nomeController.text.trim().isNotEmpty
                          ? _nomeController.text.trim()
                          : data.nomePittogramma,
                      tipo: data.tipo,
                      bytes: data.bytes,
                      fraseVocale: _fraseVocaleController.text.trim(),
                    );

                    Navigator.of(context).pop(dataWithPhrase);
                  },
                ),
                _ImageTab(
                  onSelected: (data) {
                    if (nomeAgenda == null) return;

                    // Crea l'attività includendo nome e frase vocale dai campi
                    final dataWithPhrase = NewActivityData(
                      nomeUtente: data.nomeUtente,
                      nomePittogramma: _nomeController.text.trim().isNotEmpty
                          ? _nomeController.text.trim()
                          : data.nomePittogramma,
                      tipo: data.tipo,
                      bytes: data.bytes,
                      fraseVocale: _fraseVocaleController.text.trim(),
                    );

                    Navigator.of(context).pop(dataWithPhrase);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Dati restituiti dalla pagina per creare un'attività
class NewActivityData {
  NewActivityData({
    required this.nomeUtente,
    required this.nomePittogramma,
    required this.tipo,
    required this.bytes,
    required this.fraseVocale,
  });

  final String nomeUtente;
  final String nomePittogramma;
  final TipoAttivita tipo;
  final Uint8List bytes;
  final String fraseVocale;
}

class _ArasaacTab extends ConsumerWidget {
  const _ArasaacTab({required this.queryController, required this.onSelected});

  final TextEditingController queryController;
  final void Function(NewActivityData data) onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final search = ref.watch(arasaacSearchProvider);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: queryController,
            decoration: const InputDecoration(
              labelText: 'Cerca pittogrammi ARASAAC',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              ref.read(arasaacSearchProvider.notifier).search(value);
            },
          ),
        ),
        Expanded(
          child: search.when(
            data: (lista) {
              if (lista.isEmpty) {
                return const Center(child: Text('Nessun risultato'));
              }
              final crossAxisCount = MediaQuery.of(context).size.width > 600
                  ? 5
                  : 3;
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemCount: lista.length,
                itemBuilder: (context, index) {
                  final item = lista[index];
                  final int? id = item['id'] as int?;
                  if (id == null) return const SizedBox.shrink();
                  // Calcola nome dalle keywords (italiano preferito)
                  String name = 'pittogramma';
                  final kws =
                      (item['keywords'] as List?)?.cast<dynamic>() ?? const [];
                  final it = kws
                      .whereType<Map>()
                      .where(
                        (k) =>
                            (k['language']?.toString().toLowerCase() ?? '') ==
                            'it',
                      )
                      .cast<Map<String, dynamic>>()
                      .toList();
                  if (it.isNotEmpty) {
                    it.sort(
                      (a, b) => (a['keyword'] as String).length.compareTo(
                        (b['keyword'] as String).length,
                      ),
                    );
                    name = it.first['keyword'] as String? ?? 'pittogramma';
                  } else if (kws.isNotEmpty && kws.first is Map) {
                    name =
                        (kws.first as Map)['keyword'] as String? ??
                        'pittogramma';
                  }
                  final String thumb = item['thumbnail'] as String;
                  final String url = item['url'] as String;
                  return InkWell(
                    onTap: () async {
                      final res = await http.get(Uri.parse(url));
                      if (res.statusCode == 200) {
                        onSelected(
                          NewActivityData(
                            nomeUtente: 'educatore',
                            nomePittogramma: name,
                            tipo: TipoAttivita.pittogramma,
                            bytes: res.bodyBytes,
                            fraseVocale: '',
                          ),
                        );
                      }
                    },
                    child: Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          children: [
                            Expanded(
                              child: ArasaacImage(
                                url: thumb,
                                fallbackUrl: url,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Errore durante il caricamento',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  SelectableText(e.toString()),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ImageTab extends ConsumerWidget {
  const _ImageTab({required this.onSelected});

  final void Function(NewActivityData data) onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.folder_open, size: 80, color: Colors.grey),
          const SizedBox(height: 24),
          const Text(
            'Seleziona un\'immagine dal dispositivo',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () async {
              print('🗂️ Tentativo di aprire file picker...');
              try {
                if (kIsWeb) {
                  // Su web, usa il nostro WebFilePicker personalizzato
                  print('🌐 Usando WebFilePicker per web');
                  final result = await WebFilePicker.pickImage();

                  if (result == null) {
                    print('❌ Nessun file selezionato');
                    return;
                  }

                  print(
                    '✅ File selezionato: ${result.name}, size: ${result.size} bytes',
                  );
                  _createActivity(result.name, result.bytes);
                } else {
                  // Su mobile, usa FilePicker standard
                  print('📱 Usando FilePicker standard per mobile');
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.image,
                    allowMultiple: false,
                    withData: true,
                  );

                  if (result == null || result.files.isEmpty) {
                    print('❌ Nessun file selezionato');
                    return;
                  }

                  final file = result.files.first;
                  print(
                    '✅ File selezionato: ${file.name}, size: ${file.size} bytes',
                  );

                  if (file.bytes != null) {
                    _createActivity(file.name, file.bytes!);
                  } else if (file.path != null) {
                    final fileData = await File(file.path!).readAsBytes();
                    _createActivity(file.name, fileData);
                  } else {
                    throw Exception('Impossibile leggere il file');
                  }
                }
              } catch (e, stackTrace) {
                print('❌ ERRORE file picker: $e');
                print('Stack trace: $stackTrace');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Errore durante il caricamento: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.folder_open, size: 24),
            label: const Text('Scegli immagine'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _createActivity(String fileName, Uint8List bytes) {
    // Estrai il nome del file senza estensione per il pittogramma
    final name = fileName.split('.').first;

    onSelected(
      NewActivityData(
        nomeUtente: 'educatore',
        nomePittogramma: name,
        tipo: TipoAttivita.foto,
        bytes: bytes,
        fraseVocale: '', // Sarà aggiornato dal genitore
      ),
    );
  }
}
