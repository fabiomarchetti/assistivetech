import 'dart:io';
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

class _AddActivityPageState extends ConsumerState<AddActivityPage> {
  final TextEditingController _queryController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _fraseVocaleController = TextEditingController();
  int _selectedMode = 0; // 0 = pittogramma, 1 = immagine personale

  @override
  void dispose() {
    _queryController.dispose();
    _nomeController.dispose();
    _fraseVocaleController.dispose();
    super.dispose();
  }

  // Gestisce la selezione di un'immagine dal dispositivo
  Future<void> _pickImageFile(String? nomeAgenda) async {
    if (nomeAgenda == null) return;

    try {
      if (kIsWeb) {
        // Su web, usa il nostro WebFilePicker personalizzato
        final result = await WebFilePicker.pickImage();
        if (result == null) return;

        _createActivity(result.name, result.bytes, TipoAttivita.foto);
      } else {
        // Su mobile, usa FilePicker standard
        final result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
          withData: true,
        );

        if (result == null || result.files.isEmpty) return;

        final file = result.files.first;
        if (file.bytes != null) {
          _createActivity(file.name, file.bytes!, TipoAttivita.foto);
        } else if (file.path != null) {
          final fileData = await File(file.path!).readAsBytes();
          _createActivity(file.name, fileData, TipoAttivita.foto);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore durante il caricamento: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Crea l'attività e chiude la pagina
  void _createActivity(String fileName, Uint8List bytes, TipoAttivita tipo) {
    final name = fileName.split('.').first;

    final dataWithPhrase = NewActivityData(
      nomeUtente: 'educatore',
      nomePittogramma: _nomeController.text.trim().isNotEmpty
          ? _nomeController.text.trim()
          : name,
      tipo: tipo,
      bytes: bytes,
      fraseVocale: _fraseVocaleController.text.trim(),
    );

    Navigator.of(context).pop(dataWithPhrase);
  }

  @override
  Widget build(BuildContext context) {
    final nomeAgenda = ref.watch(agendaSelezionataProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aggiungi attività'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Row(
        children: [
          // COLONNA SINISTRA - Form controls
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(
                  right: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dettagli Attività',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),

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
                  const SizedBox(height: 24),

                  // Scelta tra pittogramma e immagine
                  Text(
                    'Tipo di contenuto',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),

                  // Radio buttons per la scelta
                  Column(
                    children: [
                      RadioListTile<int>(
                        title: const Text('Pittogramma ARASAAC'),
                        subtitle: const Text('Cerca nelle API ARASAAC'),
                        value: 0,
                        groupValue: _selectedMode,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedMode = value;
                            });
                          }
                        },
                      ),
                      RadioListTile<int>(
                        title: const Text('Immagine personale'),
                        subtitle: const Text('Carica dal dispositivo'),
                        value: 1,
                        groupValue: _selectedMode,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedMode = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Pulsante per caricare immagine (solo se selezionato)
                  if (_selectedMode == 1)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _pickImageFile(nomeAgenda),
                        icon: const Icon(Icons.folder_open),
                        label: const Text('Scegli immagine'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // COLONNA DESTRA - Ricerca ARASAAC
          Expanded(
            flex: 1,
            child: Column(
              children: [
                // Header ricerca
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ricerca Pittogrammi ARASAAC',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _queryController,
                        decoration: const InputDecoration(
                          labelText: 'Cerca pittogrammi',
                          hintText: 'Es: casa, mangiare, giocare...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onChanged: (value) {
                          ref.read(arasaacSearchProvider.notifier).search(value);
                        },
                      ),
                    ],
                  ),
                ),

                // Risultati ricerca
                Expanded(
                  child: _ArasaacResultsGrid(
                    onSelected: (data) {
                      if (nomeAgenda == null) return;

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

class _ArasaacResultsGrid extends ConsumerWidget {
  const _ArasaacResultsGrid({required this.onSelected});

  final void Function(NewActivityData data) onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final search = ref.watch(arasaacSearchProvider);

    return search.when(
      data: (lista) {
        if (lista.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Digita una parola per cercare pittogrammi',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
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
            final kws = (item['keywords'] as List?)?.cast<dynamic>() ?? const [];
            final it = kws
                .whereType<Map>()
                .where((k) => (k['language']?.toString().toLowerCase() ?? '') == 'it')
                .cast<Map<String, dynamic>>()
                .toList();

            if (it.isNotEmpty) {
              it.sort((a, b) => (a['keyword'] as String).length.compareTo((b['keyword'] as String).length));
              name = it.first['keyword'] as String? ?? 'pittogramma';
            } else if (kws.isNotEmpty && kws.first is Map) {
              name = (kws.first as Map)['keyword'] as String? ?? 'pittogramma';
            }

            final String thumb = item['thumbnail'] as String;
            final String url = item['url'] as String;

            return InkWell(
              onTap: () async {
                // Mostra indicatore di caricamento
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                );

                try {
                  final res = await http.get(Uri.parse(url));
                  if (context.mounted) {
                    Navigator.of(context).pop(); // Chiudi indicatore

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
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.of(context).pop(); // Chiudi indicatore
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Errore caricamento: $e')),
                    );
                  }
                }
              },
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: ArasaacImage(
                            url: thumb,
                            fallbackUrl: url,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
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
            Text(
              e.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

